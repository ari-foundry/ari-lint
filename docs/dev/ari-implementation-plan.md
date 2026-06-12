# Ari-language Implementation Plan

## Purpose

This document plans a future Ari-language implementation of `ari-lint`.

This document records the implementation direction and source-layout policy.
It does not move `tools/lint` or change build behavior.

## Current Status

- `ari-lint` is currently in skeleton/planning state.
- Source extraction has not happened.
- The Ari source skeleton has started with source-only files under `src/`.
- A minimal Ari main entry shell is now present. It delegates to the existing
  OS argv CLI entry path and returns the internal command exit-code mapping.
  The main-facing `--list-rules` path writes stdout through the verified stdout
  adapter, and the main-facing source-file lint path writes collected human
  diagnostics to stderr through the verified stderr adapter. The main-facing
  source-file `--json` path writes collected diagnostic JSON to stdout, and CLI
  help writes concise text to stdout. CLI parse problems write a short summary
  to stderr, missing source-file input writes a short summary to stderr, and
  source-file read errors write a short summary to stderr. It does not read
  environment variables, produce parse-error JSON, produce read-error JSON,
  discover config files, traverse directories, invoke the compiler, invoke
  `ari --check`, call `tools/lint`, or call process exit.
- The rule registry, severity, and config model skeleton has started as
  preparatory source-only declarations. The registry now constructs known
  entries for `lint/trailing-whitespace` and `lint/missing-final-newline` from
  the existing rule metadata without executing rules. A data-only lookup now
  accepts exact full rule codes for those entries and records that it does not
  execute rules or scan source. A registry-backed in-memory dispatch path now
  uses that lookup to run one explicit known rule wrapper over caller-provided
  source text without reading files, scanning the filesystem, applying config,
  writing output, serializing JSON, invoking the compiler, executing
  `ari --check`, or calling `tools/lint`.
- First planned rule metadata entries have been added for
  `lint/trailing-whitespace` and `lint/missing-final-newline`. Both rules now
  have in-memory execution over caller-provided source text. Registry-backed
  in-memory dispatch can select either known rule by exact full rule code.
  Lint aggregation, CLI dispatch, config, output, tests, and parity are not
  wired to that registry dispatch yet.
- The CLI metadata skeleton for the planned surface has started as metadata-only
  declarations for positional source input and the documented options `--json`,
  `--ari`, `-I`, `--list-rules`, `--config`, and `--rule`.
  Minimal token-list parsing has started for caller-provided tokens. Internal
  OS argv reading has started through a verified stdlib boundary.
- The CLI argument result model is now used by the minimal explicit-token
  parser for positional files, planned flags/options, optional compiler/config
  paths, include paths, raw rule override values, help requests, and parse
  problems. The parser now captures the explicit `--config` path value when one
  is provided, but still does not read config files or discover
  `ari-lint.rules`. A semantic parser now converts caller-provided `--rule`
  values into command-line-sourced internal severity overrides and parse
  problems. Actual OS process argument collection now has a minimal internal entry path;
  environment handling remains future work.
- An explicit OS argv boundary now exists in `src/cli.ari`. It reads process
  arguments through the verified Ari `std::env::args` API, drops argv[0], and
  reuses the existing explicit-token parser and stdout-free dispatcher. `main`
  now returns the resulting internal exit-code mapping from this path. The
  main-facing `--list-rules` branch writes the existing human-readable
  list-rules text through the verified stdout adapter, and source-file linting
  writes collected human diagnostics through the verified stderr adapter.
  Source-file `--json` output writes collected diagnostic JSON through stdout,
  and CLI help writes concise text through stdout. CLI parse problems write a
  short summary through stderr, missing source-file input writes a short
  summary through stderr, and source-file read errors write a short summary
  through stderr. The path does not read environment variables, call process
  exit, produce parse-error JSON, produce read-error JSON, invoke the compiler,
  or recursively scan sources.
- The diagnostic output metadata skeleton has started as data-only declarations
  for human and JSON output modes, diagnostic location fields, and planned
  diagnostic fields. The JSON serializer now builds one internal JSON object
  for one already-built diagnostic, including filePath, line, column, nullable
  endLine/endColumn, severity, ruleCode, message, and common string escaping,
  without claiming final schema stability. A minimal human-readable formatter
  now builds one newline-terminated diagnostic line in memory from an
  already-built diagnostic, and a related formatter joins caller-provided
  diagnostics into in-memory human-readable text. Rule and lint aggregation
  paths can now push full internal diagnostics into caller-provided vectors,
  and the main-facing source-file lint path writes those collected human
  diagnostics to stderr. A JSON array serializer now joins caller-provided
  diagnostics in memory by reusing the single-diagnostic serializer, and the
  main-facing source-file `--json` path writes that array to stdout. Read
  errors write a short stderr summary instead of JSON output. Executable
  serializer/output tests and final JSON schema stability remain future work.
- The source input boundary model has started for caller-provided source text,
  path-only source entries, and explicit single-file reads. It records internal
  source inputs without recursively scanning the filesystem, discovering config
  files, or running lint rules on its own.
- A file-read boundary now uses the verified Ari
  `std::fs::read_detailed(ref mut zone, path)` API to read one explicitly
  provided path into a source input while preserving `PathError` details. It
  does not scan directories, discover config files, apply config, write output,
  serialize JSON, invoke the compiler, execute lint rules over file sets, or
  call `tools/lint`.
- The trailing-whitespace rule now scans caller-provided in-memory source text
  and returns an internal diagnostic count plus the first already-built
  diagnostic for lines ending in spaces or tabs. It also has an internal
  collection path that pushes each trailing-whitespace diagnostic into a
  caller-provided vector, without reading files, scanning the filesystem,
  applying config, writing output, serializing JSON, invoking the compiler, or
  calling `tools/lint`.
- The missing-final-newline rule now scans caller-provided in-memory source
  text, computes final line/column metadata from those bytes, and returns an
  internal diagnostic count plus the first already-built diagnostic when
  non-empty content does not end with a newline. It also has an internal
  collection path that pushes the missing-final-newline diagnostic into a
  caller-provided vector, without reading files, scanning the filesystem,
  applying config, writing output, serializing JSON, invoking the compiler, or
  calling `tools/lint`.
