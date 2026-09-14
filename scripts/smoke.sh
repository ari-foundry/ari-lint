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

binary="$repo_root/build/ari-lint"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ari-lint-smoke.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

if [ ! -x "$binary" ]; then
  fail "expected built ari-lint binary to be executable: $binary"
fi

run_smoke() {
  printf '%s\n' "smoke.sh: running $*"
  "$@"
}

run_stdout_success_smoke() {
  output_file="$1"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$output_file"
  status=$?
  set -e
  [ "$status" -eq 0 ] || fail "expected success exit code 0, got $status"
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
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$tmp_dir/usage.stdout" 2> "$output_file"
  status=$?
  set -e
  [ "$status" -eq 2 ] || fail "expected usage exit code 2, got $status"
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
missing_compiler_output="$tmp_dir/missing-ari.stderr"
run_stderr_unavailable_smoke "$missing_compiler_output" "$binary" --json --ari "$missing_compiler_path" "$source_file"
require_text_grep "Ari compiler path does not exist" "$missing_compiler_output"
require_text_grep "$missing_compiler_path" "$missing_compiler_output"
require_empty_file "$tmp_dir/unavailable.stdout"

non_executable_compiler_path="$tmp_dir/non-executable-ari"
non_executable_compiler_output="$tmp_dir/non-executable-ari.stderr"
printf '%s\n' "not an executable compiler" > "$non_executable_compiler_path"
chmod 600 "$non_executable_compiler_path"
run_stderr_unavailable_smoke "$non_executable_compiler_output" "$binary" --json --ari "$non_executable_compiler_path" "$source_file"
require_text_grep "Ari compiler path is not executable" "$non_executable_compiler_output"
require_text_grep "$non_executable_compiler_path" "$non_executable_compiler_output"
require_empty_file "$tmp_dir/unavailable.stdout"

sentinel_compiler_path="$tmp_dir/sentinel-ari"
sentinel_compiler_marker="$sentinel_compiler_path.spawned"
sentinel_compiler_output="$tmp_dir/sentinel-ari.json"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'touch "$0.spawned"'
  printf '%s\n' 'exit 99'
} > "$sentinel_compiler_path"
chmod 700 "$sentinel_compiler_path"
run_json_diagnostic_smoke "$sentinel_compiler_output" "$binary" --json --ari "$sentinel_compiler_path" "$source_file"
require_json_grep '"code":"lint/trailing-whitespace"' "$sentinel_compiler_output"
require_path_absent "$sentinel_compiler_marker"

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
printf '%s\n' "trailing-whitespace = loud" > "$invalid_config_file"
run_stderr_usage_smoke "$invalid_config_output" "$binary" --json --config "$invalid_config_file" "$source_file"
require_text_grep "invalid config file" "$invalid_config_output"
require_text_grep "$invalid_config_file:1" "$invalid_config_output"
require_text_grep "trailing-whitespace = loud" "$invalid_config_output"
require_text_grep "Severity must be off, hint, note, warning, or error." "$invalid_config_output"

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

discovery_parent="$tmp_dir/discovery"
discovery_child="$discovery_parent/child"
mkdir -p "$discovery_child"
parent_config_file="$discovery_parent/ari-lint.rules"
child_config_file="$discovery_child/ari-lint.rules"
printf '%s\n' "trailing-whitespace = warning" > "$parent_config_file"

parent_discovery_output="$tmp_dir/parent-discovered-warning.json"
(
  cd "$discovery_child"
  run_json_diagnostic_smoke "$parent_discovery_output" "$binary" --json "$source_file"
)
require_json_grep '"code":"lint/trailing-whitespace"' "$parent_discovery_output"
require_json_grep '"severity":"warning"' "$parent_discovery_output"

printf '%s\n' "trailing-whitespace = note" > "$child_config_file"
nearest_discovery_output="$tmp_dir/nearest-discovered-note.json"
(
  cd "$discovery_child"
  run_json_diagnostic_smoke "$nearest_discovery_output" "$binary" --json "$source_file"
)
require_json_grep '"code":"lint/trailing-whitespace"' "$nearest_discovery_output"
require_json_grep '"severity":"note"' "$nearest_discovery_output"

explicit_over_discovery_output="$tmp_dir/explicit-over-discovery-error.json"
(
  cd "$discovery_child"
  run_json_diagnostic_smoke "$explicit_over_discovery_output" "$binary" --json --config "$config_file" "$source_file"
)
require_json_grep '"code":"lint/trailing-whitespace"' "$explicit_over_discovery_output"
require_json_grep '"severity":"error"' "$explicit_over_discovery_output"

