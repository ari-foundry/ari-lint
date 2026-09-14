#!/bin/sh

set -eu

fail() {
  printf '%s\n' "smoke.sh: $*" >&2
  exit 1
}

if [ "$#" -gt 1 ]; then
  fail "usage: scripts/smoke.sh [ARI_COMPILER_PATH] or set ARI_COMPILER"
fi

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)

if [ "$#" -eq 1 ]; then
  smoke_ari_compiler="$1"
  "$script_dir/build.sh" "$1"
else
  smoke_ari_compiler="${ARI_COMPILER:-}"
  "$script_dir/build.sh"
fi

smoke_compiler_dir=$(CDPATH= cd "$(dirname "$smoke_ari_compiler")" && pwd)
smoke_ari_compiler="$smoke_compiler_dir/$(basename "$smoke_ari_compiler")"
export ARI_COMPILER="$smoke_ari_compiler"

binary="$repo_root/build/ari-lint"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ari-lint-smoke.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

if [ ! -x "$binary" ]; then
  fail "expected built ari-lint binary to be executable: $binary"
fi

command -v python3 >/dev/null 2>&1 ||
  fail "python3 is required to validate smoke JSON output"

run_smoke() {
  printf '%s\n' "smoke.sh: running $*"
  "$@"
}

run_stdout_success_smoke() {
  output_file="$1"
  stdout_success_stderr_file="${output_file}.stderr"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$output_file" 2> "$stdout_success_stderr_file"
  status=$?
  set -e
  [ "$status" -eq 0 ] || fail "expected success exit code 0, got $status"
  [ ! -s "$stdout_success_stderr_file" ] ||
    fail "expected empty stderr: $stdout_success_stderr_file"
}

run_json_diagnostic_smoke() {
  output_file="$1"
  json_stderr_file="${output_file}.stderr"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$output_file" 2> "$json_stderr_file"
  status=$?
  set -e
  [ "$status" -eq 1 ] || fail "expected diagnostic exit code 1, got $status"
  [ ! -s "$json_stderr_file" ] || fail "expected empty stderr: $json_stderr_file"
  require_json_document "$output_file"
}

run_json_success_smoke() {
  output_file="$1"
  json_stderr_file="${output_file}.stderr"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$output_file" 2> "$json_stderr_file"
  status=$?
  set -e
  [ "$status" -eq 0 ] || fail "expected success exit code 0, got $status"
  [ ! -s "$json_stderr_file" ] || fail "expected empty stderr: $json_stderr_file"
  require_json_document "$output_file"
}

run_human_diagnostic_smoke() {
  stdout_file="$1"
  stderr_file="$2"
  shift 2
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$stdout_file" 2> "$stderr_file"
  status=$?
  set -e
  [ "$status" -eq 1 ] || fail "expected diagnostic exit code 1, got $status"
}

run_human_success_smoke() {
  stdout_file="$1"
  stderr_file="$2"
  shift 2
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$stdout_file" 2> "$stderr_file"
  status=$?
  set -e
  [ "$status" -eq 0 ] || fail "expected success exit code 0, got $status"
}

run_stderr_usage_smoke() {
  output_file="$1"
  usage_stdout_file="${output_file}.stdout"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$usage_stdout_file" 2> "$output_file"
  status=$?
  set -e
  [ "$status" -eq 2 ] || fail "expected usage exit code 2, got $status"
  [ ! -s "$usage_stdout_file" ] || fail "expected empty stdout: $usage_stdout_file"
  require_final_newline "$output_file"
}

run_stderr_unavailable_smoke() {
  output_file="$1"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$tmp_dir/unavailable.stdout" 2> "$output_file"
  status=$?
  set -e
  [ "$status" -eq 1 ] || fail "expected unavailable exit code 1, got $status"
}

require_text_grep() {
  pattern="$1"
  file="$2"
  grep -F -q -- "$pattern" "$file" || fail "missing expected text in $file: $pattern"
}

require_empty_file() {
  [ ! -s "$1" ] || fail "expected empty file: $1"
}

require_path_absent() {
  [ ! -e "$1" ] || fail "unexpected path: $1"
}

require_json_grep() {
  pattern="$1"
  file="$2"
  grep -F -q -- "$pattern" "$file" || fail "missing expected JSON text in $file: $pattern"
}

require_json_no_grep() {
  pattern="$1"
  file="$2"
  if grep -F -q -- "$pattern" "$file"; then
    fail "unexpected JSON text in $file: $pattern"
  fi
}

require_files_equal() {
  expected_file="$1"
  actual_file="$2"
  cmp -s "$expected_file" "$actual_file" || {
    diff -u "$expected_file" "$actual_file" >&2 || true
    fail "files differ: $expected_file $actual_file"
  }
}

require_final_newline() {
  final_newline_byte=$(tail -c 1 "$1" | od -An -t x1 | tr -d ' \n')
  [ "$final_newline_byte" = "0a" ] || fail "expected final newline: $1"
}

require_json_document() {
  require_final_newline "$1"
  python3 -c '
import json
import pathlib
import sys

def reject_constant(value):
    raise ValueError("non-standard JSON constant: " + value)

data = pathlib.Path(sys.argv[1]).read_bytes()
text = data[:-1].decode("utf-8")
_, end = json.JSONDecoder(parse_constant=reject_constant).raw_decode(text)
raise SystemExit(0 if end == len(text) else 1)
' "$1" ||
    fail "expected one valid JSON document: $1"
}

nonstandard_json_probe="$tmp_dir/nonstandard-json.out"
printf '%s\n' "NaN" > "$nonstandard_json_probe"
if (require_json_document "$nonstandard_json_probe") >/dev/null 2>&1; then
  fail "expected strict JSON validation to reject NaN"
fi

require_text_order() {
  first_pattern="$1"
  second_pattern="$2"
  file="$3"
  text=$(tr -d '\n' < "$file")
  case "$text" in
    *"$first_pattern"*"$second_pattern"*) ;;
    *) fail "expected text order in $file: $first_pattern before $second_pattern" ;;
  esac
}

help_output="$tmp_dir/help.out"
run_stdout_success_smoke "$help_output" "$binary" --help
require_text_grep "Usage: ari-lint" "$help_output"
require_text_grep "--help" "$help_output"
require_text_grep "--list-rules" "$help_output"
require_text_grep "--json" "$help_output"
require_text_grep "--ari PATH" "$help_output"
require_text_grep "-I DIR" "$help_output"
require_text_grep "--config PATH" "$help_output"
require_text_grep "--rule RULE=SEVERITY" "$help_output"
require_text_grep "Treat following arguments as source files." "$help_output"

list_rules_output="$tmp_dir/list-rules.out"
run_stdout_success_smoke "$list_rules_output" "$binary" --list-rules
require_text_grep "lint/trailing-whitespace" "$list_rules_output"
require_text_grep "name=trailing-whitespace" "$list_rules_output"
require_text_grep "lint/missing-final-newline" "$list_rules_output"
require_text_grep "name=missing-final-newline" "$list_rules_output"
require_text_grep "default=warning" "$list_rules_output"

json_list_rules_output="$tmp_dir/json-list-rules.out"
run_stdout_success_smoke "$json_list_rules_output" "$binary" --json --list-rules
require_json_document "$json_list_rules_output"
require_json_grep '[{"ruleCode":"lint/trailing-whitespace"' "$json_list_rules_output"
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$json_list_rules_output"
require_json_grep '"name":"trailing-whitespace"' "$json_list_rules_output"
require_json_grep '"description":"Reports spaces or tabs at the end of a source line."' "$json_list_rules_output"
require_json_grep '"ruleCode":"lint/missing-final-newline"' "$json_list_rules_output"
require_json_grep '"name":"missing-final-newline"' "$json_list_rules_output"
require_json_grep '"description":"Reports non-empty source files that do not end with a newline."' "$json_list_rules_output"
require_json_grep '"defaultSeverity":"warning"' "$json_list_rules_output"
require_json_grep '}]' "$json_list_rules_output"
require_json_no_grep "name=trailing-whitespace" "$json_list_rules_output"
require_json_no_grep "default=warning" "$json_list_rules_output"

