# ari-lint Parity Test Plan

## Purpose

This document defines how the future Ari-language implementation of `ari-lint`
should be compared against the current bundled/reference `tools/lint`
implementation in `ari-foundry/ari`.

The original parity planning step did not add tests, fixtures, golden files,
source code, or build behavior. The current source-only parity runner skeleton
records boundaries only and still does not execute a parity flow.

## Current Status

- `ari-lint` has an initial Ari source skeleton.
- Real lint rules are not implemented yet.
- The current reference implementation remains `tools/lint` in
  `ari-foundry/ari`.
- The future implementation direction is Ari-language reimplementation with
  behavior parity.
- This plan does not move or copy `tools/lint`.
- Future compiler provisioning for compiler-backed parity inputs is planned in
  `docs/dev/compiler-provisioning.md`. Compiler-backed parity tests do not
  exist yet.
- Future compiler invocation selection is planned in
  `docs/dev/compiler-invocation.md`. Compiler-backed parity tests that require
  invocation do not exist yet.
- A source-only parity runner skeleton exists in `src/parity.ari`. It records
  the intended comparison boundary but does not run `tools/lint`, invoke an
  `ari-lint` binary, read fixtures, compare output, invoke the compiler, or run
  in CI.

## Reference Implementation

`tools/lint` in `ari-foundry/ari` is the reference for current behavior.

It should be used to compare CLI behavior, rule behavior, config behavior,
diagnostics, JSON output, and exit behavior.

It remains owned by `ari-foundry/ari` during transition.

Bugs in compiler behavior or standard library behavior should be filed in
`ari-foundry/ari`.

## Parity Dimensions

### CLI parity

- positional file input behavior
- `--json`
- `--ari`
- `-I`
- `--list-rules`
- `--config`
- `--rule`
- invalid argument behavior
- help/usage behavior if supported

### Rule parity

- `lint/trailing-whitespace`
- planned `lint/trailing-whitespace` behavior is documented in
  `docs/rules/trailing-whitespace.md`; future parity fixtures should compare
  that design against the current reference behavior
- future trailing-whitespace fixture strategy is documented in
  `docs/rules/trailing-whitespace-fixtures.md`; initial clean/trailing-spaces
  fixtures exist, but parity tests and an executable parity runner are not
  added yet
- rule-specific trailing-whitespace parity planning is documented in
  `docs/rules/trailing-whitespace-parity.md`
- `lint/missing-final-newline`
- planned `lint/missing-final-newline` behavior is documented in
  `docs/rules/missing-final-newline.md`; future parity fixtures should compare
  that design against the current reference behavior, but missing-final-newline
  parity tests are not added yet
- rule-specific missing-final-newline parity planning is documented in
  `docs/rules/missing-final-newline-parity.md`; no executable parity runner
  exists yet
- short rule names if supported
- default severity behavior
- disabled-rule behavior

### Config parity

- `ari-lint.rules` discovery
- `--config PATH`
- `RULE = SEVERITY` parsing
- comments and blank lines if supported
- command-line `--rule` override behavior

### Diagnostic parity

- human-readable diagnostics
- `--json` diagnostics
- line/column positions
- endLine/endColumn behavior if supported
- rule codes
- severity names
- path normalization

### Compiler-boundary parity

- compiler binary selection through `--ari`
- `ARI_COMPILER` behavior if supported
- include path forwarding through `-I`
- compiler-check failure behavior
- mixed compiler and lint diagnostics
- missing compiler binary behavior

### Exit-status parity

- success
- lint-only diagnostics
- compiler-backed diagnostics
- invalid CLI usage
- invalid config
- missing compiler binary

If any behavior is unclear, mark it as:

needs follow-up

## Fixture Categories

Future fixture categories, without adding fixtures in this step:

