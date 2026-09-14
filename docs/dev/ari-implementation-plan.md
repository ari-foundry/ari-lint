# Ari-language Implementation Plan

## Purpose

This document tracks the current and planned Ari-language implementation of
`ari-lint`.

This document records the implementation direction and source-layout policy.
It does not move `tools/lint` or change build behavior.

## Current Status

- `ari-lint` is now an active standalone split implementation with
  Ari-language source under `src/`.
- The implementation remains pre-release and compatibility is not claimed yet.
  Current `tools/lint` in `ari-foundry/ari` remains the reference
  implementation while parity work is still planned.
- Local standalone build wiring exists through `scripts/build.sh`, local smoke
  validation exists through `scripts/smoke.sh`, and `scripts/test.sh` provides
  a deterministic compiler-free default plus an explicit compiler-backed mode.
- A minimal Ari main entry shell is now present. It delegates to the existing
  OS argv CLI entry path and returns the internal command exit-code mapping.
  The main-facing `--list-rules` path writes stdout through the verified stdout
  adapter. Source runs write reference-shaped human or JSON output to stdout;
  the JSON envelope retains every positional file, and enabled diagnostics
  return exit `1`. CLI help writes concise text to stdout.
  CLI parse problems, missing source-file input, and explicit config read or
  parse failures use stderr. Bad lines in a discovered config become ordered
  per-file `lint/config` diagnostics on stdout. Source commands select an Ari
  compiler from `--ari`, `ARI_COMPILER`, or `build/ari`, invoke it once per
  positional source, and combine compiler, config, and native diagnostics.
  Compiler-visible source read failures therefore use the reference per-file
  output path. The CLI does not produce parse-error JSON, search
  home/global/XDG config locations, recursively discover source files, call
  `tools/lint`, or call process exit directly.
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
  problems. The parser now retains all positional source file paths while
  keeping `first_source_file` as compatibility metadata. It captures the
  explicit `--config` path value when one is provided. Source-file diagnostic
  collection can read that one config for every source and disable discovery,
  or when `--config` is absent search lexically upward from each source file's
  directory for its nearest readable `ari-lint.rules`. Command-line `--rule`
  overrides are applied after the selected config for every source. A semantic
  parser now converts caller-provided `--rule` values into command-line-sourced
  internal severity overrides and parse problems. Actual OS process argument
  collection and compiler-selection environment handling are implemented.
- An explicit OS argv boundary now exists in `src/cli.ari`. It reads process
  arguments through the verified Ari `std::env::args` API, drops argv[0], and
  reuses the existing explicit-token parser and stdout-free dispatcher. `main`
  now returns the resulting internal exit-code mapping from this path. The
  main-facing `--list-rules` branch writes the existing human-readable
  list-rules text through the verified stdout adapter. Source runs now write
  reference-shaped human or JSON output to stdout and return exit `1` when any
  diagnostic remains or any compiler check exits nonzero. CLI parse problems,
  missing input, and explicit config read or parse failures remain stderr
  errors. Discovered config parse problems and compiler-visible source read
  failures are ordinary per-file diagnostics on stdout. The path reads
  `ARI_COMPILER` when `--ari` is absent, invokes the compiler once per source,
  and does not recursively scan sources.
- Runtime output uses a flat diagnostic store plus ordered per-file ranges.
  JSON matches the reference `files` envelope with per-file `path`, `exitCode`,
  and `diagnostics`; diagnostic objects contain mandatory numeric positions,
  `severity`, `message`, `source`, and optional `code`. Human source results use
  `PATH: ok` or bracketed codes on stdout. Representative exact JSON and human
  smoke checks cover clean, dirty, mixed, duplicate, escaped-path, compiler
  failure, and compiler-diagnostic cases. Each per-file `exitCode` now records
  the corresponding compiler result.
