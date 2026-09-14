# trailing-whitespace Parity Plan

## Purpose

This document defines how future `lint/trailing-whitespace` behavior should be
compared against the current bundled/reference `tools/lint` behavior in
`ari-foundry/ari`.

This step adds only the local report-only `scripts/parity.sh` smoke. It does
not add source-controlled fixtures, golden output, CI parity jobs, or a strict
parity gate.

## Current Status

- A minimal trailing-whitespace helper exists.
- An internal diagnostic mapping skeleton exists.
- Initial clean/trailing-spaces fixtures exist.
- Native explicit-file rule execution and representative output smoke are
  complete; dedicated rule tests and strict parity remain open.
- A first local non-gating parity smoke/report exists in `scripts/parity.sh`.
- `tools/lint` in `ari-foundry/ari` remains the reference implementation.

## Reference Command Strategy

Future parity should use the current `tools/lint` command or Ari bundled lint
command as the reference once the command is confirmed.

The first local report verifies the Ari repo `Makefile` lint target and
`tools/lint/main.cpp`, then uses an existing executable `build/ari-lint` or an
explicit `ORIGINAL_LINT` path. Exact source-controlled parity command policy
still needs follow-up.

Future parity should avoid undocumented local monorepo paths. It should record
the Ari compiler/tooling version or commit used for each comparison.

## Comparison Inputs

Planned comparison inputs:

- clean fixture
- trailing-spaces fixture
- future trailing-tabs fixture
- future whitespace-only-line fixture
- future mixed-spaces-tabs fixture
- future final-line-no-newline fixture
- future CRLF fixture if behavior is confirmed

No new fixture files are added in this step.

## Comparison Outputs

Outputs to compare:

- whether a diagnostic is emitted
- line number
- column where trailing whitespace begins
- end column if supported
- rule code
- severity
- message if confirmed
- human-readable output
- JSON output
- exit status

The current reference implementation confirms the native rule code
`lint/trailing-whitespace`, default severity `warning`, message text
`trailing whitespace`, source value `ari-lint`, and diagnostic span fields for
the checked source line. Standalone native output shape and diagnostic exit
policy now match the reference; source-controlled strict comparison remains
future work.

## Normalization Policy

Paths should be normalized before comparison.

Environment-specific fields should be ignored or normalized.

Compiler/tooling version should be recorded.

JSON and human-readable output should be compared exactly after normalizing
environment-specific path prefixes.

## Intentional Differences

Any intentional difference from `tools/lint` must be documented.

Intentional differences require a design note update.

Breaking parity should not be silent.

## Future Runner Shape

Future runner shape:

1. prepare fixture path
2. run reference `tools/lint` behavior
3. run Ari-language `ari-lint` behavior
4. normalize output
5. compare diagnostic fields
6. report mismatch

The local `scripts/parity.sh` report implements only a first smoke-sized
version of this shape. Strict comparison, golden output, and CI gating are not
added in this step.

## Issue Routing

Lint behavior mismatch belongs in `ari-lint` if the Ari implementation differs
from the reference.

Compiler/parser/sema/module bugs belong in `ari-foundry/ari`.

Standard library bugs belong in `ari-foundry/ari`.

Ari toolchain limitations belong in `ari-foundry/ari`.

Cross-boundary bugs should link the owning issue.

## Non-Goals

- Do not add a strict parity gate in this step.
- Do not add source-controlled fixtures in this step.
- Do not add golden output in this step.
- Do not add CLI tests in this step.
- Do not add direct `ari --check` invocation in this repository in this step.
- Do not copy tools/lint source in this step.