- An in-memory lint run aggregation path now combines diagnostics from the
  trailing-whitespace and missing-final-newline in-memory rules for one
  caller-provided source text and preserves the first already-built internal
  diagnostic from those rule results. A related internal collection path pushes
  the full collected diagnostics into a caller-provided vector for in-memory
  source text and explicit single-file reads. It does not read config files,
  scan the filesystem, apply config, write output, serialize JSON, invoke the
  compiler, or call `tools/lint`.
- The CLI source-file dispatch path now reads the first explicitly provided
  file path through the file-read boundary and returns internal diagnostic
  count, first diagnostic, and read-error count data in the command result. It
  validates caller-provided `--rule` override values and reports parse problems
  without reading config files. A separate internal CLI collection path accepts
  explicit caller-provided tokens or parsed source-file input and pushes full
  internal diagnostics into a caller-provided vector while returning existing
  count and exit-code data. Parsed command-line `--rule` severity overrides are
  now applied to those collected diagnostics before main-facing human stderr or
  JSON stdout output. The main-facing OS argv path formats and writes those
  collected human diagnostics to stderr, or serializes and writes those
  collected diagnostics as JSON to stdout when `--json` is requested, through
  the verified output adapters. It does not discover config files, read config
  files, traverse directories, invoke the compiler, call `ari --check`, or call
  `tools/lint`. Source-file read errors write a short stderr summary and do not
  produce read-error JSON output yet.
- A source-only parity runner skeleton now records intended comparison
  boundaries against current `tools/lint`, with all execution, file IO, and
  output-comparison flags false. It does not run `tools/lint`, invoke an
  `ari-lint` binary, read fixtures, write files, compare output, invoke the
  compiler, call `ari --check`, or add CI parity behavior.
- An internal list-rules output path now records the known rule count for
  `lint/trailing-whitespace` and `lint/missing-final-newline`, and an internal
  human-readable list-rules formatter builds text from the same metadata.
  The main-facing OS argv `--list-rules` path now writes that text to stdout
  through the verified stdout adapter. JSON output, compiler invocation,
  config parsing, broader diagnostic output modes, and parity tests remain
  future work.
- An internal stdout-free command dispatcher now maps parsed CLI arguments to
  internal command results. It routes list-rules requests to the internal
  human-readable list-rules formatter and routes source-file requests through
  file reading plus in-memory lint aggregation. It validates parsed `--rule`
  overrides before source-file linting when provided, while the diagnostic
  collection path applies parsed `--rule` severity overrides to collected
  diagnostics. It keeps
  parse-problem, help, and missing-source command paths as internal command
  results. User-facing stdout/stderr output, JSON output, source
  scanning, compiler invocation, config-file parsing, diagnostics output, and
  parity tests remain future work.
- Internal command results now carry data-only exit-code mappings for success,
  usage-error, and unavailable command states. The model does not call process
  exit, run the CLI, read OS argv, write stdout/stderr, or claim stable
  user-facing exit behavior.
- An internal stdout/stderr output boundary model now records named stdout and
  stderr sinks plus result status for future output handling. It is data-only:
  it does not call real output APIs, write stdout/stderr, connect to OS argv or
  `main`, serialize JSON, or emit user-facing CLI output.
- A minimal stdout adapter and a minimal stderr adapter now write
  caller-provided `String` text through the verified Ari
  `std::io::print_string` and `std::io::eprint_string` APIs and return local
  status data. The stdout adapter is wired for the main-facing OS argv
  `--list-rules`, help, and source-file JSON diagnostic paths, and the stderr
  adapter is wired for source-file human diagnostics and parse problem
  summaries, missing-source summaries, and source-file read-error summaries.
  These adapters are not wired to process exit, compiler invocation, source
  scanning, or config discovery.
- An internal OS argv entry path now reads arguments through the verified Ari
  `std::env::args` API, drops the program-name argument, and dispatches the
  remaining user tokens through the existing explicit-token parser and
  stdout-free command dispatcher. `main` now returns the internal exit-code
  mapping from this path, and the main-facing `--list-rules` branch writes
  human-readable list-rules text to stdout. The main-facing help, source-file
  diagnostic, source-file JSON diagnostic, and parse problem output paths are
  also wired through verified output adapters. Missing source-file input writes
  a short stderr summary. Source-file read errors also write a short stderr
  summary. Config discovery, compiler invocation, detailed help parity, and
  tests remain future work.
- An internal explicit-token entry path now composes the existing
  caller-provided token-list parser with the stdout-free command dispatcher and
  returns a `CliCommandResult`. It does not read OS argv, environment variables,
  stdout/stderr, JSON, config files, source files, compiler output, or
  `tools/lint`. A related explicit-token diagnostic collection path parses the
  same caller-provided tokens and fills a caller-provided diagnostic vector
  without writing output or serializing JSON.
- A named explicit-token `--list-rules` command entry now builds the
  caller-provided `--list-rules` token list and reuses the existing parser,
  dispatcher, human-readable formatter, and exit-code mapping. It does not read
  OS argv, write stdout/stderr, call process exit, run a user-facing CLI
  process, serialize JSON, invoke the compiler, scan sources, or execute lint
  rules. A separate main-facing OS argv path now writes the same formatted text
  to stdout through the verified stdout adapter.
- The config override skeleton has been refined as metadata-only declarations
  for default config, `ari-lint.rules`, `--config`, `--rule`, rule severity
  overrides, and documented override precedence. A minimal caller-provided
  config text parser now handles `RULE = SEVERITY` lines, blank lines, and `#`
  comments, validates rule codes against the known rule registry, and returns
  internal overrides and parse problems. The command-line rule override parser
  now handles `RULE=SEVERITY` values for `--rule`,
  including documented short-name normalization for the two known rules.
  It now validates normalized `--rule` codes against the known rule registry
  and reports internal parse problems for unknown rules. A data-only severity
  override resolver now returns effective internal severity data for a
  caller-provided rule code and already-parsed override list without applying
  that data to lint execution. A single-diagnostic application helper now
  rebuilds one already-built diagnostic with the resolved severity.
  In-memory lint aggregation can now apply already-parsed overrides to
  diagnostics for caller-provided source text without reading config files.
  File-backed lint aggregation can now apply already-parsed overrides while
  reading explicitly provided source paths through the existing file-read
  boundary. An explicit config file parse boundary can now read one
  caller-provided config file path and parse its text into the existing
  internal override model without discovering `ari-lint.rules` or wiring CLI
  config behavior. `ari-lint.rules` discovery, CLI config integration, and
  config application remain future work.
