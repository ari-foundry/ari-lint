# ari-lint Rules

## Registry

The current standalone registry is deterministic and contains these rules in
this order:

| Rule code | Short name | Default severity | Description |
| --- | --- | --- | --- |
| `lint/trailing-whitespace` | `trailing-whitespace` | `warning` | Reports spaces or tabs at the end of a source line. |
| `lint/missing-final-newline` | `missing-final-newline` | `warning` | Reports non-empty source files that do not end with a newline. |

The exact machine-readable and human registry output is defined by
[the list-rules contract](list-rules.md). Run either form without an Ari source
file:

```sh
./build/ari-lint --list-rules
./build/ari-lint --json --list-rules
```

Neither command invokes the selected Ari compiler.

## Rule Behavior

### `lint/trailing-whitespace`

This rule reports each logical source line ending in one or more spaces or
tabs. The diagnostic starts at the first trailing space or tab and uses the
message `trailing whitespace`.

Detailed implementation status, location semantics, and remaining fixture
work are in
[the trailing-whitespace rule note](rules/trailing-whitespace.md).

### `lint/missing-final-newline`

This rule reports non-empty source bytes whose last byte is not line feed
(`0x0a`). Empty files are not reported. The diagnostic uses the message
`missing final newline`.

Detailed implementation status, location semantics, and remaining fixture
work are in
[the missing-final-newline rule note](rules/missing-final-newline.md).

## Severity Control

Both full rule codes and short names can be used in `ari-lint.rules`, an
explicit config file, or `--rule RULE=SEVERITY`. Supported severities are
`off`, `hint`, `note`, `warning`, and `error`; both rules default to `warning`.

`off` suppresses a matching native-rule diagnostic. Other severity values keep
the diagnostic enabled. Config-file settings replace registry defaults, and
later command-line overrides take precedence. See
[Configuration](config.md) for the exact grammar and discovery behavior.

## Diagnostic Order And Status

For each positional source, parsed compiler diagnostics and any truncation
markers precede discovered-config diagnostics, which precede native
diagnostics. A conditional `ari/compiler-check-failed` fallback can follow the
native portion. Within that native portion, `lint/trailing-whitespace`
diagnostics are collected before the optional `lint/missing-final-newline`
diagnostic. Files retain positional argument order. The complete order is in
[Diagnostic Output](diagnostics.md).

Any enabled native-rule diagnostic makes the top-level source command exit
`1`, regardless of whether its configured severity is `hint`, `note`,
`warning`, or `error`. Exact human and JSON shapes are documented in
[Diagnostic Output](diagnostics.md).

## Change Policy

Adding, removing, renaming, or reordering a rule, changing its short name,
default severity, description, detection behavior, or diagnostic message
requires coordinated updates to the registry docs and relevant exact tests.
This is a pre-release contract and not an Ari compiler compatibility claim.