- The source input boundary model has started for caller-provided source text,
  path-only source entries, and explicit file reads. It records internal
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
- The CLI source-file dispatch path now reads every explicitly provided file
  path through the file-read boundary and returns aggregate diagnostic count,
  first diagnostic, and read-error count data in the command result. It
  validates caller-provided `--rule` override values and reports parse
  problems. A separate internal CLI collection path accepts explicit
  caller-provided tokens or parsed source-file input and pushes full internal
  diagnostics for all source files into a caller-provided vector while
  returning aggregate count, ordered per-file diagnostic ranges, and exit-code
  data. The current precedence is default severity < selected config <
  command-line `--rule`. The selected config is either one explicit `--config`
  file shared by every source, which disables discovery, or the nearest readable
  `ari-lint.rules` found lexically upward from each source file's directory.
  The main-facing OS argv path writes reference-shaped human results or a
  newline-terminated JSON `files` envelope to stdout through the verified output
  adapter. Bad discovered config lines are inserted as ordered per-file
  `lint/config` diagnostics before native rule diagnostics. Explicit config read
  or parse failures write all reference-shaped errors to stderr and exit `2`
  before linting. For every source, the main-facing path first runs the selected
  compiler with `-I DIR ... SOURCE --check`, then adds discovered-config and
  native diagnostics. Compiler diagnostics are parsed before those later
  diagnostics. It does not search home/global/XDG config locations, recursively
  discover source files, or call `tools/lint`.
- A source-only parity runner skeleton now records intended comparison
  boundaries against current `tools/lint`, with all execution, file IO, and
  output-comparison flags false. It does not run `tools/lint`, invoke an
  `ari-lint` binary, read fixtures, write files, compare output, invoke the
  compiler, call `ari --check`, or add CI parity behavior.
- A first local report-only parity smoke script now exists at
  `scripts/parity.sh`. It verifies the original Ari `tools/lint` entrypoint
  from the Ari repo `Makefile` and `tools/lint/main.cpp`, builds this
  repository through `scripts/build.sh`, runs both tools on temporary clean,
  trailing-whitespace, missing-final-newline, explicit-config, rule-override,
  discovered-config, and multi-file cases, and reports differences without
  failing on parity mismatches or claiming parity.
- An internal list-rules output path now records the known rule count for
  `lint/trailing-whitespace` and `lint/missing-final-newline`, and an internal
  human-readable list-rules formatter and standalone JSON extension build from
  the same metadata. The main-facing OS argv `--list-rules` path writes the
  selected form to stdout through the verified adapter without invoking the
  compiler. Exact standalone/reference list-rules contracts are now documented
  and gated separately; broader CLI parity remains future work.
- An internal stdout-free command dispatcher now maps parsed CLI arguments to
  internal command results. It routes list-rules requests to the internal
  human-readable list-rules formatter and routes source-file requests through
  file reading plus in-memory lint aggregation. It validates parsed `--rule`
  overrides before source-file linting when provided, while the diagnostic
  collection path applies parsed `--rule` severity overrides to collected
  diagnostics. It keeps
  parse-problem, help, and missing-source command paths as internal command
  results. The dispatcher remains output-free; the main-facing layer formats
  those results and its source collection path invokes the compiler. Recursive
  source scanning and strict parity remain future work.
- Internal command results now carry data-only exit-code mappings for success,
  usage-error, lint-failure, and unavailable command states. The model does not
  call process exit, run the CLI, read OS argv, write stdout/stderr, or claim
  stable user-facing exit behavior.
- An internal stdout/stderr output boundary model now records named stdout and
  stderr sinks plus result status for future output handling. It is data-only:
  it does not call real output APIs, write stdout/stderr, connect to OS argv or
  `main`, serialize JSON, or emit user-facing CLI output.
- A minimal stdout adapter and a minimal stderr adapter now write
  caller-provided `String` text through the verified Ari
  `std::io::print_string` and `std::io::eprint_string` APIs and return local
  status data. The stdout adapter is wired for main-facing list-rules, help,
  and source-file human/JSON results. The stderr adapter is wired for parse
  problems, missing input, and explicit-config failures. Compiler diagnostics,
  launch failures, source failures visible to the compiler, and discovered
  config problems travel through the source-result stdout path instead. The
  adapters are not used for recursive source scanning.
