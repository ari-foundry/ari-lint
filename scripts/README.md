# ari-lint Scripts

This directory contains lightweight repository helper scripts.

`check.sh` verifies repository shape and fixture invariants only. It does not
run or provision the Ari compiler, invoke `ari --check`, execute `tools/lint`,
run parity checks, run CLI tests, or compare golden files.

`test.sh` is the local standalone test entrypoint. It resolves the repository
root and delegates to `scripts/check.sh`, so it currently runs the same
compiler-free repository-shape and fixture-invariant checks.

`build.sh` is a local build scaffold for the Ari-language entrypoint. It
requires an explicit Ari compiler path as the first argument or through
`ARI_COMPILER`; if both are provided, the positional argument wins. It resolves
the repository root, preserves relative compiler paths from the caller's
directory, validates that the compiler path exists and is executable, uses the
compiler root when `lib/std.arih` is available there, creates `build/`, and
uses the verified Ari compiler form `ari input.ari -o output` to compile
`src/main.ari` to `build/ari-lint`.

`test.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI as a compiler-backed job yet.

`build.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI yet.
