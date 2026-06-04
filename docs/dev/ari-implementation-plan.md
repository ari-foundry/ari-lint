# Ari-language Implementation Plan

## Purpose

This document plans a future Ari-language implementation of `ari-lint`.

This document records the implementation direction and source-layout policy.
It does not move `tools/lint` or change build behavior.

## Current Status

- `ari-lint` is currently in skeleton/planning state.
- Source extraction has not happened.
- The Ari source skeleton has started with source-only files under `src/`.
- The rule registry, severity, and config model skeleton has started as
  preparatory source-only declarations.
- First planned rule metadata entries have been added for
  `lint/trailing-whitespace` and `lint/missing-final-newline` as metadata-only
  placeholders. Real rule behavior remains future work.
- The CLI metadata skeleton for the planned surface has started as metadata-only
  declarations for positional source input and the documented options `--json`,
  `--ari`, `-I`, `--list-rules`, `--config`, and `--rule`. The real CLI parsing
  remains future work.
- The diagnostic output metadata skeleton has started as metadata-only
  declarations for human and JSON output modes, diagnostic location fields, and
  planned diagnostic fields. Diagnostic output is not implemented yet.
  JSON serialization is not implemented yet.
- Source directories should contain Ari source files only; source-layout
  documentation belongs in `docs/dev/` or other documentation directories.
- The existing `tools/lint` implementation remains in `ari-foundry/ari` as the
  current bundled/reference implementation.
- The future direction is Ari-language reimplementation in `ari-lint`.
- Behavior parity with current `tools/lint` is the intended transition path.
- The near-term dependency model remains invoking `ari --check`.

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
- parse planned CLI options
- accept source paths
- accept `--ari` path if feasible
- do not claim stable behavior until tested

### Phase 3: internal lint model

- define internal diagnostic representation
- define severity values, rule descriptors, registry entries, and config
  override data shapes
- record diagnostic output metadata before implementing formatting or JSON
  serialization
- map lint diagnostics to documented output expectations
- keep JSON schema follow-up explicit

Current preparatory model skeleton files are source-only placeholders:

- `src/model.ari` groups future model modules.
- `src/cli.ari` sketches planned CLI option metadata for positional source file
  input, `--json`, `--ari`, `-I`, `--list-rules`, `--config`, and `--rule`,
  including each option's purpose, value requirement, and repeatability, without
  parsing arguments.
- `src/severity.ari` sketches planned severity values: off, hint, note,
  warning, and error.
- `src/diagnostic.ari` sketches diagnostic concepts such as file path, line,
  column, optional end position, severity, rule code, and message.
- `src/output.ari` sketches diagnostic output metadata for human-readable and
  JSON output modes, diagnostic location, file path, line, column, endLine,
  endColumn, severity, rule code, and message. It does not format diagnostics,
  build diagnostic strings, serialize JSON, or write stdout/stderr output.
- `src/rule.ari` sketches rule metadata concepts such as rule code, short name,
  default severity, and description.
- `src/registry.ari` sketches rule registry concepts for planned reference
  entries, including `lint/trailing-whitespace` and
  `lint/missing-final-newline` metadata placeholders.
- `src/rules.ari` records the first planned rule metadata entries for
  `lint/trailing-whitespace` and `lint/missing-final-newline`, including their
  short names, default `warning` severity from the current Ari lint docs, and
  brief descriptions, without implementing behavior.
- `src/config.ari` sketches config concepts such as severity overrides,
  `ari-lint.rules` config source, and command-line override source.

These files do not implement real lint rules, rule execution, CLI parsing,
process argument reading, argument validation, source scanning, config parsing,
diagnostics output, JSON serialization, file reads, or `ari --check`
invocation. Descriptor value construction, severity parsing, CLI/config
override behavior, rule registration behavior, and the JSON schema are not
stable yet.

The exact JSON schema and human-readable diagnostic text remain unstable and
need follow-up before this repository claims standalone output compatibility.

### Phase 4: first rules

- turn metadata-only entries into executable rule registrations when Ari syntax
  and toolchain support are ready
- implement `lint/trailing-whitespace`
- implement `lint/missing-final-newline`
- compare behavior with reference implementation

### Phase 5: compiler boundary

- invoke `ari --check`
- handle compiler failures
- combine compiler-backed diagnostics with lint diagnostics
- preserve behavior parity where possible

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
- Metadata value construction may change once Ari constant or value syntax is
  selected for the standalone implementation.
- CLI metadata value construction may change once Ari constant or collection
  syntax is selected for the standalone implementation.
- Diagnostic output metadata value construction may change once Ari constant or
  collection syntax is selected for the standalone implementation.
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
- [ ] Define concrete metadata value construction after Ari syntax choices are
      verified
- [ ] Define parity test fixtures against current `tools/lint`
- [ ] Decide when to add first Ari source files
- [ ] Track Ari compiler/toolchain blockers in `ari-foundry/ari` issues

## Explicit Non-Goals

- Do not move `tools/lint` in this step.
- Do not copy `tools/lint` source in this step.
- Do not add implementation code in this step.
- Do not add tests in this step.
- Do not add release workflows in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.
- Do not file compiler or standard library bugs in `ari-lint` as primary
  issues.