- An internal OS argv entry path now reads arguments through the verified Ari
  `std::env::args` API, drops the program-name argument, and dispatches the
  remaining user tokens through the existing explicit-token parser and
  stdout-free command dispatcher. `main` now returns the internal exit-code
  mapping from this path, and the main-facing `--list-rules` branch writes
  human-readable list-rules text to stdout. The main-facing help, source-file
  diagnostic, source-file JSON diagnostic, and parse problem output paths are
  also wired through verified output adapters. Missing source-file input writes
  a short stderr summary. Source commands invoke the selected compiler and use
  its per-file result for compiler-visible read failures. Config discovery and
  representative executable smoke coverage are wired; detailed help parity,
  dedicated Ari tests, and strict parity remain future work.
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
  internal override model without deciding discovery. The CLI source-file
  diagnostic collection path now reads one explicit config path for all sources
  when provided, otherwise searches lexically upward from each source file's
  directory for its nearest readable `ari-lint.rules`. It applies the selected
  config overrides and then appends command-line `--rule` overrides so `--rule`
  wins for every source.
- The config precedence fixture plan is documented in
  `docs/dev/config-precedence-fixtures.md`. It records default, config-file,
  explicit `--config`, and command-line `--rule` precedence fixture areas.
  Initial fixture files now exist under
  `tests/fixtures/config-precedence/`, with shell-only executable checks for
  presence, exact line order, and key override values. They do not execute Ari
  parser code themselves. Separately, `scripts/smoke.sh` executes the built CLI
  against generated temporary configs. Dedicated Ari tests, source-controlled
  runtime goldens, strict parity, and compatibility claims remain future work.
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
  config integration, and output behavior have since been wired for the
  supported source-file path. Dedicated rule tests, parity tests, and broad
  golden output coverage remain future work.
- Source directories should contain Ari source files only; source-layout
  documentation belongs in `docs/dev/` or other documentation directories.
- A local build scaffold now exists at `scripts/build.sh`. It requires an
  explicit Ari compiler path, compiles `src/main.ari` to `build/ari-lint` using
  the verified `ari input.ari -o output` invocation form, resolves the
  repository root, uses the compiler root when `lib/std.arih` is available
  there, and is not run by CI.
- A local smoke validation script now exists at `scripts/smoke.sh`. It accepts
  an explicit Ari compiler path as its first argument or through
  `ARI_COMPILER`, delegates build behavior to `scripts/build.sh`, and then runs
  `./build/ari-lint --help`, `./build/ari-lint --list-rules`, and
  `./build/ari-lint --json --list-rules`. It also uses temporary files to run
  focused list-rules output assertions for rule-code, short-name, and
  default-severity signals, plus
  explicit `--config` JSON smoke checks for trailing-whitespace severity,
  per-source nearest readable discovery for `ari-lint.rules`, different configs
  in one multi-file run, unreadable-nearer fallback, explicit-config discovery
  suppression, and CLI-last `--rule` precedence. It also checks ordered
  `lint/config` diagnostics for bad discovered lines and exact stderr/exit `2`
  behavior for explicit config read or parse errors. Focused runtime output
  checks assert the reference file envelope and diagnostic fields for
  `lint/trailing-whitespace` and `lint/missing-final-newline`. Exact JSON and
  human expected files cover ordering and final newlines; multi-file, clean,
  mixed, duplicate, and escaped path cases are also exercised. Dedicated Ari
  tests, source-controlled broad goldens, strict parity, and compiler-backed CI
  remain follow-up work. Focused compiler invocation and diagnostic parsing are
  covered by local smoke validation.
- A local parity smoke/report script now exists at `scripts/parity.sh`. It
  accepts an explicit Ari compiler path or `ARI_COMPILER`, an Ari repository
  path or `ARI_REPO`, and optionally an existing original lint command path or
  `ORIGINAL_LINT`. It includes report-only config, `--rule`, discovered config,
  and multi-file cases, but is not run by `scripts/test.sh` or CI and is not a
  strict parity gate.
