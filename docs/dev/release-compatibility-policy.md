# ari-lint Release And Compatibility Policy

## Purpose

This document defines the initial `ari-lint` release and compatibility policy.

It records policy only. It does not create an `ari-lint` release, add a
release workflow, add a compatibility matrix, run compiler-backed tests, or
claim support for any Ari version.

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

These commands are reference checks only. Do not copy release artifacts,
download compilers automatically, or infer `ari-lint` support from the
existence of an Ari release or tag.

## Current Policy

`ari-lint` has no stable release yet.

No Ari compatibility claims are established yet.

Do not claim compatibility with an Ari release, tag, or commit until
compiler-backed `ari-lint` tests pass against that exact Ari source and the
compiler identity is recorded.

Do not invent version numbers. Do not add a compatibility matrix entry without
test evidence.

The current lightweight workflow remains compiler-free. It must not run the
Ari compiler, invoke `ari --check`, download or build the compiler, execute
`tools/lint`, run package manager commands, or publish release artifacts.

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
- Do not download or build the Ari compiler automatically.
- Do not run the Ari compiler in CI.
- Do not invoke `ari --check` in CI.
- Do not modify `ari-foundry/ari`.
- Do not modify `ari-foundry/ari-foundry.github.io`.
