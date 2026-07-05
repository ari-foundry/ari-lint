# ari-lint Known Parity Differences

## Purpose

This note records known differences between the current standalone `ari-lint`
implementation and the bundled/reference `tools/lint` implementation in
`ari-foundry/ari`.

The differences here come from the local report-only `scripts/parity.sh` smoke
and surrounding split documentation. They are not a stable compatibility
matrix, not a parity claim, and not a release policy.

## Current Report Scope

The local parity report currently compares temporary clean,
trailing-whitespace, missing-final-newline, explicit-config, rule-override,
discovered-config, and multi-file cases.

It reports signals only:

- exit code
- stdout and stderr presence
- rule sightings
- severity sightings
- file-path hit counts
- line and column presence

Differences are non-gating. The report fails only for infrastructure problems
such as a missing compiler, missing Ari checkout, missing original lint command,
or local build failure.

## Known Differences

### Compiler Check Boundary

Original `tools/lint` invokes `ari --check` before running native lint rules.
The current standalone Ari-language `ari-lint` implementation does not invoke
`ari --check` yet.

Classification: expected known difference and `ari-lint`
implementation/design follow-up.

Impact:

- compiler diagnostics are not parity-covered by the current standalone path
- missing compiler behavior is not aligned yet
- include-path and compiler-boundary behavior remains future parity work

Follow-up:

- keep using `ari-foundry/ari` as the compiler behavior owner
- add compiler invocation only after the documented provisioning and invocation
  policy is ready
- do not hide compiler, standard library, or toolchain bugs in `ari-lint`

### JSON Diagnostic Shape

Current standalone `ari-lint` emits source-file diagnostics as a flat JSON
array with fields such as `filePath` and `ruleCode`.

Original `tools/lint` emits a top-level `files` array with per-file `path`,
`exitCode`, and `diagnostics` entries. Individual diagnostics use fields such
as `file`, `source`, and `code`.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic schema follow-up.

Impact:

- exact JSON equality is not expected yet
- clean-file JSON output shape differs because original `tools/lint` still
  reports a per-file entry while current standalone `ari-lint` can emit an
  empty diagnostic array
- golden JSON files should wait until the schema and path-normalization policy
  are defined

Follow-up:

- define the standalone JSON schema before strict parity fixtures
- decide whether compatibility requires preserving the original shape or
  documenting a new stable standalone shape

### Diagnostic Exit Status

For lint diagnostics, the current standalone `ari-lint` path currently reports
exit code `2` in the local parity smoke, while original `tools/lint` reports
exit code `1`. Both report success for clean inputs in the current smoke.

Classification: original `tools/lint` behavior difference and `ari-lint`
implementation/design follow-up.

Impact:

- exact exit-code parity is not established
- scripts should not treat the local parity report as a strict exit-code gate
- release compatibility claims must not be made from the current report

Follow-up:

- decide the standalone lint diagnostic exit-code contract before releases
- add strict exit-code parity only after the contract is documented

## Current Alignment Signals

The current local report shows useful matching signals for the smoke-sized
cases: both implementations report the expected lint rule names, severity names,
line/column presence, and dirty file paths for the covered rule/config/multi-file
cases.

These are smoke signals only. They do not replace source-controlled fixtures,
golden output, compiler-backed parity, or CI parity jobs.

## Non-Goals

- Do not move, delete, or modify `ari-foundry/ari` `tools/lint`.
- Do not copy `tools/lint` source into this repository.
- Do not add a strict parity gate in this step.
- Do not add golden files or broad parity suites in this step.
- Do not add compiler-backed CI in this step.
- Do not claim stable parity, release compatibility, or full replacement.

## Issue Routing

`ari-lint` issues are for lint tooling behavior, parity, diagnostics, config,
rules, tests, docs, and the Ari-language implementation.

Compiler, standard library, and Ari toolchain bugs belong in
`ari-foundry/ari`.

No Ari language/compiler/stdlib/toolchain bug is identified by this known
differences note.
