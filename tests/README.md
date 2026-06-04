# ari-lint Tests

Behavior tests will be added after actual implementation begins.

Current checks verify skeleton files, lightweight documentation/source guards,
and the first trailing-whitespace fixture shape.

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

Initial trailing-whitespace fixtures have started under
`tests/fixtures/trailing-whitespace/`:

- `clean.ari` contains a small valid Ari snippet without trailing spaces.
- `trailing-spaces.ari` contains the same small Ari shape with an intentional
  trailing space on the first line.

The lightweight workflow check verifies fixture presence, verifies `clean.ari`
has no trailing blanks, and verifies `trailing-spaces.ari` keeps the
intentional trailing space. It does not compile fixtures, run the Ari compiler,
invoke `ari-lint`, compare diagnostics, or execute the helper directly.

Future fixtures should cover trailing tabs, whitespace-only lines, mixed spaces
and tabs, final lines without trailing newlines, CRLF behavior, diagnostics,
and parity with current `tools/lint`.

The future trailing-whitespace fixture and test plan is documented in
[docs/rules/trailing-whitespace-fixtures.md](../docs/rules/trailing-whitespace-fixtures.md).
Full trailing-whitespace behavior tests, golden files, and test runner behavior
are not added yet.

The rule-specific trailing-whitespace parity plan is documented in
[docs/rules/trailing-whitespace-parity.md](../docs/rules/trailing-whitespace-parity.md).
No parity runner exists yet.

No executable trailing-whitespace helper tests are added yet. Future tests
should cover no trailing whitespace, trailing spaces, trailing tabs,
whitespace-only lines, final lines without trailing newlines, CRLF behavior,
diagnostics, and parity behavior.

No diagnostic mapping tests are added yet. Future tests should validate mapping
from the trailing-whitespace helper result to the internal diagnostic model,
including line and column behavior, end column behavior, message, severity,
rule code, and parity behavior against current `tools/lint`.

No missing-final-newline fixtures are added yet. Future missing-final-newline
fixtures should cover a file with a final newline, a file without a final
newline, an empty file, a single-line file without a final newline, a
multi-line file without a final newline, CRLF final newline behavior, and lone
carriage return behavior if relevant.

The future missing-final-newline fixture and test plan is documented in
[docs/rules/missing-final-newline-fixtures.md](../docs/rules/missing-final-newline-fixtures.md).
No missing-final-newline fixtures are added yet.

No executable missing-final-newline helper tests are added yet. Future tests
should cover file with final newline, file without final newline, empty file,
single-line file without final newline, multi-line file without final newline,
CRLF behavior, diagnostics, and parity behavior.

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
fixtures and parity runners are not added yet.

Future parity fixture categories include valid Ari source, trailing whitespace,
missing final newline, compiler errors, config file overrides, command-line rule
overrides, include paths, JSON diagnostics, and mixed compiler/lint diagnostics.

Compiler and standard library bugs should be filed in `ari-foundry/ari`, not in
`ari-lint` as primary issues.

Tests should use an explicit `--ari` compiler path in CI unless the dependency
model changes.

Future Ari-language implementation tests must follow current `ari-foundry/ari`
language usage.

Only the initial clean and trailing-spaces fixture files are added so far; no
broad fixture set, golden output, CLI test, parity runner, or compiler-backed
test exists yet.
