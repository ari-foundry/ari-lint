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

require_json_grep() {
  pattern="$1"
  file="$2"
  grep -q -- "$pattern" "$file" || fail "missing expected JSON text in $file: $pattern"
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

printf '%s\n' "smoke.sh: smoke checks passed"
