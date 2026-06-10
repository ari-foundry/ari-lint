# ari-lint Scripts

This directory contains lightweight repository helper scripts.

`check.sh` verifies repository shape and fixture invariants only. It does not
run or provision the Ari compiler, invoke `ari --check`, execute `tools/lint`,
run parity checks, run CLI tests, or compare golden files.

`build.sh` is a local build scaffold for the Ari-language entrypoint. It
requires an explicit Ari compiler path as the first argument or through
`ARI_COMPILER`; if both are provided, the positional argument wins. It resolves
the repository root before compiling, preserves relative compiler paths from the
caller's directory, validates that the compiler path exists and is executable,
creates `build/`, and uses the verified Ari compiler form `ari input.ari -o
output` to compile `src/main.ari` to `build/ari-lint`.

`build.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI yet.