config_file="$tmp_dir/explicit.rules"
source_file="$tmp_dir/trailing.ari"
printf '%s\n' "trailing-whitespace = error" > "$config_file"
{
  printf '%s  \n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$source_file"

config_output="$tmp_dir/config-error.json"
rule_output="$tmp_dir/rule-note.json"
config_off_file="$tmp_dir/off.rules"
config_off_output="$tmp_dir/config-off.json"
rule_off_output="$tmp_dir/rule-off.json"
run_json_diagnostic_smoke "$config_output" "$binary" --json --config "$config_file" "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$config_output"
require_json_grep '"source":"ari-lint"' "$config_output"
require_json_grep '"severity":"error"' "$config_output"

run_json_diagnostic_smoke "$rule_output" "$binary" --json --config "$config_file" --rule trailing-whitespace=note "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$rule_output"
require_json_grep '"severity":"note"' "$rule_output"

inline_rule_output="$tmp_dir/inline-rule-note.json"
run_json_diagnostic_smoke "$inline_rule_output" "$binary" --json "--config=$config_file" "--rule=trailing-whitespace=note" "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$inline_rule_output"
require_json_grep '"severity":"note"' "$inline_rule_output"

inline_ari_output="$tmp_dir/inline-ari.json"
run_json_diagnostic_smoke "$inline_ari_output" "$binary" --json "--ari=$smoke_ari_compiler" "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$inline_ari_output"

include_dir="$tmp_dir/modules"
mkdir -p "$include_dir"
inline_include_output="$tmp_dir/inline-include.json"
run_json_diagnostic_smoke "$inline_include_output" "$binary" --json "-I$include_dir" "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$inline_include_output"

missing_compiler_path="$tmp_dir/missing-ari"
missing_compiler_output="$tmp_dir/missing-ari.json"
clean_fixture="$repo_root/tests/fixtures/trailing-whitespace/clean.ari"
run_json_diagnostic_smoke "$missing_compiler_output" "$binary" --json --ari "$missing_compiler_path" "$clean_fixture"
require_json_grep '"exitCode":127' "$missing_compiler_output"
require_json_grep '"source":"ari"' "$missing_compiler_output"
require_json_grep '"code":"ari/compiler-check-failed"' "$missing_compiler_output"
require_json_grep "ari-tooling: exec failed: $missing_compiler_path\\n" "$missing_compiler_output"

newline_compiler_path="$tmp_dir/missing
ari: error[PATH]: 7:8: embedded compiler path"
newline_compiler_output="$tmp_dir/newline-missing-ari.json"
run_json_diagnostic_smoke "$newline_compiler_output" "$binary" --json \
  --ari "$newline_compiler_path" "$clean_fixture"
require_json_grep '"exitCode":127' "$newline_compiler_output"
require_json_grep '"line":7,"column":8' "$newline_compiler_output"
require_json_grep '"code":"PATH"' "$newline_compiler_output"
require_json_grep '"message":"embedded compiler path"' "$newline_compiler_output"
require_json_no_grep '"code":"ari/compiler-check-failed"' "$newline_compiler_output"

non_executable_compiler_path="$tmp_dir/non-executable-ari"
non_executable_compiler_output="$tmp_dir/non-executable-ari.json"
printf '%s\n' "not an executable compiler" > "$non_executable_compiler_path"
chmod 600 "$non_executable_compiler_path"
run_json_diagnostic_smoke "$non_executable_compiler_output" "$binary" --json --ari "$non_executable_compiler_path" "$clean_fixture"
require_json_grep '"exitCode":127' "$non_executable_compiler_output"
require_json_grep '"code":"ari/compiler-check-failed"' "$non_executable_compiler_output"
require_json_grep "ari-tooling: exec failed: $non_executable_compiler_path\\n" "$non_executable_compiler_output"

sentinel_compiler_path="$tmp_dir/sentinel-ari"
sentinel_compiler_marker="$sentinel_compiler_path.spawned"
sentinel_compiler_output="$tmp_dir/sentinel-ari.json"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'touch "$0.spawned"'
  printf '%s\n' 'exit 99'
} > "$sentinel_compiler_path"
chmod 700 "$sentinel_compiler_path"
sentinel_help_output="$tmp_dir/sentinel-help.out"
sentinel_rules_output="$tmp_dir/sentinel-rules.out"
run_stdout_success_smoke "$sentinel_help_output" "$binary" --ari "$sentinel_compiler_path" --help
run_stdout_success_smoke "$sentinel_rules_output" "$binary" --ari "$sentinel_compiler_path" --list-rules
require_path_absent "$sentinel_compiler_marker"
run_json_diagnostic_smoke "$sentinel_compiler_output" "$binary" --json --ari "$sentinel_compiler_path" "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$sentinel_compiler_output"
require_json_grep '"exitCode":99' "$sentinel_compiler_output"
require_json_no_grep '"code":"ari/compiler-check-failed"' "$sentinel_compiler_output"
[ -e "$sentinel_compiler_marker" ] || fail "expected source command to invoke sentinel compiler"

