# missing-final-newline Parity Plan

## Purpose

This document defines how future `lint/missing-final-newline` behavior should
be compared against the current bundled/reference `tools/lint` behavior in
`ari-foundry/ari`.

This step does not add a runner, execute `tools/lint`, add fixtures, or add
golden output.

## Current Status

- A minimal missing-final-newline helper exists.
- An internal diagnostic mapping skeleton exists.
- Initial final-newline/no-final-newline fixtures exist.
- Full rule execution is not complete.
- No parity runner exists yet.
- `tools/lint` in `ari-foundry/ari` remains the reference implementation.

## Reference Command Strategy

Future parity should use the current `tools/lint` command or Ari bundled lint
command as the reference once the command is confirmed.

Exact reference command: needs follow-up.

Future parity should avoid undocumented local monorepo paths. It should record
the Ari compiler/tooling version or commit used for each comparison.

## Comparison Inputs

Planned comparison inputs:

- with-final-newline fixture
- missing-final-newline fixture
- future empty fixture
- future single-line-no-newline fixture
- future multi-line-no-newline fixture
- future CRLF fixture if behavior is confirmed
- future lone-CR fixture if behavior is confirmed

No new fixture files are added in this step.

## Comparison Outputs

Outputs to compare:

- whether a diagnostic is emitted
- final line number if supported
- final column if supported
- end line/end column if supported
- rule code
- severity
- message if confirmed
- human-readable output once stable: needs follow-up
- JSON output once schema is stable: needs follow-up
- exit status: needs follow-up

The current reference implementation confirms the native rule code
`lint/missing-final-newline`, default severity `warning`, message text
`missing final newline`, source value `ari-lint`, and end column one column
after the reported final column. Standalone parity output shape, exact command
strategy, and command-level exit policy still need follow-up before this
repository treats them as stable comparison data.

## Normalization Policy

Paths should be normalized before comparison.

Environment-specific fields should be ignored or normalized.

Compiler/tooling version should be recorded.

JSON comparison should wait until schema is stable.

Human-readable output comparison should wait until message text is stable.

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

This runner is not added in this step.

## Issue Routing

Lint behavior mismatch belongs in `ari-lint` if the Ari implementation differs
from the reference.

Compiler/parser/sema/module bugs belong in `ari-foundry/ari`.

Standard library bugs belong in `ari-foundry/ari`.

Ari toolchain limitations belong in `ari-foundry/ari`.

Cross-boundary bugs should link the owning issue.

## Non-Goals

- Do not add a parity runner in this step.
- Do not execute tools/lint in this step.
- Do not add fixtures in this step.
- Do not add golden output in this step.
- Do not add CLI tests in this step.
- Do not invoke ari --check in this step.
- Do not copy tools/lint source in this step.
