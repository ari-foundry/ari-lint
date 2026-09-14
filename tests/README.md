# ari-lint Tests

Compiler-free repository checks, local compiler-backed executable smoke
validation, a local report-only parity smoke/report, and a strict checked-in
native-rule parity subset all exist now. Exact standalone and reference
list-rules contracts are also gated with separate goldens. The smoke suite
includes representative exact runtime JSON, human-output, compiler invocation,
and compiler-diagnostic checks. The strict subset gates clean, trailing-whitespace,
missing-final-newline, ordered multi-file, and duplicate JSON results against
the reference tool and source-controlled goldens. Focused Ari unit tests,
strict CLI/config/compiler-boundary parity, source-controlled broad
compiler-diagnostic goldens, and broader golden coverage remain future work.

Current compiler-free checks verify repository shape, lightweight
documentation/source guards, the first trailing-whitespace fixture shape, and
the first missing-final-newline fixture shape. In-memory trailing-whitespace
execution and in-memory missing-final-newline execution have started in source.
In-memory lint run aggregation has also started for caller-provided source text,
including first-diagnostic capture and with-overrides variants that preserve
the same count and first-diagnostic shape for already-parsed severity override
inputs over in-memory source and explicitly provided file paths. Internal
diagnostic vector collection APIs now push rule and lint diagnostics into
caller-provided vectors, but these paths are not executed by these checks yet.
A file-read boundary for one caller-provided path has started in source, but
the lightweight checks do not execute file IO.
The internal CLI file lint path retains all explicit source-file arguments,
iterates them through the file-read boundary and in-memory lint aggregation,
and validates parsed `--rule` overrides when provided. It carries aggregate
diagnostic/read-error counts and the first internal diagnostic in the command
result. A separate internal CLI collection path can push full source-file
diagnostics for all explicit source files into a caller-provided vector. Parsed
explicit config file overrides are applied to collected source-file diagnostics
before command-line `--rule` severity overrides and before main-facing human or
JSON stdout output. The explicit `--config` path is captured in the
CLI argument model and can be read when source-file diagnostics are collected.
Documented short rule names in config files are normalized to full lint rule
codes before known-rule validation.
When `--config` is absent, the CLI source-file path searches upward from each
source file's directory for the nearest readable `ari-lint.rules`. Discovered
config errors become ordered per-file `lint/config` diagnostics; explicit
config read and parse errors use the reference stderr shape and exit `2`.
The main-facing source-file lint path writes reference-shaped human results to
stdout; the compiler-free checks do not execute that path, while
`scripts/smoke.sh` does.
A source-only parity runner skeleton records future comparison boundaries, and
`scripts/parity.sh` provides a local report-only parity smoke/report. The
lightweight checks do not execute that parity script.
`scripts/parity-strict.sh` provides a separate gating subset over checked-in
list-rules snapshots and native rule fixtures. List-rules intentionally uses
different standalone/reference goldens. Native cases use a no-output fixture
compiler and explicit empty config so compiler diagnostics and ambient config
cannot affect those goldens.
The config precedence fixture plan is documented. Shell-only lightweight checks
verify the committed fixture files' presence, exact line order, and expected
text; they do not execute Ari code. Dedicated Ari-backed config precedence tests
are not added yet. Separately, `scripts/smoke.sh` executes the built CLI and
asserts per-source discovered config, explicit-config suppression of discovery,
CLI-last precedence, and config error output.
The shared rule module API has started for caller-provided in-memory source
text, but the lightweight checks do not execute Ari rule API tests.
Registry-backed in-memory rule dispatch has started for one exact known rule
code and caller-provided source text, but the lightweight checks do not execute
registry dispatch tests.
The main entry returns the OS argv CLI command exit-code mapping. List-rules,
help, and source-file results use stdout. CLI parse problems and explicit config
read or parse failures use stderr. Source read failures are represented by the
selected compiler's per-file exit code and compiler diagnostic on stdout;
native source-read failure does not replace that compiler-visible result. Bad
lines in a discovered config are ordinary per-file `lint/config` diagnostics on
stdout and return exit `1`. Source `--json` output is one newline-terminated
reference-shaped object with an ordered entry for every positional input,
including clean, missing, and duplicate paths. A nonzero compiler exit or any
enabled compiler, config, or native diagnostic returns exit `1`. The
compiler-free checks do not execute these paths, while `scripts/smoke.sh`
verifies them through the built binary.
The public source-result fields, ordering, encoding, stream selection, and
status mapping are defined in
[docs/diagnostics.md](../docs/diagnostics.md).