fake_compiler_path="$tmp_dir/fake-ari"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'source_file='
  printf '%s\n' 'previous='
  printf '%s\n' 'for argument in "$@"; do'
  printf '%s\n' '  source_file="$previous"'
  printf '%s\n' '  previous="$argument"'
  printf '%s\n' 'done'
  printf '%s\n' 'if [ -n "${FAKE_ARI_LOG:-}" ]; then'
  printf '%s\n' '  printf "BEGIN\n" >> "$FAKE_ARI_LOG"'
  printf '%s\n' '  for argument in "$@"; do'
  printf '%s\n' '    printf "<%s>\n" "$argument" >> "$FAKE_ARI_LOG"'
  printf '%s\n' '  done'
  printf '%s\n' '  printf "END\n" >> "$FAKE_ARI_LOG"'
  printf '%s\n' 'fi'
  printf '%s\n' 'case "$source_file" in'
  printf '%s\n' '  *compiler-diagnostics.ari)'
  printf '%s\n' '    printf "ari: error[E1]: path:with:colon.ari:2:3: first\n" >&2'
  printf '%s\n' '    printf "ari: warning[W2]: 0:0: second\n" >&2'
  printf '%s\n' '    printf "other:path.ari:4:5: note[N3]: third\n" >&2'
  printf '%s\n' '    printf "ari: hint: fourth\n" >&2'
  printf '%s\n' '    printf "ignored compiler noise\n" >&2'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-streams.ari)'
  printf '%s\n' '    printf "ari: note[STDOUT]: 6:7: stdout-final"'
  printf '%s\n' '    printf "ari: warning[STDERR]: 4:5: stderr-crlf\r\n" >&2'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-embedded-cr.ari)'
  printf '%s\n' '    printf "ari: error: before\rafter\n" >&2'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-large-output.ari)'
  printf '%s\n' "    head -c 300000 /dev/zero | tr '\\000' 'e' >&2"
  printf '%s\n' "    head -c 300000 /dev/zero | tr '\\000' 'o'"
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-large-suppressed.ari)'
  printf '%s\n' "    head -c 300000 /dev/zero | tr '\\000' 'n'"
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-large-lines.ari)'
  printf '%s\n' '    yes noise | head -c 300000'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-late-diagnostic.ari)'
  printf '%s\n' '    yes noise | head -c 300000 >&2'
  printf '%s\n' '    printf "ari: warning[LATE]: 9:10: beyond retained output\\n" >&2'
  printf '%s\n' '    exit 0'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-early-and-late.ari)'
  printf '%s\n' '    printf "ari: note[EARLY]: 3:4: retained diagnostic\\n" >&2'
  printf '%s\n' '    yes noise | head -c 300000 >&2'
  printf '%s\n' '    printf "ari: warning[LATE]: 9:10: beyond retained output\\n" >&2'
  printf '%s\n' '    exit 0'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-many-diagnostics.ari)'
  printf '%s\n' '    diagnostic_index=0'
  printf '%s\n' '    while [ "$diagnostic_index" -lt 2200 ]; do'
  printf '%s\n' '      printf "ari: hint: flood\\n" >&2'
  printf '%s\n' '      diagnostic_index=$((diagnostic_index + 1))'
  printf '%s\n' '    done'
  printf '%s\n' '    exit 0'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-limit-2048.ari)'
  printf '%s\n' '    diagnostic_index=0'
  printf '%s\n' '    while [ "$diagnostic_index" -lt 2048 ]; do'
  printf '%s\n' '      printf "ari: hint: boundary\\n" >&2'
  printf '%s\n' '      diagnostic_index=$((diagnostic_index + 1))'
  printf '%s\n' '    done'
  printf '%s\n' '    exit 0'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-limit-2049.ari)'
  printf '%s\n' '    diagnostic_index=0'
  printf '%s\n' '    while [ "$diagnostic_index" -lt 2049 ]; do'
  printf '%s\n' '      printf "ari: hint: boundary\\n" >&2'
  printf '%s\n' '      diagnostic_index=$((diagnostic_index + 1))'
  printf '%s\n' '    done'
  printf '%s\n' '    exit 0'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-budget-one.ari)'
  printf '%s\n' '    printf "ari: hint: run budget\\n" >&2'
  printf '%s\n' '    exit 0'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-noise-failure.ari)'
  printf '%s\n' '    printf "plain noise\n" >&2'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-empty-failure.ari)'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-signal.ari)'
  printf '%s\n' '    kill -TERM "$$"'
  printf '%s\n' '    ;;'
  printf '%s\n' '  *compiler-order.ari)'
  printf '%s\n' '    printf "ari: note[C1]: 3:4: compiler first\n" >&2'
  printf '%s\n' '    exit 7'
  printf '%s\n' '    ;;'
  printf '%s\n' 'esac'
  printf '%s\n' 'exit 0'
} > "$fake_compiler_path"
chmod 700 "$fake_compiler_path"

fake_include_one="$tmp_dir/include one"
fake_include_two="$tmp_dir/include;\$two"
mkdir -p "$fake_include_one" "$fake_include_two"
fake_source_one="$tmp_dir/source one;.ari"
fake_source_two="$tmp_dir/source \$two.ari"
cp "$clean_fixture" "$fake_source_one"
cp "$clean_fixture" "$fake_source_two"
fake_argv_log="$tmp_dir/fake-argv.log"
fake_argv_output="$tmp_dir/fake-argv.json"
(
  FAKE_ARI_LOG="$fake_argv_log"
  export FAKE_ARI_LOG
  run_json_success_smoke "$fake_argv_output" "$binary" --json \
    --ari "$fake_compiler_path" \
    -I "$fake_include_one" "-I$fake_include_two" \
    "$fake_source_one" "$fake_source_two"
)
fake_argv_expected="$tmp_dir/fake-argv.expected"
{
  printf '%s\n' 'BEGIN'
  printf '<%s>\n' '-I' "$fake_include_one" '-I' "$fake_include_two" "$fake_source_one" '--check'
  printf '%s\n' 'END'
  printf '%s\n' 'BEGIN'
  printf '<%s>\n' '-I' "$fake_include_one" '-I' "$fake_include_two" "$fake_source_two" '--check'
  printf '%s\n' 'END'
} > "$fake_argv_expected"
require_files_equal "$fake_argv_expected" "$fake_argv_log"

env_compiler_path="$tmp_dir/env-ari"
env_compiler_marker="$env_compiler_path.spawned"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'touch "$0.spawned"'
  printf '%s\n' 'exit 88'
} > "$env_compiler_path"
chmod 700 "$env_compiler_path"
env_compiler_output="$tmp_dir/env-ari.json"
(
  ARI_COMPILER="$env_compiler_path"
  export ARI_COMPILER
  run_json_diagnostic_smoke "$env_compiler_output" "$binary" --json "$clean_fixture"
)
require_json_grep '"exitCode":88' "$env_compiler_output"
[ -e "$env_compiler_marker" ] || fail "expected ARI_COMPILER to select the environment compiler"

shadow_compiler_path="$tmp_dir/shadow-env-ari"
shadow_compiler_marker="$shadow_compiler_path.spawned"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'touch "$0.spawned"'
  printf '%s\n' 'exit 89'
} > "$shadow_compiler_path"
chmod 700 "$shadow_compiler_path"
explicit_precedence_output="$tmp_dir/explicit-precedence.json"
(
  ARI_COMPILER="$shadow_compiler_path"
  export ARI_COMPILER
  run_json_success_smoke "$explicit_precedence_output" "$binary" --json \
    --ari "$fake_compiler_path" "$clean_fixture"
)
require_path_absent "$shadow_compiler_marker"

default_compiler_root="$tmp_dir/default-compiler"
default_compiler_path="$default_compiler_root/build/ari"
default_compiler_marker="$default_compiler_path.spawned"
mkdir -p "$default_compiler_root/build"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'touch "$0.spawned"'
  printf '%s\n' 'exit 0'
} > "$default_compiler_path"
chmod 700 "$default_compiler_path"
default_compiler_output="$tmp_dir/default-compiler.json"
(
  unset ARI_COMPILER
  cd "$default_compiler_root"
  run_json_success_smoke "$default_compiler_output" "$binary" --json "$clean_fixture"
)
[ -e "$default_compiler_marker" ] || fail "expected build/ari default compiler selection"

empty_env_output="$tmp_dir/empty-env-compiler.json"
(
  ARI_COMPILER=
  export ARI_COMPILER
  run_json_diagnostic_smoke "$empty_env_output" "$binary" --json "$clean_fixture"
)
require_json_grep '"exitCode":127' "$empty_env_output"
require_json_grep '"message":"ari-tooling: exec failed: \n"' "$empty_env_output"

compiler_diagnostics_source="$tmp_dir/compiler-diagnostics.ari"
cp "$clean_fixture" "$compiler_diagnostics_source"
compiler_diagnostics_output="$tmp_dir/compiler-diagnostics.json"
run_json_diagnostic_smoke "$compiler_diagnostics_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_diagnostics_source"
compiler_diagnostics_expected="$tmp_dir/compiler-diagnostics.expected.json"
printf '{"files":[{"path":"%s","exitCode":7,"diagnostics":[{"file":"path:with:colon.ari","line":2,"column":3,"endLine":2,"endColumn":4,"severity":"error","message":"first","source":"ari","code":"E1"},{"file":"%s","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"warning","message":"second","source":"ari","code":"W2"},{"file":"other:path.ari","line":4,"column":5,"endLine":4,"endColumn":6,"severity":"note","message":"third","source":"ari","code":"N3"},{"file":"%s","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"hint","message":"fourth","source":"ari","code":"ari/compiler"}]}]}\n' "$compiler_diagnostics_source" "$compiler_diagnostics_source" "$compiler_diagnostics_source" > "$compiler_diagnostics_expected"
require_files_equal "$compiler_diagnostics_expected" "$compiler_diagnostics_output"
require_json_no_grep 'ignored compiler noise' "$compiler_diagnostics_output"
require_json_no_grep 'ari/compiler-check-failed' "$compiler_diagnostics_output"

