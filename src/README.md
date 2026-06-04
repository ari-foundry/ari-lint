# ari-lint Source

This directory is the future Ari-language implementation area for `ari-lint`.

The source here is currently a skeleton only. Real lint rules are not
implemented yet, CLI parsing is not implemented yet, diagnostics are not
implemented yet, and this source does not invoke `ari --check` yet.

The current behavior parity target is the bundled `tools/lint` reference
implementation in `ari-foundry/ari`. Do not copy or move `tools/lint` into this
repository.

Ari syntax and idioms must be verified against `ari-foundry/ari` docs,
examples, and tests before adding source here.

Compiler or standard library bugs should be filed in `ari-foundry/ari`, not in
`ari-lint` as primary issues.

No package manager manifest exists yet because the arix/package workflow is not
established in this repository.