Run the lightweight check script from the repository root:

```sh
scripts/check.sh
```

Run the local standalone test entrypoint with:

```sh
scripts/test.sh
scripts/test.sh /path/to/ari
```

With no argument, the standalone entrypoint resolves the repository root and
runs only `scripts/check.sh`; a present `ARI_COMPILER` does not opt in. With one
explicit, non-empty compiler path, it runs those checks and then the full
`scripts/smoke.sh` suite. An empty path or more than one argument fails. Neither
mode executes `tools/lint` or a parity runner. The explicit compiler path is the
reproducer for compiler-backed validation and does not establish compatibility.

The lightweight GitHub Actions workflow is intentionally compiler-free and runs
zero-argument `scripts/test.sh`. A separate compiler-smoke workflow verifies a
checksum-pinned Ari `v0.1.0` prerelease artifact and runs
`scripts/test.sh "$ARI_COMPILER"`. Neither workflow executes `tools/lint`, runs
parity, uses package-manager dependencies, or establishes compatibility.

Run the strict list-rules and native-rule subsets from any checkout with
explicit compiler and Ari repository paths:

```sh
scripts/parity-strict.sh /path/to/ari /path/to/ari-repo
```

The initial goldens under `tests/golden/native/` were verified against the
bundled reference at Ari tag `v0.1.0`, commit
`c615f1c2ce1a93835118b4da8867a7f3dfaf991a`. This is provenance for the
native-rule expectations, not an Ari release compatibility claim. Relative
fixture paths remove the need for path rewriting. Future temporary-path cases
must normalize only their known temporary-root prefix rather than rewriting
arbitrary paths.

The exact registry outputs under `tests/golden/list-rules/` implement the
standalone contract in [docs/list-rules.md](../docs/list-rules.md) and
separately preserve current bundled-reference behavior at Ari tag `v0.1.0`,
commit `c615f1c2ce1a93835118b4da8867a7f3dfaf991a`. The strict runner checks both
option orders for each implementation, final LF, empty stderr, exit `0`, JSON
validity for the standalone JSON form, and sentinel-backed absence of compiler
invocation for the explicitly selected compiler. This provenance is not an Ari
release compatibility claim.

`scripts/build.sh` is separate from the lightweight checks. It is a
compiler-dependent local build scaffold that requires an explicit Ari compiler
path, resolves the repository root, and uses the compiler root when
`lib/std.arih` is available there. Zero-argument tests and the lightweight CI
job do not run it; explicit-compiler `scripts/test.sh` and compiler-smoke CI
reach it through the smoke suite.
Relative compiler paths are preserved from the caller's directory.

