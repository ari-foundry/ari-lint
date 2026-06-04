# missing-final-newline Fixture Plan

## Purpose

This document plans future fixtures and tests for
`lint/missing-final-newline`.

This step does not add fixtures, tests, golden files, or test runner behavior.

## Current Status

- A minimal internal helper exists for missing-final-newline detection.
- Full rule execution is not complete.
- No real fixtures are added yet.
- No test runner is wired yet.
- The current reference behavior remains `tools/lint` in `ari-foundry/ari`.

## Planned Fixture Layout

Future fixture paths may include:

```text
tests/fixtures/missing-final-newline/with-final-newline.ari
tests/fixtures/missing-final-newline/missing-final-newline.ari
tests/fixtures/missing-final-newline/empty.ari
tests/fixtures/missing-final-newline/single-line-no-newline.ari
tests/fixtures/missing-final-newline/multi-line-no-newline.ari
tests/fixtures/missing-final-newline/crlf-final-newline.ari
tests/fixtures/missing-final-newline/lone-cr.ari
```

These are planned paths only. `crlf-final-newline.ari` should be added only if
CRLF behavior is intentionally tested and the fixture encoding policy is clear.
`lone-cr.ari` should be added only if lone carriage return behavior is
intentionally tested.

## Planned Cases

Future cases should cover:

- file with final newline
- file without final newline
- empty file behavior
- single-line file without final newline
- multi-line file without final newline
- CRLF final newline behavior
- lone carriage return behavior if supported or needs follow-up

## Expected Result Strategy

Future tests should record:

- whether a diagnostic is expected
- final line number, if confirmed
- final column, if confirmed
- end line and end column, if confirmed
- rule code `lint/missing-final-newline`
- severity, if confirmed
- message, if confirmed

The current reference confirms rule code `lint/missing-final-newline`, default
severity `warning`, and message text `missing final newline`.

The current reference does not flag empty files and treats content ending in
`'\n'` as having a final newline. Files ending in CRLF count as having a final
newline because the final byte is `'\n'`. A file ending with a lone carriage
return is currently treated as missing the final newline.

Standalone fixture confirmation for empty file behavior, CRLF behavior, lone
carriage return behavior, exact line and column behavior, and end line/end
column behavior remains needs follow-up until dedicated fixtures and tests
exist.

Exact standalone JSON output, human-readable output, fixture encoding, path
normalization, and any golden-file schema details remain needs follow-up.

## Parity Strategy

Future tests should compare the Ari implementation against current `tools/lint`.

Parity dimensions:

- which files are flagged
- empty file behavior
- final newline and no final newline behavior
- CRLF and lone carriage return behavior
- line and column behavior
- severity
- message
- human-readable output
- JSON output once schema is stable
- exit behavior

## Golden Output Policy

- Do not add golden JSON until JSON schema is stable.
- Human-readable golden output should wait until message text is stable.
- Path normalization is required before comparing outputs.
- Ari compiler version or commit should be recorded when compiler-backed
  diagnostics are involved.

## Test Runner Notes

- No test runner is added in this step.
- Future test runner should not depend on undocumented local monorepo paths.
- Tests should use explicit Ari compiler path only when compiler-backed
  behavior is involved.
- Pure helper tests should not require `ari --check`.

## Non-Goals

- Do not add fixtures in this step.
- Do not add tests in this step.
- Do not add golden files in this step.
- Do not add test runner behavior in this step.
- Do not invoke `ari --check` in this step.
- Do not copy `tools/lint` source in this step.
