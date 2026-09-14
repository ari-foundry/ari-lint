#!/bin/sh

set -eu

fail() {
  printf '%s\n' "parity-strict.sh: $*" >&2
  exit 1
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  fail "usage: scripts/parity-strict.sh ARI_COMPILER_PATH ARI_REPO_PATH [REFERENCE_LINT_PATH]"
fi

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)
original_pwd=$(pwd)

absolute_path() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s/%s\n' "$original_pwd" "$1" ;;
  esac
}

ari_compiler=$(absolute_path "$1")
ari_repo=$(absolute_path "$2")
reference_lint="${3:-$ari_repo/build/ari-lint}"
reference_lint=$(absolute_path "$reference_lint")

[ -x "$ari_compiler" ] || fail "Ari compiler is not executable: $ari_compiler"
[ -d "$ari_repo" ] || fail "Ari repository does not exist: $ari_repo"
[ -f "$ari_repo/Makefile" ] || fail "missing Ari Makefile: $ari_repo/Makefile"
[ -f "$ari_repo/tools/lint/main.cpp" ] || fail "missing reference lint source: $ari_repo/tools/lint/main.cpp"
[ -x "$reference_lint" ] || fail "reference lint is not executable: $reference_lint"

"$script_dir/build.sh" "$ari_compiler"

standalone_lint="$repo_root/build/ari-lint"
fixture_compiler="$repo_root/tests/fixtures/parity/compiler-ok.sh"
diagnostic_compiler="$repo_root/tests/fixtures/parity/compiler-diagnostic.sh"
empty_config="$repo_root/tests/fixtures/parity/empty.rules"
native_golden_dir="$repo_root/tests/golden/native"
compiler_golden_dir="$repo_root/tests/golden/compiler-boundary"
list_rules_golden_dir="$repo_root/tests/golden/list-rules"

[ -x "$standalone_lint" ] || fail "standalone lint is not executable: $standalone_lint"
[ -x "$fixture_compiler" ] || fail "fixture compiler is not executable: $fixture_compiler"
[ -x "$diagnostic_compiler" ] || fail "diagnostic compiler is not executable: $diagnostic_compiler"
[ -f "$empty_config" ] || fail "missing empty config fixture: $empty_config"
command -v python3 >/dev/null 2>&1 || fail "python3 is required to validate JSON goldens"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ari-lint-parity-strict.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

metadata_sentinel_compiler="$tmp_dir/metadata-sentinel-ari"
{
  printf '%s\n' '#!/bin/sh'
  printf '%s\n' 'touch "${ARI_LINT_METADATA_SENTINEL_MARKER:?}"'
  printf '%s\n' 'exit 99'
} > "$metadata_sentinel_compiler"
chmod 700 "$metadata_sentinel_compiler"

require_final_newline() {
  last_byte=$(tail -c 1 "$1" | od -An -t x1 | tr -d ' \n')
  [ "$last_byte" = "0a" ] || fail "expected final newline: $1"
}

