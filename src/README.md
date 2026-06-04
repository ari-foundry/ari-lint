# ari-lint Source

This directory is the future Ari-language implementation area for `ari-lint`.

The source here is currently a skeleton only: real lint rules are not implemented yet.
CLI parsing is not implemented yet, diagnostics output is not
implemented yet, config parsing is not implemented yet, and this source does
not invoke `ari --check` yet.

## Internal Model Skeleton

This source tree now contains minimal Ari-language internal model skeleton
files:

- `src/model.ari` groups future model modules.
- `src/diagnostic.ari` sketches diagnostic concepts such as file path, line,
  column, optional end position, severity, rule code, and message.
- `src/rule.ari` sketches rule metadata concepts such as rule code, short name,
  default severity, and description.
- `src/config.ari` sketches config concepts such as severity overrides,
  `ari-lint.rules` config source, and command-line override source.

These files define placeholder data shapes only. They do not implement real
lint rules, rule execution, CLI parsing, config parsing, diagnostics output,
JSON serialization, file reads, or `ari --check` invocation. The JSON schema is
not stable yet.

The current behavior parity target is the bundled `tools/lint` reference
implementation in `ari-foundry/ari`. Do not copy or move `tools/lint` into this
repository.

Ari syntax and idioms must be verified against `ari-foundry/ari` docs,
examples, and tests before adding source here.

Compiler, standard library, or Ari toolchain bugs should be filed in
`ari-foundry/ari`, not in `ari-lint` as primary issues.

No package manager manifest exists yet because the arix/package workflow is not
established in this repository.