- The config precedence fixture plan is documented in
  `docs/dev/config-precedence-fixtures.md`. It records future default,
  config-file, explicit `--config`, and command-line `--rule` precedence
  fixture areas. Initial fixture files now exist under
  `tests/fixtures/config-precedence/`, with shell-only executable checks for
  presence, exact line order, and key override values. They do not execute Ari
  parser code, read config files through CLI behavior, discover
  `ari-lint.rules`, run CLI tests, invoke the compiler, execute `ari --check`,
  or claim stable config behavior.
- The rule module layout has started with source-only child modules for the
  trailing whitespace and missing final newline rules.
  A minimal internal single-line helper has started for trailing whitespace,
  a minimal internal content helper has started for missing final newline, and
  internal diagnostic mapping skeletons have started for trailing whitespace and
  missing final newline.
  The trailing-whitespace mapping now feeds an in-memory rule execution
  function that produces an internal diagnostic count and keeps the first
  already-built diagnostic from caller-provided source text.
  The missing-final-newline mapping now feeds an in-memory rule execution
  function that computes final position metadata from caller-provided source
  text and produces an internal diagnostic count plus the first already-built
  diagnostic when the final newline is missing.
  A shared rule execution input/result API now gives both rule modules a common
  wrapper shape for caller-provided in-memory source text without reading
  files, scanning the filesystem, applying config, writing output, serializing
  JSON, invoking the compiler, executing `ari --check`, or calling
  `tools/lint`.
- Rule design notes have started:
  `docs/rules/trailing-whitespace.md` records the current in-memory
  `lint/trailing-whitespace` behavior, and
  `docs/rules/missing-final-newline.md` records the current in-memory
  `lint/missing-final-newline` behavior. File-backed linting, CLI integration,
  config integration, output behavior, and tests remain future work.
- Source directories should contain Ari source files only; source-layout
  documentation belongs in `docs/dev/` or other documentation directories.
- A local build scaffold now exists at `scripts/build.sh`. It requires an
  explicit Ari compiler path, compiles `src/main.ari` to `build/ari-lint` using
  the verified `ari input.ari -o output` invocation form, resolves the
  repository root, uses the compiler root when `lib/std.arih` is available
  there, and is not run by CI.
- A local standalone test entrypoint now exists at `scripts/test.sh`. It
  resolves the repository root and delegates to `scripts/check.sh`, so it
  currently runs only compiler-free repository-shape and fixture-invariant
  checks. It does not run the Ari compiler, invoke `ari --check`, execute
  `tools/lint`, run CLI tests, run parity checks, install dependencies, or use
  package manager commands.
- The initial release and compatibility policy is documented in
  `docs/dev/release-compatibility-policy.md`. It uses Ari releases and tags as
  read-only references only and does not claim support for any Ari release,
  tag, or commit.
- The CI compiler-backed check gate is documented. The GitHub Actions workflow
  remains compiler-free and runs only `scripts/check.sh` until explicit Ari
  compiler provisioning, standalone tests, and compiler identity recording are
  ready.
- The existing `tools/lint` implementation remains in `ari-foundry/ari` as the
  current bundled/reference implementation.
- The future direction is Ari-language reimplementation in `ari-lint`.
- Behavior parity with current `tools/lint` is the intended transition path.
- The near-term dependency model remains invoking `ari --check`.
- Future Ari compiler provisioning for compiler-backed behavior is planned in
  `docs/dev/compiler-provisioning.md`. Compiler invocation remains future work.
- Future Ari compiler invocation selection through `--ari PATH` or
  `ARI_COMPILER` is planned in `docs/dev/compiler-invocation.md`. Compiler
  invocation remains future work.

## Reference Implementation

`tools/lint` in `ari-foundry/ari` is the reference implementation during the
transition.

Use it to understand current CLI behavior, lint rules, diagnostics, config
handling, and integration with `ari --check`.

Do not copy `tools/lint` wholesale into `ari-lint`. Any behavior mismatch
between the future Ari-language implementation and current `tools/lint` should
be tracked explicitly.

## Ari Language Source Of Truth

Ari language syntax and idioms must be checked against `ari-foundry/ari` docs,
examples, and tests.

Do not invent Ari syntax. Do not add Ari examples unless they are verified
against current Ari usage.

If Ari language/toolchain limitations block implementation, file issues in
`ari-foundry/ari`.

Reference locations:

- `ari-foundry/ari` `README.md`
- `ari-foundry/ari` `docs/README.md`
- `ari-foundry/ari` language docs, if present
- `ari-foundry/ari` examples
- `ari-foundry/ari` `tests/cases`

## Implementation Phases

### Phase 0: documentation and planning

- repo skeleton
- docs migration plan
- Ari implementation plan
- no source yet

### Phase 1: Ari source skeleton

- add minimal Ari project layout
- no real lint rules yet
- document source layout and build assumptions in docs, not in source-directory
  README files
- keep checks lightweight

### Phase 2: CLI shell

- record CLI surface metadata before implementing parsing
- parse planned CLI options from explicit caller-provided token lists
- accept source paths
- accept `--ari` path if feasible
- do not claim stable behavior until tested

### Phase 3: internal lint model

- define internal diagnostic representation
- define severity values, rule descriptors, registry entries, and config
  override data shapes
- record config override metadata before implementing config parsing, config
  discovery, or severity override application
- record diagnostic output metadata before implementing formatting or JSON
  serialization
- map lint diagnostics to documented output expectations
- keep JSON schema follow-up explicit

Current preparatory model skeleton files are source-only placeholders:

