# ari-lint Agent Guide

## Repository Role

This repository owns `ari-lint` tooling only.

Ari compiler behavior remains in `ari-foundry/ari`. `ari-lint` invokes
`ari --check` unless the dependency model changes.

The long-term implementation direction is Ari-language implementation when the
language and toolchain make that feasible.

Before writing Ari code or documenting Ari syntax, inspect `ari-foundry/ari`
docs, examples, and tests for current language usage.

Broad Ari language and compiler docs must not be copied here. Keep docs focused
on lint CLI behavior, rules, diagnostics, configuration, tests, releases, and
compatibility once those topics are ready for this repository.

## Current Split Status

- source extraction from ari-foundry/ari has not happened yet
- docs migration from ari-foundry/ari has not happened yet
- standalone build/test wiring has not happened yet

## Boundaries

Do not modify `ari-foundry/ari` from this repository.

Do not modify `ari-foundry/ari-foundry.github.io` from this repository.

Do not invent compatibility claims before releases exist.

Do not invent Ari syntax or APIs without checking `ari-foundry/ari`.

Do not copy broad Ari language, compiler, standard library, LSP, editor, or
package-manager docs into this repository.

## Workflow

Keep pull requests small and scoped.

Run the available validation before creating a pull request.

Before changing split-related content, read the relevant Ari reference docs,
especially the documentation ownership note, tooling split criteria,
`ari-lint` boundary inventory, CLI/diagnostic contract, dependency model,
standalone test plan, and repository skeleton note.
