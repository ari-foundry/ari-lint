# Ari Compiler Provisioning Plan

## Purpose

This document defines how local `ari-lint` build, source-command, smoke, and CI
checks receive an Ari compiler binary.

The pinned CI baseline described here is validation evidence only. It does not
establish an Ari compatibility entry or a stable `ari-lint` release.

## Current Status

- `scripts/check.sh` does not run the Ari compiler.
- `scripts/test.sh` runs the compiler-free lightweight checks with no argument.
  With one explicit, non-empty compiler path it runs those checks and then the
  compiler-backed executable smoke. `ARI_COMPILER` alone does not opt it in.
- `scripts/build.sh` and `scripts/smoke.sh` accept a caller-provided Ari
  compiler for local build and executable validation.
- Standalone source commands invoke the selected compiler once per source with
  `--check`.
- `.github/workflows/check.yml` remains deterministically compiler-free and
  runs zero-argument `scripts/test.sh`.
- `.github/workflows/compiler-smoke.yml` provisions the pinned Ari `v0.1.0`
  Linux x86-64 artifact, verifies its archive and BUILDINFO identities, and runs
  explicit-compiler `scripts/test.sh`.
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

The lightweight `check.yml` workflow does not download or invoke the compiler.
The separate `compiler-smoke.yml` workflow runs on `ubuntu-24.04` with
read-only repository permissions, no credential persistence, no cache, and the
LLVM driver fixed to `/usr/bin/clang-18`.

The compiler baseline is:

- release/tag: `v0.1.0` (prerelease)
- release URL:
  `https://github.com/ari-foundry/ari/releases/tag/v0.1.0`
- source commit: `c615f1c2ce1a93835118b4da8867a7f3dfaf991a`
- target: `linux-x86_64`
- asset: `ari-v0.1.0-linux-x86_64.tar.gz`
- asset SHA-256:
  `0af99459eb2ad4ad688ae8ba8e4e3bcce88358bba969f88bff65f5df3ced6da2`
- extracted `BUILDINFO` SHA-256:
  `6a9eaefbbc6aef083496e7d78749ec5e13ef87175301923ee000e45a9824baa6`
- checkout action: `actions/checkout@v4.4.0`, pinned to
  `11d5960a326750d5838078e36cf38b85af677262`

The release is currently marked `immutable: false` by GitHub. The workflow
therefore trusts neither the tag name nor download URL alone: it verifies the
archive before extraction, verifies the exact extracted BUILDINFO bytes, and
then checks the recorded version, tag, commit, and target fields. Any asset
replacement, identity drift, missing standard library, or missing executable
fails before `ari-lint` runs.

The Ari artifact is byte-pinned, but the GitHub-hosted Ubuntu image is not. CI
fixes the LLVM driver to the installed `clang-18` path and records its version
in the job log; image or driver patch updates may still change this smoke
environment. That is another reason this job is validation evidence rather
than a hermetic compatibility result.

After provisioning, CI records the selected path through `GITHUB_ENV` and calls
`scripts/test.sh "$ARI_COMPILER"`. The positional argument is the explicit
opt-in; ambient environment state cannot activate the compiler-backed mode.
The workflow downloads no package-manager dependencies, builds no compiler,
and does not execute the bundled `tools/lint` or local parity runners.

## Release And Compatibility Policy

`ari-lint` has no stable compatibility matrix yet.

Do not claim compatibility with Ari releases until tested.

Compatibility entries must reference real Ari release tags or commits.

The pinned job passing is a prerequisite for any later compatibility entry, but
is not sufficient by itself. Compatibility still requires a deliberate matrix
entry with the tested `ari-lint` revision, coverage, and known limitations.

## Test Runner Integration

Pure helper and repository-shape checks should not require the Ari compiler.

`scripts/test.sh` is the canonical orchestrator. Its zero-argument mode is
deterministically compiler-free and ignores `ARI_COMPILER`. Its one-argument
mode runs `scripts/check.sh` first and then passes the caller-provided path to
`scripts/smoke.sh`. It downloads nothing and keeps parity outside the default
test command.

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
- [x] Decide compiler version/commit recording format
- [x] Select and pin the first CI compiler artifact
- [x] Keep the lightweight GitHub Actions workflow compiler-free
- [x] Add local compiler-backed executable smoke coverage
- [x] Add an explicit compiler-backed mode to the standalone test entrypoint
- [x] Add a separate compiler-backed smoke workflow with identity verification
- [ ] Add a compatibility matrix entry only after its remaining requirements
      are deliberately approved

## Non-Goals

- Do not add compiler execution to the lightweight workflow.
- Do not download or build a compiler in `scripts/test.sh` itself.
- Do not build Ari from source in CI.
- Do not execute `tools/lint` or strict/reference parity in compiler-smoke CI.
- Do not treat one passing prerelease baseline as a compatibility matrix.
- Do not add release automation or support claims in this step.
- Do not modify `ari-foundry/ari` or `ari-foundry.github.io` from this
  repository.
