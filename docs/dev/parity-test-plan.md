# ari-lint Parity Test Plan

## Purpose

This document defines how the standalone Ari-language `ari-lint`
implementation should be compared against the bundled/reference `tools/lint`
implementation in `ari-foundry/ari`.

The original parity planning step did not add tests, fixtures, golden files,
source code, or build behavior. The current source-only parity runner skeleton
records boundaries only and still does not execute a parity flow from Ari
source.

A first local non-gating parity smoke/report now exists at `scripts/parity.sh`.
It builds this repository with `scripts/build.sh`, runs both implementations on
usage, list-rules, source read-error, missing compiler path, compiler-error,
config read-error, temporary clean, trailing-whitespace, missing-final-newline,
config, short-name config, disabled explicit config, disabled command-line rule
override, dirty multi-file cases, and `multi-file-mixed`, and prints a concise
report without failing on behavior differences.

A separate gating list-rules and native-rule subset now exists at
`scripts/parity-strict.sh`. List-rules uses separately approved standalone and
reference snapshots. Native cases reuse checked-in source fixtures and isolate
both implementations with a deterministic no-output compiler and explicit
empty config. Stdout must match the case golden, stderr must be empty, exit
status must match the case expectation, and JSON output must retain its final
LF and parse successfully. Every list-rules case also selects a sentinel
compiler and fails if it is invoked.

## Current Status

- `ari-lint` has an initial Ari source implementation with the current
  source-file lint path and two implemented rules.
- The current reference implementation remains `tools/lint` in
  `ari-foundry/ari`.
- The standalone implementation is written in Ari; parity remains the target.
- This plan does not move or copy `tools/lint`.
- Future compiler provisioning for compiler-backed parity inputs is planned in
  `docs/dev/compiler-provisioning.md`. Compiler-backed parity tests do not
  exist yet.
- Compiler invocation selection and the per-source runtime boundary are
  implemented as documented in `docs/dev/compiler-invocation.md`. Strict
  compiler-backed parity tests do not exist yet.
- A source-only parity runner skeleton exists in `src/parity.ari`. It records
  the intended comparison boundary but does not run `tools/lint`, invoke an
  `ari-lint` binary, read fixtures, compare output, invoke the compiler, or run
  in CI.
- `scripts/parity.sh` is local-only and report-only. It is not wired into
  `scripts/test.sh` or CI, does not add source-controlled fixtures or golden
  files, and does not claim parity.
- Known differences from the current report-only smoke are tracked in
  `docs/dev/parity-differences.md`.
- `scripts/parity-strict.sh` is local-only and gating. Its current scope is
  the separately approved standalone/reference list-rules contracts plus native
  clean, trailing-whitespace, missing-final-newline, ordered multi-file, and
  duplicate-input output. It does not cover remaining help/usage CLI, config,
  compiler-boundary, or process-infrastructure differences and is not wired
  into CI.

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

The strict compiler-boundary allowlist has five documented categories:
cross-stream ordering, retained-output capture, retained diagnostic material,
non-interactive stdin, and out-of-range coordinates.
Parent-side process infrastructure errors are unresolved strict-gate cases,
not a sixth allowlist category.

- compiler binary selection through `--ari`
- separated `--ari PATH` reference parity and an explicit CLI-contract decision
  for standalone-only `--ari=PATH`
- an explicit CLI-contract decision for the standalone-only `--` separator
- `ARI_COMPILER` behavior if supported
- include path forwarding through `-I`
- compiler-check failure behavior
- mixed compiler and lint diagnostics
- missing compiler binary behavior
- retained-output boundary, fail-closed truncation diagnostics, and late
  diagnostic loss behavior
- per-file, per-run, and repeated-payload compiler diagnostic budgets
- non-interactive compiler stdin policy
- fault-injected spawn/pipe/read/wait infrastructure-error behavior
- cross-stream ordering and out-of-range coordinate allowlists documented in
  `docs/dev/parity-differences.md`

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

The first strict layout is:

- native source inputs under `tests/fixtures/trailing-whitespace/` and
  `tests/fixtures/missing-final-newline/`
- parity isolation inputs under `tests/fixtures/parity/`
- exact native JSON results under `tests/golden/native/`
- exact standalone and reference registry results under
  `tests/golden/list-rules/`

Remaining fixture categories:

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

The strict native subset stores compact, newline-terminated JSON exactly as
emitted by both implementations. Raw byte comparison fixes field order and
escaping while a separate JSON parse rejects malformed documents.

Human-readable output should only use golden files for stable text.

Absolute paths should be normalized.

Current strict cases use identical repository-relative operands and need no
normalization. A future temporary fixture may replace only its known temporary
root with one fixed token; generic path rewriting is not allowed because it can
hide real path-field differences.

List-rules uses separate exact goldens because the standalone short-name and
JSON registry fields are intentional CLI extensions. The strict runner does not
hide that difference behind a parity allowlist.

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
6. Run a report-only `-h` short-help case and report usage-option,
   stdout/stderr, and exit-code signals.
7. Run a report-only no-source-file usage case and report usage text,
   missing-source-file text, stdout/stderr, and exit-code signals.
8. Run a report-only source read-error case and report source-read text,
   compiler-diagnostic, JSON-shape, path, stdout/stderr, and exit-code signals.
9. Run a report-only missing compiler path case through `--ari` and report
   compiler-check-failed, JSON-shape, source-path, missing-compiler-path,
   stdout/stderr, and exit-code signals.
10. Run a report-only compiler-error case and report compiler-diagnostic,
   expected parser text, JSON-shape, source-path, stdout/stderr, and exit-code
   signals.