- `src/main.ari` defines a minimal main entry shell and delegates `main` through
  a local `run_main_entry_shell` function. The shell calls the existing OS argv
  CLI entry path and returns the internal exit-code mapping. It does not invoke
  the compiler, call `ari --check`, call `tools/lint`, or call process exit.
  Scoped main-facing stdout/stderr output is delegated through the CLI layer's
  verified adapters.
- `src/model.ari` groups future model modules.
- `src/source.ari` defines the internal source input boundary model for
  caller-provided source text, path-only source entries, and path-list inputs
  from already-parsed CLI paths. It now also defines the explicit file-read
  boundary for one caller-provided path using
  `std::fs::read_detailed(ref mut zone, path)`. It does not walk directories,
  discover config files, invoke the compiler, produce diagnostics, or execute
  lint rules. File reads return source text directly to the caller rather than
  storing owned text in a source struct.
- `src/lint.ari` defines in-memory lint run aggregation over one
  caller-provided source text and file-backed aggregation for explicitly
  provided file paths. The default aggregation combines diagnostic counts from
  the in-memory trailing-whitespace and missing-final-newline rule execution
  paths and preserves the first already-built internal diagnostic without
  reading config. File-backed aggregation preserves the first diagnostic across
  explicit source paths. Separate with-overrides variants preserve the same
  count and first-diagnostic shape while recording that config data was
  supplied. They do not read config files, discover `ari-lint.rules`, scan the
  filesystem, write output, serialize JSON, invoke the compiler, or call
  `tools/lint`.
- `src/cli.ari` sketches planned CLI option metadata for positional source file
  input, `--json`, `--ari`, `-I`, `--list-rules`, `--config`, and `--rule`,
  including each option's purpose, value requirement, and repeatability. It
  also defines a CLI argument result model and a minimal explicit-token parser
  for caller-provided token lists, including positional files, requested
  output/list/help flags, optional compiler path presence, explicit config path
  capture, include paths, raw rule override entries, missing-value problems,
  and unknown-argument problems. It does not read the captured config path or
  discover `ari-lint.rules`. It also exposes a semantic `--rule` parser bridge
  that converts raw
  rule override values into the internal config override model and parse
  problems. Source-file dispatch validates parsed rule overrides before
  file-backed linting. It
  also defines an internal stdout-free command result model and a dispatcher
  that routes list-rules requests to internal formatted text and routes
  source-file requests through file reading plus in-memory lint aggregation
  while carrying the first internal diagnostic and keeping other command paths
  as explicit future-work placeholders, plus an internal exit-code mapping
  carried by command results, plus an internal explicit-token entry function
  that composes parsing and dispatch. It also has
  a named explicit-token `--list-rules` command path that reaches formatted
  text and exit-code data through that existing pipeline. It also defines an OS
  argv integration path that reads process arguments through verified
  `std::env::args`, drops argv[0], and dispatches through the existing
  explicit-token path. It does not read environment variables, read config
  files, discover config files, or call process exit.
  `main` returns the internal exit-code mapping from that path, and the scoped
  main-facing paths
  write list-rules/help/JSON text to stdout plus diagnostics, parse problems,
  missing-source summaries, and file-read-error summaries to stderr through the
  verified adapters.
- `src/severity.ari` sketches planned severity values: off, hint, note,
  warning, and error.
- `src/diagnostic.ari` sketches diagnostic concepts such as file path, line,
  column, optional end position, severity, rule code, and message. It now also
  has a small source-span constructor used by the trailing-whitespace and
  missing-final-newline mapping skeletons; it does not format output or
  serialize JSON.
- `src/output.ari` sketches diagnostic output metadata for human-readable and
  JSON output modes, diagnostic location, file path, line, column, endLine,
  endColumn, severity, rule code, and message. It also defines an internal
  single-diagnostic JSON serializer, list-rules output row model, a known-rule
  output count builder from existing rule metadata, an internal human-readable
  list-rules formatter, and a data-only stdout/stderr output boundary model for
  named future output sinks. It now includes a minimal human-readable formatter
  for one already-built diagnostic, a human-readable formatter for
  caller-provided diagnostic arrays, an internal JSON array serializer for
  caller-provided diagnostics, plus minimal stdout and stderr adapters that use
  the verified Ari `std::io::print_string` and
  `std::io::eprint_string` APIs for caller-provided `String` text and return
  local status data. It does not collect diagnostics from rule execution,
  read OS argv, or run the CLI. The CLI layer now calls the stdout adapter for
  main-facing `--list-rules` output, help text, and source-file JSON
  diagnostics, and the stderr adapter is wired for source-file human
  diagnostics, parse problem summaries, missing-source summaries, and
  source-file read-error summaries.
- `src/rule.ari` sketches rule metadata concepts such as rule code, short name,
  default severity, and description, and exposes a small constructor for
  internal rule descriptors. It also defines shared rule execution input/result
  shapes and constructors for caller-provided in-memory source text. The shared
  rule API records that it does not read files, scan the filesystem, write
  output, serialize JSON, invoke the compiler, execute `ari --check`, or call
  `tools/lint`.
- `src/registry.ari` constructs a known rule registry from the existing
  `lint/trailing-whitespace` and `lint/missing-final-newline` metadata entries.
  It records reference-only registry entries, provides a data-only lookup for
  exact full rule codes, and provides registry-backed in-memory dispatch for
  one explicit known rule code over caller-provided source text. Lookup remains
  data-only. Dispatch does not read files, scan the filesystem, apply config,
  write output, serialize JSON, invoke the compiler, execute `ari --check`, or
  call `tools/lint`.
- `src/rules.ari` records the first planned rule metadata entries for
  `lint/trailing-whitespace` and `lint/missing-final-newline`, including their
  short names, default `warning` severity from the current Ari lint docs, and
  brief descriptions. It now provides concrete metadata value constructors for
  internal callers, without implementing rule behavior.