run_tool() {
  tool_name="$1"
  tool_path="$2"
  case_name="$3"
  selected_compiler="$4"
  expects_json="$5"
  shift 5

  case "$expects_json" in
    yes|no) ;;
    *) fail "invalid JSON expectation for $case_name: $expects_json" ;;
  esac

  stdout_path="$tmp_dir/$case_name.$tool_name.stdout"
  stderr_path="$tmp_dir/$case_name.$tool_name.stderr"
  status_path="$tmp_dir/$case_name.$tool_name.status"

  set +e
  (
    CDPATH= cd "$repo_root" || exit 1
    if [ "$expects_json" = "yes" ]; then
      "$tool_path" --json --ari "$selected_compiler" \
        --config "$empty_config" "$@"
    else
      "$tool_path" --ari "$selected_compiler" \
        --config "$empty_config" "$@"
    fi
  ) > "$stdout_path" 2> "$stderr_path"
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_metadata_tool() {
  tool_name="$1"
  tool_path="$2"
  case_name="$3"
  shift 3

  stdout_path="$tmp_dir/$case_name.$tool_name.stdout"
  stderr_path="$tmp_dir/$case_name.$tool_name.stderr"
  status_path="$tmp_dir/$case_name.$tool_name.status"
  metadata_sentinel_marker="$tmp_dir/$case_name.$tool_name.compiler-spawned"

  set +e
  (
    ARI_COMPILER="$metadata_sentinel_compiler"
    ARI_LINT_METADATA_SENTINEL_MARKER="$metadata_sentinel_marker"
    export ARI_COMPILER ARI_LINT_METADATA_SENTINEL_MARKER
    CDPATH= cd "$repo_root" &&
      "$tool_path" --ari "$metadata_sentinel_compiler" "$@"
  ) > "$stdout_path" 2> "$stderr_path"
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_metadata_case() {
  case_name="$1"
  tool_name="$2"
  tool_path="$3"
  expected_file="$4"
  expects_json="$5"
  shift 5

  [ -f "$expected_file" ] || fail "missing golden: $expected_file"
  require_final_newline "$expected_file"
  run_metadata_tool "$tool_name" "$tool_path" "$case_name" "$@"

  stdout_path="$tmp_dir/$case_name.$tool_name.stdout"
  stderr_path="$tmp_dir/$case_name.$tool_name.stderr"
  status_path="$tmp_dir/$case_name.$tool_name.status"
  metadata_sentinel_marker="$tmp_dir/$case_name.$tool_name.compiler-spawned"

  [ "$(cat "$status_path")" = "0" ] ||
    fail "$case_name $tool_name exit status differs from 0"
  [ ! -e "$metadata_sentinel_marker" ] ||
    fail "$case_name $tool_name unexpectedly invoked the Ari compiler"
  [ ! -s "$stderr_path" ] || fail "$case_name $tool_name stderr is not empty"
  cmp -s "$expected_file" "$stdout_path" || {
    diff -u "$expected_file" "$stdout_path" >&2 || true
    fail "$case_name $tool_name stdout differs from golden"
  }
  require_final_newline "$stdout_path"

  if [ "$expects_json" = "yes" ]; then
    python3 -c 'import json, sys; json.load(open(sys.argv[1], encoding="utf-8"))' \
      "$stdout_path" || fail "$case_name $tool_name output is not valid JSON"
  fi

  printf '%s\n' "parity-strict.sh: passed $case_name ($tool_name)"
}

require_no_metadata_compiler_invocation() {
  unexpected_marker=$(find "$tmp_dir" -type f -name '*.compiler-spawned' -print -quit)
  [ -z "$unexpected_marker" ] ||
    fail "list-rules unexpectedly invoked the selected Ari compiler: $unexpected_marker"
}

run_case() {
  case_name="$1"
  expected_status="$2"
  expected_file="$3"
  selected_compiler="$4"
  expects_json="$5"
  shift 5

  [ -f "$expected_file" ] || fail "missing golden: $expected_file"
  require_final_newline "$expected_file"

  run_tool standalone "$standalone_lint" "$case_name" \
    "$selected_compiler" "$expects_json" "$@"
  run_tool reference "$reference_lint" "$case_name" \
    "$selected_compiler" "$expects_json" "$@"

  standalone_stdout="$tmp_dir/$case_name.standalone.stdout"
  standalone_stderr="$tmp_dir/$case_name.standalone.stderr"
  standalone_status="$tmp_dir/$case_name.standalone.status"
  reference_stdout="$tmp_dir/$case_name.reference.stdout"
  reference_stderr="$tmp_dir/$case_name.reference.stderr"
  reference_status="$tmp_dir/$case_name.reference.status"

  [ "$(cat "$standalone_status")" = "$expected_status" ] ||
    fail "$case_name standalone exit status differs from $expected_status"
  [ "$(cat "$reference_status")" = "$expected_status" ] ||
    fail "$case_name reference exit status differs from $expected_status"
  [ ! -s "$standalone_stderr" ] || fail "$case_name standalone stderr is not empty"
  [ ! -s "$reference_stderr" ] || fail "$case_name reference stderr is not empty"

  cmp -s "$expected_file" "$standalone_stdout" || {
    diff -u "$expected_file" "$standalone_stdout" >&2 || true
    fail "$case_name standalone stdout differs from golden"
  }
  cmp -s "$expected_file" "$reference_stdout" || {
    diff -u "$expected_file" "$reference_stdout" >&2 || true
    fail "$case_name reference stdout differs from golden"
  }
  cmp -s "$standalone_stdout" "$reference_stdout" ||
    fail "$case_name implementations differ"
  cmp -s "$standalone_stderr" "$reference_stderr" ||
    fail "$case_name stderr streams differ"
  cmp -s "$standalone_status" "$reference_status" ||
    fail "$case_name exit statuses differ"

  require_final_newline "$standalone_stdout"
  require_final_newline "$reference_stdout"
  if [ "$expects_json" = "yes" ]; then
    python3 -c 'import json, sys; [json.load(open(path, encoding="utf-8")) for path in sys.argv[1:]]' \
      "$expected_file" "$standalone_stdout" "$reference_stdout" ||
      fail "$case_name output is not valid JSON"
  fi

  printf '%s\n' "parity-strict.sh: passed $case_name"
}

run_metadata_case list-rules standalone "$standalone_lint" \
  "$list_rules_golden_dir/standalone-human.txt" no \
  --list-rules
run_metadata_case json-list-rules standalone "$standalone_lint" \
  "$list_rules_golden_dir/standalone.json" yes \
  --json --list-rules
run_metadata_case list-rules-json standalone "$standalone_lint" \
  "$list_rules_golden_dir/standalone.json" yes \
  --list-rules --json
run_metadata_case list-rules reference "$reference_lint" \
  "$list_rules_golden_dir/reference-human.txt" no \
  --list-rules
run_metadata_case json-list-rules reference "$reference_lint" \
  "$list_rules_golden_dir/reference-human.txt" no \
  --json --list-rules
run_metadata_case list-rules-json reference "$reference_lint" \
  "$list_rules_golden_dir/reference-human.txt" no \
  --list-rules --json

require_no_metadata_compiler_invocation
printf '%s\n' "strict list-rules contract goldens passed"

run_case clean 0 "$native_golden_dir/clean.json" "$fixture_compiler" yes \
  tests/fixtures/trailing-whitespace/clean.ari
run_case trailing-whitespace 1 "$native_golden_dir/trailing-whitespace.json" \
  "$fixture_compiler" yes \
  tests/fixtures/trailing-whitespace/trailing-spaces.ari
run_case missing-final-newline 1 "$native_golden_dir/missing-final-newline.json" \
  "$fixture_compiler" yes \
  tests/fixtures/missing-final-newline/missing-final-newline.ari
run_case ordered-multi-file-duplicate 1 \
  "$native_golden_dir/ordered-multi-file-duplicate.json" "$fixture_compiler" yes \
  tests/fixtures/trailing-whitespace/clean.ari \
  tests/fixtures/trailing-whitespace/trailing-spaces.ari \
  tests/fixtures/missing-final-newline/with-final-newline.ari \
  tests/fixtures/missing-final-newline/missing-final-newline.ari \
  tests/fixtures/trailing-whitespace/trailing-spaces.ari

require_no_metadata_compiler_invocation
printf '%s\n' "strict native parity goldens passed"

run_case compiler-diagnostic-native-json 1 \
  "$compiler_golden_dir/diagnostic-native.json" "$diagnostic_compiler" yes \
  tests/fixtures/trailing-whitespace/trailing-spaces.ari
run_case compiler-diagnostic-native-human 1 \
  "$compiler_golden_dir/diagnostic-native.txt" "$diagnostic_compiler" no \
  tests/fixtures/trailing-whitespace/trailing-spaces.ari

printf '%s\n' "strict compiler-boundary parity goldens passed"
