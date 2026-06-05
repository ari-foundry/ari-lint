# ari-lint Tests

Behavior tests will be added after actual implementation begins.

Current checks verify skeleton files, lightweight documentation/source guards,
the first trailing-whitespace fixture shape, and the first
missing-final-newline fixture shape.

Run the lightweight check script from the repository root:

```sh
scripts/check.sh
```

The script checks repository shape and fixture invariants only. It does not run
the Ari compiler, execute `tools/lint`, invoke `ari --check`, run a parity
runner, run CLI tests, or compare golden tests.

Compiler-backed tests remain future work. Current checks do not run the
compiler. Future compiler-backed tests should use explicit compiler
provisioning as planned in
[docs/dev/compiler-provisioning.md](../docs/dev/compiler-provisioning.md).
Compiler invocation also remains future work; future compiler-backed tests
should use explicit compiler invocation as planned in
[docs/dev/compiler-invocation.md](../docs/dev/compiler-invocation.md).

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

Initial missing-final-newline fixtures have started under
`tests/fixtures/missing-final-newline/`:

- `with-final-newline.ari` contains a small valid Ari snippet with a final
  newline.
- `missing-final-newline.ari` contains the same small Ari shape and
  intentionally does not end with a final newline.

The lightweight workflow check verifies fixture presence, verifies
`with-final-newline.ari` ends with a newline, and verifies
`missing-final-newline.ari` intentionally does not end with a newline. It does
not compile fixtures, run the Ari compiler, invoke `ari-lint`, compare
diagnostics, or execute the helper directly.

The future missing-final-newline fixture and test plan is documented in
[docs/rules/missing-final-newline-fixtures.md](../docs/rules/missing-final-newline-fixtures.md).
Full missing-final-newline behavior tests, golden files, and test runner
behavior are not added yet.

The rule-specific missing-final-newline parity plan is documented in
[docs/rules/missing-final-newline-parity.md](../docs/rules/missing-final-newline-parity.md).
No parity runner exists yet.

Future missing-final-newline fixtures should cover an empty file, a single-line
file without a final newline, a multi-line file without a final newline, CRLF
final newline behavior, diagnostics, and lone carriage return behavior if
relevant.

No executable missing-final-newline helper tests are added yet. Future tests
should cover file with final newline, file without final newline, empty file,
single-line file without final newline, multi-line file without final newline,
CRLF behavior, diagnostics, and parity behavior.

No missing-final-newline diagnostic mapping tests are added yet. Future tests
should validate mapping from the missing-final-newline helper result to the
internal diagnostic model, including caller-provided line and column behavior,
end column behavior, message, severity, rule code, and parity behavior against
current `tools/lint`.

No CLI tests are added yet. Future CLI tests should validate positional source
input, `--json`, `--ari`, `-I`, `--list-rules`, `--config`, `--rule`, invalid
arguments, and parity behavior against current `tools/lint`.

No CLI model tests are added yet. Future tests should cover parser output for
positional files, `--json`, `--list-rules`, `--ari`, `-I`, `--config`,
`--rule`, invalid args, and parity behavior.

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

Only the initial trailing-whitespace clean/trailing-spaces fixtures and
missing-final-newline final-newline/no-final-newline fixtures are added so far;
no broad fixture set, golden output, CLI test, parity runner, or
compiler-backed test exists yet.
