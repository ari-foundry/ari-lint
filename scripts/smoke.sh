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

run_smoke "$binary" --help
run_smoke "$binary" --list-rules
run_smoke "$binary" --json --list-rules

config_file="$tmp_dir/explicit.rules"
source_file="$tmp_dir/clean.ari"
printf '%s\n' "lint/trailing-whitespace = error" > "$config_file"
{
  printf '%s\n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$source_file"
run_smoke "$binary" --config "$config_file" "$source_file"

printf '%s\n' "smoke.sh: smoke checks passed"