compiler_streams_source="$tmp_dir/compiler-streams.ari"
cp "$clean_fixture" "$compiler_streams_source"
compiler_streams_output="$tmp_dir/compiler-streams.json"
run_json_diagnostic_smoke "$compiler_streams_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_streams_source"
require_json_grep '"code":"STDERR"' "$compiler_streams_output"
require_json_grep '"message":"stderr-crlf"' "$compiler_streams_output"
require_json_grep '"code":"STDOUT"' "$compiler_streams_output"
require_json_grep '"message":"stdout-final"' "$compiler_streams_output"
require_text_order '"code":"STDERR"' '"code":"STDOUT"' "$compiler_streams_output"
require_json_no_grep 'stderr-crlf\r' "$compiler_streams_output"

compiler_embedded_cr_source="$tmp_dir/compiler-embedded-cr.ari"
cp "$clean_fixture" "$compiler_embedded_cr_source"
compiler_embedded_cr_output="$tmp_dir/compiler-embedded-cr.json"
run_json_diagnostic_smoke "$compiler_embedded_cr_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_embedded_cr_source"
require_json_grep '"code":"ari/compiler-check-failed"' "$compiler_embedded_cr_output"
require_json_grep 'before\rafter\n' "$compiler_embedded_cr_output"
require_json_no_grep '"code":"ari/compiler"' "$compiler_embedded_cr_output"

compiler_large_source="$tmp_dir/compiler-large-output.ari"
cp "$clean_fixture" "$compiler_large_source"
compiler_large_output="$tmp_dir/compiler-large-output.json"
run_json_diagnostic_smoke "$compiler_large_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_large_source"
require_json_grep '"exitCode":7' "$compiler_large_output"
require_json_grep '"code":"ari/compiler-check-failed"' "$compiler_large_output"
require_json_grep '"code":"ari/compiler-output-truncated"' "$compiler_large_output"
require_json_grep 'later diagnostics may be unavailable' "$compiler_large_output"
require_text_order '"code":"ari/compiler-output-truncated"' '"code":"ari/compiler-check-failed"' "$compiler_large_output"

compiler_large_suppressed_source="$tmp_dir/compiler-large-suppressed.ari"
printf '%s  \n' 'fn large_suppressed() -> i64 { return 0; }' > "$compiler_large_suppressed_source"
compiler_large_suppressed_output="$tmp_dir/compiler-large-suppressed.json"
run_json_diagnostic_smoke "$compiler_large_suppressed_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_large_suppressed_source"
require_json_grep '"exitCode":7' "$compiler_large_suppressed_output"
require_json_grep '"code":"lint/trailing-whitespace"' "$compiler_large_suppressed_output"
require_json_grep '"code":"ari/compiler-output-truncated"' "$compiler_large_suppressed_output"
require_json_no_grep '"code":"ari/compiler-check-failed"' "$compiler_large_suppressed_output"
require_text_order '"code":"ari/compiler-output-truncated"' '"code":"lint/trailing-whitespace"' "$compiler_large_suppressed_output"

compiler_late_source="$tmp_dir/compiler-late-diagnostic.ari"
cp "$clean_fixture" "$compiler_late_source"
compiler_late_output="$tmp_dir/compiler-late-diagnostic.json"
run_json_diagnostic_smoke "$compiler_late_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_late_source"
require_json_grep '"exitCode":0' "$compiler_late_output"
require_json_grep '"code":"ari/compiler-output-truncated"' "$compiler_late_output"
require_json_no_grep '"code":"LATE"' "$compiler_late_output"

compiler_early_late_source="$tmp_dir/compiler-early-and-late.ari"
cp "$clean_fixture" "$compiler_early_late_source"
compiler_early_late_output="$tmp_dir/compiler-early-and-late.json"
run_json_diagnostic_smoke "$compiler_early_late_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_early_late_source"
require_json_grep '"exitCode":0' "$compiler_early_late_output"
require_json_grep '"code":"EARLY"' "$compiler_early_late_output"
require_json_grep '"code":"ari/compiler-output-truncated"' "$compiler_early_late_output"
require_json_no_grep '"code":"LATE"' "$compiler_early_late_output"
require_text_order '"code":"EARLY"' '"code":"ari/compiler-output-truncated"' "$compiler_early_late_output"

compiler_many_source="$tmp_dir/compiler-many-diagnostics.ari"
cp "$clean_fixture" "$compiler_many_source"
compiler_many_output="$tmp_dir/compiler-many-diagnostics.json"
run_json_diagnostic_smoke "$compiler_many_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_many_source"
require_json_grep '"exitCode":0' "$compiler_many_output"
require_json_grep '"code":"ari/compiler-diagnostics-truncated"' "$compiler_many_output"
compiler_many_retained_count=$(grep -F -o -- '"code":"ari/compiler"' "$compiler_many_output" | wc -l | tr -d ' ')
[ "$compiler_many_retained_count" -eq 2048 ] || fail "expected exactly 2048 retained compiler diagnostics"

compiler_limit_2048_source="$tmp_dir/compiler-limit-2048.ari"
compiler_limit_2049_source="$tmp_dir/compiler-limit-2049.ari"
compiler_budget_one_source="$tmp_dir/compiler-budget-one.ari"
cp "$clean_fixture" "$compiler_limit_2048_source"
cp "$clean_fixture" "$compiler_limit_2049_source"
cp "$clean_fixture" "$compiler_budget_one_source"
compiler_limit_2048_output="$tmp_dir/compiler-limit-2048.json"
compiler_limit_2049_output="$tmp_dir/compiler-limit-2049.json"
compiler_global_limit_output="$tmp_dir/compiler-global-limit.json"
run_json_diagnostic_smoke "$compiler_limit_2048_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_limit_2048_source"
compiler_limit_2048_count=$(grep -F -o -- '"code":"ari/compiler"' "$compiler_limit_2048_output" | wc -l | tr -d ' ')
[ "$compiler_limit_2048_count" -eq 2048 ] || fail "expected exactly 2048 diagnostics at the per-file limit"
require_json_no_grep '"code":"ari/compiler-diagnostics-truncated"' "$compiler_limit_2048_output"
run_json_diagnostic_smoke "$compiler_limit_2049_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_limit_2049_source"
compiler_limit_2049_count=$(grep -F -o -- '"code":"ari/compiler"' "$compiler_limit_2049_output" | wc -l | tr -d ' ')
[ "$compiler_limit_2049_count" -eq 2048 ] || fail "expected 2048 retained diagnostics above the per-file limit"
require_json_grep '"code":"ari/compiler-diagnostics-truncated"' "$compiler_limit_2049_output"
run_json_diagnostic_smoke "$compiler_global_limit_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_limit_2048_source" \
  "$compiler_limit_2048_source" "$compiler_budget_one_source"
compiler_global_limit_count=$(grep -F -o -- '"code":"ari/compiler"' "$compiler_global_limit_output" | wc -l | tr -d ' ')
compiler_global_marker_count=$(grep -F -o -- '"code":"ari/compiler-diagnostics-truncated"' "$compiler_global_limit_output" | wc -l | tr -d ' ')
[ "$compiler_global_limit_count" -eq 4096 ] || fail "expected exactly 4096 diagnostics at the run limit"
[ "$compiler_global_marker_count" -eq 1 ] || fail "expected one marker above the run diagnostic limit"

