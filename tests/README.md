# ari-lint Tests

Behavior tests will be added after executable test wiring begins.

Current checks verify skeleton files, lightweight documentation/source guards,
the first trailing-whitespace fixture shape, and the first
missing-final-newline fixture shape. In-memory trailing-whitespace execution
and in-memory missing-final-newline execution have started in source. In-memory
lint run aggregation has also started for caller-provided source text, but
these paths are not executed by these checks yet. A file-read boundary for one
caller-provided path has started in source, but the lightweight checks do not
execute file IO. An internal CLI file lint path now routes explicit source-file
arguments through the file-read boundary and in-memory lint aggregation, but
the lightweight checks do not run CLI tests.
A source-only parity runner skeleton records future comparison boundaries, but
the lightweight checks do not execute a parity runner.

Run the lightweight check script from the repository root:

```sh
scripts/check.sh
```

Run the local standalone test entrypoint with:

```sh
scripts/test.sh
```

The standalone test entrypoint resolves the repository root and delegates to
`scripts/check.sh`. These scripts check repository shape and fixture invariants
only. They do not run the Ari compiler, execute `tools/lint`, invoke
`ari --check`, run a parity runner, run CLI tests, or compare golden tests.
The standalone test entrypoint does not run compiler-backed tests yet.

The GitHub Actions workflow is intentionally compiler-free. It runs only
`scripts/check.sh` and must not run `scripts/build.sh`, invoke the Ari
compiler, invoke `ari --check`, execute `tools/lint`, install package manager
dependencies, or run parity checks until standalone tests and explicit compiler
provisioning are ready.

`scripts/build.sh` is separate from `scripts/test.sh` and the lightweight
checks. It is a compiler-dependent local build scaffold that requires an
explicit Ari compiler path, resolves the repository root before compiling, and
is not run by default tests or CI. Relative compiler paths are preserved from
the caller's directory.

Compiler-backed tests remain future work. Current checks do not run the
compiler. Future compiler-backed tests should use explicit compiler
provisioning as planned in
[docs/dev/compiler-provisioning.md](../docs/dev/compiler-provisioning.md).
Compiler invocation also remains future work; future compiler-backed tests
should use explicit compiler invocation as planned in
[docs/dev/compiler-invocation.md](../docs/dev/compiler-invocation.md).
Release and compatibility policy is documented in
[docs/dev/release-compatibility-policy.md](../docs/dev/release-compatibility-policy.md).
No compatibility matrix entry should be added until compiler-backed tests pass
against a recorded Ari release tag or commit.

Future tests should cover CLI smoke tests, rule tests, configuration tests,
diagnostic output, JSON diagnostic tests, compiler-boundary behavior, and
parity with current `tools/lint`.

No model tests are added yet. Future model tests should validate severity
handling, rule metadata, diagnostic data, config override data, JSON output
shape after the schema is defined, and parity behavior against current
`tools/lint`.

Known rule registry construction has started from the existing
`lint/trailing-whitespace` and `lint/missing-final-newline` metadata entries.
A data-only known rule registry lookup by exact full rule code has also
started, but no registry, severity, or config behavior tests are added yet.
Future tests should validate severity values, rule registry metadata, known
rule lookup behavior, config overrides, diagnostics, JSON output after the
schema is defined, and parity behavior against current `tools/lint`.

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
In-memory trailing-whitespace execution has started, but full
trailing-whitespace behavior tests, golden files, and test runner behavior are
not added yet.

The rule-specific trailing-whitespace parity plan is documented in
[docs/rules/trailing-whitespace-parity.md](../docs/rules/trailing-whitespace-parity.md).
No executable parity runner exists yet; the source-only skeleton records future
runner boundaries only.

No executable trailing-whitespace rule execution tests are added yet. Future
tests should cover no trailing whitespace, trailing spaces, trailing tabs,
whitespace-only lines, final lines without trailing newlines, CRLF behavior,
diagnostics, no file reads, no filesystem scanning, and parity behavior.

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
In-memory missing-final-newline execution has started, but full
missing-final-newline behavior tests, golden files, and test runner behavior
are not added yet.

The rule-specific missing-final-newline parity plan is documented in
[docs/rules/missing-final-newline-parity.md](../docs/rules/missing-final-newline-parity.md).
No executable parity runner exists yet; the source-only skeleton records future
runner boundaries only.

Future missing-final-newline fixtures should cover an empty file, a single-line
file without a final newline, a multi-line file without a final newline, CRLF
final newline behavior, diagnostics, and lone carriage return behavior if
relevant.

No executable missing-final-newline rule execution tests are added yet. Future
tests should cover file with final newline, file without final newline, empty
file, single-line file without final newline, multi-line file without final
newline, CRLF behavior, diagnostics, no file reads, no filesystem scanning, and
parity behavior.

No missing-final-newline diagnostic mapping tests are added yet. Future tests
should validate mapping from the missing-final-newline helper result to the
internal diagnostic model, including caller-provided line and column behavior,
end column behavior, message, severity, rule code, and parity behavior against
current `tools/lint`.

No executable in-memory lint run aggregation tests are added yet. Future tests
should cover combining rule diagnostics, diagnostic ordering, empty diagnostic
sets, no file reads, no filesystem scanning, no config application, no output
or JSON serialization, no compiler invocation, and parity behavior against
current `tools/lint`.

No CLI tests are added yet. Future CLI tests should validate positional source
input, `--json`, `--ari`, `-I`, `--list-rules`, `--config`, `--rule`, invalid
arguments, and parity behavior against current `tools/lint`.

No CLI model tests are added yet. Future tests should cover parser output for
positional files, `--json`, `--list-rules`, `--ari`, `-I`, `--config`,
`--rule`, invalid args, and parity behavior.

