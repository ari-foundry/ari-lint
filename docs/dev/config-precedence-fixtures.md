# ari-lint Config Precedence Fixture Plan

This document records fixture coverage for future `ari-lint` configuration
precedence behavior.

It does not add executable parser tests, config-file discovery, `--config` file
reading, CLI output, compiler execution, `ari --check`, `tools/lint`, package
manager wiring, release automation, or compatibility claims.

## Current Status

`src/config.ari` can parse caller-provided config text and caller-provided
`--rule` values into internal severity overrides. The CLI source-file lint path
can apply parsed `--rule` overrides to explicit source-file inputs.

Initial config precedence fixture files now exist under
`tests/fixtures/config-precedence/`. Lightweight checks verify the fixture set
and key contents only. Standalone config discovery, explicit `--config` file
reading, executable config tests, and parity checks remain future work.

## Planned Precedence

The intended precedence order is:

1. default rule severity
2. config-file overrides from future `ari-lint.rules` discovery or explicit
   `--config`
3. command-line `--rule` overrides

Later matching overrides in the caller-provided override list win. Future
fixture files must preserve that rule without claiming stable behavior until
the executable tests exist.

## Planned Fixture Areas

Initial fixtures cover:

- default severity when no override exists
- a config-file override for one known rule
- an explicit `--config` override disabling discovery
- a command-line `--rule` override for one known rule
- a config-file override replaced by a later command-line `--rule` override
- repeated command-line `--rule` overrides where the later value wins
- unknown rule handling
- invalid severity handling
- blank lines and `#` comments in config text

## Boundaries

The current fixture set is intentionally narrow:

- `tests/fixtures/config-precedence/ari-lint.rules`
- `tests/fixtures/config-precedence/explicit-config.rules`
- `tests/fixtures/config-precedence/command-line-overrides.txt`
- `tests/fixtures/config-precedence/invalid.rules`

The lightweight checks do not parse these fixtures with Ari code. They only
verify presence and expected text. Future executable tests must still connect
the fixture data to config parsing and precedence behavior.

Avoid golden JSON, CLI-process tests, compiler execution, `ari --check`,
`tools/lint`, and broad source fixture expansion until those behaviors are
explicitly scoped.

Config precedence must not be documented as stable until fixture files,
executable tests, and parity checks exist.
