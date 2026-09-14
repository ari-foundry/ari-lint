# missing-final-newline Parity Plan

## Purpose

This document defines how `lint/missing-final-newline` behavior is compared
against the current bundled/reference `tools/lint` behavior in
`ari-foundry/ari`.

The original planning step added only the report-only `scripts/parity.sh`
smoke. An initial source-controlled strict native case and golden now exist;
broader strict coverage and parity CI remain follow-up work.

## Current Status

- A minimal missing-final-newline helper exists.
- An internal diagnostic mapping skeleton exists.
- Initial final-newline/no-final-newline fixtures exist.
- Native explicit-file rule execution and representative output smoke are
  complete; the initial native case is gated by `scripts/parity-strict.sh`,
  while dedicated rule tests and broader strict parity remain open.
- A broader local non-gating parity smoke/report exists in `scripts/parity.sh`.
- `tools/lint` in `ari-foundry/ari` remains the reference implementation.

## Reference Command Strategy

Parity uses the current `tools/lint` command or Ari bundled lint command as the
reference.

The first local report verifies the Ari repo `Makefile` lint target and
`tools/lint/main.cpp`, then uses an existing executable `build/ari-lint` or an
explicit `ORIGINAL_LINT` path. Exact source-controlled parity command policy is
implemented for the current strict subset; broader cases still need follow-up.

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

The first two fixtures are checked in; the remaining entries are future paths.

## Comparison Outputs

Outputs to compare:

- whether a diagnostic is emitted
- final line number if supported
- final column if supported
- end line/end column if supported
- rule code
- severity
- message if confirmed
- human-readable output
- JSON output
- exit status

The current reference implementation confirms the native rule code
`lint/missing-final-newline`, default severity `warning`, message text
`missing final newline`, source value `ari-lint`, and end column one column
after the reported final column. Standalone native output shape and diagnostic
exit policy now match the reference; source-controlled strict comparison is
gated for the initial native case, while broader comparison remains future work.

## Normalization Policy

Current strict fixtures preserve the caller-provided relative path without
rewrite.

Environment-specific fields in future cases should be ignored or normalized.

Compiler/tooling version should be recorded.

Current strict JSON and human-readable output is compared exactly without
normalization. Any future normalization should be scoped to environment-specific
path prefixes.

## Intentional Differences

Any intentional difference from `tools/lint` must be documented.

Intentional differences require a design note update.

Breaking parity should not be silent.

## Runner Shape

The comparison shape is:

1. prepare fixture path
2. run reference `tools/lint` behavior
3. run Ari-language `ari-lint` behavior
4. normalize output
5. compare diagnostic fields
6. report mismatch

The local `scripts/parity.sh` report implements a broad non-gating version.
`scripts/parity-strict.sh` implements the checked-in native subset with exact
goldens; broader strict comparison and parity CI are not added yet.

## Issue Routing

Lint behavior mismatch belongs in `ari-lint` if the Ari implementation differs
from the reference.

Compiler/parser/sema/module bugs belong in `ari-foundry/ari`.

Standard library bugs belong in `ari-foundry/ari`.

Ari toolchain limitations belong in `ari-foundry/ari`.

Cross-boundary bugs should link the owning issue.

## Original Planning-Step Non-Goals

- Do not add a strict parity gate in this step.
- Do not add source-controlled fixtures in this step.
- Do not add golden output in this step.
- Do not add CLI tests in this step.
- Do not add direct `ari --check` invocation in this repository in this step.
- Do not copy tools/lint source in this step.
