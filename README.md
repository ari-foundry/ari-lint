# ari-lint

`ari-lint` is lint tooling for the Ari language.

This repository is the active standalone split implementation of `ari-lint`.
It now carries Ari-language source, local build and smoke scripts, lint rule
metadata, config handling, diagnostic output wiring, and focused development
documentation for the split.

The near-term dependency model invokes an external Ari compiler with `--check`
once for every explicit source file. Compiler behavior remains owned by the Ari
compiler project. The current `tools/lint` implementation in
`ari-foundry/ari` remains the reference implementation for now.

The long-term implementation direction is to develop `ari-lint` in Ari when
the language and toolchain are ready.

## References

- Ari compiler/language project: https://github.com/ari-foundry/ari
- Ari releases: https://github.com/ari-foundry/ari/releases
- Ari tags: https://github.com/ari-foundry/ari/tags
- Ari Foundry portal: https://ari-foundry.github.io

## Current Scope

This repository owns `ari-lint` tooling, lint rule source, CLI behavior,
diagnostic behavior, configuration behavior, local validation scripts, focused
developer documentation, and future release notes.

Contributors should use `ari-foundry/ari` docs, examples, and tests as the
source of truth for current Ari language usage.

Future `ari-lint` compatibility policy should be based on real Ari releases and
tags. Do not claim compatibility with any Ari version unless it is verified from
an actual Ari release or tag.

Do not treat the current implementation as a stable release. No install
command, package registry entry, release artifact, or compatibility guarantee
is available from this repository yet. Do not add unverified Ari code examples
here.

## Current Capabilities

- Local build via `scripts/build.sh` with an explicit Ari compiler path or
  `ARI_COMPILER`.
- Local smoke validation via `scripts/smoke.sh` with an explicit Ari compiler
  path or `ARI_COMPILER`.
- Local parity smoke/report via `scripts/parity.sh` with an explicit Ari
  compiler path or `ARI_COMPILER`, plus an Ari repository path or `ARI_REPO`.
- CLI `--help` output.
- CLI `--list-rules` output.
- Exact human and JSON list-rules contracts with deterministic registry order,
  short names, default severities, descriptions, and final newlines.
- Compiler selection for source commands from explicit `--ari PATH` /
  `--ari=PATH`, then a present `ARI_COMPILER` environment entry, then the
  literal default `build/ari`.
- `-I DIR` / `-IDIR` parsing and direct, shell-free compiler execution once per
  positional source file with argv `-I DIR ... FILE --check`.
- Compiler diagnostic parsing from captured output, with the compiler status
  retained as each JSON file result's `exitCode`. Launch failures use
  `exitCode` `127` and a per-file `ari/compiler-check-failed` diagnostic when
  no other diagnostic explains the failure.
- Source-file lint for all explicitly provided positional source files, using
  the currently implemented rules:
  `lint/trailing-whitespace` and `lint/missing-final-newline`.
- Reference-shaped `--json` source results with one ordered `files` entry per
  positional input, including clean and duplicate inputs. JSON preserves valid
  UTF-8 and renders invalid input bytes as escaped replacement characters.
- Human source results on stdout as `PATH: ok` or
  `PATH:LINE:COLUMN: SEVERITY: [CODE] MESSAGE`; enabled diagnostics exit `1`.
- Explicit config file loading with `--config`.
- Discovered `ari-lint.rules` config when `--config` is absent, searching from
  each source file's directory upward and using the nearest readable file.
- `--rule` severity overrides. Explicit `--config` disables discovery, and CLI
  `--rule` settings are applied after the selected config settings.

## Current Limitations

- `tools/lint` in `ari-foundry/ari` remains the reference implementation for
  now.
- This repository has no stable `ari-lint` release yet.
- No Ari version compatibility claim is established yet.
- A strict native-rule parity gate covers checked-in clean,
  trailing-whitespace, missing-final-newline, ordered multi-file, and duplicate
  inputs. Remaining help/usage CLI, config, compiler-boundary, and broad golden
  parity remain open; the wider local parity smoke/report is still report-only.
