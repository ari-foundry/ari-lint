# Ari Compiler Invocation Plan

## Purpose

This document defines the future invocation contract for selecting an Ari
compiler binary for `ari-lint` compiler-backed behavior.

This step does not implement CLI parsing, environment-variable handling,
compiler execution, or `ari --check`.

## Current Status

- Compiler provisioning is documented but not implemented.
- `scripts/check.sh` does not run the compiler.
- `--ari PATH` and `ARI_COMPILER` are future invocation concepts in this
  repository unless they are implemented later.
- Compiler-backed behavior is future work.
- Current `tools/lint` in `ari-foundry/ari` remains the reference
  implementation.

## Invocation Sources

Future compiler invocation may use these sources:

- explicit `--ari PATH`
- `ARI_COMPILER` environment variable

Future standalone `ari-lint` should not use:

- implicit monorepo-relative defaults
- network download fallback
- package-manager fallback

## Precedence

The current bundled/reference implementation in `ari-foundry/ari` uses
`ARI_COMPILER` only when `--ari PATH` is not provided, so future standalone
behavior should prefer `--ari PATH` over `ARI_COMPILER` if that remains the
confirmed contract.

Standalone precedence tests and compatibility policy do not exist yet.

needs follow-up

Do not invent final behavior if future Ari reference behavior changes or is not
confirmed by docs, source, and tests.

## Validation Rules

Future compiler path validation should check that:

- path must exist
- path must be executable
- path should identify an Ari compiler binary
- version/tag/commit should be recorded when available
- invalid path should produce a clear error
- missing compiler should not silently fall back to unrelated binaries

These are planned rules, not implemented in this step.

## Failure Behavior

Future compiler invocation should define behavior for:

- missing `--ari` path
- non-existent path
- non-executable path
- compiler invocation failure
- compiler returns unsupported output
- compiler crashes
- incompatible compiler version

Exact diagnostic wording or exit status:

needs follow-up

## Test Runner Integration

Fixture-shape checks remain compiler-free.

Helper-level tests should remain compiler-free.

Future compiler-boundary tests must require explicit compiler provisioning.

A future parity runner must record compiler identity.

JSON golden tests should wait until the schema is stable.

## Security And Reproducibility

Do not execute arbitrary compiler paths implicitly.

Do not download compiler binaries automatically in lightweight checks.

CI must pin compiler source by release tag or commit when compiler-backed tests
are added.

Logs should record compiler identity without leaking secrets.

## Issue Routing

Compiler bugs go to `ari-foundry/ari`.

Standard library bugs go to `ari-foundry/ari`.

Ari language/toolchain limitations go to `ari-foundry/ari`.

`ari-lint` issues should track lint behavior, config, diagnostics, CLI, docs,
tests, and Ari-language implementation.

Cross-boundary issues should link both repos if needed.

## Follow-up Checklist

- [ ] Confirm current `--ari` behavior from ari reference implementation
- [ ] Confirm whether `ARI_COMPILER` is supported
- [ ] Decide precedence between `--ari` and `ARI_COMPILER`
- [ ] Define missing/non-executable compiler diagnostics
- [ ] Define compiler identity recording format
- [ ] Add CLI metadata update only after behavior is confirmed
- [ ] Add implementation only after tests are planned

## Non-Goals

- Do not implement `--ari` parsing in this step.
- Do not implement `ARI_COMPILER` handling in this step.
- Do not run the compiler in this step.
- Do not invoke `ari --check` in this step.
- Do not add compiler download or build automation in this step.
- Do not run tools/lint in this step.
- Do not add parity runner behavior in this step.
- Do not add compatibility claims in this step.
