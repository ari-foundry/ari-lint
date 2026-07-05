#!/bin/sh

set -eu

fail() {
  printf '%s\n' "parity.sh: $*" >&2
  exit 1
}

usage() {
  printf '%s\n' "usage: scripts/parity.sh [ARI_COMPILER_PATH] [ARI_REPO_PATH] [ORIGINAL_LINT_PATH]" >&2
  printf '%s\n' "       or set ARI_COMPILER, ARI_REPO, and optionally ORIGINAL_LINT" >&2
}

resolve_from_original_pwd() {
  path="$1"
  case "$path" in
    "" | /*) printf '%s\n' "$path" ;;
    *) printf '%s\n' "$original_pwd/$path" ;;
  esac
}

resolve_dir_from_original_pwd() {
  path=$(resolve_from_original_pwd "$1")
  [ -d "$path" ] || fail "missing ari repository path: $path"
  (CDPATH= cd "$path" && pwd)
}

require_executable() {
  path="$1"
  description="$2"
  [ -n "$path" ] || fail "missing $description"
  [ -e "$path" ] || fail "$description does not exist: $path"
  [ -x "$path" ] || fail "$description is not executable: $path"
}

has_text() {
  if [ -s "$1" ]; then
    printf '%s' "yes"
  else
    printf '%s' "no"
  fi
}

has_fixed_text() {
  pattern="$1"
  file="$2"
  if grep -F -q -- "$pattern" "$file"; then
    printf '%s' "yes"
  else
    printf '%s' "no"
  fi
}

has_json_position() {
  field="$1"
  file="$2"
  if grep -E -q "\"$field\"[[:space:]]*:[[:space:]]*[0-9]+" "$file"; then
    printf '%s' "yes"
  else
    printf '%s' "no"
  fi
}

locate_original_lint() {
  explicit_path="${1:-}"
  if [ -n "$explicit_path" ]; then
    resolved=$(resolve_from_original_pwd "$explicit_path")
    require_executable "$resolved" "original tools/lint command"
    printf '%s\n' "$resolved"
    return
  fi

  [ -f "$ari_repo/Makefile" ] || fail "missing Ari Makefile: $ari_repo/Makefile"
  [ -f "$ari_repo/tools/lint/main.cpp" ] || fail "missing Ari lint entrypoint: $ari_repo/tools/lint/main.cpp"
  grep -q "LINT_TARGET" "$ari_repo/Makefile" || fail "unable to verify Ari Makefile lint target"
  grep -q "tools/lint" "$ari_repo/Makefile" || fail "unable to verify Ari Makefile tools/lint sources"
  grep -q "usage: ari-lint" "$ari_repo/tools/lint/main.cpp" || fail "unable to verify tools/lint/main.cpp as lint CLI entrypoint"

  candidate="$ari_repo/build/ari-lint"
  if [ -x "$candidate" ]; then
    printf '%s\n' "$candidate"
    return
  fi

  candidate_exe="$ari_repo/build/ari-lint.exe"
  if [ -x "$candidate_exe" ]; then
    printf '%s\n' "$candidate_exe"
    return
  fi

  fail "unable to locate executable original lint command; verified tools/lint/main.cpp and Makefile lint target, but build/ari-lint is not executable"
}

run_case() {
  tool_name="$1"
  tool_path="$2"
  case_name="$3"
  source_path="$4"
  stdout_path="$5"
  stderr_path="$6"
  status_path="$7"

  set +e
  "$tool_path" --json --ari "$compiler" "$source_path" > "$stdout_path" 2> "$stderr_path"
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

print_case_summary() {
  tool_name="$1"
  case_name="$2"
  source_path="$3"
  stdout_path="$4"
  stderr_path="$5"
  status_path="$6"

  status=$(cat "$status_path")
  trailing=$(has_fixed_text "lint/trailing-whitespace" "$stdout_path")
  missing=$(has_fixed_text "lint/missing-final-newline" "$stdout_path")
  path_present=$(has_fixed_text "$source_path" "$stdout_path")
  line_present=$(has_json_position "line" "$stdout_path")
  column_present=$(has_json_position "column" "$stdout_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    trailing_whitespace_reported: $trailing"
  printf '%s\n' "    missing_final_newline_reported: $missing"
  printf '%s\n' "    file_path_present: $path_present"
  printf '%s\n' "    line_present: $line_present"
  printf '%s\n' "    column_present: $column_present"
}

if [ "$#" -gt 3 ]; then
  usage
  exit 1
fi

original_pwd=$(pwd)
script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)

compiler=$(resolve_from_original_pwd "${1:-${ARI_COMPILER:-}}")
ari_repo_input="${2:-${ARI_REPO:-}}"
original_lint_input="${3:-${ORIGINAL_LINT:-}}"

if [ -z "$compiler" ]; then
  usage
  fail "missing Ari compiler path; pass it as the first argument or set ARI_COMPILER"
fi
require_executable "$compiler" "Ari compiler path"

if [ -z "$ari_repo_input" ]; then
  usage
  fail "missing ari repository path; pass it as the second argument or set ARI_REPO"
fi
ari_repo=$(resolve_dir_from_original_pwd "$ari_repo_input")
original_lint=$(locate_original_lint "$original_lint_input")

"$script_dir/build.sh" "$compiler" || fail "ari-lint build failed"
current_lint="$repo_root/build/ari-lint"
require_executable "$current_lint" "built ari-lint binary"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ari-lint-parity.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

trailing_source="$tmp_dir/trailing-whitespace.ari"
missing_source="$tmp_dir/missing-final-newline.ari"
clean_source="$tmp_dir/clean.ari"

{
  printf '%s  \n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$trailing_source"

printf '%s' "fn main() -> i64 { return 0; }" > "$missing_source"

{
  printf '%s\n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$clean_source"

printf '%s\n' "ari-lint local parity smoke report"
printf '%s\n' "current ari-lint: $current_lint"
printf '%s\n' "original tools/lint: $original_lint"
printf '%s\n' "ari compiler: $compiler"
printf '%s\n' "ari repo: $ari_repo"
printf '%s\n' "original entrypoint evidence: Makefile LINT_TARGET plus tools/lint/main.cpp usage"
printf '%s\n' ""

for case_name in trailing-whitespace missing-final-newline clean; do
  case "$case_name" in
    trailing-whitespace) source_path="$trailing_source" ;;
    missing-final-newline) source_path="$missing_source" ;;
    clean) source_path="$clean_source" ;;
    *) fail "unknown parity case: $case_name" ;;
  esac

  current_stdout="$tmp_dir/current-$case_name.stdout"
  current_stderr="$tmp_dir/current-$case_name.stderr"
  current_status="$tmp_dir/current-$case_name.status"
  original_stdout="$tmp_dir/original-$case_name.stdout"
  original_stderr="$tmp_dir/original-$case_name.stderr"
  original_status="$tmp_dir/original-$case_name.status"

  run_case "current ari-lint" "$current_lint" "$case_name" "$source_path" "$current_stdout" "$current_stderr" "$current_status"
  run_case "original tools/lint" "$original_lint" "$case_name" "$source_path" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: $case_name"
  print_case_summary "current ari-lint" "$case_name" "$source_path" "$current_stdout" "$current_stderr" "$current_status"
  print_case_summary "original tools/lint" "$case_name" "$source_path" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
done

printf '%s\n' "known differences:"
printf '%s\n' "- current Ari-language ari-lint does not invoke ari --check yet; original tools/lint does."
printf '%s\n' "- current JSON diagnostics are a flat array with filePath/ruleCode fields; original tools/lint emits a files array with path/diagnostics and code/source fields."
printf '%s\n' "- diagnostic exit codes may differ while this repository has no stable exit-code compatibility claim."
printf '%s\n' ""
printf '%s\n' "parity result: report-only; differences above do not fail this script."