compiler_large_lines_source="$tmp_dir/compiler-large-lines.ari"
cp "$clean_fixture" "$compiler_large_lines_source"
compiler_large_lines_output="$tmp_dir/compiler-large-lines.json"
run_json_diagnostic_smoke "$compiler_large_lines_output" "$binary" --json \
  --ari "$fake_compiler_path" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source" \
  "$compiler_large_lines_source" "$compiler_large_lines_source"
compiler_large_lines_file_count=$(grep -F -o -- '"exitCode":7' "$compiler_large_lines_output" | wc -l | tr -d ' ')
[ "$compiler_large_lines_file_count" -eq 24 ] || fail "expected 24 bounded large-output file results"
require_json_grep '"code":"ari/compiler-output-truncated"' "$compiler_large_lines_output"
require_json_grep '"code":"ari/compiler-diagnostics-truncated"' "$compiler_large_lines_output"
require_json_grep '"code":"ari/compiler-check-failed"' "$compiler_large_lines_output"

compiler_noise_source="$tmp_dir/compiler-noise-failure.ari"
cp "$clean_fixture" "$compiler_noise_source"
compiler_noise_output="$tmp_dir/compiler-noise-failure.json"
run_json_diagnostic_smoke "$compiler_noise_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_noise_source"
require_json_grep '"exitCode":7' "$compiler_noise_output"
require_json_grep '"code":"ari/compiler-check-failed"' "$compiler_noise_output"
require_json_grep '"message":"plain noise\n"' "$compiler_noise_output"

compiler_noise_human_output="$tmp_dir/compiler-noise-failure.human"
compiler_noise_human_stderr="$tmp_dir/compiler-noise-failure.human.stderr"
run_human_diagnostic_smoke "$compiler_noise_human_output" "$compiler_noise_human_stderr" \
  "$binary" --ari "$fake_compiler_path" "$compiler_noise_source"
compiler_noise_human_expected="$tmp_dir/compiler-noise-failure.human.expected"
printf '%s:1:1: error: [ari/compiler-check-failed] plain noise\n\n' \
  "$compiler_noise_source" > "$compiler_noise_human_expected"
require_files_equal "$compiler_noise_human_expected" "$compiler_noise_human_output"
require_empty_file "$compiler_noise_human_stderr"

compiler_empty_source="$tmp_dir/compiler-empty-failure.ari"
cp "$clean_fixture" "$compiler_empty_source"
compiler_empty_output="$tmp_dir/compiler-empty-failure.json"
run_json_diagnostic_smoke "$compiler_empty_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_empty_source"
require_json_grep '"exitCode":7' "$compiler_empty_output"
require_json_grep '"message":"compiler check failed"' "$compiler_empty_output"

compiler_empty_human_output="$tmp_dir/compiler-empty-failure.human"
compiler_empty_human_stderr="$tmp_dir/compiler-empty-failure.human.stderr"
run_human_diagnostic_smoke "$compiler_empty_human_output" "$compiler_empty_human_stderr" \
  "$binary" --ari "$fake_compiler_path" "$compiler_empty_source"
compiler_empty_human_expected="$tmp_dir/compiler-empty-failure.human.expected"
printf '%s:1:1: error: [ari/compiler-check-failed] compiler check failed\n' \
  "$compiler_empty_source" > "$compiler_empty_human_expected"
require_files_equal "$compiler_empty_human_expected" "$compiler_empty_human_output"
require_empty_file "$compiler_empty_human_stderr"

compiler_signal_source="$tmp_dir/compiler-signal.ari"
cp "$clean_fixture" "$compiler_signal_source"
compiler_signal_output="$tmp_dir/compiler-signal.json"
run_json_diagnostic_smoke "$compiler_signal_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_signal_source"
require_json_grep '"exitCode":143' "$compiler_signal_output"
require_json_grep '"code":"ari/compiler-check-failed"' "$compiler_signal_output"

compiler_order_dir="$tmp_dir/compiler-order"
mkdir -p "$compiler_order_dir"
compiler_order_source="$compiler_order_dir/compiler-order.ari"
printf '%s  \n' 'fn order() -> i64 { return 0; }' > "$compiler_order_source"
printf '%s\n' 'broken' > "$compiler_order_dir/ari-lint.rules"
compiler_order_output="$tmp_dir/compiler-order.json"
run_json_diagnostic_smoke "$compiler_order_output" "$binary" --json \
  --ari "$fake_compiler_path" "$compiler_order_source"
require_json_grep '"exitCode":7' "$compiler_order_output"
require_json_grep '"code":"C1"' "$compiler_order_output"
require_json_grep '"code":"lint/config"' "$compiler_order_output"
require_json_grep '"code":"lint/trailing-whitespace"' "$compiler_order_output"
require_json_no_grep '"code":"ari/compiler-check-failed"' "$compiler_order_output"
require_text_order '"code":"C1"' '"code":"lint/config"' "$compiler_order_output"
require_text_order '"code":"lint/config"' '"code":"lint/trailing-whitespace"' "$compiler_order_output"

printf '%s\n' "trailing-whitespace = off" > "$config_off_file"
run_json_success_smoke "$config_off_output" "$binary" --json --config "$config_off_file" "$source_file"
require_json_no_grep '"code":"lint/trailing-whitespace"' "$config_off_output"
require_json_no_grep '"severity":"off"' "$config_off_output"

run_json_success_smoke "$rule_off_output" "$binary" --json --config "$config_file" --rule trailing-whitespace=off "$source_file"
require_json_no_grep '"code":"lint/trailing-whitespace"' "$rule_off_output"
require_json_no_grep '"severity":"off"' "$rule_off_output"

invalid_rule_output="$tmp_dir/invalid-rule.stderr"
run_stderr_usage_smoke "$invalid_rule_output" "$binary" --rule trailing-whitespace "$source_file"
require_text_grep "invalid --rule override" "$invalid_rule_output"
require_text_grep "trailing-whitespace" "$invalid_rule_output"
require_text_grep "--rule RULE=SEVERITY" "$invalid_rule_output"

invalid_config_file="$tmp_dir/invalid.rules"
invalid_config_output="$tmp_dir/invalid-config.stderr"
{
  printf '%s\n' "trailing-whitespace = loud"
  printf '%s\n' "broken"
} > "$invalid_config_file"
run_stderr_usage_smoke "$invalid_config_output" "$binary" --json --config "$invalid_config_file" "$source_file"
invalid_config_expected="$tmp_dir/invalid-config.expected.stderr"
{
  printf 'ari-lint: error: %s:1: unknown rule or severity\n' "$invalid_config_file"
  printf 'ari-lint: error: %s:2: expected RULE=SEVERITY\n' "$invalid_config_file"
} > "$invalid_config_expected"
require_files_equal "$invalid_config_expected" "$invalid_config_output"

unreadable_config_file="$tmp_dir/missing-explicit.rules"
unreadable_config_output="$tmp_dir/missing-explicit.stderr"
run_stderr_usage_smoke "$unreadable_config_output" "$binary" --json --config "$unreadable_config_file" "$source_file"
unreadable_config_expected="$tmp_dir/missing-explicit.expected.stderr"
printf 'ari-lint: error: %s: cannot open lint config\n' "$unreadable_config_file" > "$unreadable_config_expected"
require_files_equal "$unreadable_config_expected" "$unreadable_config_output"

missing_config_output="$tmp_dir/missing-config.stderr"
run_stderr_usage_smoke "$missing_config_output" "$binary" --config
require_text_grep "missing option value for --config" "$missing_config_output"

missing_rule_output="$tmp_dir/missing-rule.stderr"
run_stderr_usage_smoke "$missing_rule_output" "$binary" --rule
require_text_grep "missing option value for --rule" "$missing_rule_output"