- CI is not compiler-backed yet.
- Child stderr and stdout are captured separately and parsed in deterministic
  stderr-then-stdout order. This can differ from the reference implementation's
  cross-stream write order; see
  [docs/dev/compiler-invocation.md](docs/dev/compiler-invocation.md).
- Compiler stdout and stderr are drained concurrently, with at most 256 KiB
  retained from each stream. Excess output is discarded without blocking the
  child; every truncated run adds an `ari/compiler-output-truncated` error so
  lost diagnostics cannot produce a silent success. The per-file `exitCode`
  still preserves the compiler's actual status.
- Parsed compiler diagnostics are limited to 2,048 per file, 4,096 per run,
  and, together with raw compiler-failure fallback text, 1 MiB of repeated
  file/code/message payload per run. Exceeding a budget omits later material,
  adds `ari/compiler-diagnostics-truncated`, and fails closed.
- The implemented rule set is limited.
- Directory traversal and recursive source-tree scanning are not implemented;
  pass source files explicitly.
- Home, global, XDG, and environment-provided config locations are not part of
  the current config behavior.

## Local Checks

Run the lightweight repository-shape check with:

```sh
scripts/check.sh
```

Run the local standalone test entrypoint with:

```sh
scripts/test.sh
```

This is not a full test suite yet. The standalone test entrypoint delegates to
the lightweight check script, which checks repository-shape, source, script,
documentation, and fixture invariants only. Use `scripts/smoke.sh` for local
compiler-backed build and CLI smoke validation.

## Local Build Scaffold

Build the current Ari-language entrypoint locally with an explicit Ari compiler path:

```sh
scripts/build.sh /path/to/ari
```

You may also set `ARI_COMPILER`; a positional compiler path takes precedence if
both are provided. The build script resolves the repository root, uses the
compiler root when `lib/std.arih` is available there, writes `build/ari-lint`,
does not download or build the Ari compiler, and does not run `tools/lint`. It
preserves relative compiler paths from the caller's directory.

This selects the compiler used to build `ari-lint`. When the resulting binary
checks source files, its runtime compiler selection independently follows
`--ari`, then `ARI_COMPILER`, then `build/ari`. Help and rule-listing commands
do not execute the runtime compiler.

CI does not run compiler-backed builds or tests yet, and this repository is not
a standalone release.

## Local Parity Smoke/Report

Run the first local report-only parity smoke against the bundled reference
implementation in an `ari-foundry/ari` checkout with:

```sh
scripts/parity.sh /path/to/ari /path/to/ari-repo
```

You may also set `ARI_COMPILER` and `ARI_REPO`. A third positional argument or
`ORIGINAL_LINT` can point at an already-built original lint binary. When that
path is not provided, the script verifies the Ari repo `Makefile` lint target
and `tools/lint/main.cpp`, then uses the existing `build/ari-lint` binary if it
is executable.

The parity smoke builds this repository with `scripts/build.sh`, reports
`--help`, `-h`, no-source-file usage, source read-error behavior, missing
compiler path behavior passed through `--ari`, compiler-error behavior,
unknown-option usage, missing config value usage, missing rule value usage,
missing Ari value usage, missing include value usage, malformed `--rule` usage,
invalid `--rule` severity usage, unknown `--rule` rule usage, and
`--list-rules` and JSON list-rules comparison signals, then creates tiny
temporary trailing-whitespace, missing-final-newline, clean, config, dirty
multi-file, and mixed clean/dirty multi-file fixtures, runs both tools with
`--json --ari`, and prints stdout/stderr presence, exit codes, basic rule
sightings, severity sightings, file-path hit counts, and line/column presence.
It includes report-only coverage for `--help`,
`-h`, no source file, missing source read errors, an unknown option, missing
compiler path behavior passed through `--ari`, compiler-error behavior,
missing `--config` value, missing `--rule` value, missing `--ari` value, missing `-I`
value, `--list-rules`, `--json --list-rules`, explicit `--config`, invalid
`--config`, missing config file read errors, malformed `--rule`, invalid
`--rule` severity, unknown `--rule` rule, short rule names in explicit config,
disabled rules from explicit config and CLI `--rule`, severity-changing CLI
`--rule`, include-path `-I`, discovered `ari-lint.rules`, dirty multi-file
invocations, and mixed clean/dirty multi-file invocations.
Differences are reported but do not fail the script. The script fails only for
infrastructure errors such as a missing compiler, missing Ari repo, missing
original lint command, or local build failure.

