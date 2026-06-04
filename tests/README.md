# ari-lint Tests

Tests will be added after actual implementation begins.

Current checks only verify skeleton files and lightweight documentation/source
guards.

Future tests should cover CLI smoke tests, rule tests, configuration tests,
diagnostic output, compiler-boundary behavior, and parity with current
`tools/lint`.

Tests should use an explicit `--ari` compiler path in CI unless the dependency
model changes.

Future Ari-language implementation tests must follow current `ari-foundry/ari`
language usage.

No actual test fixtures are added in this skeleton step.