- A local standalone test entrypoint now exists at `scripts/test.sh`. It
  resolves the repository root and runs `scripts/check.sh`. With no argument it
  stays compiler-free even if `ARI_COMPILER` is present. With one explicit,
  non-empty compiler path it runs the checks and delegates to
  `scripts/smoke.sh`; parity remains separate. It does not download a compiler,
  execute `tools/lint`, install dependencies, or use package manager commands.
- The initial release and compatibility policy is documented in
  `docs/dev/release-compatibility-policy.md`. It uses Ari releases and tags as
  read-only references only and does not claim support for any Ari release,
  tag, or commit.
- The CI compiler-backed check gate is documented. The GitHub Actions workflow
  remains compiler-free and runs zero-argument `scripts/test.sh` until explicit
  Ari compiler provisioning and compiler identity recording are ready.
- The existing `tools/lint` implementation remains in `ari-foundry/ari` as the
  current bundled/reference implementation.
- The implementation direction remains Ari-language development in `ari-lint`.
- Behavior parity with current `tools/lint` is the intended transition path.
- The near-term dependency model remains invoking `ari --check`.
- Ari compiler provisioning for compiler-backed CI remains planned in
  `docs/dev/compiler-provisioning.md`.
- Runtime compiler selection through `--ari PATH`, `ARI_COMPILER`, and the
  `build/ari` default is implemented as documented in
  `docs/dev/compiler-invocation.md`.

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

Current Ari-language implementation module inventory:

- `src/main.ari` defines a minimal main entry shell and delegates `main` through
  a local `run_main_entry_shell` function. The shell calls the existing OS argv
  CLI entry path and returns the internal exit-code mapping. Source dispatch in
  that CLI path invokes the compiler; `main` itself does not call `tools/lint`
  or call process exit. Scoped main-facing stdout/stderr output is delegated
  through the CLI layer's verified adapters.
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
  explicit-token path. The source-file collection path can read one explicit
  config for all source files or search lexically upward from each source file's
  directory for its nearest readable `ari-lint.rules` when `--config` is absent.
  It selects a compiler from `--ari`, `ARI_COMPILER`, or `build/ari`, invokes
  one compiler process per source, and combines compiler diagnostics before
  config and native diagnostics. It does not search home/global/XDG config
  locations or call process exit directly.
  `main` returns the internal exit-code mapping from that path. Main-facing
  list-rules, help, and source human/JSON results use stdout; parse problems,
  missing-source summaries, and explicit-config failures use stderr through the
  verified adapters. Compiler launch and source failures use per-file results.
- `src/compiler.ari` owns direct shell-free compiler execution, exit-status
  normalization, bounded concurrent stream draining, deterministic
  stderr-then-stdout capture, parsing of the four reference Ari diagnostic
  forms, and construction of deferred compiler-check failure diagnostics. It
  retains at most 256 KiB per stream and drains excess bytes. Variable
  diagnostic text and any actually needed fallback output are copied into the
  caller zone before per-process scratch storage is released.
- `src/severity.ari` sketches planned severity values: off, hint, note,
  warning, and error.
- `src/diagnostic.ari` defines diagnostic concepts such as file path, line,
  column, optional end position, severity, message, source, and code. It also
  has a small source-span constructor used by the trailing-whitespace and
  missing-final-newline mapping skeletons; it does not format output or
  serialize JSON.
- `src/output.ari` defines diagnostic output metadata for human-readable and
  JSON output modes, diagnostic location, file path, line, column, endLine,
  endColumn, severity, message, source, and code. It also defines an internal
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
  main-facing `--list-rules`, help, and source-file human/JSON output. The
  stderr adapter is wired for parse-problem, missing-source, and current
  source/config-read summaries.
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
  problems, normalizing documented short rule names into full lint rule codes
  before validating those codes against the known rule registry. It also parses
  caller-provided command-line rule override text in `RULE=SEVERITY` form,
  normalizing documented short rule names into full lint rule codes and
  validating those codes against the known rule registry. It also resolves
  effective severity data for a caller-provided rule code from an already-parsed
  override list and can rebuild one already-built diagnostic with that resolved
  severity. It can read and parse one caller-selected config file path into
  internal override data, tagging explicit and discovered sources separately.
  It does not decide discovery, inspect CLI arguments, run lint rules, or apply
  config to lint execution.