Known differences from the current report-only parity smoke are tracked in
[docs/dev/parity-differences.md](docs/dev/parity-differences.md). That document
does not establish stable parity or release compatibility.

Run the strict checked-in list-rules and native-rule subsets with an explicit
build compiler and Ari checkout:

```sh
scripts/parity-strict.sh /path/to/ari /path/to/ari-repo
```

An optional third argument selects an already-built reference `ari-lint`.
This gate checks separate exact standalone/reference list-rules contracts. For
native rules it uses identical relative operands, a deterministic no-output
runtime compiler, and an explicit empty config, then requires byte-identical
JSON. Every case checks its approved golden, stdout/stderr selection, exit
status, final LF, and JSON syntax where applicable. The list-rules cases also
use a sentinel to prove that neither implementation invokes the selected Ari
compiler. Passing these subsets is not a full parity or Ari release
compatibility claim.

## Local Smoke Validation

Run the local build plus minimal CLI smoke checks with an explicit Ari compiler
path:

```sh
scripts/smoke.sh /path/to/ari
```

You may also set `ARI_COMPILER`:

```sh
ARI_COMPILER=/path/to/ari scripts/smoke.sh
```

The smoke script delegates build behavior to `scripts/build.sh` and makes the
selected compiler available to source-command runtime checks. After the build
succeeds, it runs these current safe CLI invocations:

```sh
./build/ari-lint --help
./build/ari-lint --list-rules
./build/ari-lint --json --list-rules
./build/ari-lint --json --config /tmp/.../explicit.rules /tmp/.../trailing.ari
./build/ari-lint --json --config /tmp/.../explicit.rules --rule trailing-whitespace=note /tmp/.../trailing.ari
./build/ari-lint --rule trailing-whitespace /tmp/.../trailing.ari
./build/ari-lint --config
./build/ari-lint --rule
./build/ari-lint --ari
./build/ari-lint --definitely-unknown
./build/ari-lint --json /tmp/.../trailing.ari
./build/ari-lint --json /tmp/.../one.ari /tmp/.../two.ari
```

These checks verify that the local binary builds, that the supported smoke
commands execute, that `--help` names the current supported option set, and that
`--list-rules` and `--json --list-rules` include the current rule-code,
short-name, and default-severity signals. They do not add a strict parity gate,
compiler-backed CI, home/global/XDG config search, new lint semantics, or
compatibility claims. The config smoke uses explicit temporary files and
temporary source trees containing `ari-lint.rules`. It checks per-source nearest
readable discovery, different configs in one multi-file run, unreadable-nearer
fallback, explicit `--config` discovery suppression, and CLI-last precedence.
It also checks ordered per-file `lint/config` diagnostics on stdout with exit
`1` for bad discovered lines, and exact stderr with exit `2` for explicit config
read or parse errors. Short rule names are covered, and `off` suppression is
checked for explicit config and CLI `--rule`. A focused usage-error smoke checks
malformed `--rule` text, missing `--config`, `--rule`, or parser-only `--ari`
values, and one unknown option only for the current short stderr summary.
Focused diagnostic smoke checks assert the runtime `files`, `path`, `exitCode`,
`diagnostics`, `file`, position, `severity`, `message`, `source`, and `code`
fields for `lint/trailing-whitespace` and `lint/missing-final-newline`. Exact
checks cover representative JSON and human output, including final newlines.
Source invocations also exercise the compiler-backed `--check` boundary. The
smoke covers dirty multi-file, clean/dirty, all-clean, duplicate-argument, and
escaped path cases. Dedicated Ari tests, broader source-controlled goldens,
broader strict parity, compiler-backed CI, and broad compiler-diagnostic
goldens remain future work.