missing_ari_output="$tmp_dir/missing-ari.stderr"
run_stderr_usage_smoke "$missing_ari_output" "$binary" --ari
require_text_grep "missing option value for --ari" "$missing_ari_output"

unknown_argument_output="$tmp_dir/unknown-argument.stderr"
run_stderr_usage_smoke "$unknown_argument_output" "$binary" --definitely-unknown
require_text_grep "unknown argument: --definitely-unknown" "$unknown_argument_output"

missing_source_output="$tmp_dir/missing-source.stderr"
run_stderr_usage_smoke "$missing_source_output" "$binary"
require_text_grep "missing source file" "$missing_source_output"

json_missing_source_output="$tmp_dir/json-missing-source.stderr"
run_stderr_usage_smoke "$json_missing_source_output" "$binary" --json
require_text_grep "missing source file" "$json_missing_source_output"

discovery_parent="$tmp_dir/discovery"
discovery_child="$discovery_parent/child"
mkdir -p "$discovery_child"
parent_config_file="$discovery_parent/ari-lint.rules"
child_config_file="$discovery_child/ari-lint.rules"
discovery_source="$discovery_child/trailing.ari"
cp "$source_file" "$discovery_source"
printf '%s\n' "trailing-whitespace = warning" > "$parent_config_file"

parent_discovery_output="$tmp_dir/parent-discovered-warning.json"
run_json_diagnostic_smoke "$parent_discovery_output" "$binary" --json "$discovery_source"
require_json_grep '"code":"lint/trailing-whitespace"' "$parent_discovery_output"
require_json_grep '"severity":"warning"' "$parent_discovery_output"

printf '%s\n' "trailing-whitespace = note" > "$child_config_file"
nearest_discovery_output="$tmp_dir/nearest-discovered-note.json"
run_json_diagnostic_smoke "$nearest_discovery_output" "$binary" --json "$discovery_source"
require_json_grep '"code":"lint/trailing-whitespace"' "$nearest_discovery_output"
require_json_grep '"severity":"note"' "$nearest_discovery_output"

empty_inline_config_output="$tmp_dir/empty-inline-config.json"
run_json_diagnostic_smoke "$empty_inline_config_output" "$binary" --json --config= "$discovery_source"
require_json_grep '"severity":"note"' "$empty_inline_config_output"

empty_config_value_output="$tmp_dir/empty-config-value.json"
run_json_diagnostic_smoke "$empty_config_value_output" "$binary" --json --config "" "$discovery_source"
require_json_grep '"severity":"note"' "$empty_config_value_output"

unreadable_discovery_parent="$tmp_dir/unreadable-discovery"
unreadable_discovery_child="$unreadable_discovery_parent/child"
mkdir -p "$unreadable_discovery_child"
printf '%s\n' "trailing-whitespace = note" > "$unreadable_discovery_parent/ari-lint.rules"
printf '%s\n' "trailing-whitespace = error" > "$unreadable_discovery_child/ari-lint.rules"
chmod 000 "$unreadable_discovery_child/ari-lint.rules"
unreadable_discovery_source="$unreadable_discovery_child/input.ari"
cp "$source_file" "$unreadable_discovery_source"
unreadable_discovery_output="$tmp_dir/unreadable-discovery.json"
run_json_diagnostic_smoke "$unreadable_discovery_output" "$binary" --json "$unreadable_discovery_source"
require_json_grep '"severity":"note"' "$unreadable_discovery_output"
require_json_no_grep '"severity":"error"' "$unreadable_discovery_output"
chmod 600 "$unreadable_discovery_child/ari-lint.rules"

directory_discovery_parent="$tmp_dir/directory-discovery"
directory_discovery_child="$directory_discovery_parent/child"
mkdir -p "$directory_discovery_child/ari-lint.rules"
printf '%s\n' "trailing-whitespace = error" > "$directory_discovery_parent/ari-lint.rules"
directory_discovery_source="$directory_discovery_child/input.ari"
cp "$source_file" "$directory_discovery_source"
directory_discovery_output="$tmp_dir/directory-discovery.json"
run_json_diagnostic_smoke "$directory_discovery_output" "$binary" --json "$directory_discovery_source"
require_json_grep '"severity":"warning"' "$directory_discovery_output"
require_json_no_grep '"severity":"error"' "$directory_discovery_output"
require_json_no_grep '"code":"lint/config"' "$directory_discovery_output"

explicit_over_discovery_output="$tmp_dir/explicit-over-discovery-error.json"
run_json_diagnostic_smoke "$explicit_over_discovery_output" "$binary" --json --config "$config_file" "$discovery_source"
require_json_grep '"code":"lint/trailing-whitespace"' "$explicit_over_discovery_output"
require_json_grep '"severity":"error"' "$explicit_over_discovery_output"

per_source_root="$tmp_dir/per-source"
per_source_one="$per_source_root/one"
per_source_two="$per_source_root/two"
mkdir -p "$per_source_one" "$per_source_two"
per_source_one_file="$per_source_one/input.ari"
per_source_two_file="$per_source_two/input.ari"
cp "$source_file" "$per_source_one_file"
cp "$source_file" "$per_source_two_file"
printf '%s\n' "trailing-whitespace = note" > "$per_source_one/ari-lint.rules"
printf '%s\n' "trailing-whitespace = error" > "$per_source_two/ari-lint.rules"

per_source_output="$tmp_dir/per-source.json"
run_json_diagnostic_smoke "$per_source_output" "$binary" --json "$per_source_one_file" "$per_source_two_file"
per_source_expected="$tmp_dir/per-source.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":19,"endLine":1,"endColumn":21,"severity":"note","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]},{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":19,"endLine":1,"endColumn":21,"severity":"error","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]}]}\n' "$per_source_one_file" "$per_source_one_file" "$per_source_two_file" "$per_source_two_file" > "$per_source_expected"
require_files_equal "$per_source_expected" "$per_source_output"

per_source_cli_output="$tmp_dir/per-source-cli-override.json"
run_json_diagnostic_smoke "$per_source_cli_output" "$binary" --json --rule trailing-whitespace=hint "$per_source_one_file" "$per_source_two_file"
require_json_grep '"severity":"hint"' "$per_source_cli_output"
require_json_no_grep '"severity":"note"' "$per_source_cli_output"
require_json_no_grep '"severity":"error"' "$per_source_cli_output"

per_source_explicit_output="$tmp_dir/per-source-explicit.json"
run_json_diagnostic_smoke "$per_source_explicit_output" "$binary" --json --config "$config_file" "$per_source_one_file" "$per_source_two_file"
per_source_explicit_count=$(grep -F -o -- '"severity":"error"' "$per_source_explicit_output" | wc -l | tr -d ' ')
[ "$per_source_explicit_count" -eq 2 ] || fail "expected explicit config to disable per-source discovery"
require_json_no_grep '"severity":"note"' "$per_source_explicit_output"

explicit_directory_config="$tmp_dir/explicit-directory-config"
mkdir -p "$explicit_directory_config"
explicit_directory_output="$tmp_dir/explicit-directory-config.json"
run_json_diagnostic_smoke "$explicit_directory_output" "$binary" --json --config "$explicit_directory_config" "$per_source_one_file"
require_json_grep '"severity":"warning"' "$explicit_directory_output"
require_json_no_grep '"severity":"note"' "$explicit_directory_output"
require_json_no_grep '"code":"lint/config"' "$explicit_directory_output"

