# ari-lint Documentation Migration Plan

## Purpose

This document plans how lint documentation will move from `ari-foundry/ari`
into `ari-foundry/ari-lint`.

This step does not move source code, does not copy docs wholesale, and does not
remove docs from `ari-foundry/ari`.

## Current Documentation Sources

Current Ari lint documentation sources in `ari-foundry/ari` are:

- `docs/lint/README.md`
- `docs/lint/features.md`
- `docs/lint/dev/README.md`
- `docs/lint/dev/roadmap.md`

Do not guess files that do not exist.

## Target Documentation Areas

Future `ari-lint` documentation areas in this repository are:

- `docs/README.md` as the docs entry point
- `docs/features.md` for lint feature documentation
- `docs/config.md` for `ari-lint.rules` and rule override documentation
- `docs/diagnostics.md` for human-readable and JSON diagnostic behavior
- `docs/rules.md` for lint rule reference
- `docs/dev/roadmap.md` for development roadmap
- `README.md` for high-level project overview

These files are planned targets. They are not all created in this step.

## Migration Strategy

1. Add migration plan in `ari-lint`.
2. Add handoff note in `ari-foundry/ari` `docs/lint` later.
3. Copy or adapt `docs/lint` content into `ari-lint` in small scoped PRs.
4. Keep links back to `ari-foundry/ari` while source extraction is incomplete.
5. After source extraction, make `ari-lint` docs the primary docs.
6. Update Ari Foundry portal only after `ari-lint` docs are usable.

## Content Ownership

`ari-lint` docs should own lint CLI, rules, config, diagnostics, tests,
releases, and compatibility.

Ari language and compiler docs remain in `ari-foundry/ari`. Compiler behavior
remains in `ari-foundry/ari`.

Broad Ari language and compiler documentation must not be copied into
`ari-lint`.

Current Ari language usage must be checked against `ari-foundry/ari` docs,
examples, and tests.

## Release And Compatibility References

Future `ari-lint` compatibility docs must reference real Ari releases and tags.

Ari releases:
https://github.com/ari-foundry/ari/releases

Ari tags:
https://github.com/ari-foundry/ari/tags

Do not invent compatibility claims or version numbers.

Do not claim `ari-lint` has a stable release yet.

## Handoff Plan For ari-foundry/ari

A later step should update `ari-foundry/ari` `docs/lint` with a handoff note
once this repository has enough docs to be useful.

The handoff should:

- point to `ari-foundry/ari-lint`
- keep historical context in `ari` during migration
- avoid deleting `docs/lint` abruptly
- avoid broken links from `docs/README.md`
- avoid claiming `ari-lint` is stable before source extraction and tests exist

## Non-Goals

- Do not move `tools/lint` in this step.
- Do not move `docs/lint` out of `ari-foundry/ari` in this step.
- Do not copy `docs/lint` content wholesale in this step.
- Do not add `ari-lint` source code in this step.
- Do not add Ari source files in this step.
- Do not add standalone tests in this step.
- Do not add release workflows in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.

## Follow-up Checklist

- [ ] Add handoff note in `ari-foundry/ari` `docs/lint`
- [ ] Adapt `docs/lint/features.md` into `ari-lint` `docs/features.md`
- [ ] Adapt `docs/lint/README.md` into `ari-lint` README/docs entry points
- [ ] Split config documentation into `docs/config.md`
- [ ] Split diagnostics documentation into `docs/diagnostics.md`
- [ ] Split rule reference into `docs/rules.md`
- [ ] Keep links to Ari compiler docs in `ari-foundry/ari`
- [ ] Update Ari Foundry portal after docs are usable
- [ ] Avoid stable release claims until release policy exists
