# lint/trailing-whitespace

## Purpose

This document defines the planned behavior for `lint/trailing-whitespace`.

This step does not implement the rule. It records the design target for a
future Ari-language implementation.

## Current Status

- The rule is planned for the Ari-language implementation.
- The current reference behavior is the bundled `tools/lint` implementation in
  `ari-foundry/ari`.
- This repository currently has metadata/module layout only.
- Real source scanning and diagnostic production are future work.

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
stable.

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
- JSON output shape, once schema is stable
- exit behavior

## Fixture Ideas

Future fixture ideas, without adding fixtures in this step:

- no trailing whitespace
- trailing spaces
- trailing tabs
- whitespace-only line
- mixed spaces and tabs
- final line without newline
- CRLF or carriage return behavior

## Non-Goals

- Do not implement trailing-whitespace in this step.
- Do not scan source text in this step.
- Do not produce diagnostics in this step.
- Do not add tests or fixtures in this step.
- Do not add JSON serialization in this step.
- Do not invoke `ari --check` in this step.
- Do not copy `tools/lint` source in this step.