- `src/config.ari` sketches config override metadata such as default config,
  `ari-lint.rules` config source, explicit `--config` file path, `--rule`
  command-line override, rule severity override, and override precedence. It
  records the documented reference order that config-file settings precede
  command-line `--rule` overrides, and that explicit `--config` disables
  discovery. It now parses caller-provided config text with blank lines,
  comments, and `RULE = SEVERITY` entries into internal overrides and parse
  problems after validating rule codes against the known rule registry. It also
  parses caller-provided command-line rule override text in `RULE=SEVERITY`
  form, normalizing documented short rule names into full lint rule codes and
  validating those codes against the known rule registry. It also resolves
  effective severity data for a caller-provided rule code from an already-parsed
  override list and can rebuild one already-built diagnostic with that resolved
  severity. It can read and parse one explicit caller-provided config file path
  into internal override data. It does not discover config files, read
  `ari-lint.rules`, inspect CLI arguments, run lint rules, or apply config to
  lint execution.

These files do not implement user-facing rule execution,
argument validation, diagnostics output, JSON serialization, or `ari --check`
invocation. The trailing-whitespace and missing-final-newline rule
execution paths are limited to caller-provided in-memory source text, the main
entry shell is limited to returning the internal exit-code mapping from the OS
argv CLI entry path, the OS argv entry path is limited to reading
`std::env::args`, dropping argv[0], dispatching internal tokens, and writing
stdout only for the `--list-rules` command through the verified adapter,
the CLI parser is limited to explicit caller-provided token lists, raw option
values, and explicit `--config` path capture without reading that path,
the config parser is limited to caller-provided text, rule/severity
pairs, blank lines, comments, known-rule validation, and one explicit
caller-provided config file path without discovery or CLI integration, the rule override
parser is limited to caller-provided `--rule` text, internal override
construction, and known-rule validation, the severity override resolver is
limited to effective severity data for a caller-provided rule code and
already-parsed overrides, the diagnostic severity application helper is limited
to rebuilding one already-built internal Diagnostic with resolved severity, the
diagnostic JSON serializers are limited to one internal diagnostic object and
one caller-provided diagnostic array,
the source input boundary is limited to caller-provided source text and
path-only entries, the default lint run aggregation path is limited to combining
diagnostic counts and preserving the first already-built diagnostic for one
caller-provided in-memory source text, the in-memory override aggregation path
is limited to preserving that count and first-diagnostic result shape when
already-parsed severity overrides are supplied,
the file-backed override aggregation path is limited to reading explicitly
provided source paths through the file-read boundary and preserving diagnostic
counts plus the first diagnostic,
the file-read boundary is limited to reading one explicitly provided path with
the verified Ari `std::fs::read_detailed` API and preserving file read errors,
the CLI file lint path is limited to explicit source-file arguments, the
file-read boundary, in-memory lint aggregation, optional parsed `--rule`
override validation, internal diagnostic counts, the first internal diagnostic,
and internal read-error counts,
the known-rule registry lookup is limited to returning internal data for exact
full rule codes, registry-backed rule dispatch is limited to selecting one
known in-memory rule wrapper for caller-provided source text,
the list-rules formatter is limited to internal text construction, the command
dispatcher is limited to stdout-free internal command results, the exit-code
model is limited to internal data carried by those results, the explicit-token
`--list-rules` command path is limited to caller-provided token construction,
the main-facing `--list-rules` stdout path is limited to writing that formatted
text through the stdout adapter, the main-facing help path is limited to
concise stdout text, the stdout and stderr adapters are limited to
caller-provided `String` text, the main-facing source-file read-error path is
limited to a short stderr summary without read-error JSON output, and the
stdout/stderr output boundary is limited to status data for named future sinks.
Compiler invocation, config discovery, config file reading, override
application to lint execution, diagnostics output, stderr writing, stdout
adapter wiring beyond the scoped main-facing output paths, process exit, JSON
schema stability, environment handling, source
filesystem scanning, directory traversal, main-entry tests, argv-boundary tests, OS-argv
integration tests, config parser tests, rule override parser tests, severity
resolution tests, diagnostic severity application tests, diagnostic JSON
serializer tests, source input tests,
trailing-whitespace execution tests, missing-final-newline execution tests,
output-boundary tests,
stdout-adapter tests, exit-code tests, list-rules command tests, parser tests,
dispatcher tests, and
explicit-token entry tests remain future work. Registry-backed dispatch is not
yet wired into lint aggregation or CLI behavior. Severity parsing, CLI/config
override behavior, rule registration behavior, directory traversal policy,
file-backed lint command behavior, and the JSON schema are not stable yet.

The local build scaffold is not compiler-backed CI or full build validation.
Compiler-backed CI, standalone test execution, compiler provisioning in CI,
and compatibility validation remain future work.

The local standalone test entrypoint is not a full executable test suite.
`scripts/test.sh` resolves the repository root and delegates to
`scripts/check.sh` only. Compiler-backed tests, CLI tests, rule execution
tests, parity checks, golden output comparison, package manager commands, and
CI compiler execution remain future work.

Standalone build wiring is local-only. `scripts/build.sh` resolves the
repository root, requires an explicit compiler path or `ARI_COMPILER`, writes
`build/ari-lint`, preserves relative compiler paths from the caller's
directory, and remains separate from the lightweight check workflow.

The compiler-backed CI gate keeps `.github/workflows/check.yml` limited to
lightweight repository checks. It does not run `scripts/build.sh`, invoke the
Ari compiler, invoke `ari --check`, download or build the compiler, run package
manager commands, execute `tools/lint`, run parity checks, or claim
compatibility.

Config precedence is recorded from the current Ari lint reference docs. The
minimal parser only handles caller-provided text. Initial config precedence
fixture files and shell-only executable checks now exist, but standalone config
discovery and Ari-backed config precedence checks remain needs follow-up before
this repository claims stable config behavior. The fixture plan is documented in
`docs/dev/config-precedence-fixtures.md`.

The exact JSON schema and human-readable diagnostic text remain unstable and
need follow-up before this repository claims standalone output compatibility.

### Phase 4: first rules

- start rule module layout before implementing rule behavior
- use `docs/rules/trailing-whitespace.md` and
  `docs/rules/missing-final-newline.md` as rule design notes
- turn metadata entries into executable rule registrations when Ari syntax and
  toolchain support are ready
- implement `lint/trailing-whitespace` over caller-provided in-memory source
- implement `lint/missing-final-newline` over caller-provided in-memory source
- add a file-read boundary for one caller-provided path after verifying the
  Ari `std::fs` API