`scripts/smoke.sh` is the local compiler-backed smoke entrypoint. It accepts an
explicit Ari compiler path as its first argument or through `ARI_COMPILER`,
delegates build behavior to `scripts/build.sh`, and then runs
`./build/ari-lint --help`, `./build/ari-lint --list-rules`, and
`./build/ari-lint --json --list-rules`. It also runs JSON smoke commands with
temporary source trees containing `ari-lint.rules` to check per-source nearest
readable discovery, different configs in one multi-file run, unreadable-nearer
fallback, explicit `--config` discovery suppression, and CLI-last `--rule`
precedence. It checks discovered bad lines as ordered per-file `lint/config`
diagnostics on stdout with exit `1`, and exact explicit config read and parse
errors on stderr with exit `2`. The temporary config files use documented short
rule names to cover config-file normalization. The smoke also checks the runtime
`files` envelope and per-file `path`, `exitCode`, and `diagnostics`, plus
diagnostic `file`, positions, `severity`, `message`, `source`, and `code` for
`lint/trailing-whitespace` and `lint/missing-final-newline`. Representative JSON
and human outputs are checked exactly, including final newlines. Multi-file
coverage includes two dirty files, per-source config differences, clean plus
dirty, all-clean, and duplicate source arguments.
The executable source path invokes the selected compiler once per positional
file with exact `-I DIR ... FILE --check` arguments. The smoke verifies
shell-free preservation of spaces and metacharacters, per-file invocation and
include-path order, explicit `--ari` precedence over `ARI_COMPILER`, environment
selection, the `build/ari` default, and the behavior of a present but empty
`ARI_COMPILER` value. Help and both list-rules forms are checked with a sentinel
compiler to ensure they do not spawn it.
The fake-compiler matrix covers all four supported Ari diagnostic line shapes,
greedy colon-containing file paths, coordinate normalization, explicit and
fallback diagnostic codes, ignored non-diagnostic output, a trailing carriage
return, rejection of an embedded carriage return in regex-dot fields, a final
diagnostic line without a newline, and deterministic stderr then stdout parsing.
It also checks missing, newline-containing missing, and non-executable compiler
paths as per-file exit `127`, including reference-shaped reparsing of synthetic
launch-failure output,
ordinary nonzero and signal-derived exit codes, raw-output and empty-output
fallback diagnostics, concurrent draining beyond the 256 KiB per-stream capture
limit, an always-on `ari/compiler-output-truncated` error, exit-zero diagnostics
beyond that boundary, a 2,048-per-file dense-diagnostic cap with
`ari/compiler-diagnostics-truncated`, exact 2,048/2,049 and 4,096 run-boundary
checks, bounded raw fallback material repeated across 24 files, fallback
suppression when a config or native diagnostic
already exists, and compiler-before-truncation-before-config-before-native
diagnostic ordering. A missing source is checked through the real compiler's
per-file JSON diagnostic with stderr empty.
It is not run by zero-argument `scripts/test.sh` or the lightweight CI job.
One-argument `scripts/test.sh`, including compiler-smoke CI, delegates to it as
the current validation path for build, supported CLI commands, source-file JSON
diagnostics, explicit config, per-source discovered `ari-lint.rules`, nearest
readable precedence, and CLI severity override precedence across explicit source
files. It does not run
a strict parity gate, search home/global/XDG config locations, add new lint
semantics, or claim compatibility. It now checks focused JSON list-rules
rule-code, short-name, and default-severity output signals; dedicated Ari tests,
source-controlled broad goldens, and broad compiler-diagnostic goldens remain
follow-up work.

`scripts/parity.sh` is the local report-only parity smoke/report. It accepts an
explicit Ari compiler path or `ARI_COMPILER`, an Ari repo path or `ARI_REPO`,
and optionally an original lint command path or `ORIGINAL_LINT`. It verifies
the original lint entrypoint from the Ari repo `Makefile` and
`tools/lint/main.cpp`, builds this repository through `scripts/build.sh`, runs
both tools with `--json --ari` on temporary clean, trailing-whitespace,
missing-final-newline, explicit-config, rule-override, discovered-config, and
multi-file cases, and reports exit codes, stdout/stderr presence, rule
sightings, severity sightings, file-path hit counts, and line/column presence.
Differences do not fail the script. It is not run by `scripts/test.sh` or CI,
does not add golden files or source-controlled parity fixtures, and does not
claim compatibility or parity.
Known report-only differences are tracked in
[docs/dev/parity-differences.md](../docs/dev/parity-differences.md).

The local executable smoke uses an explicit compiler to build `ari-lint`, then
verifies that source runs invoke the selected compiler with `--check`. Its
fake-compiler cases isolate argv, selection, process status, output parsing, and
diagnostic composition without depending on a particular compiler diagnostic.
Compiler provisioning and the invocation contract are documented in
[docs/dev/compiler-provisioning.md](../docs/dev/compiler-provisioning.md) and
[docs/dev/compiler-invocation.md](../docs/dev/compiler-invocation.md).
Release and compatibility policy is documented in
[docs/dev/release-compatibility-policy.md](../docs/dev/release-compatibility-policy.md).
No compatibility matrix entry should be added until compiler-backed tests pass
against a recorded Ari release tag or commit.

Future tests should expand the existing CLI/output smoke with dedicated Ari
rule, configuration, serializer, compiler-boundary, and broader strict parity
tests.

No model tests are added yet. Future model tests should validate severity
handling, rule metadata, diagnostic data, config override data, the documented
JSON output shape, and parity behavior against current `tools/lint`.

