# Ari-language Implementation Plan

## Purpose

This document plans a future Ari-language implementation of `ari-lint`.

This document records the implementation direction and source-layout policy.
It does not move `tools/lint` or change build behavior.

## Current Status

- `ari-lint` is currently in skeleton/planning state.
- Source extraction has not happened.
- The Ari source skeleton has started with source-only files under `src/`.
- A minimal Ari main entry shell is now present. It provides a source-level
  connection point for future OS argv handling to reach the internal
  explicit-token entry path, but it currently returns success without reading OS
  argv, reading environment variables, writing stdout/stderr, serializing JSON,
  scanning sources, parsing config, invoking the compiler, invoking
  `ari --check`, or calling `tools/lint`.
- The rule registry, severity, and config model skeleton has started as
  preparatory source-only declarations.
- First planned rule metadata entries have been added for
  `lint/trailing-whitespace` and `lint/missing-final-newline` as metadata-only
  placeholders. Real rule behavior remains future work.
- The CLI metadata skeleton for the planned surface has started as metadata-only
  declarations for positional source input and the documented options `--json`,
  `--ari`, `-I`, `--list-rules`, `--config`, and `--rule`.
  Minimal token-list parsing has started for caller-provided tokens. OS argv
  reading remains future work.
- The CLI argument result model is now used by the minimal explicit-token
  parser for positional files, planned flags/options, optional compiler/config
  paths, include paths, raw rule overrides, help requests, and parse problems.
  Actual OS process argument parsing and environment handling remain future
  work.
- An explicit OS argv boundary marker now exists in `src/cli.ari`. It records
  that OS argv integration has a named internal boundary, but the boundary is
  inactive and does not read process arguments, read environment variables,
  dispatch tokens, or write output.
- The diagnostic output metadata skeleton has started as metadata-only
  declarations for human and JSON output modes, diagnostic location fields, and
  planned diagnostic fields. Diagnostic output is not implemented yet.
  JSON serialization is not implemented yet.
- An internal list-rules output path now converts known rule metadata into
  list-rules rows for `lint/trailing-whitespace` and
  `lint/missing-final-newline`, and an internal human-readable list-rules
  formatter now converts those rows to text. User-facing stdout/stderr output,
  JSON output, OS argv/main wiring, compiler invocation, config parsing,
  diagnostics output, and parity tests remain future work.
- An internal stdout-free command dispatcher now maps parsed CLI arguments to
  internal command results. It routes list-rules requests to the internal
  human-readable list-rules formatter and returns explicit future-work
  placeholders for parse-problem, help, source-file linting, and unsupported
  command paths. User-facing stdout/stderr output, OS argv/main wiring, JSON
  output, source scanning, compiler invocation, config parsing, diagnostics
  output, and parity tests remain future work.
- Internal command results now carry data-only exit-code mappings for success,
  usage-error, and unavailable command states. The model does not call process
  exit, run the CLI, read OS argv, write stdout/stderr, or claim stable
  user-facing exit behavior.
- An internal stdout/stderr output boundary model now records named stdout and
  stderr sinks plus result status for future output handling. It is data-only:
  it does not call real output APIs, write stdout/stderr, connect to OS argv or
  `main`, serialize JSON, or emit user-facing CLI output.
- An internal explicit-token entry path now composes the existing
  caller-provided token-list parser with the stdout-free command dispatcher and
  returns a `CliCommandResult`. It does not read OS argv, environment variables,
  stdout/stderr, JSON, config files, source files, compiler output, or
  `tools/lint`.
- The config override skeleton has been refined as metadata-only declarations
  for default config, `ari-lint.rules`, `--config`, `--rule`, rule severity
  overrides, and documented override precedence. Config parsing is not implemented yet.
  `ari-lint.rules` is not parsed yet.
- The non-executing rule module layout has started with source-only child
  modules for the planned trailing whitespace and missing final newline rules.
  A minimal internal single-line helper has started for trailing whitespace,
  a minimal internal content helper has started for missing final newline, and
  internal diagnostic mapping skeletons have started for trailing whitespace and
  missing final newline.
  The trailing-whitespace mapping converts a single-line helper result into
  diagnostic-model span/severity data. The missing-final-newline mapping
  converts a content-helper result plus explicit caller-provided final position
  metadata into diagnostic-model span/severity data. Full rule behavior is not
  implemented yet.
- Rule design notes have started:
  `docs/rules/trailing-whitespace.md` records the planned
  `lint/trailing-whitespace` behavior, and
  `docs/rules/missing-final-newline.md` records the planned
  `lint/missing-final-newline` behavior. Implementation remains future work.
- Source directories should contain Ari source files only; source-layout
  documentation belongs in `docs/dev/` or other documentation directories.
- A local build scaffold now exists at `scripts/build.sh`. It requires an
  explicit Ari compiler path, compiles `src/main.ari` to `build/ari-lint` using
  the verified `ari input.ari -o output` invocation form, and is not run by CI.
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
  a local `run_main_entry_shell` function. The shell is the future connection
  point to the explicit-token entry path after OS argv and output wiring are
  designed. It currently returns success without reading process state or
  producing output.