- route explicit source-file CLI input through file reading and in-memory lint
  aggregation as internal command data
- compare behavior with reference implementation

Current rule module state:

- `src/rules.ari` exposes planned child rule modules and keeps shared rule
  metadata entries.
- `src/rules/trailing_whitespace.ari` records layout metadata, a minimal
  internal single-line helper, diagnostic mapping for one already-split line,
  and in-memory rule execution for caller-provided source text. The in-memory
  execution returns an internal diagnostic count, has a shared rule module API
  wrapper for caller-provided in-memory source input, and records that it does
  not read files or scan the filesystem.
- `src/rules/missing_final_newline.ari` records layout metadata and a minimal
  internal content helper for the `lint/missing-final-newline` implementation.
  It also records diagnostic mapping and in-memory rule execution for
  caller-provided source text. The in-memory execution computes final
  line/column metadata from caller-provided bytes, returns an internal
  diagnostic count plus the first already-built diagnostic, has a shared rule
  module API wrapper for
  caller-provided in-memory source input, and records that it does not read
  files or scan the filesystem.
- `src/lint.ari` combines diagnostic counts and the first already-built
  diagnostic from the in-memory
  trailing-whitespace and missing-final-newline rule execution paths for one
  caller-provided source text or explicitly provided file paths, recording that
  it does not scan the filesystem, write output, serialize JSON, invoke the
  compiler, or call `tools/lint`. Its with-overrides variants preserve the same
  count and first-diagnostic shape for in-memory source text or explicitly
  provided file paths without reading config files or wiring config-file
  behavior. Diagnostic collection variants can rewrite collected diagnostic
  severity from already-parsed overrides.
- `src/registry.ari` can dispatch one exact known rule code to the corresponding
  in-memory rule wrapper for caller-provided source text. It returns structured
  found/not-found dispatch data and does not read files, scan the filesystem,
  apply config, write output, serialize JSON, invoke the compiler, execute
  `ari --check`, or call `tools/lint`.

The rule implementations only handle caller-provided bytes in memory. These
rule module files do not implement file reading, filesystem scanning, config
parsing, CLI parsing, diagnostics output, JSON serialization, compiler
invocation, tests, or CI. File-backed aggregation beyond explicit source paths,
CLI config integration, config discovery, user-facing output, JSON diagnostic
arrays, tests, and parity checks remain future work.

The source input file-read boundary reads one explicitly provided path into a
source input using `std::fs::read_detailed`. It does not scan directories,
discover config, apply config, run lint rules over file sets, produce output,
serialize JSON, invoke the compiler, call `ari --check`, or call `tools/lint`.

The CLI file lint path reads the first explicit source-file argument, runs the
in-memory lint aggregation for successfully read files, validates parsed
`--rule` overrides when provided, preserves read errors, and carries counts
plus the first internal diagnostic in `CliCommandResult`. The main-facing OS
argv path now also collects source-file diagnostics into a caller-provided
vector, applies parsed command-line `--rule` severity overrides to those
collected diagnostics, formats them as human diagnostics, and writes them to
stderr through the verified stderr adapter. It can also serialize those
collected source-file diagnostics as JSON to stdout when `--json` is requested.
CLI parse problems write a short summary to stderr. Source-file read errors
write a short stderr summary and do not produce read-error JSON output. It does
not produce parse-error JSON, discover config files, read config files,
traverse directories, invoke the compiler, call `ari --check`, call
`tools/lint`, or call process exit.

### Phase 5: compiler boundary

- invoke `ari --check`
- handle compiler failures
- combine compiler-backed diagnostics with lint diagnostics
- preserve behavior parity where possible
- use the compiler provisioning plan in `docs/dev/compiler-provisioning.md`
  before adding compiler-backed tests or CI compiler setup
- use the compiler invocation plan in `docs/dev/compiler-invocation.md` before
  implementing `--ari`, `ARI_COMPILER`, or compiler execution

### Phase 6: standalone tests and CI

- add a local standalone test entrypoint for lightweight checks
- add fixtures
- add golden JSON diagnostics when schema is stable
- run tests with explicit `--ari` compiler path
- add compiler-backed CI only after compiler provisioning, standalone tests,
  and compiler identity recording are ready

The source-only parity runner skeleton in `src/parity.ari` records the future
comparison boundary. It does not execute `tools/lint`, execute `ari-lint`, read
fixtures, compare outputs, invoke the compiler, or run in CI.

## Parity Strategy

Parity should be checked against the current bundled `tools/lint`
implementation.

A source-only parity runner skeleton names current `tools/lint` as the
reference implementation and the Ari-language `ari-lint` implementation as the
future implementation under test. It is not an executable parity runner and
does not compare output.

Parity dimensions:

- CLI options
- rule names
- severity names
- config handling
- diagnostic locations
- JSON output shape
- exit behavior
- interaction with `ari --check`

Unclear or unstable behavior should be marked as:

needs follow-up

## Issue Routing

compiler bugs belong in ari-foundry/ari issues.

standard library bugs belong in ari-foundry/ari issues.

Ari language/toolchain limitations belong in `ari-foundry/ari` issues.

`ari-lint` issues should focus on lint tooling, lint rules, config,
diagnostics, docs, tests, and Ari-language implementation.

If a bug crosses the boundary, file the root cause in `ari-foundry/ari` and
link it from `ari-lint` if needed.

## Release And Compatibility

`ari-lint` has no stable release yet.

Compatibility claims must not be invented.

The initial policy is documented in
`docs/dev/release-compatibility-policy.md`.

Future compatibility must reference real Ari releases and tags:

- https://github.com/ari-foundry/ari/releases
- https://github.com/ari-foundry/ari/tags

Compatibility matrix updates should wait until `ari-lint` source and tests are
usable.

## Risks

- Ari language/toolchain may not yet support everything needed for `ari-lint`.
- Invoking `ari --check` from Ari code may require runtime/process support.
- JSON diagnostic schema may still be unstable.
- Human-readable diagnostic text may still be unstable.
- CLI parity may be hard to preserve exactly.
- Tests may depend on a compatible Ari compiler binary.
- Source layout may change after implementation starts.
- Registry, severity, and config shapes may change when real rule execution,
  config discovery, rule override validation, and override application begin.
