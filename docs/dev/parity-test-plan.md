# ari-lint Parity Test Plan

## Purpose

This document defines how the future Ari-language implementation of `ari-lint`
should be compared against the current bundled/reference `tools/lint`
implementation in `ari-foundry/ari`.

This step does not add tests, fixtures, golden files, source code, or build
behavior.

## Current Status

- `ari-lint` has an initial Ari source skeleton.
- Real lint rules are not implemented yet.
- The current reference implementation remains `tools/lint` in
  `ari-foundry/ari`.
- The future implementation direction is Ari-language reimplementation with
  behavior parity.
- This plan does not move or copy `tools/lint`.

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
- `lint/missing-final-newline`
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
  whitespace-only lines, final lines without newlines, and CRLF behavior
- missing final newline
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