invalid_discovery_parent="$tmp_dir/invalid-discovery"
invalid_discovery_dir="$invalid_discovery_parent/child"
mkdir -p "$invalid_discovery_dir"
invalid_discovery_source="$invalid_discovery_dir/input.ari"
invalid_discovery_config="$invalid_discovery_dir/ari-lint.rules"
printf '%s\n' "trailing-whitespace = error" > "$invalid_discovery_parent/ari-lint.rules"
cp "$source_file" "$invalid_discovery_source"
{
  printf '%s\n' "trailing-whitespace = loud"
  printf '%s\n' "broken"
} > "$invalid_discovery_config"
invalid_discovery_output="$tmp_dir/invalid-discovery.json"
(
  cd "$invalid_discovery_dir"
  run_json_diagnostic_smoke "$invalid_discovery_output" "$binary" --json "input.ari"
)
invalid_discovery_expected="$tmp_dir/invalid-discovery.expected.json"
printf '%s\n' '{"files":[{"path":"input.ari","exitCode":0,"diagnostics":[{"file":"input.ari","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"error","message":"ari-lint.rules:1: unknown rule or severity","source":"ari-lint","code":"lint/config"},{"file":"input.ari","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"error","message":"ari-lint.rules:2: expected RULE=SEVERITY","source":"ari-lint","code":"lint/config"},{"file":"input.ari","line":1,"column":19,"endLine":1,"endColumn":21,"severity":"warning","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]}]}' > "$invalid_discovery_expected"
require_files_equal "$invalid_discovery_expected" "$invalid_discovery_output"

invalid_discovery_multi_output="$tmp_dir/invalid-discovery-multi.json"
run_json_diagnostic_smoke "$invalid_discovery_multi_output" "$binary" --json "$invalid_discovery_source" "$per_source_one_file"
invalid_discovery_multi_expected="$tmp_dir/invalid-discovery-multi.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"error","message":"%s:1: unknown rule or severity","source":"ari-lint","code":"lint/config"},{"file":"%s","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"error","message":"%s:2: expected RULE=SEVERITY","source":"ari-lint","code":"lint/config"},{"file":"%s","line":1,"column":19,"endLine":1,"endColumn":21,"severity":"warning","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]},{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":19,"endLine":1,"endColumn":21,"severity":"note","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]}]}\n' "$invalid_discovery_source" "$invalid_discovery_source" "$invalid_discovery_config" "$invalid_discovery_source" "$invalid_discovery_config" "$invalid_discovery_source" "$per_source_one_file" "$per_source_one_file" > "$invalid_discovery_multi_expected"
require_files_equal "$invalid_discovery_multi_expected" "$invalid_discovery_multi_output"

partial_discovery_dir="$tmp_dir/partial-discovery"
mkdir -p "$partial_discovery_dir"
partial_discovery_source="$partial_discovery_dir/input.ari"
partial_discovery_config="$partial_discovery_dir/ari-lint.rules"
cp "$source_file" "$partial_discovery_source"
{
  printf '%s\n' "trailing-whitespace = off"
  printf '%s\n' "broken"
} > "$partial_discovery_config"

partial_discovery_output="$tmp_dir/partial-discovery.json"
run_json_diagnostic_smoke "$partial_discovery_output" "$binary" --json "$partial_discovery_source"
partial_discovery_expected="$tmp_dir/partial-discovery.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":1,"endLine":1,"endColumn":2,"severity":"error","message":"%s:2: expected RULE=SEVERITY","source":"ari-lint","code":"lint/config"}]}]}\n' "$partial_discovery_source" "$partial_discovery_source" "$partial_discovery_config" > "$partial_discovery_expected"
require_files_equal "$partial_discovery_expected" "$partial_discovery_output"

partial_discovery_human="$tmp_dir/partial-discovery.human"
partial_discovery_human_stderr="$tmp_dir/partial-discovery.human.stderr"
run_human_diagnostic_smoke "$partial_discovery_human" "$partial_discovery_human_stderr" "$binary" "$partial_discovery_source"
partial_discovery_human_expected="$tmp_dir/partial-discovery.human.expected"
printf '%s:1:1: error: [lint/config] %s:2: expected RULE=SEVERITY\n' "$partial_discovery_source" "$partial_discovery_config" > "$partial_discovery_human_expected"
require_files_equal "$partial_discovery_human_expected" "$partial_discovery_human"
require_empty_file "$partial_discovery_human_stderr"

field_config_file="$tmp_dir/diagnostic-fields.rules"
{
  printf '%s\n' "trailing-whitespace = warning"
  printf '%s\n' "missing-final-newline = warning"
} > "$field_config_file"

trailing_field_source="$tmp_dir/trailing-field.ari"
cp "$source_file" "$trailing_field_source"

trailing_field_output="$tmp_dir/trailing-field.json"
run_json_diagnostic_smoke "$trailing_field_output" "$binary" --json --config "$field_config_file" "$trailing_field_source"
require_json_grep "\"path\":\"$trailing_field_source\"" "$trailing_field_output"
require_json_grep "\"file\":\"$trailing_field_source\"" "$trailing_field_output"
require_json_grep '"line":1' "$trailing_field_output"
require_json_grep '"column":19' "$trailing_field_output"
require_json_grep '"severity":"warning"' "$trailing_field_output"
require_json_grep '"endLine":1' "$trailing_field_output"
require_json_grep '"endColumn":21' "$trailing_field_output"
require_json_grep '"source":"ari-lint"' "$trailing_field_output"
require_json_grep '"code":"lint/trailing-whitespace"' "$trailing_field_output"
require_json_grep '"message":"trailing whitespace"' "$trailing_field_output"
trailing_field_expected="$tmp_dir/trailing-field.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":19,"endLine":1,"endColumn":21,"severity":"warning","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]}]}\n' "$trailing_field_source" "$trailing_field_source" > "$trailing_field_expected"
require_files_equal "$trailing_field_expected" "$trailing_field_output"

trailing_field_human="$tmp_dir/trailing-field.human"
trailing_field_human_stderr="$tmp_dir/trailing-field.human.stderr"
run_human_diagnostic_smoke "$trailing_field_human" "$trailing_field_human_stderr" "$binary" --config "$field_config_file" "$trailing_field_source"
trailing_field_human_expected="$tmp_dir/trailing-field.human.expected"
printf '%s:1:19: warning: [lint/trailing-whitespace] trailing whitespace\n' "$trailing_field_source" > "$trailing_field_human_expected"
require_files_equal "$trailing_field_human_expected" "$trailing_field_human"
require_empty_file "$trailing_field_human_stderr"

missing_final_newline_field_source="$tmp_dir/missing-final-newline-field.ari"
printf '%s' "fn main() -> i64 { return 0; }" > "$missing_final_newline_field_source"

missing_final_newline_field_output="$tmp_dir/missing-final-newline-field.json"
run_json_diagnostic_smoke "$missing_final_newline_field_output" "$binary" --json --config "$field_config_file" "$missing_final_newline_field_source"
require_json_grep "\"path\":\"$missing_final_newline_field_source\"" "$missing_final_newline_field_output"
require_json_grep "\"file\":\"$missing_final_newline_field_source\"" "$missing_final_newline_field_output"
require_json_grep '"line":1' "$missing_final_newline_field_output"
require_json_grep '"column":31' "$missing_final_newline_field_output"
require_json_grep '"severity":"warning"' "$missing_final_newline_field_output"
require_json_grep '"endLine":1' "$missing_final_newline_field_output"
require_json_grep '"endColumn":32' "$missing_final_newline_field_output"
require_json_grep '"source":"ari-lint"' "$missing_final_newline_field_output"
require_json_grep '"code":"lint/missing-final-newline"' "$missing_final_newline_field_output"
require_json_grep '"message":"missing final newline"' "$missing_final_newline_field_output"
missing_final_newline_expected="$tmp_dir/missing-final-newline-field.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":31,"endLine":1,"endColumn":32,"severity":"warning","message":"missing final newline","source":"ari-lint","code":"lint/missing-final-newline"}]}]}\n' "$missing_final_newline_field_source" "$missing_final_newline_field_source" > "$missing_final_newline_expected"
require_files_equal "$missing_final_newline_expected" "$missing_final_newline_field_output"

