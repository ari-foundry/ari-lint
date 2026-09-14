# Ari Compiler Provisioning Plan

## Purpose

This document defines how local `ari-lint` build, source-command, smoke, and
future CI checks receive an Ari compiler binary.

This document does not add compiler downloads, compiler builds, or CI
provisioning. Local callers provide the compiler explicitly or through the
documented runtime selection boundary.

## Current Status

- `scripts/check.sh` does not run the Ari compiler.
- `scripts/test.sh` delegates to the same compiler-free lightweight checks.
- `scripts/build.sh` and `scripts/smoke.sh` accept a caller-provided Ari
  compiler for local build and executable validation.
- Standalone source commands invoke the selected compiler once per source with
  `--check`.
- The GitHub Actions workflow is intentionally compiler-free and runs only the
  lightweight check until explicit compiler provisioning, standalone tests, and
  compiler identity recording are ready.
- Current `tools/lint` in `ari-foundry/ari` remains the reference
  implementation.

## Compiler Source Of Truth

Ari compiler ownership remains `ari-foundry/ari`.

Compiler, standard library, parser, sema, module, and toolchain bugs belong in
`ari-foundry/ari`.

`ari-lint` should not fork or vendor the compiler.

`ari-lint` should not copy `tools/lint` source.

## Local Compiler Selection

Standalone source commands select the runtime compiler in this order:

1. explicit `--ari PATH` or `--ari=PATH`
2. a present `ARI_COMPILER` environment entry, including an empty value
3. the literal path `build/ari`

`scripts/build.sh` has a separate build-time selection boundary: its positional
compiler argument wins over its `ARI_COMPILER` fallback. It validates that path
before using it to build `src/main.ari`.

Tests should avoid guessing compiler paths.

Tests should not depend on undocumented monorepo-relative paths.

Local real-compiler checks should use an explicit compiler path. Focused
process-boundary tests may provide controlled fake executables. The implemented
selection, invocation, status, and diagnostic contract is documented in
`docs/dev/compiler-invocation.md`; this behavior does not by itself establish
compatibility with an Ari release.

## CI Compiler Strategy

Do not download or build the compiler in the current lightweight check.

The current GitHub Actions workflow must not run `scripts/build.sh`, invoke the
Ari compiler, invoke `ari --check`, execute `tools/lint`, install package
manager dependencies, or claim compatibility. It preserves a compiler-free CI
gate while pinned compiler provisioning and identity recording remain future
work.

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

Pure helper and repository-shape checks should not require the Ari compiler.

The local executable smoke accepts an explicit real compiler path and uses
controlled fake executables for focused process-boundary behavior.

Parity and compatibility tests using a real compiler should record its
identity.

Fixture shape checks should remain compiler-free.

JSON golden tests should wait until the schema is stable.

## Failure Modes

Compiler provisioning and compiler-boundary tests should account for:

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

- [x] Confirm documented `--ari` behavior
- [x] Support `ARI_COMPILER` for runtime compiler selection
- [x] Define and implement precedence between `--ari` and `ARI_COMPILER`
- [ ] Decide compiler version/commit recording format
- [ ] Decide future CI compiler source
- [x] Keep current GitHub Actions workflow compiler-free until explicit
      compiler provisioning and standalone tests exist
- [x] Add local compiler-backed executable smoke coverage
- [ ] Update compatibility docs only after tests pass

## Non-Goals

- Do not download the compiler in this step.
- Do not build the compiler in this step.
- Do not add compiler execution to CI in this step.
- Do not add `ari --check` invocation to the lightweight check or CI in this
  step.
- Do not add `tools/lint` execution to CI in this step.
- Do not add a strict parity gate in this step.
- Do not add compatibility claims in this step.
- Do not modify ari-foundry/ari in this step.
- Do not modify ari-foundry.github.io in this step.