11. Run a report-only unknown-option usage case and report usage text,
   unknown-argument text, stdout/stderr, and exit-code signals.
12. Run a report-only missing `--config` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
13. Run a report-only missing `--rule` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
14. Run a report-only missing `--ari` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
15. Run a report-only missing `-I` value case and report usage text,
   missing-option text, stdout/stderr, and exit-code signals.
16. Run a report-only `--list-rules` case and report rule-code,
   default-severity, stdout/stderr, exit-code, and short-name-field signals.
17. Run a report-only `--json --list-rules` case and report rule-code,
   default-severity, stdout/stderr, exit-code, and short-name-field signals.
18. Create tiny temporary trailing-whitespace, missing-final-newline, clean,
   explicit-config, discovered-config, dirty multi-file, and mixed clean/dirty
   multi-file fixtures.
19. Run a report-only invalid `--config` case and report stderr text,
   config-path, config-line, stdout/stderr, and exit-code signals.
20. Run a report-only malformed `--rule` case and report invalid-override,
   invalid-rule-setting, expected-shape, stdout/stderr, and exit-code signals.
21. Run a report-only invalid `--rule` severity case and report
   invalid-override, invalid-rule-setting, unknown-rule-or-severity,
   stdout/stderr, and exit-code signals.
22. Run a report-only unknown `--rule` rule case and report invalid-override,
   invalid-rule-setting, unknown-rule-or-severity, stdout/stderr, and
   exit-code signals.
23. Run current `ari-lint` and original `tools/lint` with `--json --ari` across
   baseline rule, explicit `--config`, short-name config, disabled explicit
   config, disabled command-line `--rule`, command-line `--rule`, include-path
   `-I`, discovered `ari-lint.rules`, dirty multi-file cases, and
   `multi-file-mixed`.
24. Report exit code, stdout/stderr presence, rule sightings, severity
   sightings, file-path hit counts, and line/column presence.

The report intentionally does not require exact text equality or exact JSON
equality yet.

Known current differences are documented in
`docs/dev/parity-differences.md`. That document records report-only differences
without making them gating, stable, or release-compatible behavior.

Future comparison flow:

1. Run current reference `tools/lint` or built `ari-lint` from
   `ari-foundry/ari`.
2. Run standalone Ari-language `ari-lint` on the same fixture.
3. Normalize paths and environment-dependent fields.
4. Compare diagnostics, severities, rule codes, and exit status.
5. Record intentional differences explicitly.

The current strict native flow already performs steps 1 through 4 for its
checked-in subset. Compiler-boundary and unresolved CLI cases remain outside
that gate rather than being silently normalized or allowlisted.

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
- Ari captures child stdout and stderr separately, so exact cross-stream
  interleaving cannot match the reference shared-pipe implementation.
- Include path behavior may differ outside the `ari` monorepo.

## Follow-up Checklist

- [x] Inventory the current `tools/lint` entrypoint from `tools/lint/main.cpp`
      and the Ari repo `Makefile`
- [x] Define the initial native fixture directory layout
- [x] Define the initial compact JSON golden format
- [x] Define the no-rewrite relative-path policy for current strict fixtures
- [x] Define the Ari compiler version pinning policy for the compiler-smoke
      baseline
- [x] Define compiler provisioning policy in
      `docs/dev/compiler-provisioning.md`
- [x] Define and implement compiler invocation policy from
      `docs/dev/compiler-invocation.md`
- [x] Add source-only parity runner skeleton without executing either
      implementation
- [x] Add first local non-gating parity smoke/report with temporary clean,
      trailing-whitespace, and missing-final-newline fixtures
- [x] Expand the local non-gating parity smoke/report with explicit `--config`,
      command-line `--rule`, discovered `ari-lint.rules`, and multi-file cases
- [x] Add a mixed clean/dirty `multi-file-mixed` report-only case to the local
      non-gating parity smoke/report
- [x] Add `--help` report-only CLI signals to the local non-gating parity
      smoke/report
- [x] Add `--list-rules` report-only CLI signals to the local non-gating parity
      smoke/report
- [x] Add JSON list-rules report-only CLI signals to the local non-gating
      parity smoke/report
- [x] Define and gate separate exact standalone/reference list-rules contracts
- [x] Add missing-compiler report-only compiler-boundary signals to the local
      non-gating parity smoke/report
- [x] Add compiler-error report-only compiler-boundary signals to the local
      non-gating parity smoke/report
- [x] Add disabled explicit config report-only signals to the local
      non-gating parity smoke/report
- [x] Add disabled command-line `--rule` report-only signals to the local
      non-gating parity smoke/report
- [x] Add short-name explicit config report-only signals to the local
      non-gating parity smoke/report
- [x] Document known report-only parity differences
- [x] Add first source-controlled positional CLI parity fixtures
- [x] Add first source-controlled rule parity fixture for trailing whitespace
- [x] Add first source-controlled rule parity fixture for missing final newline
- [x] Add exact clean, rule, ordered multi-file, and duplicate JSON goldens
- [x] Add a gating local native parity runner
- [ ] Add compiler-boundary parity fixture
- [ ] Add a parity CI job only after its broader gating contract exists

## Explicit Non-Goals

- Do not move `tools/lint` in this step.
- Do not copy `tools/lint` source in this step.
- Do not add source-controlled test fixtures in this step.
- Do not add golden files in this step.
- Do not add Ari implementation code in this step.
- Do not implement lint rules in this step.
- Do not add CI parity jobs in this step.
- Do not make parity differences fail the local report in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.
