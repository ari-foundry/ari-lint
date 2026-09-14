# ari-lint Scripts

This directory contains repository helpers for lightweight checks,
compiler-backed smoke validation, and local parity work.

`check.sh` verifies repository shape and fixture invariants only. It does not
run or provision the Ari compiler, invoke `ari --check`, execute `tools/lint`,
run parity checks, run CLI tests, or compare golden files.

`test.sh` is the local standalone test entrypoint. With no argument it resolves
the repository root and runs only `scripts/check.sh`, regardless of any
`ARI_COMPILER` environment entry. With one explicit, non-empty compiler path it
runs the same checks first and then delegates to `scripts/smoke.sh` with that
path. It rejects an empty path or more than one argument. The explicit path is
resolved by the existing build/smoke boundary relative to the caller's original
working directory.

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
`scripts/build.sh`, exports that compiler for runtime checks, and runs the
current CLI smoke invocations:
`./build/ari-lint --help`, `./build/ari-lint --list-rules`, and
`./build/ari-lint --json --list-rules`. It also runs JSON smoke commands
against temporary source trees containing `ari-lint.rules` to check per-source
nearest readable discovery, different configs in one multi-file run,
unreadable-nearer fallback, discovery suppression by explicit `--config`, and
CLI-last `--rule` precedence. Discovered bad config lines are checked as ordered
per-file `lint/config` diagnostics on stdout with exit `1`; explicit config read
and parse errors are checked as exact stderr with exit `2`. The script checks
the reference-shaped runtime JSON `files` envelope, per-file `path`, `exitCode`,
and `diagnostics`, and diagnostic `file`, position, `severity`, `message`,
`source`, and `code` fields. Exact expected output covers representative JSON
and human results, including final newlines. Multi-file coverage includes dirty,
clean plus dirty, all-clean, duplicate-argument, and escaped-path cases.
It also uses fake compilers to verify `--ari`/environment/default selection,
exact shell-free `-I DIR ... SOURCE --check` argv for every source, duplicate
execution, all four accepted compiler diagnostic shapes, CRLF and final lines
without newlines, deterministic stderr-then-stdout parsing, exit and signal
normalization, missing/non-executable compiler exit `127`, fallback generation
and suppression, embedded-carriage-return rejection, bounded concurrent
stdout/stderr draining with fail-closed truncation diagnostics (including an
exit-zero late-diagnostic case), dense compiler-diagnostic budgeting,
exact 2,048-per-file and 4,096-per-run boundaries, bounded raw fallback
material across repeated sources,
compiler/truncation/config/native diagnostic order, and help/list-rules
no-spawn behavior. The configured real
compiler checks representative valid inputs and a missing-input diagnostic.

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

`parity-strict.sh` is a local gating contract/parity wrapper. It requires an
explicit build compiler and Ari checkout, with an optional explicit reference
lint binary. It builds the standalone implementation, runs both tools from this
repository root, and gates separate exact list-rules snapshots for the
intentional standalone/reference CLI difference. It also isolates native rules
with a no-output fixture compiler plus an explicit empty config. Clean,
trailing-whitespace, missing-final-newline, ordered multi-file, and duplicate
inputs must match checked-in JSON goldens byte-for-byte in both tools. Every
case requires its exact stdout, empty stderr, exit status, and final LF. The
initial config subset selects committed config fixtures to gate explicit
severity, `off` suppression, CLI-last precedence, exact JSON, and one human
result. A separate argv-checking fixture compiler emits one deterministic
diagnostic and exits `7`; both tools must match checked-in combined
compiler/native JSON and human goldens. JSON cases must parse. Every list-rules
case selects a sentinel compiler and fails if that compiler is invoked.

`test.sh` does not download or build the Ari compiler. Its zero-argument mode
does not invoke the compiler or `ari --check`. Its explicit-compiler mode runs
the existing smoke suite, which builds `ari-lint` and exercises source commands;
neither mode executes `tools/lint`, installs dependencies, runs package manager
commands, or runs parity checks. The lightweight CI job uses compiler-free mode;
the separate compiler-smoke job supplies one pinned compiler path explicitly.

`build.sh` does not download or build the Ari compiler. It does not execute
`tools/lint`, run `ari --check`, install dependencies, run package manager
commands, or run parity checks. Compiler-smoke CI reaches it only through
explicit-compiler `scripts/test.sh` and `scripts/smoke.sh`.

`smoke.sh` does not add a strict parity gate, home/global/XDG config search, new
lint semantics, or compatibility claims. The separate checksum-pinned
compiler-smoke workflow runs it through `scripts/test.sh`.
It requires Python 3 only to parse emitted JSON; it installs no dependency.
Every JSON source/listing case must be one valid document with a final LF and
empty stderr. Successful stdout-only commands require empty stderr, and usage
errors require empty stdout. It checks that `--help` names the current supported
option set, checks focused
`--list-rules` and `--json --list-rules` rule-code, short-name, and
default-severity output signals, checks focused
usage-error summaries for malformed `--rule` text and missing `--config` or
`--rule` values, parser-only missing `--ari` values, one unknown option, and
missing source input with and without `--json`,
checks that explicit config and CLI `--rule` `off` suppress diagnostics, and
checks exact reference-shaped runtime JSON and human output for representative
diagnostics. It also covers per-source nearest config discovery, unreadable
nearer-config fallback, discovery suppression by explicit config, CLI-last
precedence, discovered config diagnostics, exact explicit config errors, clean,
mixed, duplicate, 24-file repeated-input, 66 KB clean-source, final-newline,
stderr-isolation, and valid, control-byte, and invalid-UTF-8 path behavior.
Broader strict parity, source-controlled broad compiler goldens, and
dedicated Ari unit tests remain future work.

`parity.sh` does not add CI wiring, a strict parity gate, golden files,
source-controlled parity fixtures, new lint semantics, release compatibility
claims, or copies of `tools/lint`. It fails only for infrastructure errors such
as a missing build compiler, missing Ari repo, missing original lint command,
or local `ari-lint` build failure.

`parity-strict.sh` does not cover unresolved help/usage differences, broader
config discovery/error/precedence contracts, broader compiler output ordering
or resource boundaries, parent-side process failures, or real-compiler
diagnostics. It does not claim full parity or release compatibility and is not
run in CI yet.
