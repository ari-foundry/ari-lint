# lint/trailing-whitespace

## Purpose

This document defines the current in-memory behavior and remaining planned
behavior for `lint/trailing-whitespace`.

## Current Status

- The rule is implemented in the Ari-language standalone path.
- The current reference behavior is the bundled `tools/lint` implementation in
  `ari-foundry/ari`.
- This repository currently has metadata/module layout and a minimal internal
  single-line helper in `src/rules/trailing_whitespace.ari`.
- The helper only checks whether one already-split byte line ends with a space
  or tab.
- Internal diagnostic mapping has started for one already-split line. The
  mapping records whether the helper found trailing whitespace, the planned
  diagnostic span, and default `warning` severity in an internal
  diagnostic-like data value.
- In-memory rule execution now scans caller-provided source text, splits it on
  newline bytes, and returns internal `Diagnostic` values for lines with
  trailing spaces or tabs.
- Explicit-file reading, config severity overrides, CLI integration, and
  reference-shaped human/JSON diagnostics are implemented. An initial strict
  native parity case exists; dedicated Ari rule tests, broader fixtures, and
  broader strict parity remain future work. The
  main-facing CLI now combines this rule with compiler diagnostics.
- Fixture and test planning is tracked in
  [docs/rules/trailing-whitespace-fixtures.md](trailing-whitespace-fixtures.md);
  initial clean and trailing-spaces fixtures are started, while full fixture
  coverage and behavior tests remain future work.

## Rule Identity

- Canonical rule code: `lint/trailing-whitespace`.
- Short name: `trailing-whitespace`.
- Default severity: `warning`, confirmed from the current Ari lint docs and
  reference rule registry.

## Planned Detection

The rule detects spaces or tabs at the end of a caller-provided source line.

The newline itself should not be flagged. Empty lines that contain only spaces
or tabs should be handled as trailing-whitespace diagnostics. A final line
should be checked whether or not the file ends with a trailing newline.

The current reference implementation removes a final carriage return from each
line before checking for trailing spaces or tabs, so CRLF line endings should
not be flagged solely because of the carriage return. Future parity fixtures
should confirm this behavior before the Ari-language implementation treats it as
stable. Standalone CRLF fixture coverage remains needs follow-up.

The current in-memory implementation splits caller-provided source text on
newline bytes and checks each logical line. The single-line helper ignores a
final carriage return before checking the last content byte.

## Planned Diagnostic Location

The emitted diagnostic includes:

- file path
- line number for the source line containing trailing whitespace
- column where the trailing whitespace begins
- end column at the logical line end
- rule code `lint/trailing-whitespace`
- configured severity
- message text

The current reference implementation reports the column as the first trailing
space or tab and `endColumn` as one past the logical line end after CRLF
normalization.

The Ari-language implementation maps each matching line to an internal span
using the explicit file path and computed line number. The CLI emits that span
in the reference human and JSON forms and applies configured severity. Recursive
file scanning and broader strict parity tests remain future work.

## Planned Message

The current reference implementation reports:

```text
trailing whitespace
```

The in-memory Ari-language implementation uses this message for internal
diagnostics.

## Parity Expectations

Remaining parity work should continue comparing behavior against the current
bundled `tools/lint` implementation.

The rule-specific parity plan is documented in
[docs/rules/trailing-whitespace-parity.md](trailing-whitespace-parity.md).
A broad local parity smoke/report exists in `scripts/parity.sh`, and the initial
native rule case is gated by `scripts/parity-strict.sh`; broader rule-specific
parity remains future work.

Parity dimensions:

- which lines are flagged
- diagnostic line/column
- rule code
- severity
- human-readable output
- reference-shaped JSON output
- exit behavior

## Fixture Coverage

Initial fixture coverage includes:

- `tests/fixtures/trailing-whitespace/clean.ari`
- `tests/fixtures/trailing-whitespace/trailing-spaces.ari`

Compiler-free checks validate fixture shape, and compiler-backed smoke runs
representative temporary equivalents through `ari-lint` with exact output.
The initial source-controlled comparison against `tools/lint` is gated locally;
broader fixture comparison remains future work.

Remaining future fixture ideas:

- trailing tabs
- whitespace-only line
- mixed spaces and tabs
- final line without newline
- CRLF or carriage return behavior

The detailed future fixture and test plan is documented in
[docs/rules/trailing-whitespace-fixtures.md](trailing-whitespace-fixtures.md).
Compiler-backed CLI smoke covers representative behavior and exact output;
dedicated Ari rule tests, broader source-controlled goldens, and broader strict
parity remain future work.

## Original Implementation-Step Non-Goals

- Do not read files in this step.
- Do not scan the filesystem in this step.
- Do not produce CLI, human-readable, or JSON diagnostics in this step.
- Do not add full CLI, parity, golden, or diagnostic tests in this step.
- Do not add JSON serialization in this step.
- Do not invoke `ari --check` in this step.
- Do not copy `tools/lint` source in this step.
