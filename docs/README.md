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
tracked in [docs/dev/parity-test-plan.md](dev/parity-test-plan.md). A local
report-only runner and strict list-rules/native-rule subsets exist. An initial
strict config subset gates explicit severity, `off`, and CLI-last behavior, and
one deterministic strict compiler-boundary case gates exact `SOURCE --check`
child argv with combined compiler/native JSON and human output. Broader CLI,
config, and compiler-boundary parity remains open.
Known parity differences from the current report-only local smoke are tracked
in [docs/dev/parity-differences.md](dev/parity-differences.md).

The standalone rule-registry listing schema, exact stream/status behavior, and
intentional differences from the bundled reference are defined in
[docs/list-rules.md](list-rules.md).

The standalone source-result JSON schema, human diagnostic shape, diagnostic
ordering, encoding, stream selection, and top-level status mapping are defined
in [docs/diagnostics.md](diagnostics.md). This is a tested pre-release contract,
not an Ari compatibility claim.

Local compiler selection and the checksum-pinned CI baseline are documented in
[docs/dev/compiler-provisioning.md](dev/compiler-provisioning.md). The local
runtime boundary and separate compiler-backed smoke workflow are implemented;
the baseline is not a compatibility claim.

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
