# ari-lint Parity Test Plan

## Purpose

This document defines how the future Ari-language implementation of `ari-lint`
should be compared against the current bundled/reference `tools/lint`
implementation in `ari-foundry/ari`.

The original parity planning step did not add tests, fixtures, golden files,
source code, or build behavior. The current source-only parity runner skeleton
records boundaries only and still does not execute a parity flow from Ari
source.

A first local non-gating parity smoke/report now exists at `scripts/parity.sh`.
It builds this repository with `scripts/build.sh`, runs both implementations on
usage, list-rules, temporary clean, trailing-whitespace, missing-final-newline,
config, and multi-file cases, and prints a concise report without failing on
behavior differences.

## Current Status

- `ari-lint` has an initial Ari source implementation with the current
  source-file lint path and two implemented rules.
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
- `scripts/parity.sh` is local-only and report-only. It is not wired into
  `scripts/test.sh` or CI, does not add source-controlled fixtures or golden
  files, and does not claim parity.
- Known differences from the current report-only smoke are tracked in
  `docs/dev/parity-differences.md`.

## Reference Implementation

`tools/lint` in `ari-foundry/ari` is the reference for current behavior.

It should be used to compare CLI behavior, rule behavior, config behavior,
diagnostics, JSON output, and exit behavior.

It remains owned by `ari-foundry/ari` during transition.

The current original lint entrypoint was located by inspecting
`ari-foundry/ari`: `tools/lint/main.cpp` contains the `ari-lint` CLI entrypoint
and usage string, and the Ari repo `Makefile` defines `LINT_TARGET` as
`build/ari-lint` built from `tools/lint/*.cpp` plus shared tooling helpers.
`scripts/parity.sh` verifies those files before using an existing executable
`build/ari-lint` or an explicitly provided `ORIGINAL_LINT` path.

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

Current local report-only flow in `scripts/parity.sh`:

1. Validate the explicit Ari compiler path from the first argument or
   `ARI_COMPILER`.
2. Validate the Ari repo path from the second argument or `ARI_REPO`.
3. Verify the original lint entrypoint from the Ari repo `Makefile` and
   `tools/lint/main.cpp`.
4. Build this repository's current `ari-lint` with `scripts/build.sh`.
5. Run a report-only `--help` case and report usage-option, stdout/stderr, and
   exit-code signals.
6. Run a report-only no-source-file usage case and report usage text,
   missing-source-file text, stdout/stderr, and exit-code signals.
7. Run a report-only unknown-option usage case and report usage text,
   unknown-argument text, stdout/stderr, and exit-code signals.
8. Run a report-only missing `--config` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
9. Run a report-only missing `--rule` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
10. Run a report-only missing `--ari` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
11. Run a report-only `--list-rules` case and report rule-code,
   default-severity, stdout/stderr, exit-code, and short-name-field signals.
12. Run a report-only `--json --list-rules` case and report rule-code,
   default-severity, stdout/stderr, exit-code, and short-name-field signals.
13. Create tiny temporary trailing-whitespace, missing-final-newline, clean,
   explicit-config, discovered-config, and multi-file fixtures.
14. Run a report-only invalid `--config` case and report stderr text,
   config-path, config-line, stdout/stderr, and exit-code signals.
15. Run a report-only malformed `--rule` case and report invalid-override,
   invalid-rule-setting, expected-shape, stdout/stderr, and exit-code signals.
16. Run a report-only invalid `--rule` severity case and report
   invalid-override, invalid-rule-setting, unknown-rule-or-severity,
   stdout/stderr, and exit-code signals.
17. Run a report-only unknown `--rule` rule case and report invalid-override,
   invalid-rule-setting, unknown-rule-or-severity, stdout/stderr, and
   exit-code signals.
18. Run current `ari-lint` and original `tools/lint` with `--json --ari` across
   baseline rule, explicit `--config`, command-line `--rule`, discovered
   `ari-lint.rules`, and multi-file cases.
19. Report exit code, stdout/stderr presence, rule sightings, severity
   sightings, file-path hit counts, and line/column presence.

The report intentionally does not require exact text equality or exact JSON
equality yet.

Known current differences are documented in
`docs/dev/parity-differences.md`. That document records report-only differences
without making them gating, stable, or release-compatible behavior.

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

- [x] Inventory the current `tools/lint` entrypoint from `tools/lint/main.cpp`
      and the Ari repo `Makefile`
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
- [x] Add first local non-gating parity smoke/report with temporary clean,
      trailing-whitespace, and missing-final-newline fixtures
- [x] Expand the local non-gating parity smoke/report with explicit `--config`,
      command-line `--rule`, discovered `ari-lint.rules`, and multi-file cases
- [x] Add `--help` report-only CLI signals to the local non-gating parity
      smoke/report
- [x] Add `--list-rules` report-only CLI signals to the local non-gating parity
      smoke/report
- [x] Add JSON list-rules report-only CLI signals to the local non-gating
      parity smoke/report
- [x] Document known report-only parity differences
- [ ] Add first source-controlled CLI smoke parity fixture
- [ ] Add first source-controlled rule parity fixture for trailing whitespace
- [ ] Add first source-controlled rule parity fixture for missing final newline
- [ ] Add compiler-boundary parity fixture
- [ ] Add CI job only after test runner exists

## Explicit Non-Goals

- Do not move `tools/lint` in this step.
- Do not copy `tools/lint` source in this step.
- Do not add source-controlled test fixtures in this step.
- Do not add golden files in this step.
- Do not add Ari implementation code in this step.
- Do not implement lint rules in this step.
- Do not add direct `ari --check` invocation in this repository in this step.
- Do not add CI parity jobs in this step.
- Do not make parity differences fail the local report in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.
