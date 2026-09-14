# ari-lint Configuration

## Scope

This page defines the current standalone, pre-release rule-configuration
behavior. Intentional changes must update this page and the corresponding
smoke or strict-parity coverage. It does not establish a stable release or an
Ari compiler compatibility claim.

## File Format

A config file contains one `RULE = SEVERITY` setting per line:

```text
# Project lint policy
trailing-whitespace = error
lint/missing-final-newline = off
```

The parser applies these rules:

- The first `#` starts a comment; the rest of that line is ignored.
- Leading and trailing whitespace is ignored around the remaining line, the
  rule name, and the severity.
- Empty and comment-only lines are ignored.
- A setting is split at its first `=`. Both sides must be present and the rule
  must be known.
- A rule may use its full code, such as `lint/trailing-whitespace`, or its short
  name, such as `trailing-whitespace`.
- Severity names are the exact lowercase values `off`, `hint`, `note`,
  `warning`, and `error`.
- Later settings for the same rule win.

`off` suppresses matching native-rule diagnostics. The other values are emitted
as the configured diagnostic severity; `hint`, `note`, `warning`, and `error`
remain enabled diagnostics and therefore make the current source command exit
`1`.

## Discovery And Selection

Without a non-empty explicit `--config` path, configuration is discovered
independently for each positional source file. Search starts in that source
file's directory and walks through lexical parents, selecting the nearest readable
path named `ari-lint.rules`. An unreadable candidate is skipped and
the search continues upward.

Search follows the lexical directory of the supplied source operand; a bare
filename starts at `.`. Different files in one command can therefore select
different configs.

A selected directory named `ari-lint.rules` is treated as an empty config and
masks higher candidates. Likewise, an explicit directory path is treated as an
empty config while still disabling discovery. These edge behaviors are covered
by current smoke tests but are not release compatibility guarantees.

```text
project/
  ari-lint.rules
  app/
    ari-lint.rules
    main.ari
  lib/
    helper.ari
```

In this layout, `app/main.ari` selects `app/ari-lint.rules`, while
`lib/helper.ari` selects `project/ari-lint.rules`, provided those candidates
are readable.

An explicit `--config PATH` or `--config=PATH` applies the same file to every
source and disables discovery:

```sh
./build/ari-lint --config path/to/policy.rules path/to/source.ari
```

Home, global, XDG, and environment-selected config locations are not part of
the current behavior.

## Precedence

Effective native-rule severity is resolved in this order:

1. the registry default
2. settings from the selected discovered or explicit config file
3. command-line `--rule` settings, in command-line order

The last matching setting wins. For example:

```sh
./build/ari-lint \
  --config path/to/policy.rules \
  --rule trailing-whitespace=note \
  path/to/source.ari
```

Both `--rule RULE=SEVERITY` and `--rule=RULE=SEVERITY` are accepted, and the
option may be repeated.

## Invalid Configuration

Explicit and discovered config errors intentionally use different command
boundaries:

| Situation | Output | Status | Source processing |
| --- | --- | --- | --- |
| Explicit config cannot be read or contains an invalid line | Text diagnostics on stderr | `2` | No source result is emitted. |
| Discovered config contains an invalid line | Ordered per-file `lint/config` diagnostics in the selected human or JSON source result on stdout | `1` | Valid settings from that same file still participate. |
| A `--rule` value is malformed, has an unknown rule, or has an invalid severity | A command-line error summary on stderr | `2` | No source result is emitted. |

Each invalid discovered-config line becomes a diagnostic. Config diagnostics
are not disabled by native-rule severity settings.

The general source output and stream contract is in
[Diagnostic Output](diagnostics.md). Current rule names and defaults are in
[Rules](rules.md).

## Validation Boundary

Compiler-backed smoke covers per-source nearest-readable discovery, different
configs in one multi-file command, unreadable-nearer fallback, explicit-config
discovery suppression, CLI-last precedence, disabled rules, and both config
error paths. The strict checked-in subset gates explicit severity, `off`, and
CLI-last behavior with exact JSON and representative human output. Broader
strict discovery and config-error parity remains future work.