- `src/model.ari` groups future model modules.
- `src/cli.ari` sketches planned CLI option metadata for positional source file
  input, `--json`, `--ari`, `-I`, `--list-rules`, `--config`, and `--rule`,
  including each option's purpose, value requirement, and repeatability. It
  also defines a CLI argument result model and a minimal explicit-token parser
  for caller-provided token lists, including positional files, requested
  output/list/help flags, optional compiler and config paths, include paths,
  raw rule override entries, missing-value problems, and unknown-argument
  problems. It also defines an internal stdout-free command result model and a
  dispatcher that routes list-rules requests to internal formatted text while
  keeping other command paths as explicit future-work placeholders, plus an
  internal exit-code mapping carried by command results, plus an internal
  explicit-token entry function that composes parsing and dispatch. It also
  defines an inactive OS argv boundary marker for future process-argument
  integration. It does not read OS process argv, write stdout/stderr output, or
  call process exit.
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
  list-rules output row model, a known-rule output builder from existing rule
  metadata, an internal human-readable list-rules formatter, and a data-only
  stdout/stderr output boundary model for named future output sinks. It does
  not format diagnostics, build diagnostic strings, serialize JSON, emit
  user-facing `--list-rules` CLI output, call output APIs, or write
  stdout/stderr output.
- `src/rule.ari` sketches rule metadata concepts such as rule code, short name,
  default severity, and description.
- `src/registry.ari` sketches rule registry concepts for planned reference
  entries, including `lint/trailing-whitespace` and
  `lint/missing-final-newline` metadata placeholders.
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
  discovery. It does not parse config files, read `ari-lint.rules`, inspect
  CLI arguments, or apply overrides.

These files do not implement real lint rules, rule execution, process argument
reading, argument validation, source scanning, config parsing, diagnostics
output, JSON serialization, file reads, or `ari --check` invocation. The main
entry shell is limited to returning success, the OS argv boundary marker is
limited to inactive status data, the CLI parser is limited to explicit
caller-provided token lists and raw option values, the list-rules formatter is
limited to internal text construction, the command dispatcher is limited to
stdout-free internal command results, the exit-code model is limited to internal
data carried by those results, and the stdout/stderr output boundary is limited
to status data for named future sinks. OS argv reading, compiler invocation,
config parsing, diagnostics output, real stdout/stderr writing, stdout/stderr
adapter wiring, process exit, JSON serialization, environment handling,
semantic `--rule` parsing, source scanning, lint execution, main-entry tests,
argv-boundary tests, output-boundary tests, exit-code tests, parser tests,
dispatcher tests, and explicit-token entry tests remain future work. Severity
parsing, CLI/config override behavior, rule registration behavior, and the JSON
schema are not stable yet.

The local build scaffold is not compiler-backed CI or full build validation.
Compiler-backed CI, standalone test execution, compiler provisioning in CI,
and compatibility validation remain future work.

Config precedence is recorded from the current Ari lint reference docs as
metadata only. Standalone config discovery and config precedence fixtures remain
needs follow-up before this repository claims stable config behavior.

The exact JSON schema and human-readable diagnostic text remain unstable and
need follow-up before this repository claims standalone output compatibility.

### Phase 4: first rules

- start non-executing rule module layout before implementing rule behavior
- use `docs/rules/trailing-whitespace.md` and
  `docs/rules/missing-final-newline.md` as planned rule design notes
- turn metadata-only entries into executable rule registrations when Ari syntax
  and toolchain support are ready
- implement `lint/trailing-whitespace`
- implement `lint/missing-final-newline`
- compare behavior with reference implementation

Current non-executing rule module layout:

- `src/rules.ari` exposes planned child rule modules and keeps shared rule
  metadata entries.
- `src/rules/trailing_whitespace.ari` records layout metadata and a minimal
  internal single-line helper for the future `lint/trailing-whitespace`
  implementation. It also records a diagnostic mapping skeleton for one
  already-split line, mapping helper output to internal span/severity data
  without constructing full string-bearing diagnostics.
- `src/rules/missing_final_newline.ari` records layout metadata and a minimal
  internal content helper for the future `lint/missing-final-newline`
  implementation. The helper only checks already-provided bytes for a missing
  final newline. It also records a diagnostic mapping skeleton that uses
  explicit caller-provided final position metadata to map helper output to
  internal span/severity data without constructing full string-bearing
  diagnostics.

The trailing-whitespace helper, missing-final-newline helper, and diagnostic
mapping skeletons are not full rule implementations. They only handle
already-provided bytes or explicit caller-provided file/line data. These rule
module files do not implement rule execution, file reading, whole-source
scanning, full diagnostic production, config parsing, CLI parsing, diagnostics
output, JSON serialization, compiler invocation, tests, or CI. Rule code and
message value construction for full diagnostics remains needs follow-up. The
full rule behavior is not implemented yet.

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

- add fixtures
- add golden JSON diagnostics when schema is stable
- run tests with explicit `--ari` compiler path

## Parity Strategy

Parity should be checked against the current bundled `tools/lint`
implementation.

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
- Registry, severity, and config shapes may change when real rule execution and
  config parsing begin.
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
- [ ] Define registry, severity, and config model behavior after source
      skeletons compile in the real build
- [ ] Define concrete config override metadata value construction after Ari
      syntax choices are verified
- [ ] Add config precedence fixtures before claiming stable config behavior
- [ ] Define executable rule module API after the non-executing layout is
      validated
- [ ] Define concrete metadata value construction after Ari syntax choices are
      verified
- [ ] Define parity test fixtures against current `tools/lint`
- [ ] Decide when to add first Ari source files
- [ ] Track Ari compiler/toolchain blockers in `ari-foundry/ari` issues

## Explicit Non-Goals

- Do not move `tools/lint` in this step.
- Do not copy `tools/lint` source in this step.
- Do not add user-facing CLI/output integration in this step.
- Do not add tests in this step.
- Do not add release workflows in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.
- Do not file compiler or standard library bugs in `ari-lint` as primary
  issues.
