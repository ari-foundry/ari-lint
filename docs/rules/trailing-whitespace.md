# lint/trailing-whitespace

## Purpose

This document defines the planned behavior for `lint/trailing-whitespace`.

This step does not implement the rule. It records the design target for a
future Ari-language implementation.

## Current Status

- The rule is planned for the Ari-language implementation.
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
- The mapping does not construct full string-bearing diagnostics yet. Rule code
  `lint/trailing-whitespace` and message `trailing whitespace` are confirmed
  from the current reference implementation, but final value construction for
  those `String` fields remains needs follow-up.
- Full rule execution is not complete.
- File scanning, diagnostics, config integration, CLI integration, JSON output,
  and tests remain future work.
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

The future rule should detect spaces or tabs at the end of a source line.

The newline itself should not be flagged. Empty lines that contain only spaces
or tabs should be handled as trailing-whitespace diagnostics. A final line
should be checked whether or not the file ends with a trailing newline.

The current reference implementation removes a final carriage return from each
line before checking for trailing spaces or tabs, so CRLF line endings should
not be flagged solely because of the carriage return. Future parity fixtures
should confirm this behavior before the Ari-language implementation treats it as
stable. Standalone CRLF fixture coverage remains needs follow-up.

The current helper is limited to a single borrowed `Slice[u8]` line. It ignores
a final carriage return before checking the last content byte, but it does not
split source text into lines or compute a diagnostic span.

## Planned Diagnostic Location

The future diagnostic should include:

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

The current Ari-language skeleton maps a single helper result to an internal
span using the explicit file path and line number passed to the mapping
function. Full diagnostics output is not implemented. JSON serialization is not
implemented. CLI integration, file scanning, config integration, and parity
tests remain future work.

## Planned Message

The current reference implementation reports:

```text
trailing whitespace
```

The future Ari-language implementation should use this message for behavior
parity unless the reference implementation changes before the rule is
implemented.

## Parity Expectations

The future implementation should compare behavior against the current bundled
`tools/lint` implementation.

Parity dimensions:

- which lines are flagged
- diagnostic line/column
- rule code
- severity
- human-readable output
- JSON output shape, once schema is stable; exact JSON output details remain
  needs follow-up
- exit behavior

## Fixture Coverage

Initial fixture coverage includes:

- `tests/fixtures/trailing-whitespace/clean.ari`
- `tests/fixtures/trailing-whitespace/trailing-spaces.ari`

These fixtures are checked only for fixture shape. They are not compiled, run
through `ari-lint`, compared against `tools/lint`, or connected to diagnostic
goldens yet.

Remaining future fixture ideas:

- trailing tabs
- whitespace-only line
- mixed spaces and tabs
- final line without newline
- CRLF or carriage return behavior

The detailed future fixture and test plan is documented in
[docs/rules/trailing-whitespace-fixtures.md](trailing-whitespace-fixtures.md).
Full trailing-whitespace behavior tests, golden files, CLI tests, parity tests,
and test runner behavior are not added yet.

## Non-Goals

- Do not implement full trailing-whitespace rule execution in this step.
- Do not scan source text in this step.
- Do not produce CLI, human-readable, or JSON diagnostics in this step.
- Do not add full CLI, parity, golden, or diagnostic tests in this step.
- Do not add JSON serialization in this step.
- Do not invoke `ari --check` in this step.
- Do not copy `tools/lint` source in this step.
