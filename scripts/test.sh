#!/bin/sh

set -eu

fail() {
  printf '%s\n' "test.sh: $*" >&2
  exit 1
}

if [ "$#" -gt 1 ]; then
  fail "usage: scripts/test.sh [COMPILER_PATH]"
fi

if [ "$#" -eq 1 ] && [ -z "$1" ]; then
  fail "Ari compiler path must not be empty"
fi

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)

(
  cd "$repo_root"
  scripts/check.sh
)

if [ "$#" -eq 0 ]; then
  exit 0
fi

exec "$repo_root/scripts/smoke.sh" "$1"