field_config_file="$tmp_dir/diagnostic-fields.rules"
{
  printf '%s\n' "trailing-whitespace = warning"
  printf '%s\n' "missing-final-newline = warning"
} > "$field_config_file"

trailing_field_source="$tmp_dir/trailing-field.ari"
printf '%s  \n' "x" > "$trailing_field_source"

trailing_field_output="$tmp_dir/trailing-field.json"
run_json_diagnostic_smoke "$trailing_field_output" "$binary" --json --config "$field_config_file" "$trailing_field_source"
require_json_grep "\"path\":\"$trailing_field_source\"" "$trailing_field_output"
require_json_grep "\"file\":\"$trailing_field_source\"" "$trailing_field_output"
require_json_grep '"line":1' "$trailing_field_output"
require_json_grep '"column":2' "$trailing_field_output"
require_json_grep '"severity":"warning"' "$trailing_field_output"
require_json_grep '"endLine":1' "$trailing_field_output"
require_json_grep '"endColumn":4' "$trailing_field_output"
require_json_grep '"source":"ari-lint"' "$trailing_field_output"
require_json_grep '"code":"lint/trailing-whitespace"' "$trailing_field_output"
require_json_grep '"message":"trailing whitespace"' "$trailing_field_output"
trailing_field_expected="$tmp_dir/trailing-field.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":2,"endLine":1,"endColumn":4,"severity":"warning","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]}]}\n' "$trailing_field_source" "$trailing_field_source" > "$trailing_field_expected"
require_files_equal "$trailing_field_expected" "$trailing_field_output"

trailing_field_human="$tmp_dir/trailing-field.human"
trailing_field_human_stderr="$tmp_dir/trailing-field.human.stderr"
run_human_diagnostic_smoke "$trailing_field_human" "$trailing_field_human_stderr" "$binary" --config "$field_config_file" "$trailing_field_source"
trailing_field_human_expected="$tmp_dir/trailing-field.human.expected"
printf '%s:1:2: warning: [lint/trailing-whitespace] trailing whitespace\n' "$trailing_field_source" > "$trailing_field_human_expected"
require_files_equal "$trailing_field_human_expected" "$trailing_field_human"
require_empty_file "$trailing_field_human_stderr"

missing_final_newline_field_source="$tmp_dir/missing-final-newline-field.ari"
printf '%s' "x" > "$missing_final_newline_field_source"

missing_final_newline_field_output="$tmp_dir/missing-final-newline-field.json"
run_json_diagnostic_smoke "$missing_final_newline_field_output" "$binary" --json --config "$field_config_file" "$missing_final_newline_field_source"
require_json_grep "\"path\":\"$missing_final_newline_field_source\"" "$missing_final_newline_field_output"
require_json_grep "\"file\":\"$missing_final_newline_field_source\"" "$missing_final_newline_field_output"
require_json_grep '"line":1' "$missing_final_newline_field_output"
require_json_grep '"column":2' "$missing_final_newline_field_output"
require_json_grep '"severity":"warning"' "$missing_final_newline_field_output"
require_json_grep '"endLine":1' "$missing_final_newline_field_output"
require_json_grep '"endColumn":3' "$missing_final_newline_field_output"
require_json_grep '"source":"ari-lint"' "$missing_final_newline_field_output"
require_json_grep '"code":"lint/missing-final-newline"' "$missing_final_newline_field_output"
require_json_grep '"message":"missing final newline"' "$missing_final_newline_field_output"
missing_final_newline_expected="$tmp_dir/missing-final-newline-field.expected.json"
printf '{"files":[{"path":"%s","exitCode":0,"diagnostics":[{"file":"%s","line":1,"column":2,"endLine":1,"endColumn":3,"severity":"warning","message":"missing final newline","source":"ari-lint","code":"lint/missing-final-newline"}]}]}\n' "$missing_final_newline_field_source" "$missing_final_newline_field_source" > "$missing_final_newline_expected"
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
head -c 66000 /dev/zero | tr '\000' 'a' > "$large_clean_source"
printf '\n' >> "$large_clean_source"
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
set -- "$binary" --json
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
multi_read_error_output="$tmp_dir/multi-read-error.stderr"
run_stderr_unavailable_smoke "$multi_read_error_output" "$binary" --json "$clean_source" "$missing_source_file"
require_text_grep "unable to read one or more source files" "$multi_read_error_output"
require_text_grep "$missing_source_file" "$multi_read_error_output"

printf '%s\n' "smoke.sh: smoke checks passed"
