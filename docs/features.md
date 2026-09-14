# ari-lint Features

## Status

This page describes the current standalone, pre-release `ari-lint`
implementation. It is the user-facing feature overview for this repository; it
does not establish a stable `ari-lint` release or compatibility with an Ari
compiler release.

## Explicit Source Checks

Once CLI and explicit-config validation succeeds, `ari-lint` checks one or more
source files named on the command line. It keeps positional order, including
duplicate paths, and produces one result for each positional input. Directory
traversal and recursive source-tree scanning are not implemented.

For every source file, the tool invokes the selected Ari compiler directly,
without a shell, using this argument order:

```text
-I DIR ... SOURCE --check
```

Runtime compiler selection is, in descending precedence:

1. `--ari PATH` or `--ari=PATH`
2. a present `ARI_COMPILER` environment entry
3. the literal fallback `build/ari`

Compiler execution happens before discovered-config and native-rule checks.
Parsed compiler diagnostics and truncation markers are normally emitted first;
the conditional compiler-failure fallback can follow native diagnostics. The
exact order is defined in [Diagnostic Output](diagnostics.md). Compiler
behavior, Ari syntax, and Ari language diagnostics remain owned by
[the Ari compiler project](https://github.com/ari-foundry/ari).

## Native Rules

The current rule registry contains two rules:

| Rule | Default | Behavior |
| --- | --- | --- |
| `lint/trailing-whitespace` | `warning` | Reports spaces or tabs at the end of a source line. |
| `lint/missing-final-newline` | `warning` | Reports a non-empty source file that does not end with a line-feed byte. |

Full rule codes and their short names are accepted by config and command-line
overrides. See [the rule reference](rules.md) for the registry and links to the
detailed rule notes.

## Configuration

Rule severities can be selected through a discovered `ari-lint.rules` file, an
explicit `--config PATH`, and one or more `--rule RULE=SEVERITY` overrides.
Command-line overrides are applied last. The exact grammar, discovery boundary,
precedence, and error behavior are documented in
[Configuration](config.md).

## Output And Metadata

Human source results are the default. `--json` emits one JSON document with an
ordered `files` array. The exact source-result fields, diagnostic order,
stream selection, exit statuses, encoding, final newline, and bounded compiler
output behavior are defined in [Diagnostic Output](diagnostics.md).

`--list-rules` and `--json --list-rules` expose the current registry without
invoking the selected compiler. Their exact output contract is documented in
[List-Rules](list-rules.md).

`--help` prints the supported command surface. Include paths supplied as
`-I DIR` or `-IDIR` are forwarded to every compiler invocation in their
original order. `--` treats every following token as a source operand.

## Current Boundaries

- The bundled `tools/lint` implementation in `ari-foundry/ari` remains the
  behavior-parity reference during the split.
- The native rule set is intentionally small.
- Home, global, XDG, and environment-selected config locations are not
  searched.
- Strict parity currently covers the registry, a native-rule subset, an
  explicit-config subset, and one deterministic compiler-boundary case. Wider
  report-only coverage is not a compatibility guarantee.
- Compiler-backed CI exercises one checksum-pinned Ari `v0.1.0` prerelease
  artifact. That is build/test evidence, not a compatibility claim.

Build, smoke, parity, and CI details remain in the focused developer docs
linked from [the documentation index](README.md).
