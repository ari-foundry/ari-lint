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

No rule module tests are added yet. Future rule module tests should validate
rule module metadata, rule behavior, diagnostics, config interactions, and
parity behavior against current `tools/lint`.

No trailing-whitespace fixtures are added yet. Future fixtures should cover no
trailing whitespace, trailing spaces, trailing tabs, whitespace-only lines,
mixed spaces and tabs, final lines without trailing newlines, CRLF behavior,
diagnostics, and parity with current `tools/lint`.

No CLI tests are added yet. Future CLI tests should validate positional source
input, `--json`, `--ari`, `-I`, `--list-rules`, `--config`, `--rule`, invalid
arguments, and parity behavior against current `tools/lint`.

No diagnostic output tests are added yet. Future diagnostic tests should
validate human-readable output, JSON output shape, line/column fields,
endLine/endColumn fields if supported, severity, rule code, message, path
normalization, and parity behavior against current `tools/lint`.

No config override tests are added yet. Future config override tests should
validate `ari-lint.rules` discovery, `--config` behavior, `--rule` behavior,
precedence, invalid config, diagnostics, and parity behavior against current
`tools/lint`.

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