- Rule module boundaries may change once real rule behavior and shared rule
  execution APIs are designed.
- Standalone config discovery and override precedence may need fixtures before
  they become stable behavior.
- Metadata value construction may change once Ari constant or value syntax is
  selected for the standalone implementation.
- CLI metadata value construction may change once Ari constant or collection
  syntax is selected for the standalone implementation.
- Diagnostic output and internal list-rules value construction may change once
  broader Ari constant or collection syntax is selected for the standalone
  implementation.
- Source directories may accidentally collect README-style documentation unless
  docs stay under `docs/`.
- The source-only parity runner skeleton may be mistaken for an executable
  runner unless docs and checks continue to state that execution remains future
  work.
- Compiler-backed CI may be added too early unless the lightweight workflow
  continues to guard against implicit compiler execution.

## Follow-up Checklist

- [ ] Confirm current Ari language docs and examples
- [ ] Define initial Ari source layout
- [ ] Identify Ari runtime/process support needed for invoking `ari --check`
- [ ] Define minimal CLI parser strategy
- [ ] Define concrete CLI metadata value construction after Ari syntax choices
      are verified
- [ ] Define diagnostic data model
- [ ] Define concrete diagnostic output metadata value construction after Ari
      syntax choices are verified
- [ ] Define stable JSON schema and human-readable diagnostic text policy
- [x] Add minimal internal diagnostic JSON serialization placeholder for one diagnostic
- [x] Add internal diagnostic JSON field serialization for one diagnostic
- [x] Add internal diagnostic JSON array serialization for caller-provided diagnostics
- [x] Add source input boundary model without file IO or filesystem scanning
- [ ] Define registry, severity, and config model behavior after source
      skeletons compile in the real build
- [x] Add known rule registry construction from existing rule metadata without
      executing rules, applying config, scanning sources, emitting diagnostics,
      or invoking the compiler
- [x] Add data-only known rule registry lookup by exact full rule code without
      executing rules, applying config, scanning sources, emitting diagnostics,
      or invoking the compiler
- [x] Add registry-backed in-memory rule dispatch for one exact known rule code
      over caller-provided source text without reading files, scanning the
      filesystem, applying config, emitting output, serializing JSON, invoking
      the compiler, executing `ari --check`, or calling `tools/lint`
- [x] Add minimal caller-provided config text parsing
- [x] Add known-rule validation for caller-provided config text without reading
      config files, discovering config paths, applying overrides, scanning
      sources, emitting diagnostics, or invoking the compiler
- [x] Add minimal command-line rule override semantic parsing
- [x] Add known-rule validation for caller-provided `--rule` override values
      without applying overrides, reading config files, scanning sources,
      emitting diagnostics, or invoking the compiler
- [x] Add data-only severity override resolution for a caller-provided rule code
      and already-parsed overrides without reading config files, mutating
      diagnostics, applying config to lint execution, emitting output, scanning
      sources, or invoking the compiler
- [x] Add single-diagnostic severity override application for one already-built
      diagnostic and already-parsed overrides without reading config files,
      running lint rules, applying config to lint execution, emitting output,
      serializing JSON, scanning sources, or invoking the compiler
- [x] Add count-based in-memory lint aggregation with already-parsed severity
      override inputs over caller-provided source text without reading config
      files, discovering config paths, integrating with command dispatch,
      reading files, scanning the filesystem, emitting output, serializing JSON,
      invoking the compiler, executing `ari --check`, or calling `tools/lint`
- [x] Add count-based file-backed lint aggregation with already-parsed severity
      override inputs over explicitly provided source paths without reading
      config files, discovering config paths, integrating with command dispatch,
      traversing directories, emitting output, serializing JSON, invoking the
      compiler, executing `ari --check`, or calling `tools/lint`
- [x] Validate caller-provided `--rule` overrides in the internal CLI file lint
      path without reading config files, discovering config paths, traversing
      directories, emitting output, serializing JSON, invoking the compiler,
      executing `ari --check`, calling `tools/lint`, or calling process exit
- [x] Apply parsed command-line `--rule` severity overrides to source-file
      diagnostic collection for explicit token and main-facing paths without
      reading config files, discovering config paths, traversing directories,
      invoking the compiler, executing `ari --check`, calling `tools/lint`,
      adding tests, or calling process exit
- [x] Add a config precedence fixture plan before claiming stable config
      behavior without adding fixture files, reading config files, discovering
      config paths, running CLI tests, emitting output, serializing JSON,
      invoking the compiler, executing `ari --check`, or calling `tools/lint`
- [x] Add initial config precedence fixture files and lightweight checks without
      parser execution, config discovery, CLI tests, output, JSON, compiler
      execution, `ari --check`, or `tools/lint`
- [x] Add shell-only executable config precedence fixture checks without parser
      execution, config discovery, CLI tests, output, JSON, compiler execution,
      `ari --check`, or `tools/lint`
- [x] Add an explicit config file parse boundary that reads one caller-provided
      config path and parses it into existing override data without
      discovering `ari-lint.rules`, wiring CLI config behavior, applying config,
      emitting output, serializing JSON, invoking the compiler, executing
      `ari --check`, or calling `tools/lint`
- [ ] Add Ari-backed config precedence checks before claiming stable config
      behavior
- [x] Define executable rule module API after the initial layout and in-memory
      rule execution shape are validated, without file IO, filesystem scanning,
      config application, output, JSON, compiler invocation, `ari --check`, or
      `tools/lint`
- [x] Add in-memory trailing-whitespace rule execution without file IO or
      filesystem scanning
- [x] Add in-memory missing-final-newline rule execution without file IO or
      filesystem scanning
- [x] Add in-memory lint run aggregation without file IO or filesystem scanning
- [x] Capture the first already-built internal diagnostic at lint aggregation
      boundaries without collecting full diagnostic arrays, writing output,
      serializing JSON, invoking the compiler, executing `ari --check`, calling
      `tools/lint`, or calling process exit
