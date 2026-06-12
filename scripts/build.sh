#!/bin/sh

set -eu

fail() {
  printf '%s\n' "build.sh: $*" >&2
  exit 1
}

if [ "$#" -gt 1 ]; then
  fail "usage: scripts/build.sh [ARI_COMPILER_PATH]"
fi

compiler="${1:-${ARI_COMPILER:-}}"
original_pwd=$(pwd)

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)

case "$compiler" in
  "" | /*) ;;
  *) compiler="$original_pwd/$compiler" ;;
esac

if [ -z "$compiler" ]; then
  fail "missing Ari compiler path; pass scripts/build.sh /path/to/ari or set ARI_COMPILER"
fi

if [ ! -e "$compiler" ]; then
  fail "Ari compiler path does not exist: $compiler"
fi

if [ ! -x "$compiler" ]; then
  fail "Ari compiler path is not executable: $compiler"
fi

compiler_root=$(CDPATH= cd "$(dirname "$compiler")/.." && pwd)
build_workdir="$repo_root"
if [ -e "$compiler_root/lib/std.arih" ]; then
  build_workdir="$compiler_root"
fi

mkdir -p "$repo_root/build"

input="$repo_root/src/main.ari"
output="$repo_root/build/ari-lint"

printf '%s\n' "build.sh: using Ari compiler: $compiler"
printf '%s\n' "build.sh: compiling $input -> $output"
cd "$build_workdir"
"$compiler" "$input" -o "$output"
printf '%s\n' "build.sh: wrote $output"
