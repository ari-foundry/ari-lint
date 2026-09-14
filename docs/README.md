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

Ari-language implementation is active, including per-source external compiler
checks. The implementation plan is tracked in
[docs/dev/ari-implementation-plan.md](dev/ari-implementation-plan.md).

Parity testing against the current bundled/reference `tools/lint` behavior is
planned in [docs/dev/parity-test-plan.md](dev/parity-test-plan.md). A local
report-only parity runner exists; a strict gate does not.
Known parity differences from the current report-only local smoke are tracked
in [docs/dev/parity-differences.md](dev/parity-differences.md).

Local compiler selection and the remaining pinned CI provisioning work are
documented in
[docs/dev/compiler-provisioning.md](dev/compiler-provisioning.md). The local
runtime boundary is implemented; compiler-backed CI is not.

The implemented compiler selection, per-file argv, diagnostic parsing, and
process-status boundary is documented in
[docs/dev/compiler-invocation.md](dev/compiler-invocation.md). Source commands
select `--ari`, then `ARI_COMPILER`, then `build/ari`, and invoke the selected
compiler directly without a shell.

The initial release and compatibility policy is documented in
[docs/dev/release-compatibility-policy.md](dev/release-compatibility-policy.md).
It does not claim compatibility with any Ari release or tag.

Rule documentation contains focused behavior and design notes for the current
rule implementation. Current rule notes include
[docs/rules/trailing-whitespace.md](rules/trailing-whitespace.md) and
[docs/rules/missing-final-newline.md](rules/missing-final-newline.md).

Compiler and standard library (stdlib) bugs should be filed in
`ari-foundry/ari`, not `ari-lint`.

This documentation remains provisional until the standalone implementation and
docs migration are complete. Do not copy `docs/lint` content from
`ari-foundry/ari` wholesale, and do not include unverified Ari syntax examples.
