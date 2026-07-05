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

`smoke.sh` is a local smoke wrapper. It accepts an explicit Ari compiler path
as the first argument or through `ARI_COMPILER`, delegates compilation to
`scripts/build.sh`, and runs the current safe CLI smoke invocations:
`./build/ari-lint --help`, `./build/ari-lint --list-rules`, and
`./build/ari-lint --json --list-rules`. It also runs JSON smoke commands
against temporary files and a temporary nested working directory containing
`ari-lint.rules` to check parent discovered config severity, nearest discovered
config precedence, explicit `--config` precedence, and CLI `--rule`
precedence. It also checks current JSON diagnostic `ruleCode`, `severity`,
`message`, `filePath`, `line`, and `column` fields for
`lint/trailing-whitespace` and `lint/missing-final-newline`, JSON diagnostics
for two dirty source files, a clean plus dirty multi-file invocation, and a
clean plus clean multi-file invocation.

`parity.sh` is a local report-only parity smoke wrapper. It accepts an explicit
Ari compiler path as the first argument or through `ARI_COMPILER`, an
`ari-foundry/ari` checkout path as the second argument or through `ARI_REPO`,
and optionally an already-built original lint command path as the third
argument or through `ORIGINAL_LINT`. It verifies the original lint entrypoint
from the Ari repo `Makefile` and `tools/lint/main.cpp`, builds this repository
with `scripts/build.sh`, runs report-only `--help`, unknown-argument usage, and
`--list-rules` cases, runs both tools with `--json --ari` on temporary
trailing-whitespace, missing-final-newline, clean, explicit-config,
rule-override, discovered-config, and multi-file cases, and prints a concise
report of exit codes, stdout/stderr presence, help/usage/list-rules signals,
rule sightings, severity sightings, file-path hit counts, and line/column
presence. Parity differences do not fail the script.

`test.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI as a compiler-backed job yet.

`build.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI yet.

`smoke.sh` does not add golden output tests, a parity runner, compiler-backed
CI, home/global/XDG config search, new lint semantics, or compatibility claims.
It checks that `--help` names the current supported option set, checks focused
usage-error summaries for malformed `--rule` text and missing `--config` or
`--rule` values, parser-only missing `--ari` values, plus one unknown option,
and checks only the current JSON rule code, severity, message, file path, line,
and column fields for temporary diagnostics. JSON list-rules output assertions
and broad golden output coverage remain future smoke coverage.

`parity.sh` does not add CI wiring, a strict parity gate, golden files,
source-controlled parity fixtures, new lint semantics, release compatibility
claims, or copies of `tools/lint`. It fails only for infrastructure errors such
as a missing compiler, missing Ari repo, missing original lint command, or
local `ari-lint` build failure.
