# lint/missing-final-newline

## Purpose

This document defines the planned behavior for
`lint/missing-final-newline`.

This step does not implement the rule. It records the design target for a
future Ari-language implementation.

## Current Status

- The rule is planned for the Ari-language implementation.
- The current reference behavior is the bundled `tools/lint` implementation in
  `ari-foundry/ari`.
- This repository currently has metadata/module layout only.
- Real file inspection and diagnostic production are future work.

## Rule Identity

- Canonical rule code: `lint/missing-final-newline`.
- Short name: `missing-final-newline`.
- Default severity: `warning`, confirmed from the current Ari lint docs and
  reference rule registry.

## Planned Detection

The future rule should detect a non-empty source file that does not end with a
newline.

The current reference implementation does not flag empty files.

Files ending in CRLF count as having a final newline because the current
reference checks whether the final byte is `\n`.

A file ending with a lone carriage return is currently treated as missing the
final newline by the reference implementation. Standalone fixture coverage for
lone carriage return behavior remains needs follow-up.

## Planned Diagnostic Location

The future diagnostic should include:

- file path
- line number for the final line
- column at the end of the final line
- end line and end column
- rule code `lint/missing-final-newline`
- configured severity
- message text

The current reference implementation reports the diagnostic at the final
position in the file, with `endLine` equal to the diagnostic line and
`endColumn` one column after the reported column.

Exact standalone JSON and human-readable output details remain needs
follow-up until output schema and text stability are documented.

## Planned Message

The current reference implementation reports:

```text
missing final newline
```

The future Ari-language implementation should use this message for behavior
parity unless the reference implementation changes before the rule is
implemented.

## Parity Expectations

The future implementation should compare behavior against the current bundled
`tools/lint` implementation.

Parity dimensions:

- which files are flagged
- behavior for empty files
- behavior for final newline, no final newline, CRLF, and lone CR
- diagnostic line/column
- rule code
- severity
- human-readable output
- JSON output shape, once schema is stable
- exit behavior

## Fixture Ideas

Future fixture ideas, without adding fixtures in this step:

- file with final newline
- file without final newline
- empty file
- single-line file without final newline
- multi-line file without final newline
- CRLF final newline behavior
- lone carriage return behavior if relevant

## Non-Goals

- Do not implement missing-final-newline in this step.
- Do not read files in this step.
- Do not inspect file contents in this step.
- Do not produce diagnostics in this step.
- Do not add tests or fixtures in this step.
- Do not add JSON serialization in this step.
- Do not invoke `ari --check` in this step.
- Do not copy `tools/lint` source in this step.
