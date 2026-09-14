# trailing-whitespace Fixture Plan

## Purpose

This document plans future fixtures and tests for
`lint/trailing-whitespace`.

The first fixtures, exact native JSON goldens, executable CLI smoke, and strict
local native parity case exist. Broader fixture/golden coverage, dedicated rule
tests, and parity CI remain future work.

## Current Status

- The current reference behavior remains `tools/lint` in `ari-foundry/ari`.
- `ari-lint` has in-memory and explicit-file execution for trailing whitespace.
- Diagnostic production, CLI/config behavior, and reference-shaped human/JSON
  output are wired for explicit files.
- Recursive source scanning, broad fixtures and goldens, and broader strict
  parity remain future work.
- The first minimal fixture files now exist:
  `tests/fixtures/trailing-whitespace/clean.ari` and
  `tests/fixtures/trailing-whitespace/trailing-spaces.ari`.
- The lightweight workflow check verifies fixture presence and whether the
  clean fixture avoids trailing blanks while the trailing-spaces fixture keeps
  an intentional trailing space.
- `scripts/smoke.sh` exercises representative trailing-whitespace behavior.
- Additional fixture cases remain future work.

## Started Fixture Coverage

Step 11.18.4 starts minimal fixture coverage with:

- `tests/fixtures/trailing-whitespace/clean.ari`
- `tests/fixtures/trailing-whitespace/trailing-spaces.ari`

`clean.ari` uses a small valid Ari `fn main() -> i64` snippet with no trailing
spaces.

`trailing-spaces.ari` uses the same small Ari shape and intentionally keeps one
trailing space on the first line.

The current lightweight check does not compile the fixtures, run `ari-lint`,
invoke `ari --check`, compare diagnostics, or execute the helper directly.

## Planned Fixture Layout

Fixture paths use a dedicated trailing-whitespace area:

```text
tests/fixtures/trailing-whitespace/clean.ari
tests/fixtures/trailing-whitespace/trailing-spaces.ari
```

Remaining future fixture paths may include:

```text
tests/fixtures/trailing-whitespace/trailing-tabs.ari
tests/fixtures/trailing-whitespace/whitespace-only-line.ari
tests/fixtures/trailing-whitespace/mixed-spaces-tabs.ari
tests/fixtures/trailing-whitespace/final-line-no-newline.ari
tests/fixtures/trailing-whitespace/crlf-behavior.ari
```

`crlf-behavior.ari` should be added only if CRLF behavior is intentionally
tested and the fixture encoding policy is clear.

## Planned Cases

Future cases should cover:

- clean source with no trailing whitespace; started with `clean.ari`
- source lines ending in spaces; started with `trailing-spaces.ari`
- source lines ending in tabs
- lines containing only whitespace before the newline
- mixed spaces and tabs at the end of a line
- final line without a trailing newline
- CRLF behavior, after fixture encoding and expected diagnostics are defined

## Expected Result Strategy

Expected results should record the fields needed to compare with the current
reference implementation:

- whether a diagnostic is expected
- line number
- column where trailing whitespace starts
- end column at the logical line end
- rule code
- severity
- message text

The current reference confirms rule code `lint/trailing-whitespace`, default
severity `warning`, and message text `trailing whitespace`.

The current reference reports the column as the first trailing space or tab and
`endColumn` as one past the logical line end after CRLF normalization.

Representative exact runtime JSON is covered by executable smoke. Broader
source-controlled fixture encoding, path normalization, and golden-file
coverage remain needs follow-up.

## Parity Strategy

Future trailing-whitespace tests should compare the Ari-language implementation
with the current bundled/reference `tools/lint` implementation in
`ari-foundry/ari`.

The rule-specific parity plan is documented in
[docs/rules/trailing-whitespace-parity.md](trailing-whitespace-parity.md).
Fixture comparison has broad report-only coverage through `scripts/parity.sh`
and an initial source-controlled strict native case through
`scripts/parity-strict.sh`. Broader strict fixture parity remains future work.

Parity dimensions should include:

- which lines are flagged
- line, column, and end column
- rule code
- configured severity
- message text
- human-readable diagnostics
- JSON diagnostics under the documented source-result contract
- exit behavior

## Golden Output Policy

Exact native JSON goldens now cover the initial fixture subset under
`tests/golden/native/`. Broader goldens should follow the documented
source-result contract and the current no-rewrite relative-path policy.

Human-readable golden files should be limited to stable text. Volatile paths,
compiler-dependent diagnostics, and environment-dependent values should be
normalized or excluded.

Golden files should identify the Ari compiler version or commit when that
affects expected output.

## Test Runner Notes

`scripts/parity-strict.sh` is the gating local runner for the checked-in native
subset, while `scripts/parity.sh` remains report-only for broader signals.
Future cases should preserve explicit tool paths and normalize only genuinely
environment-dependent output.

CI parity jobs should be added only after source implementation, fixture files,
and a standalone test runner exist.

## Original Planning-Step Non-Goals

- Do not add source implementation in this step.
- Do not add a broad fixture set in this step.
- Do not add CLI tests in this step.
- Do not add parity tests in this step.
- Do not add golden files in this step.
- Do not add test runner behavior in this step.
- Do not copy or move `tools/lint` in this step.
- Do not invoke `ari --check` in this step.
- Do not add release workflow or compatibility claims in this step.