Known rule registry construction has started from the existing
`lint/trailing-whitespace` and `lint/missing-final-newline` metadata entries.
A data-only known rule registry lookup by exact full rule code has also
started. Registry-backed in-memory dispatch for one exact known rule code has
also started, but no dedicated Ari registry, severity, or config behavior tests
are added yet. The executable shell smoke covers representative main-facing
config behavior. Future dedicated tests should validate severity values, rule
registry metadata, known rule lookup behavior, registry-backed in-memory rule
dispatch, unknown rule dispatch results, config overrides, severity override
resolution, single-diagnostic severity application, diagnostics, JSON output,
and parity behavior against current `tools/lint`.

No executable registry dispatch tests are added yet. Future registry dispatch
tests should validate exact full rule code matching, dispatch to
`lint/trailing-whitespace`, dispatch to `lint/missing-final-newline`, unknown
rule handling, caller-provided source text, no file reads, no filesystem
scanning, no config application, no output or JSON serialization, no compiler
invocation, no `ari --check`, and parity behavior.

No rule metadata tests are added yet. Future metadata tests should validate the
rule code, short name, default severity, and description for
`lint/trailing-whitespace` and `lint/missing-final-newline`, then cover config
override behavior, diagnostics, and parity with current `tools/lint` after real
implementation begins.

No executable shared rule module API tests are added yet. Future rule module
tests should validate `RuleExecutionInput`, `RuleExecutionResult`, per-rule
shared wrappers, rule module metadata, rule behavior, diagnostics, no file
reads, no filesystem scanning, no output or JSON serialization, no compiler
invocation, config interactions, and parity behavior against current
`tools/lint`.

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
A first local parity smoke/report exists, and the source-only skeleton records
future Ari-source runner boundaries. The strict native subset now gates the
checked-in clean and trailing-spaces fixtures; broader cases remain future work.

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
A first local parity smoke/report exists, and the source-only skeleton records
future Ari-source runner boundaries. The strict native subset now gates the
checked-in with-final-newline and missing-final-newline fixtures; broader cases
remain future work.

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
sets, first-diagnostic preservation, caller-provided diagnostic vector
collection, already-parsed severity override data, no config-file reads, no
filesystem scanning, no output or JSON serialization, no compiler invocation,
and parity behavior against current `tools/lint`.

Executable shell CLI smoke now covers positional source input, `--json`,
`--ari`, `-I`, `--list-rules`, `--config`, `--rule`, representative invalid
arguments, output streams, and exit codes. Dedicated Ari CLI unit tests and
broader strict CLI parity remain future work.

No CLI model tests are added yet. Future tests should cover parser output for
positional files, `--json`, `--list-rules`, `--ari`, `-I`, `--config`,
`--rule`, invalid args, and parity behavior.

No executable CLI parser tests are added yet. Future parser tests should cover
the minimal explicit token-list parser for positional files, `--json`,
`--list-rules`, `--help`/`-h`, `--ari`, `-I`, explicit `--config` path
capture, raw `--rule` values, missing option values, unknown options, repeated
`-I` and `--rule`, multiple positional files, the internal OS argv integration
entry path, plus parity behavior against current `tools/lint` in a dedicated Ari
test harness.

No executable dispatcher tests are added yet. Future dispatcher tests should
cover list-rules dispatch, missing-source commands, source-file lint requests,
file read errors through the current per-file compiler-shaped JSON path, lint
diagnostics,
first diagnostic command-result carrying, caller-provided diagnostic vector
collection, parsed `--rule` override application, rule override parse-problem
results, internal exit-code mapping, stdout-free behavior, and parity behavior
against current `tools/lint` in a dedicated Ari test harness.

No dedicated Ari exit-code model tests are added yet. Executable shell smoke
covers user-facing success, lint-failure, usage-error, and unavailable exits;
future unit tests should isolate the internal mappings and failure paths.

No executable explicit-token entry tests are added yet. Future entry-path tests
should cover list-rules token input, parse problems, missing source input,
source-file lint requests, stdout-free behavior, and parity behavior against
current `tools/lint` in a dedicated Ari test harness.

No dedicated Ari explicit-token list-rules command tests are added yet. The
strict executable runner covers the main-facing OS argv path, both output
forms, option ordering, stream selection, exit status, and exact goldens.
Future Ari unit tests should isolate the internal command path, stdout-free
behavior, and absence of OS argv reads.

Executable shell smoke enters through `main` and OS argv, checking returned
exit codes, list-rules/help output, human and JSON source results, parse errors,
missing input with and without `--json`, and stream isolation. Stdout-only
successes require empty stderr; usage failures require empty stdout. Every JSON
case is parsed as one document and must end in LF. Dedicated Ari main-entry and
argv-boundary unit tests, environment isolation, and broader strict
CLI/config/compiler parity remain future work.

