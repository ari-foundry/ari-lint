# ari-lint Agent Guide

## Repository Role

This repository owns `ari-lint` tooling only.

Ari compiler behavior remains in `ari-foundry/ari`. `ari-lint` invokes
`ari --check` unless the dependency model changes.

The implementation is written in Ari and should remain Ari-language-first where
current language and toolchain support permit.

The current `tools/lint` implementation in `ari-foundry/ari` is a
bundled/reference implementation for behavior parity. Do not copy it wholesale
into this repository.

Ari language syntax and idioms must be checked against `ari-foundry/ari` docs,
examples, and tests.

Do not invent Ari syntax. Do not add Ari examples unless they are verified
against current Ari usage.

Broad Ari language and compiler docs must not be copied here. Keep docs focused
on lint CLI behavior, rules, diagnostics, configuration, tests, releases, and
compatibility.

## Current Split Status

- Ari-language implementation source is active under `src/`.
- Focused user documentation is owned here; historical handoff links remain in
  `ari-foundry/ari`, and portal navigation is separately owned.
- Standalone build, checks, smoke, parity, and pinned compiler CI are wired.
- No stable `ari-lint` release or Ari compatibility entry exists yet.

## Boundaries

Do not modify `ari-foundry/ari` from this repository.

Do not modify `ari-foundry/ari-foundry.github.io` from this repository.

Do not invent compatibility claims before releases exist.

Before making compatibility or release claims, check Ari releases and tags as
read-only references:

- https://github.com/ari-foundry/ari/releases
- https://github.com/ari-foundry/ari/tags

Compatibility claims must not be invented. The initial `ari-lint`
release/version policy is documented in
`docs/dev/release-compatibility-policy.md`, but no compatibility entry exists
until its evidence requirements are satisfied.

Do not invent Ari syntax or APIs without checking `ari-foundry/ari`.

Do not copy broad Ari language, compiler, standard library, LSP, editor, or
package-manager docs into this repository.

## Issue Routing

compiler bugs belong in ari-foundry/ari issues.

standard library bugs belong in ari-foundry/ari issues.

Ari language/toolchain limitations belong in ari-foundry/ari issues.

`ari-lint` issues are for lint tooling, lint rules, config, diagnostics, docs,
tests, and Ari-language implementation.

If a bug crosses the boundary, file the root cause in ari-foundry/ari and link
it from `ari-lint` if needed.

## Workflow

Keep pull requests small and scoped.

Run the available validation before creating a pull request.

Before changing split-related content, read the relevant Ari reference docs,
especially the documentation ownership note, tooling split criteria,
`ari-lint` boundary inventory, CLI/diagnostic contract, dependency model,
standalone test plan, and repository skeleton note.
