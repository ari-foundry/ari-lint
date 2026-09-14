# ari-lint Release And Compatibility Policy

## Purpose

This document defines the initial `ari-lint` release and compatibility policy.

It does not create an `ari-lint` release, add a release workflow, add a
compatibility matrix, or claim support for any Ari version. A separately pinned
compiler-smoke CI baseline supplies build/test evidence under this policy.

## Read-only Ari Sources

Compatibility work must use real Ari release and tag sources as read-only
references:

- https://github.com/ari-foundry/ari/releases
- https://github.com/ari-foundry/ari/tags

Useful local checks:

```sh
gh release list -R ari-foundry/ari
git ls-remote --tags https://github.com/ari-foundry/ari.git
```

These commands are reference checks only. Do not copy compiler sources or infer
`ari-lint` support from the existence of an Ari release or tag. CI artifact use
must follow the pinned identity checks in `docs/dev/compiler-provisioning.md`.

## Current Policy

`ari-lint` has no stable release yet.

No Ari compatibility claims are established yet.

Do not claim compatibility with an Ari release, tag, or commit until
compiler-backed `ari-lint` tests pass against that exact Ari source and the
compiler identity is recorded.

Do not invent version numbers. Do not add a compatibility matrix entry without
test evidence.

The lightweight `check.yml` workflow remains compiler-free. The separate
`compiler-smoke.yml` workflow byte-verifies the exact Ari `v0.1.0` prerelease
archive and BUILDINFO, then checks the recorded source commit and target before
running `scripts/test.sh "$ARI_COMPILER"`. It does not build Ari, execute
`tools/lint`, run parity, use a package manager, or publish artifacts.

This single pinned baseline is continuous validation evidence, not an Ari
compatibility matrix entry. GitHub reports the release as `immutable: false`,
so both the archive and extracted BUILDINFO SHA-256 values are mandatory.

## Future Compatibility Entry Requirements

A future compatibility entry should include:

- the Ari release tag or commit that was tested
- the `ari-lint` revision or release artifact that was tested
- the exact compiler provisioning method
- the exact compiler invocation path
- the standalone test command
- the relevant parity or rule test coverage
- any known limitations or intentional differences

Compatibility entries should link to the validation evidence instead of relying
on hand-written assertions.

## Release Workflow Requirements

A future `ari-lint` release workflow should wait until:

- the Ari-language source builds through explicit local compiler provisioning
- standalone tests exist beyond lightweight repository-shape checks
- compiler-backed tests record the Ari compiler identity
- output and JSON schema behavior is stable enough to document
- release artifacts and install instructions are intentionally scoped

Until those conditions are met, release notes should describe the repository as
pre-release split work, not a stable standalone tool.

## Non-goals

- Do not add release automation in this step.
- Do not add compatibility matrix claims in this step.
- Do not claim support for any Ari release, tag, or commit in this step.
- Do not build the Ari compiler in CI.
- Do not add compiler execution to the lightweight workflow.
- Do not treat compiler-smoke success as a release-support declaration.
- Do not run reference parity or `tools/lint` in compiler-smoke CI.
- Do not modify `ari-foundry/ari`.
- Do not modify `ari-foundry/ari-foundry.github.io`.
