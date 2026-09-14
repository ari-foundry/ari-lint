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
precedence. It checks the reference-shaped runtime JSON `files` envelope,
per-file `path`, `exitCode`, and `diagnostics`, and diagnostic `file`, position,
`severity`, `message`, `source`, and `code` fields. Exact expected output covers
representative JSON and human results, including final newlines. Multi-file
coverage includes dirty, clean plus dirty, all-clean, duplicate-argument, and
escaped-path cases.

`parity.sh` is a local report-only parity smoke wrapper. It accepts an explicit
Ari compiler path as the first argument or through `ARI_COMPILER`, an
`ari-foundry/ari` checkout path as the second argument or through `ARI_REPO`,
and optionally an already-built original lint command path as the third
argument or through `ORIGINAL_LINT`. It verifies the original lint entrypoint
from the Ari repo `Makefile` and `tools/lint/main.cpp`, builds this repository
with `scripts/build.sh`, runs report-only `--help`, short-help,
no-source-file usage, source read-error behavior, missing compiler path behavior
passed through `--ari`, compiler-error behavior, unknown-argument usage,
missing config value usage, missing rule value usage, missing ari value usage,
missing include value usage, malformed `--rule` usage, invalid `--rule` severity usage, unknown
`--rule` rule usage, `--list-rules`, and JSON list-rules cases, runs both
tools with `--json --ari` on temporary trailing-whitespace,
missing-final-newline, clean, missing-compiler, compiler-error, explicit-config,
config-short-name, config-read-error, invalid config, invalid rule override,
invalid rule severity, unknown rule override, config-off, rule-off,
rule-override, include-path, discovered-config, multi-file, and
multi-file-mixed cases,
and prints a concise report of exit codes, stdout/stderr
presence, help/usage/list-rules signals, compiler-check-failed and missing
compiler path sightings, compiler-error JSON-shape and diagnostic-code
sightings, rule sightings, severity sightings, file-path hit counts, and
line/column presence. Parity differences do not fail the script.

`test.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI as a compiler-backed job yet.

`build.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, run parity checks, or participate in CI yet.

`smoke.sh` does not add a strict parity gate, compiler-backed CI,
home/global/XDG config search, new lint semantics, or compatibility claims.
It checks that `--help` names the current supported option set, checks focused
`--list-rules` and `--json --list-rules` rule-code, short-name, and
default-severity output signals, checks focused
usage-error summaries for malformed `--rule` text and missing `--config` or
`--rule` values, parser-only missing `--ari` values, plus one unknown option,
checks that explicit config and CLI `--rule` `off` suppress diagnostics, and
checks exact reference-shaped runtime JSON and human output for representative
diagnostics. It also covers clean, mixed, duplicate, 24-file repeated-input,
66 KB clean-source, final-newline, stderr-isolation, and valid, control-byte,
and invalid-UTF-8 path behavior. Strict parity, source-controlled broad goldens,
and compiler diagnostics remain future work.

`parity.sh` does not add CI wiring, a strict parity gate, golden files,
source-controlled parity fixtures, new lint semantics, release compatibility
claims, or copies of `tools/lint`. It fails only for infrastructure errors such
as a missing build compiler, missing Ari repo, missing original lint command,
or local `ari-lint` build failure.
