# Ari Compiler Provisioning Plan

## Purpose

This document defines how future `ari-lint` tests and compiler-boundary
behavior should receive an Ari compiler binary.

This step does not download, build, run, or validate the compiler.

## Current Status

- `ari-lint` currently has lightweight repository checks only.
- `scripts/check.sh` does not run the Ari compiler.
- Compiler-backed behavior is future work.
- The near-term dependency model remains invoking `ari --check` when compiler
  integration begins.
- Current `tools/lint` in `ari-foundry/ari` remains the reference
  implementation.

## Compiler Source Of Truth

Ari compiler ownership remains `ari-foundry/ari`.

Compiler, standard library, parser, sema, module, and toolchain bugs belong in
`ari-foundry/ari`.

`ari-lint` should not fork or vendor the compiler.

`ari-lint` should not copy `tools/lint` source.

## Local Compiler Selection

Future local compiler selection should prefer explicit `--ari PATH` for CLI use
when available.

`ARI_COMPILER` should be allowed only if it is documented by the standalone CLI
contract or implemented later. The current bundled/reference implementation
documents `ARI_COMPILER` as a fallback when `--ari` is not provided, but
standalone behavior still needs tests and documentation before it becomes an
`ari-lint` compatibility promise.

Tests should avoid guessing compiler paths.

Tests should not depend on undocumented monorepo-relative paths.

If both `--ari` and `ARI_COMPILER` exist later, precedence must be documented
before implementation.

needs follow-up

The future invocation contract for `--ari PATH`, `ARI_COMPILER`, precedence,
and validation is planned in `docs/dev/compiler-invocation.md`. Invocation is
planned but not implemented.

## CI Compiler Strategy

Do not download or build the compiler in the current lightweight check.

Future compiler-backed CI may use a pinned Ari release artifact or a pinned
source commit.

Any future source build should be explicit and isolated.

CI must record the compiler version, release tag, or commit.

CI should fail clearly when the compiler is missing or incompatible.

## Release And Compatibility Policy

`ari-lint` has no stable compatibility matrix yet.

Do not claim compatibility with Ari releases until tested.

Compatibility entries must reference real Ari release tags or commits.

Compatibility should be updated only after compiler-backed tests pass.

## Test Runner Integration

Pure helper checks should not require the Ari compiler.

Compiler-boundary tests should require an explicit compiler path.

Parity tests should record the compiler identity.

Fixture shape checks should remain compiler-free.

JSON golden tests should wait until the schema is stable.

## Failure Modes

Future compiler provisioning and compiler-boundary tests should account for:

- missing compiler path
- non-executable compiler path
- incompatible compiler version
- compiler returns diagnostics outside expected schema
- compiler crashes
- compiler output changes between releases
- stdlib or module path mismatch

## Issue Routing

Compiler bugs go to `ari-foundry/ari`.

Standard library bugs go to `ari-foundry/ari`.

Ari language/toolchain limitations go to `ari-foundry/ari`.

`ari-lint` issues should track lint behavior, config, diagnostics, CLI, docs,
tests, and Ari-language implementation.

Cross-boundary issues should link both repos if needed.

## Follow-up Checklist

- [ ] Confirm documented `--ari` behavior
- [ ] Confirm whether `ARI_COMPILER` is supported
- [ ] Define precedence between `--ari` and `ARI_COMPILER`
- [ ] Decide compiler version/commit recording format
- [ ] Decide future CI compiler source
- [ ] Add compiler-backed smoke test only after runner exists
- [ ] Update compatibility docs only after tests pass

## Non-Goals

- Do not download the compiler in this step.
- Do not build the compiler in this step.
- Do not run the compiler in this step.
- Do not invoke `ari --check` in this step.
- Do not run tools/lint in this step.
- Do not add a parity runner in this step.
- Do not add compatibility claims in this step.
- Do not modify ari-foundry/ari in this step.
- Do not modify ari-foundry.github.io in this step.
