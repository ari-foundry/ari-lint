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
  "$script_dir/build.sh" "$1"
else
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

run_json_diagnostic_smoke() {
  output_file="$1"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$output_file"
  status=$?
  set -e
  [ "$status" -eq 2 ] || fail "expected diagnostic exit code 2, got $status"
}

run_json_success_smoke() {
  output_file="$1"
  shift
  printf '%s\n' "smoke.sh: running $*"
  set +e
  "$@" > "$output_file"
  status=$?
  set -e
  [ "$status" -eq 0 ] || fail "expected success exit code 0, got $status"
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

run_smoke "$binary" --help
run_smoke "$binary" --list-rules
run_smoke "$binary" --json --list-rules

config_file="$tmp_dir/explicit.rules"
source_file="$tmp_dir/trailing.ari"
printf '%s\n' "lint/trailing-whitespace = error" > "$config_file"
{
  printf '%s  \n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$source_file"

config_output="$tmp_dir/config-error.json"
rule_output="$tmp_dir/rule-note.json"
run_json_diagnostic_smoke "$config_output" "$binary" --json --config "$config_file" "$source_file"
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$config_output"
require_json_grep '"severity":"error"' "$config_output"

run_json_diagnostic_smoke "$rule_output" "$binary" --json --config "$config_file" --rule trailing-whitespace=note "$source_file"
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$rule_output"
require_json_grep '"severity":"note"' "$rule_output"

discovery_parent="$tmp_dir/discovery"
discovery_child="$discovery_parent/child"
mkdir -p "$discovery_child"
parent_config_file="$discovery_parent/ari-lint.rules"
child_config_file="$discovery_child/ari-lint.rules"
printf '%s\n' "lint/trailing-whitespace = warning" > "$parent_config_file"

parent_discovery_output="$tmp_dir/parent-discovered-warning.json"
(
  cd "$discovery_child"
  run_json_diagnostic_smoke "$parent_discovery_output" "$binary" --json "$source_file"
)
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$parent_discovery_output"
require_json_grep '"severity":"warning"' "$parent_discovery_output"

printf '%s\n' "lint/trailing-whitespace = note" > "$child_config_file"
nearest_discovery_output="$tmp_dir/nearest-discovered-note.json"
(
  cd "$discovery_child"
  run_json_diagnostic_smoke "$nearest_discovery_output" "$binary" --json "$source_file"
)
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$nearest_discovery_output"
require_json_grep '"severity":"note"' "$nearest_discovery_output"

explicit_over_discovery_output="$tmp_dir/explicit-over-discovery-error.json"
(
  cd "$discovery_child"
  run_json_diagnostic_smoke "$explicit_over_discovery_output" "$binary" --json --config "$config_file" "$source_file"
)
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$explicit_over_discovery_output"
require_json_grep '"severity":"error"' "$explicit_over_discovery_output"

field_config_file="$tmp_dir/diagnostic-fields.rules"
{
  printf '%s\n' "lint/trailing-whitespace = warning"
  printf '%s\n' "lint/missing-final-newline = warning"
} > "$field_config_file"

trailing_field_source="$tmp_dir/trailing-field.ari"
printf '%s  \n' "x" > "$trailing_field_source"

trailing_field_output="$tmp_dir/trailing-field.json"
run_json_diagnostic_smoke "$trailing_field_output" "$binary" --json --config "$field_config_file" "$trailing_field_source"
require_json_grep "\"filePath\":\"$trailing_field_source\"" "$trailing_field_output"
require_json_grep '"line":1' "$trailing_field_output"
require_json_grep '"column":2' "$trailing_field_output"
require_json_grep '"severity":"warning"' "$trailing_field_output"
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$trailing_field_output"
require_json_grep '"message":"trailing whitespace"' "$trailing_field_output"

missing_final_newline_field_source="$tmp_dir/missing-final-newline-field.ari"
printf '%s' "x" > "$missing_final_newline_field_source"

missing_final_newline_field_output="$tmp_dir/missing-final-newline-field.json"
run_json_diagnostic_smoke "$missing_final_newline_field_output" "$binary" --json --config "$field_config_file" "$missing_final_newline_field_source"
require_json_grep "\"filePath\":\"$missing_final_newline_field_source\"" "$missing_final_newline_field_output"
require_json_grep '"line":1' "$missing_final_newline_field_output"
require_json_grep '"column":2' "$missing_final_newline_field_output"
require_json_grep '"severity":"warning"' "$missing_final_newline_field_output"
require_json_grep '"ruleCode":"lint/missing-final-newline"' "$missing_final_newline_field_output"
require_json_grep '"message":"missing final newline"' "$missing_final_newline_field_output"

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
require_json_grep "\"filePath\":\"$multi_dirty_one\"" "$multi_output"
require_json_grep "\"filePath\":\"$multi_dirty_two\"" "$multi_output"
require_json_grep '"ruleCode":"lint/trailing-whitespace"' "$multi_output"
require_json_grep '"ruleCode":"lint/missing-final-newline"' "$multi_output"

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
require_json_grep "[]" "$clean_output"

mixed_output="$tmp_dir/mixed-clean-dirty.json"
run_json_diagnostic_smoke "$mixed_output" "$binary" --json "$clean_source" "$multi_dirty_one"
require_json_grep "\"filePath\":\"$multi_dirty_one\"" "$mixed_output"
require_json_no_grep "\"filePath\":\"$clean_source\"" "$mixed_output"

printf '%s\n' "smoke.sh: smoke checks passed"
