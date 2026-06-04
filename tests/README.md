# ari-lint Tests

Tests will be added after actual implementation begins.

Current checks only verify skeleton files and lightweight documentation/source
guards.

Future tests should cover CLI smoke tests, rule tests, configuration tests,
diagnostic output, JSON diagnostic tests, compiler-boundary behavior, and
parity with current `tools/lint`.

No model tests are added yet. Future model tests should validate severity
handling, rule metadata, diagnostic data, config override data, JSON output
shape after the schema is defined, and parity behavior against current
`tools/lint`.

No registry, severity, or config behavior tests are added yet. Future tests
should validate severity values, rule registry metadata, config overrides,
diagnostics, JSON output after the schema is defined, and parity behavior
against current `tools/lint`.

No rule metadata tests are added yet. Future metadata tests should validate the
rule code, short name, default severity, and description for
`lint/trailing-whitespace` and `lint/missing-final-newline`, then cover config
override behavior, diagnostics, and parity with current `tools/lint` after real
implementation begins.

Parity testing is planned in
[docs/dev/parity-test-plan.md](../docs/dev/parity-test-plan.md). Real parity
fixtures are not added yet.

Future parity fixture categories include valid Ari source, trailing whitespace,
missing final newline, compiler errors, config file overrides, command-line rule
overrides, include paths, JSON diagnostics, and mixed compiler/lint diagnostics.

Compiler and standard library bugs should be filed in `ari-foundry/ari`, not in
`ari-lint` as primary issues.

Tests should use an explicit `--ari` compiler path in CI unless the dependency
model changes.

Future Ari-language implementation tests must follow current `ari-foundry/ari`
language usage.

No actual test fixtures are added in this skeleton step.
