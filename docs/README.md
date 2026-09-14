# ari-lint Docs

These docs will eventually contain `ari-lint` CLI, rule, diagnostic,
configuration, test, release, and compatibility documentation.

Detailed Ari language and compiler docs remain in the Ari compiler project:
https://github.com/ari-foundry/ari

Current Ari language usage must be referenced from `ari-foundry/ari` docs,
examples, and tests.

The Ari Foundry portal remains the ecosystem entry point:
https://ari-foundry.github.io

Future compatibility docs should reference real Ari releases and tags:

- https://github.com/ari-foundry/ari/releases
- https://github.com/ari-foundry/ari/tags

Documentation migration is staged and tracked in
[docs/migration.md](migration.md).

Ari-language implementation is active but not yet compiler-integrated. The implementation plan is
tracked in [docs/dev/ari-implementation-plan.md](dev/ari-implementation-plan.md).

Parity testing against the current bundled/reference `tools/lint` behavior is
planned in [docs/dev/parity-test-plan.md](dev/parity-test-plan.md). A local
report-only parity runner exists; a strict gate does not.
Known parity differences from the current report-only local smoke are tracked
in [docs/dev/parity-differences.md](dev/parity-differences.md).

Future Ari compiler provisioning for compiler-backed tests and boundary
behavior is planned in
[docs/dev/compiler-provisioning.md](dev/compiler-provisioning.md). Compiler
provisioning is not implemented yet.

The compiler selection and per-file argv boundary is documented in
[docs/dev/compiler-invocation.md](dev/compiler-invocation.md). Explicit
`--ari` path validation and `-I` planning exist, but compiler invocation and
`ARI_COMPILER` fallback are not implemented yet.

The initial release and compatibility policy is documented in
[docs/dev/release-compatibility-policy.md](dev/release-compatibility-policy.md).
It does not claim compatibility with any Ari release or tag.

Rule documentation is currently a set of design notes until Ari-language rule
implementation exists. Current rule design notes include
[docs/rules/trailing-whitespace.md](rules/trailing-whitespace.md) and
[docs/rules/missing-final-newline.md](rules/missing-final-newline.md).

Compiler and standard library (stdlib) bugs should be filed in
`ari-foundry/ari`, not `ari-lint`.

This documentation is provisional until Ari-language implementation and docs
migration are complete. Do not copy `docs/lint` content from `ari-foundry/ari`
wholesale in this skeleton step, and do not include unverified Ari syntax
examples.