No executable stdout/stderr output boundary tests are added yet. Future tests
should cover the internal sink/result model, stdout versus stderr stream
selection, adapter failure paths, diagnostic stream behavior, and broader
strict parity.

No executable stdout adapter tests are added yet. Future tests should cover the
minimal `std::io::print_string` adapter, successful write status, failed write
status if Ari exposes a practical failure path, no stderr writes, no OS argv
reads, existing main-facing stdout wiring, and adapter failure paths.

No executable stderr adapter tests are added yet. Future tests should cover the
minimal `std::io::eprint_string` adapter, successful write status, failed write
status if Ari exposes a practical failure path, no stdout writes, no OS argv
reads, and current usage and explicit-config error wiring. Compiler launch and
source-read failures in a source run belong to the per-file stdout result.

Executable diagnostic output smoke tests validate exact reference-shaped JSON
and human text for representative native diagnostics, numeric start/end
positions, source/code fields, clean output, ordering, and newline termination.
All JSON cases are syntax-checked and human diagnostics are verified on stdout
with stderr empty. The fake-compiler smoke also checks representative exact
compiler diagnostic objects. Focused formatter helper tests and
source-controlled broad compiler-diagnostic goldens remain follow-up work.

No executable trailing-whitespace first-diagnostic capture tests are added yet.
Future tests should validate the first captured diagnostic, count preservation,
line/column metadata, no stderr writes, no JSON serialization, and parity
behavior against current `tools/lint`.

No executable missing-final-newline first-diagnostic capture tests are added yet.
Future tests should validate the first captured diagnostic, count preservation,
line/column metadata, no stderr writes, no JSON serialization, and parity
behavior against current `tools/lint`.

Executable CLI smoke tests now validate the runtime JSON envelope, exact native
diagnostic objects, clean and mixed file accounting, duplicate inputs, final
newlines, JSON syntax, path control-byte escaping, opposite-stream isolation,
and representative exact fake-compiler diagnostic objects. Focused internal
serializer tests and source-controlled broad compiler-diagnostic golden cases
remain follow-up work.

No executable source input boundary tests are added yet. Future source input
tests should validate caller-provided source text, path-only source entries,
path-list inputs from already-parsed CLI paths, the single-path file-read
boundary, file read error preservation, no recursive filesystem scanning, no
config discovery inside the boundary, and existing explicit-file CLI behavior.

No executable file IO boundary tests are added yet. Future tests should cover
successful single-file reads, missing-file `PathError` preservation,
permission errors if practical, no directory traversal, no config-file
discovery, no rule execution, no output, no JSON serialization, no compiler
invocation, and parity behavior against current `tools/lint`.

No executable file-backed lint severity override aggregation tests are added yet.
Future tests should validate explicitly provided source paths, successful file
reads feeding already-parsed overrides into in-memory rule diagnostics, read
error preservation, caller-provided diagnostic vector collection, multiple
files sharing one override list, no config-file reads, no config discovery, no
config-file CLI wiring, no directory traversal, no output, no JSON
serialization, no compiler invocation, no `ari --check`, and parity behavior.

No executable CLI file lint path tests are added yet as dedicated Ari tests.
The shell smoke executes this path for representative runtime contracts. Future
dedicated tests should cover
explicit source-file arguments, successful file reads feeding in-memory lint
aggregation, parsed `--rule` override validation, rule override parse
problems, explicit config file override application, per-source nearest readable
`ari-lint.rules` discovery, parsed `--rule` severity override application after
config overrides, discovered config diagnostics, file read error preservation,
explicit config read error preservation, diagnostic counts, first diagnostic
command-result carrying, caller-provided diagnostic vector collection,
exit-code mapping, no recursive source directory traversal, no home/global/XDG
config search, no stdout/stderr output in the internal path, no JSON
serialization in the internal path, isolation of the compiler-free in-memory
helpers, main-facing compiler invocation, and parity behavior against current
`tools/lint`.

No dedicated Ari list-rules formatter unit tests are added yet. The strict
executable goldens cover rule code, short name, default severity, description,
ordering, newline behavior, human text, standalone JSON, main-facing stdout,
and the explicit reference difference. Future Ari tests should isolate the
internal formatter without OS argv or stream IO.

