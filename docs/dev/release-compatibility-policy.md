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

## Recorded Compiler Validation Evidence

### Ari v0.1.0 prerelease compiler validation - evidence only

This is a compiler validation evidence record, not a compatibility matrix
entry. It records only that the identified `ari-lint` revision completed the
named tests with the byte-identified Ari artifact in the stated environment.
It does not declare Ari `v0.1.0` supported or compatible, establish a supported
version range, or create a stable `ari-lint` release.

The tested subject was the `ari-lint` source revision
[`73a14027d3259de9b015bf17bc05466bbc42d2a3`](https://github.com/ari-foundry/ari-lint/commit/73a14027d3259de9b015bf17bc05466bbc42d2a3).
It was not an `ari-lint` release artifact. The successful evidence is
[Compiler Smoke run 34889392418, attempt 1](https://github.com/ari-foundry/ari-lint/actions/runs/34889392418),
[job 104127958190](https://github.com/ari-foundry/ari-lint/actions/runs/34889392418/job/104127958190).
GitHub recorded a `push` event on `main`, head SHA
`73a14027d3259de9b015bf17bc05466bbc42d2a3`, run start
`2026-09-14T19:51:10Z`, job start `2026-09-14T19:51:14Z`, job completion
`2026-09-14T19:52:03Z`, and conclusion `success`.

The compiler identity for that run was:

- Ari [release/tag `v0.1.0`](https://github.com/ari-foundry/ari/releases/tag/v0.1.0),
  marked prerelease
- Ari source commit recorded in BUILDINFO:
  [`c615f1c2ce1a93835118b4da8867a7f3dfaf991a`](https://github.com/ari-foundry/ari/commit/c615f1c2ce1a93835118b4da8867a7f3dfaf991a)
- target and asset: `linux-x86_64`,
  `ari-v0.1.0-linux-x86_64.tar.gz`
- archive SHA-256:
  `0af99459eb2ad4ad688ae8ba8e4e3bcce88358bba969f88bff65f5df3ced6da2`
- extracted BUILDINFO SHA-256:
  `6a9eaefbbc6aef083496e7d78749ec5e13ef87175301923ee000e45a9824baa6`

The tested revision's
[`compiler-smoke.yml`](https://github.com/ari-foundry/ari-lint/blob/73a14027d3259de9b015bf17bc05466bbc42d2a3/.github/workflows/compiler-smoke.yml)
downloaded the release asset, verified the archive before extraction, verified
the extracted BUILDINFO bytes, and checked its version, tag, source commit,
target, executable, and standard-library header before running `ari-lint`.
During evidence verification at `2026-09-14T19:53:27Z`, GitHub reported the
Ari release as `prerelease: true` and `immutable: false`, so the two content
hashes are part of this evidence rather than trusting the tag or asset URL
alone.

The observed execution environment was GitHub-hosted Ubuntu `24.04.5`, runner
image `ubuntu-24.04` version `20260907.300.1`, Actions runner `2.337.0`, and
Ubuntu clang `18.1.3 (1ubuntu1)` at `/usr/bin/clang-18`. Locale was
`C.UTF-8`. The hosted image is not hermetic even though the Ari artifact is
byte-identified.

The exact CI entry command was:

```sh
scripts/test.sh "$ARI_COMPILER"
```

The tested revision's
[`scripts/test.sh`](https://github.com/ari-foundry/ari-lint/blob/73a14027d3259de9b015bf17bc05466bbc42d2a3/scripts/test.sh)
ran `scripts/check.sh` and then delegated explicit-compiler mode to
`scripts/smoke.sh`. The smoke built `src/main.ari` with the selected compiler;
source commands then used the direct process boundary
`ARI [-I DIR ...] SOURCE --check`. After checking out the tested revision and
independently provisioning and verifying the same compiler bytes, the local
test entry can be rerun as:

```sh
scripts/test.sh /absolute/path/to/ari
```

Relevant coverage in the cited run included repository guards, standalone
build, help and list-rules no-spawn paths, both native rules present at that
revision, exact human and JSON results, status and stream selection, config
discovery and overrides, multi-file ordering and duplicate operands, compiler
selection and argv forwarding, compiler diagnostic parsing and failure
normalization, and bounded compiler-output behavior. The run exercised a real
Ari compiler for build and representative source checks, and controlled fake
compilers for deterministic process-boundary cases.

Known limitations of this evidence are:

- one prerelease Ari artifact, target, hosted OS image, and LLVM driver were
  exercised
- the tested `ari-lint` subject was a source revision, not a released artifact
- no Ari version range or stable `ari-lint` release was tested or declared
- the hosted runner image can change even though the Ari archive and BUILDINFO
  bytes were fixed
- the cited Compiler Smoke job did not execute `tools/lint` or either parity
  runner, so it records no bundled-reference parity result

Any later compatibility matrix entry must be a separate, deliberate decision
that cites this or newer evidence and states its own scope and limitations.

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