- [x] Add file read boundary for one caller-provided path using verified
      `std::fs::read_detailed`
- [x] Add internal CLI file lint path over explicit source-file arguments
- [x] Carry the first already-built internal diagnostic from source-file lint
      aggregation into the internal CLI command result without writing output,
      serializing JSON, invoking the compiler, executing `ari --check`, calling
      `tools/lint`, or calling process exit
- [x] Wire the main-facing source-file lint path to write the first diagnostic
      to stderr through the verified stderr adapter without full diagnostic
      arrays, JSON output, config discovery, compiler invocation,
      `ari --check`, `tools/lint`, or process exit
- [x] Add internal diagnostic vector collection for in-memory and explicit
      file-backed linting through caller-provided vectors without CLI
      diagnostic-array carrying, user-facing full diagnostic output, JSON
      output, config discovery, compiler invocation, `ari --check`,
      `tools/lint`, or process exit
- [x] Add internal CLI diagnostic vector collection for explicit
      caller-provided tokens and parsed source-file input through
      caller-provided vectors without changing main-facing output, emitting
      full diagnostic arrays, JSON output, config discovery, compiler
      invocation, `ari --check`, `tools/lint`, or process exit
- [x] Wire the main-facing source-file lint path to format and write collected
      human diagnostics to stderr through the verified stderr adapter without
      JSON output, config discovery, compiler invocation, `ari --check`,
      `tools/lint`, or process exit
- [x] Wire the main-facing source-file `--json` path to serialize collected
      diagnostics and write them to stdout through the verified stdout adapter
      without parse-error JSON output, config discovery, compiler invocation,
      `ari --check`, `tools/lint`, or process exit
- [x] Wire the main-facing CLI parse problem path to write a short usage-error
      summary to stderr through the verified stderr adapter without
      parse-error JSON output, config discovery, compiler
      invocation, `ari --check`, `tools/lint`, or process exit
- [x] Wire the main-facing CLI help path to write concise help text to stdout
      through the verified stdout adapter without config discovery, compiler
      invocation, `ari --check`, `tools/lint`, or process exit
- [x] Wire the main-facing missing source-file path to write a short
      usage-error summary to stderr through the verified stderr adapter without
      config discovery, compiler invocation, `ari --check`, `tools/lint`, or
      process exit
- [x] Wire the main-facing source-file read-error path to write a short
      unavailable summary to stderr through the verified stderr adapter without
      read-error JSON output, config discovery, compiler invocation,
      `ari --check`, `tools/lint`, or process exit
- [x] Add source-only parity runner skeleton without executing `tools/lint`,
      `ari-lint`, the Ari compiler, shell commands, file IO, or comparisons
- [x] Record compiler-backed CI gate without running the Ari compiler,
      `ari --check`, `tools/lint`, package managers, or release automation
- [x] Wire local standalone build script root handling without running the Ari
      compiler in CI or adding package manager files
- [x] Add a local standalone test entrypoint that resolves the repository root
      and delegates to `scripts/check.sh` only; executable rule, CLI,
      compiler-backed, parity, and golden-output tests remain future work
- [x] Define the initial release and compatibility policy without adding a
      release workflow, compatibility matrix, compiler-backed CI, or Ari
      version support claims
- [x] Wire `main` to the existing OS argv CLI entry path and return the internal
      command exit-code mapping without writing stdout/stderr, serializing JSON,
      discovering config files, traversing directories, invoking the compiler,
      executing `ari --check`, calling `tools/lint`, or calling process exit
- [x] Wire the main-facing OS argv `--list-rules` branch to stdout through the
      verified stdout adapter without writing stderr, serializing JSON,
      printing diagnostics, invoking the compiler, executing `ari --check`,
      calling `tools/lint`, or calling process exit
- [x] Add a minimal stderr adapter through the verified `std::io::eprint_string`
      API without wiring diagnostics, writing stdout, serializing JSON,
      invoking the compiler, executing `ari --check`, calling `tools/lint`, or
      calling process exit
- [x] Add a minimal internal human-readable diagnostic formatter for one
      already-built diagnostic without writing stderr, wiring CLI output,
      serializing diagnostic arrays, invoking the compiler, executing
      `ari --check`, calling `tools/lint`, or calling process exit
- [x] Replace the single-diagnostic JSON placeholder with internal field
      serialization for one already-built diagnostic without writing
      stdout/stderr, wiring CLI output, serializing diagnostic arrays, invoking
      the compiler, executing `ari --check`, calling `tools/lint`, or calling
      process exit
- [x] Add internal JSON array serialization for caller-provided diagnostics
      without collecting diagnostics from rule execution, writing stdout/stderr,
      wiring CLI output, invoking the compiler, executing `ari --check`,
      calling `tools/lint`, or calling process exit
- [x] Add a minimal internal human-readable diagnostic array formatter for
      caller-provided diagnostics without collecting diagnostics from rule
      execution, writing stderr, wiring CLI output, serializing JSON, invoking
      the compiler, executing `ari --check`, calling `tools/lint`, or calling
      process exit
- [x] Capture the first already-built internal diagnostic from in-memory
      `lint/trailing-whitespace` execution without collecting full diagnostic
      arrays, writing output, serializing JSON, invoking the compiler, executing
      `ari --check`, calling `tools/lint`, or calling process exit
- [x] Capture the first already-built internal diagnostic from in-memory
      `lint/missing-final-newline` execution without collecting full diagnostic
      arrays, writing output, serializing JSON, invoking the compiler,
      executing `ari --check`, calling `tools/lint`, or calling process exit
- [ ] Define concrete metadata value construction after Ari syntax choices are
      verified
- [ ] Define parity test fixtures against current `tools/lint`
- [ ] Decide when to add first Ari source files
- [ ] Track Ari compiler/toolchain blockers in `ari-foundry/ari` issues

## Explicit Non-Goals

- Do not move `tools/lint` in this step.
- Do not copy `tools/lint` source in this step.
- Do not add user-facing CLI/output integration beyond the scoped
  main-facing output paths in this step.
- Do not add tests in this step.
- Do not add release workflows in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.
- Do not file compiler or standard library bugs in `ari-lint` as primary
  issues.