The current standalone path implements explicit-file native rule execution,
CLI/config severity validation, per-source nearest readable config discovery,
explicit-config discovery suppression, CLI-last precedence, ordered per-file
results, reference-shaped runtime JSON and human output, per-source
`ari --check` execution, compiler diagnostic parsing, and main-entry exit
behavior. Bad discovered config lines are per-file `lint/config` diagnostics;
explicit config read and parse failures use reference-shaped stderr and exit
`2`. Compiler launch failures become per-file exit `127`, and compiler-visible
source failures use compiler diagnostics. The output layer retains focused
single-diagnostic and caller-provided diagnostic-array helpers, and adds
`FileResult`/`RunResult` serializers used by the CLI. Registry-backed dispatch,
file-backed aggregation, and the two native rules are wired into the executable
path.

The remaining implementation limits are explicit: recursive source discovery
and home/global/XDG config search are out of scope. Focused executable compiler
smoke exists, but dedicated Ari unit tests, broad source-controlled goldens,
strict parity, compiler-backed CI, and a release-backed compatibility matrix
remain future work.

The local build scaffold and `scripts/smoke.sh` provide compiler-backed build
and executable CLI/output smoke validation, but they are not compiler-backed
CI or full build validation. Dedicated Ari tests, broad source-controlled
goldens, compiler provisioning in CI, strict parity, and compatibility
validation remain future work.

The local standalone test entrypoint is not a full unit or parity suite.
`scripts/test.sh` runs compiler-free checks by default and accepts one explicit
compiler path to run the full executable smoke afterward. Dedicated Ari unit
tests, broad source-controlled golden comparison, broader strict parity, package
manager commands, and CI compiler execution remain future work.

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
parser handles caller-provided text and documented short rule-name
normalization, and the main-facing CLI now applies per-source nearest readable
discovery, explicit-config discovery suppression, and CLI-last precedence.
Initial config precedence fixture files, lightweight fixture checks, and focused
executable shell smoke now exist. Dedicated Ari config tests,
source-controlled runtime goldens, and strict parity remain follow-up work
before this repository claims stable config behavior. The fixture plan is
documented in `docs/dev/config-precedence-fixtures.md`.

The exact source-diagnostic JSON schema and human-readable source-diagnostic
text remain unstable and need follow-up before this repository claims standalone
output compatibility. The separately documented list-rules contract is already
gated by exact goldens.

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
  compiler, or call `tools/lint`. Its with-overrides variants preserve
  diagnostic counts and apply already-parsed override severity to collected
  diagnostics for in-memory source text or explicitly provided file paths. The
  CLI layer can now provide discovered or explicit config-file overrides to
  those collection paths.
- `src/registry.ari` can dispatch one exact known rule code to the corresponding
  in-memory rule wrapper for caller-provided source text. It returns structured
  found/not-found dispatch data and does not read files, scan the filesystem,
  apply config, write output, serialize JSON, invoke the compiler, execute
  `ari --check`, or call `tools/lint`.

The individual rule modules remain in-memory and do not own file reading,
config, CLI, or output concerns. The surrounding lint and CLI layers now compose
them for explicit files, invoke the compiler, and emit runtime results.
Home/global/XDG config search, dedicated Ari unit tests, strict parity, and CI
compiler provisioning remain future work.

The source input file-read boundary reads one explicitly provided path into a
source input using `std::fs::read_detailed`. It does not scan directories,
discover config, apply config, run lint rules over file sets, produce output,
serialize JSON, invoke the compiler, call `ari --check`, or call `tools/lint`.

