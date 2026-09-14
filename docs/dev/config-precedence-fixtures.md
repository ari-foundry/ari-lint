# ari-lint Config Precedence Fixture Plan

This document records the narrow source-controlled fixture set, executable
smoke coverage, and initial strict parity subset for `ari-lint` configuration
precedence behavior.

It does not add dedicated Ari parser tests, real-compiler validation, package
manager wiring, release automation, broad strict parity, or compatibility
claims. The local strict runner invokes the bundled `tools/lint` reference only
when explicitly requested by a developer.

## Current Status

`src/config.ari` parses caller-provided config text and `--rule` values into
internal severity overrides, normalizing documented short rule names to full
lint rule codes. The main-facing CLI searches lexically upward from each source
file's directory for the nearest readable `ari-lint.rules`. An explicit
`--config` applies to every source and disables discovery, and command-line
`--rule` settings are applied last.

Bad lines in a discovered config become ordered per-file `lint/config`
diagnostics on stdout and make the command exit `1`; valid lines from the same
file still participate in precedence. Explicit config read or parse errors are
written to stderr in the reference shape, include every parse error, stop before
source linting, and exit `2`.

Initial config precedence fixture files exist under
`tests/fixtures/config-precedence/`. Lightweight checks verify that committed
fixture set's key contents and exact line order only. Separately,
`scripts/smoke.sh` builds and executes the standalone CLI against generated
temporary configs to cover per-source discovery, explicit-config precedence,
CLI-last precedence, and config error output; the pinned compiler-smoke CI now
runs that suite. The local `scripts/parity-strict.sh` runner uses the committed
config fixtures to gate explicit severity, `off` suppression, and CLI-last
override behavior against exact source-controlled JSON goldens, plus one exact
human-output golden. Dedicated Ari unit tests and broader strict discovery and
config-error coverage remain future work.

## Implemented Precedence

The implemented precedence order is:

1. default rule severity
2. config-file overrides from per-source `ari-lint.rules` discovery or explicit
   `--config`
3. command-line `--rule` overrides

Later matching overrides in the caller-provided override list win. The local
executable smoke exercises the broader order, while the initial strict subset
gates default-to-explicit severity changes, explicit `off`, and a later CLI
override. Neither is a release compatibility claim.

## Fixture Areas

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

The lightweight checks do not parse these committed fixtures with Ari code.
They only verify presence, exact line order, expected text, and strict-runner
wiring. The strict runner passes the committed discovered/explicit config files
through both executable implementations; the separate executable smoke uses
generated temporary config files for broader cases. Dedicated Ari unit tests
remain future work.

Broader source-controlled golden coverage, real-compiler validation, and broad
source fixture expansion remain outside this fixture plan until those
behaviors are explicitly scoped.

The initial strict subset is a reviewed pre-release config behavior contract.
Config precedence must not be documented as stable release compatibility from
this subset; broader discovery, config-error, and multi-source strict coverage
plus a deliberate compatibility entry remain separate requirements for any
support claim.