multi_dirty_one="$tmp_dir/multi-dirty-one.ari"
multi_dirty_two="$tmp_dir/multi-dirty-two.ari"
{
  printf '%s  \n' "fn dirty_one() -> i64 {"
  printf '%s\n' "  return 1;"
  printf '%s\n' "}"
} > "$multi_dirty_one"
printf '%s' "fn dirty_two() -> i64 { return 2; }" > "$multi_dirty_two"

multi_output="$tmp_dir/multi-dirty.json"
run_json_diagnostic_smoke "$multi_output" "$binary" --json "$multi_dirty_one" "$multi_dirty_two"
require_json_grep "\"path\":\"$multi_dirty_one\"" "$multi_output"
require_json_grep "\"path\":\"$multi_dirty_two\"" "$multi_output"
require_json_grep '"code":"lint/trailing-whitespace"' "$multi_output"
require_json_grep '"code":"lint/missing-final-newline"' "$multi_output"
multi_expected="$tmp_dir/multi-dirty.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":24,"endLine":1,"endColumn":26,"severity":"warning","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]},{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":36,"endLine":1,"endColumn":37,"severity":"warning","message":"missing final newline","source":"ari-lint","code":"lint/missing-final-newline"}]}]}\n' "$multi_dirty_one" "$multi_dirty_one" "$multi_dirty_two" "$multi_dirty_two" > "$multi_expected"
require_files_equal "$multi_expected" "$multi_output"

dash_source="$tmp_dir/-dash-source.ari"
printf '%s  \n' "fn dash_source() -> i64 { return 0; }" > "$dash_source"
dash_output="$tmp_dir/dash-source.json"
(
  cd "$tmp_dir"
  run_json_diagnostic_smoke "$dash_output" "$binary" --json -- "-dash-source.ari"
)
require_json_grep '"path":"-dash-source.ari"' "$dash_output"
require_json_grep '"file":"-dash-source.ari"' "$dash_output"
require_json_grep '"code":"lint/trailing-whitespace"' "$dash_output"

clean_source="$tmp_dir/clean.ari"
{
  printf '%s\n' "fn clean() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$clean_source"

clean_source_two="$tmp_dir/clean-two.ari"
{
  printf '%s\n' "fn clean_two() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$clean_source_two"

clean_output="$tmp_dir/multi-clean.json"
run_json_success_smoke "$clean_output" "$binary" --json "$clean_source" "$clean_source_two"
clean_expected="$tmp_dir/multi-clean.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[]},{"path":"%s","exitCode":0,"diagnostics":[]}]}\n' "$clean_source" "$clean_source_two" > "$clean_expected"
require_files_equal "$clean_expected" "$clean_output"

large_clean_source="$tmp_dir/large-clean.ari"
printf '// ' > "$large_clean_source"
head -c 66000 /dev/zero | tr '\000' 'a' >> "$large_clean_source"
printf '\nfn main() -> i64 { return 0; }\n' >> "$large_clean_source"
large_clean_output="$tmp_dir/large-clean.json"
run_json_success_smoke "$large_clean_output" "$binary" --json "$large_clean_source"
large_clean_expected="$tmp_dir/large-clean.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[]}]}' "$large_clean_source" > "$large_clean_expected"
printf '\n' >> "$large_clean_expected"
require_files_equal "$large_clean_expected" "$large_clean_output"

tab_character=$(printf '\t')
escaped_path_source="$tmp_dir/control${tab_character}name.ari"
cp "$clean_source" "$escaped_path_source"
escaped_path_output="$tmp_dir/escaped-path.json"
run_json_success_smoke "$escaped_path_output" "$binary" --json "$escaped_path_source"
require_json_grep 'control\tname.ari' "$escaped_path_output"

utf8_path_source="$tmp_dir/한글.ari"
cp "$clean_source" "$utf8_path_source"
utf8_path_output="$tmp_dir/utf8-path.json"
run_json_success_smoke "$utf8_path_output" "$binary" --json "$utf8_path_source"
require_json_grep '한글.ari' "$utf8_path_output"

invalid_path_byte=$(printf '\377')
invalid_utf8_path_source="$tmp_dir/invalid-${invalid_path_byte}.ari"
cp "$clean_source" "$invalid_utf8_path_source"
invalid_utf8_path_output="$tmp_dir/invalid-utf8-path.json"
run_json_success_smoke "$invalid_utf8_path_output" "$binary" --json "$invalid_utf8_path_source"
require_json_grep 'invalid-\ufffd.ari' "$invalid_utf8_path_output"

clean_human_output="$tmp_dir/clean.human"
clean_human_stderr="$tmp_dir/clean.human.stderr"
run_human_success_smoke "$clean_human_output" "$clean_human_stderr" "$binary" "$clean_source"
printf '%s: ok\n' "$clean_source" > "$tmp_dir/clean.human.expected"
require_files_equal "$tmp_dir/clean.human.expected" "$clean_human_output"
require_empty_file "$clean_human_stderr"

mixed_output="$tmp_dir/mixed-clean-dirty.json"
run_json_diagnostic_smoke "$mixed_output" "$binary" --json "$clean_source" "$multi_dirty_one"
require_json_grep "\"path\":\"$multi_dirty_one\"" "$mixed_output"
require_json_grep "\"path\":\"$clean_source\"" "$mixed_output"

duplicate_output="$tmp_dir/duplicate.json"
run_json_diagnostic_smoke "$duplicate_output" "$binary" --json "$multi_dirty_one" "$multi_dirty_one"
duplicate_path_count=$(grep -F -o -- "\"path\":\"$multi_dirty_one\"" "$duplicate_output" | wc -l | tr -d ' ')
[ "$duplicate_path_count" -eq 2 ] || fail "expected duplicate source arguments to produce two file results"

stress_output="$tmp_dir/repeated-dirty.json"
set -- "$binary" --json --ari "$fake_compiler_path"
stress_index=0
while [ "$stress_index" -lt 24 ]; do
  set -- "$@" "$multi_dirty_one"
  stress_index=$((stress_index + 1))
done
run_json_diagnostic_smoke "$stress_output" "$@"
stress_path_count=$(grep -F -o -- "\"path\":\"$multi_dirty_one\"" "$stress_output" | wc -l | tr -d ' ')
[ "$stress_path_count" -eq 24 ] || fail "expected 24 repeated source arguments in the JSON result"
stress_suffix=$(tail -c 3 "$stress_output")
[ "$stress_suffix" = "]}" ] || fail "expected repeated-input JSON to end with a complete files envelope"

missing_source_file="$tmp_dir/missing-source.ari"
multi_read_error_output="$tmp_dir/multi-read-error.json"
run_json_diagnostic_smoke "$multi_read_error_output" "$binary" --json "$clean_source" "$missing_source_file"
require_json_grep "\"path\":\"$clean_source\",\"exitCode\":0" "$multi_read_error_output"
require_json_grep "\"path\":\"$missing_source_file\",\"exitCode\":1" "$multi_read_error_output"
require_json_grep '"source":"ari"' "$multi_read_error_output"
require_json_grep '"code":"ari/compiler"' "$multi_read_error_output"
require_json_grep "cannot open input file '$missing_source_file'" "$multi_read_error_output"

printf '%s\n' "smoke.sh: smoke checks passed"