The CLI file lint path reads each explicit source-file argument, runs the
in-memory lint aggregation for successfully read files, validates parsed
`--rule` overrides when provided, preserves read errors, and carries aggregate
counts plus the first internal diagnostic in `CliCommandResult`. The
main-facing OS argv path collects source-file diagnostics into a flat vector,
  records an ordered range for every positional file, applies each source's
  discovered config or the invocation-wide explicit config first, then parsed
  command-line `--rule` severity overrides, and writes reference-shaped human or
  JSON results to stdout. Bad discovered config lines become ordered per-file
  `lint/config` diagnostics on stdout. The main-facing collection path invokes
  the selected compiler before config/native lint for each source and records
  the compiler exit code. CLI parse problems and explicit config read or parse
  failures write reference-shaped errors to stderr; compiler-visible
  source-file read errors remain per-file compiler diagnostics on stdout. It
  does not produce parse-error JSON, search home/global/XDG config locations,
  recursively discover source files, call `tools/lint`, or call process exit.

### Phase 5: compiler boundary

- [x] invoke `ari --check` once per explicit source
- [x] handle compiler failures and normalize process status
- [x] combine compiler-backed diagnostics with config and lint diagnostics
- [x] preserve reference behavior where Ari process APIs permit it
- use the compiler provisioning plan in `docs/dev/compiler-provisioning.md`
  before adding compiler-backed tests or CI compiler setup
- [x] implement `--ari`, `ARI_COMPILER`, default selection, and exact argv as
  specified in `docs/dev/compiler-invocation.md`

### Phase 6: standalone tests and CI

- [x] add a local standalone test entrypoint with compiler-free and explicit
  compiler-backed modes
- add fixtures
- add golden JSON diagnostics when schema is stable
- [x] run local standalone tests with an explicit Ari compiler path
- add compiler-backed CI only after compiler provisioning, standalone tests,
  and compiler identity recording are ready
- keep local smoke validation scoped to compiler-backed build plus
  representative exact CLI/output assertions until broader source-controlled
  goldens and strict parity exist

The source-only parity runner skeleton in `src/parity.ari` records the future
comparison boundary. It does not execute `tools/lint`, execute `ari-lint`, read
fixtures, compare outputs, invoke the compiler, or run in CI.

The local `scripts/parity.sh` smoke/report executes outside Ari source as a
developer helper only. It compares current output signals with the original
bundled lint binary across temporary native-rule, config, usage/error,
compiler-boundary, and multi-file cases and keeps differences non-gating.

## Parity Strategy

Parity should be checked against the current bundled `tools/lint`
implementation.

A source-only parity runner skeleton names current `tools/lint` as the
reference implementation and the Ari-language `ari-lint` implementation as the
future implementation under test. It is not an executable parity runner and
does not compare output.

`scripts/parity.sh` provides the first executable local parity smoke/report. It
does not replace the source-only skeleton, does not add source-controlled
fixtures or golden files, and does not make differences fail. It currently
compares exit code, stdout/stderr presence, whether each rule is reported,
severity sightings, basic path hit counts, and basic line/column presence for
baseline rule, explicit config, command-line rule override, discovered config,
and multi-file temporary cases.

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
- Registry, severity, and config shapes may change as compiler-backed rule
  execution, dedicated Ari tests, and strict parity coverage expand.
- Rule module boundaries may change once real rule behavior and shared rule
  execution APIs are designed.
- Standalone config discovery and override precedence still need dedicated Ari
  tests and source-controlled parity fixtures before they become stable
  behavior.
- Metadata value construction may change once Ari constant or value syntax is
  selected for the standalone implementation.
- CLI metadata value construction may change once Ari constant or collection
  syntax is selected for the standalone implementation.
- Internal diagnostic output construction may change as long as its public
  contract remains intact. Public list-rules metadata or serialization changes
  require a contract review and matching exact golden updates.
- Source directories may accidentally collect README-style documentation unless
  docs stay under `docs/`.
- The source-only parity runner skeleton may be mistaken for the local shell
  parity helper unless docs and checks continue to distinguish the Ari-source
  skeleton from `scripts/parity.sh`.
- The report-only parity smoke may be mistaken for a strict parity gate unless
  docs and checks continue to state that differences remain non-gating.
- Compiler-backed CI may be added too early unless the lightweight workflow
  continues to guard against implicit compiler execution.

## Follow-up Checklist