No executable config parser tests are added yet as dedicated Ari tests. The
shell smoke exercises parsing through the built CLI. Future dedicated tests
should validate caller-provided `RULE = SEVERITY` text, blank lines, comments,
documented short-name normalization, invalid lines, invalid severity names,
known-rule validation, explicit config file path parsing, read-error reporting,
and complete parse problem reporting.

No executable rule override parser tests are added yet. Future rule override
parser tests should validate caller-provided `--rule RULE=SEVERITY` text,
documented short-name normalization, invalid lines, invalid severity names,
known-rule validation, parse problem reporting, and parity behavior.

No executable severity override resolution tests are added yet. Future tests
should validate effective severity for caller-provided rule codes,
caller-provided override order, unknown rule reporting data, no diagnostic
mutation, no config-file reads, no output, no compiler invocation, and parity
behavior.

No executable diagnostic severity application tests are added yet. Future tests
should validate one already-built diagnostic rebuilt with resolved severity,
matched override reporting, no config-file reads, no lint rule execution, no
lint-run config application, no output, no JSON serialization, no compiler
invocation, and parity behavior.

No executable in-memory lint severity override aggregation tests are added yet.
Future tests should validate already-parsed override data flowing through
in-memory rule aggregation, first-diagnostic preservation, later config-aware
diagnostic rewriting, multiple diagnostics, default severities when no override
matches, no config-file reads, no config-file CLI wiring, no file reads, no
filesystem scanning, no output, no JSON serialization, no compiler invocation,
no `ari --check`, and parity behavior.

No config override tests are added yet as dedicated Ari tests. The executable
shell smoke covers representative main-facing behavior. Future dedicated tests
should validate explicit `--config` behavior, `--rule` behavior, defaults <
selected config < CLI `--rule` precedence, severity override resolution,
single-diagnostic severity application, in-memory severity override aggregation,
file-backed and CLI config application, CLI `--rule` lint dispatch, collected
diagnostic severity rewriting, per-source nearest readable `ari-lint.rules`
discovery, discovered config diagnostics, and parity behavior against current
`tools/lint`.

The config precedence fixture and runtime coverage plan is documented in
[docs/dev/config-precedence-fixtures.md](../docs/dev/config-precedence-fixtures.md).
Initial config precedence fixtures exist under
`tests/fixtures/config-precedence/`:

- `ari-lint.rules` records a discovered config-file override shape.
- `explicit-config.rules` records an explicit `--config` override shape.
- `command-line-overrides.txt` records command-line `--rule` values,
  including repeated override ordering.
- `invalid.rules` records unknown-rule and invalid-severity cases.

The lightweight checks verify fixture presence, exact line order, and key text
only. They do not parse these committed fixtures with Ari code. Separately, the
smoke script runs CLI-process tests against generated temporary configs and
compares focused exact output. Dedicated Ari-backed config precedence tests,
source-controlled broad goldens, and broader strict config parity remain
future work.

Parity testing is specified in
[docs/dev/parity-test-plan.md](../docs/dev/parity-test-plan.md). Checked-in
native-rule fixtures and list-rules/native golden subsets now run through
`scripts/parity-strict.sh`; `scripts/parity.sh` remains the broader report-only
runner. A source-only Ari parity skeleton records intended internal boundaries.

No dedicated tests of the parity-runner infrastructure are added yet. Future
runner tests should isolate reference and standalone command selection, fixture
inputs, path normalization, output comparison, exit-code comparison, and strict
avoidance of accidental compiler or network execution in lightweight checks.

Compiler-backed CI now records the Ari `v0.1.0` tag, source commit, target,
archive SHA-256, and extracted BUILDINFO SHA-256 before running the explicit
compiler test mode. The release is a prerelease and GitHub marks it mutable, so
this is a pinned validation baseline rather than a compatibility claim.

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

Compiler-backed CI must pass its verified compiler path explicitly to
`scripts/test.sh`; the smoke suite then controls runtime compiler selection.

Future Ari-language implementation tests must follow current `ari-foundry/ari`
language usage.

The current source-controlled fixture set covers initial trailing-whitespace and
missing-final-newline cases. Exact list-rules and focused native JSON goldens,
plus their strict runner, now exist. Executable CLI and compiler-backed smoke
coverage also uses generated temporary cases, but no broad compiler/config/CLI
fixture-and-golden suite exists yet.