- valid Ari source
- trailing whitespace, including future parity cases for spaces, tabs,
  whitespace-only lines, final lines without newlines, and CRLF behavior; see
  `docs/rules/trailing-whitespace-fixtures.md` and
  `docs/rules/trailing-whitespace-parity.md`
- missing final newline
- missing final newline future parity cases for files with final newlines,
  files without final newlines, empty files, single-line files, multi-line
  files, CRLF behavior, and lone carriage return behavior; see
  `docs/rules/missing-final-newline.md` and
  `docs/rules/missing-final-newline-fixtures.md` and
  `docs/rules/missing-final-newline-parity.md`; missing-final-newline parity
  runner execution and parity tests are not added yet
- compiler error
- config file override
- command-line rule override
- include path fixture
- JSON diagnostics fixture
- mixed compiler/lint diagnostics fixture

## Golden Output Policy

JSON diagnostics should use golden files once schema is stable.

Human-readable output should only use golden files for stable text.

Absolute paths should be normalized.

Compiler diagnostics may need separate golden files from lint diagnostics.

Golden files must identify the Ari compiler version or commit when relevant.

## Comparison Strategy

Future comparison flow:

1. Run current reference `tools/lint` or built `ari-lint` from
   `ari-foundry/ari`.
2. Run future Ari-language `ari-lint` implementation on the same fixture.
3. Normalize paths and environment-dependent fields.
4. Compare diagnostics, severities, rule codes, and exit status.
5. Record intentional differences explicitly.

Exact command lines should be added only when the standalone build and test
runner exist.

The current source-only parity runner skeleton does not perform this flow.

Parity tests that use compiler-backed behavior must record the Ari compiler
identity, such as version, release tag, or commit, according to
`docs/dev/compiler-provisioning.md`.

Parity tests requiring compiler-backed behavior must use explicit compiler
provisioning and invocation according to `docs/dev/compiler-provisioning.md`
and `docs/dev/compiler-invocation.md`.

## Issue Routing

Lint behavior mismatch belongs in `ari-lint` if the Ari implementation
disagrees with the reference implementation.

`ari-lint` issues are for lint behavior, parity, docs, tests, config,
diagnostics, rules, and Ari implementation.

Compiler parser/sema/module bugs belong in `ari-foundry/ari`.

Standard library bugs belong in `ari-foundry/ari`.

Ari language/toolchain limitations belong in `ari-foundry/ari`.

Cross-boundary bugs should have root cause filed in the owning repo and linked
from the other repo if needed.

## Risks

- Reference behavior may change in `ari-foundry/ari` before parity tests are
  implemented.
- JSON diagnostic schema may still be unstable.
- Compiler diagnostics may depend on Ari compiler version.
- Exact human-readable output may be too unstable for golden tests.
- Process invocation from Ari may require runtime/toolchain support.
- Include path behavior may differ outside the `ari` monorepo.

## Follow-up Checklist

- [ ] Inventory exact reference commands for current `tools/lint`
- [ ] Define fixture directory layout
- [ ] Define golden JSON format
- [ ] Define path normalization policy
- [ ] Define Ari compiler version pinning policy
- [ ] Define compiler provisioning policy from
      `docs/dev/compiler-provisioning.md`
- [ ] Define compiler invocation policy from
      `docs/dev/compiler-invocation.md`
- [x] Add source-only parity runner skeleton without executing either
      implementation
- [ ] Add first CLI smoke parity fixture
- [ ] Add first rule parity fixture for trailing whitespace
- [ ] Add first rule parity fixture for missing final newline
- [ ] Add compiler-boundary parity fixture
- [ ] Add CI job only after test runner exists

## Explicit Non-Goals

- Do not move `tools/lint` in this step.
- Do not copy `tools/lint` source in this step.
- Do not add test fixtures in this step.
- Do not add golden files in this step.
- Do not add Ari implementation code in this step.
- Do not implement lint rules in this step.
- Do not invoke `ari --check` in this step.
- Do not add CI parity jobs in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.
