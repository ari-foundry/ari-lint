# ari-lint Agent Guide

## Repository Role

This repository owns `ari-lint` tooling only.

Ari compiler behavior remains in `ari-foundry/ari`. `ari-lint` invokes
`ari --check` unless the dependency model changes.

The long-term implementation direction is Ari-language implementation when the
language and toolchain make that feasible.

The current `tools/lint` implementation in `ari-foundry/ari` is a
bundled/reference implementation for behavior parity. Do not copy it wholesale
into this repository.

Before writing Ari code or documenting Ari syntax, inspect `ari-foundry/ari`
docs, examples, and tests for current language usage.

Broad Ari language and compiler docs must not be copied here. Keep docs focused
on lint CLI behavior, rules, diagnostics, configuration, tests, releases, and
compatibility once those topics are ready for this repository.

## Current Split Status

- Ari-language implementation source has not been added yet
- docs migration from ari-foundry/ari has not happened yet
- standalone build/test wiring has not happened yet

## Boundaries

Do not modify `ari-foundry/ari` from this repository.

Do not modify `ari-foundry/ari-foundry.github.io` from this repository.

Do not invent compatibility claims before releases exist.

Before making compatibility or release claims, check Ari releases and tags as
read-only references:

- https://github.com/ari-foundry/ari/releases
- https://github.com/ari-foundry/ari/tags

Compatibility claims must not be invented. The `ari-lint` release/version
policy is not established yet.

Do not invent Ari syntax or APIs without checking `ari-foundry/ari`.

Do not copy broad Ari language, compiler, standard library, LSP, editor, or
package-manager docs into this repository.

## Issue Routing

Compiler bugs go to `ari-foundry/ari`.

Standard library bugs go to `ari-foundry/ari`.

Ari language/toolchain limitations go to `ari-foundry/ari`.

`ari-lint` issues are for lint tooling, lint rules, diagnostics, config, docs,
tests, and Ari-language implementation.

If a bug crosses the boundary, file the root cause in `ari-foundry/ari` and
link it from `ari-lint` if needed.

## Workflow

Keep pull requests small and scoped.

Run the available validation before creating a pull request.

Before changing split-related content, read the relevant Ari reference docs,
especially the documentation ownership note, tooling split criteria,
`ari-lint` boundary inventory, CLI/diagnostic contract, dependency model,
standalone test plan, and repository skeleton note.