- [x] Confirm current Ari language docs and examples
- [x] Define initial Ari source layout
- [x] Identify and use Ari runtime/process support for invoking `ari --check`
- [x] Define minimal CLI parser strategy
- [x] Define concrete CLI metadata value construction after Ari syntax choices
      are verified
- [x] Define diagnostic data model
- [x] Define concrete diagnostic output metadata value construction after Ari
      syntax choices are verified
- [x] Define the reference-compatible runtime JSON schema and human-readable
      diagnostic text policy
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
- [x] Accept documented short rule names in caller-provided config text before
      known-rule validation without broadening config discovery, invoking the
      compiler, executing `ari --check`, adding compiler-backed CI, adding
      golden tests, or calling `tools/lint`
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
- [x] Apply explicit config file overrides to CLI source-file diagnostic
      collection before command-line `--rule` overrides without discovering
      `ari-lint.rules`, adding a parity runner, adding compiler-backed CI,
      adding golden tests, invoking `ari --check`, or calling `tools/lint`
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
- [x] Retain all positional source file paths in the CLI argument model and
      iterate every explicit source-file argument for lint execution without
      directory traversal, recursive source-tree scanning, parity runner
      behavior, compiler-backed CI, compatibility claims, `ari --check`, or
      `tools/lint`
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
- [x] Add a first local report-only parity smoke script that builds this
      repository, locates the original Ari `tools/lint` entrypoint from the
      Ari repo, compares temporary clean/trailing-whitespace/missing-final-newline
      fixtures, and keeps differences non-gating
- [x] Expand the local report-only parity smoke script with explicit config,
      command-line rule override, discovered config, and multi-file cases
- [x] Record compiler-backed CI gate without running the Ari compiler,
      `ari --check`, `tools/lint`, package managers, or release automation
- [x] Add direct per-source compiler execution with `--ari`, `ARI_COMPILER`,
      and `build/ari` selection, exact `-I DIR ... SOURCE --check` argv,
      compiler diagnostic parsing, normalized exit status, and deferred
      compiler-check failure diagnostics
- [x] Add local fake-compiler smoke coverage for argv preservation, selection
      precedence, diagnostic parsing, stream merge order, failures, signals,
      fallback suppression, bounded stream and diagnostic material,
      fail-closed truncation, and compiler/truncation/config/native ordering
- [x] Wire local standalone build script root handling without running the Ari
      compiler in CI or adding package manager files
- [x] Add local smoke validation that delegates to `scripts/build.sh` and runs
      the current safe `--help`, `--list-rules`, and `--json --list-rules` CLI
      invocations without adding golden tests, parity checks, compiler-backed
      CI, config discovery, new lint semantics, or compatibility claims
- [x] Add minimal config override smoke coverage with temporary files and
      simple JSON rule-code/severity checks for explicit `--config` severity
      and CLI `--rule` precedence, without adding golden tests,
      parent-directory config search, a parity runner, compiler-backed CI, or
      new lint semantics
- [x] Add focused diagnostic field smoke coverage with temporary files for
      `lint/trailing-whitespace` and `lint/missing-final-newline`, checking
      current JSON `ruleCode`, `severity`, `message`, `filePath`, `line`, and
      `column` fields without adding broad golden fixtures, a parity runner,
      compiler-backed CI, or new lint semantics
- [x] Discover only `./ari-lint.rules` in the current working directory when
      `--config` is absent, apply it before explicit command-line `--rule`
      overrides, and keep explicit `--config` ahead of discovery without parent
      search, parity runner, compiler-backed CI, broad golden tests,
      compatibility claims, `ari --check`, or `tools/lint`
- [x] Extend discovery upward through parent directories when `--config` is
      absent, stop at the filesystem root, use the nearest `ari-lint.rules`,
      and keep explicit `--config` ahead of discovery without home/global/XDG
      config search, parity runner, compiler-backed CI, broad golden tests,
      compatibility claims, `ari --check`, or `tools/lint`
- [x] Add a local standalone test entrypoint that resolves the repository root
      with a deterministic compiler-free default and an explicit
      compiler-backed smoke mode; dedicated Ari unit, parity, and broader
      golden-output tests remain future work
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