No executable CLI parser tests are added yet. Future parser tests should cover
the minimal explicit token-list parser for positional files, `--json`,
`--list-rules`, `--help`/`-h`, `--ari`, `-I`, `--config`, raw `--rule` values,
missing option values, unknown options, repeated `-I` and `--rule`, multiple
positional files, the internal OS argv integration entry path, plus parity
behavior against current `tools/lint` once a parity runner exists.

No executable dispatcher tests are added yet. Future dispatcher tests should
cover list-rules dispatch, unsupported commands, source-file lint requests,
file read errors, lint diagnostics, parse-problem/error results, internal
exit-code mapping, stdout-free behavior, and parity behavior against current
`tools/lint` once a parity runner exists.

No executable exit-code tests are added yet. Future tests should cover the
internal command-result mappings for success, usage-error, and unavailable
states, ensure no process exit is called by the model, and compare user-facing
exit behavior with current `tools/lint` once CLI wiring and a parity runner
exist.

No executable explicit-token entry tests are added yet. Future entry-path tests
should cover list-rules token input, parse problems, unsupported commands,
source-file lint requests, stdout-free behavior, and parity behavior against
current `tools/lint` once a parity runner exists.

No executable explicit-token list-rules command tests are added yet. Future
tests should cover the named `--list-rules` command path, formatted text
presence, success exit-code mapping, stdout-free behavior, no OS argv reads, and
parity behavior against current `tools/lint` once a parity runner exists.

No executable main-entry tests are added yet. Future tests should cover main
entry behavior, delegation from the main shell to explicit-token handling,
stdout-free behavior, future OS argv integration, and parity behavior against
current `tools/lint` once a parity runner exists.

No executable OS argv integration tests are added yet. Future tests should
cover `std::env::args` collection, argv[0] dropping, delegation into
explicit-token parsing, environment isolation, stdout-free behavior, no process
exit calls, and parity behavior against current `tools/lint` once a parity
runner exists.

No executable stdout/stderr output boundary tests are added yet. Future tests
should cover the internal sink/result model, stdout versus stderr stream
selection, no-write behavior before output adapters exist, later output adapter
wiring, diagnostic stream behavior, and parity behavior against current
`tools/lint` once a parity runner exists.

No executable stdout adapter tests are added yet. Future tests should cover the
minimal `std::io::print_string` adapter, successful write status, failed write
status if Ari exposes a practical failure path, no stderr writes, no OS argv
reads, and later user-facing CLI output wiring.

No diagnostic output tests are added yet. Future diagnostic tests should
validate human-readable output, JSON output shape, line/column fields,
endLine/endColumn fields if supported, severity, rule code, message, path
normalization, and parity behavior against current `tools/lint`.

No executable diagnostic JSON serializer tests are added yet. Future serializer
tests should validate single-diagnostic JSON construction, string escaping,
optional end positions, severity names, rule codes, messages, and final schema
stability once the schema is set.

No executable source input boundary tests are added yet. Future source input
tests should validate caller-provided source text, path-only source entries,
path-list inputs from already-parsed CLI paths, the single-path file-read
boundary, file read error preservation, no recursive filesystem scanning, no
config discovery, and later file input behavior once CLI wiring is scoped.

No executable file IO boundary tests are added yet. Future tests should cover
successful single-file reads, missing-file `PathError` preservation,
permission errors if practical, no directory traversal, no config-file
discovery, no rule execution, no output, no JSON serialization, no compiler
invocation, and parity behavior against current `tools/lint`.

No executable CLI file lint path tests are added yet. Future tests should cover
explicit source-file arguments, successful file reads feeding in-memory lint
aggregation, file read error preservation, diagnostic counts, exit-code
mapping, no directory traversal, no config discovery, no stdout/stderr output,
no JSON serialization, no compiler invocation, no `ari --check`, and parity
behavior against current `tools/lint`.

No executable list-rules formatter tests are added yet. Future tests should
cover list-rules rows and formatting for rule code, short name, default
severity, description, ordering, newline behavior, human-readable text
stability, future JSON formatting, and parity behavior against current
`tools/lint`.

No executable config parser tests are added yet. Future config parser tests
should validate caller-provided `RULE = SEVERITY` text, blank lines, comments,
invalid lines, invalid severity names, and parse problem reporting.

No executable rule override parser tests are added yet. Future rule override
parser tests should validate caller-provided `--rule RULE=SEVERITY` text,
documented short-name normalization, invalid lines, invalid severity names,
parse problem reporting, unknown-rule handling once policy is set, and parity
behavior.

No config override tests are added yet. Future config override tests should
validate `ari-lint.rules` discovery, `--config` behavior, `--rule` behavior,
precedence, override application, diagnostics, and parity behavior against
current `tools/lint`.

Parity testing is planned in
[docs/dev/parity-test-plan.md](../docs/dev/parity-test-plan.md). Real parity
fixtures and executable parity runners are not added yet. A source-only parity
runner skeleton records intended boundaries only.

No executable parity runner tests are added yet. Future parity runner tests
should cover reference command selection, standalone `ari-lint` command
selection, fixture inputs, path normalization, output comparison, exit-code
comparison, and strict avoidance of accidental compiler or network execution in
lightweight checks.

No compiler-backed CI tests are added yet. Future compiler-backed CI should
record the Ari compiler release tag or commit, use explicit compiler
provisioning, and run only after standalone tests exist.

The local standalone test entrypoint exists.

No executable standalone build tests are added yet. Future build tests should
cover repository-root resolution, explicit compiler path validation,
relative compiler path preservation, `ARI_COMPILER` fallback behavior, output
path handling, and failure diagnostics without adding compiler execution to
lightweight checks.

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
no broad fixture set, golden output, CLI test, executable parity runner, or
compiler-backed test exists yet.
