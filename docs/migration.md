# ari-lint Documentation Migration Plan

## Purpose

This document tracks how lint documentation is moving from `ari-foundry/ari`
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

Target `ari-lint` documentation areas in this repository are:

- `docs/README.md` as the docs entry point
- `docs/features.md` for lint feature documentation
- `docs/config.md` for `ari-lint.rules` and rule override documentation
- `docs/diagnostics.md` for human-readable and JSON diagnostic behavior
- `docs/rules.md` for lint rule reference
- `docs/dev/roadmap.md` for development roadmap
- `README.md` for high-level project overview

These are migration targets. The entry point, diagnostic contract, and
developer roadmap now exist; the remaining user-facing targets are tracked
below.

## Migration Strategy

1. Keep the migration plan in `ari-lint` current as each area moves.
2. The initial `ari-foundry/ari` `docs/lint` handoff links were added by
   [Ari PR #16](https://github.com/ari-foundry/ari/pull/16).
3. Adapt lint-specific `docs/lint` content into `ari-lint` in small scoped PRs.
4. Keep links back to `ari-foundry/ari` while the standalone documentation
   handoff is incomplete.
5. After the user-facing handoff is complete, make `ari-lint` docs primary.
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

## Handoff State For ari-foundry/ari

The initial handoff links now exist in `ari-foundry/ari` `docs/lint`. Further
handoff edits remain separate upstream work as the user-facing docs here become
complete.

Further handoff work should:

- point to `ari-foundry/ari-lint`
- keep historical context in `ari` during migration
- avoid deleting `docs/lint` abruptly
- avoid broken links from `docs/README.md`
- avoid claiming `ari-lint` is stable before the standalone implementation and
  tests are ready

## Non-Goals

- Do not move `tools/lint` in this step.
- Do not move `docs/lint` out of `ari-foundry/ari` in this step.
- Do not copy `docs/lint` content wholesale in this step.
- Do not add `ari-lint` source code in this step.
- Do not add Ari source files in this step.
- Do not add release workflows in this step.
- Do not claim compatibility matrix support in this step.
- Do not modify `ari-foundry/ari` in this step.
- Do not modify `ari-foundry/ari-foundry.github.io` in this step.

## Follow-up Checklist

- [x] Add handoff note in `ari-foundry/ari` `docs/lint`
- [ ] Adapt `docs/lint/features.md` into `ari-lint` `docs/features.md`
- [ ] Adapt `docs/lint/README.md` into `ari-lint` README/docs entry points
- [ ] Split config documentation into `docs/config.md`
- [x] Split diagnostics documentation into `docs/diagnostics.md`
- [ ] Split rule reference into `docs/rules.md`
- [x] Keep links to Ari compiler docs in `ari-foundry/ari`
- [ ] Update Ari Foundry portal after docs are usable
- [x] Avoid stable release claims under the documented release policy
