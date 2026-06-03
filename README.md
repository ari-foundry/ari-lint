# ari-lint

`ari-lint` is lint tooling for the Ari language.

This repository is being initialized as part of the `ari-lint` split from
`ari-foundry/ari`. It is a skeleton only at this stage:

- source extraction from ari-foundry/ari has not happened yet
- docs migration from ari-foundry/ari has not happened yet
- standalone build/test wiring has not happened yet

The near-term dependency model is invoking `ari --check` for compiler-backed
checking. Compiler behavior remains owned by the Ari compiler project.

The long-term implementation direction is to develop `ari-lint` in Ari when
the language and toolchain are ready.

## References

- Ari compiler/language project: https://github.com/ari-foundry/ari
- Ari Foundry portal: https://ari-foundry.github.io

## Current Scope

This repository will eventually hold `ari-lint` source, CLI documentation, rule
documentation, diagnostic documentation, configuration docs, tests, and release
notes.

Contributors should use `ari-foundry/ari` docs, examples, and tests as the
source of truth for current Ari language usage.

Do not treat this skeleton as a stable release or a fully standalone tool. No
install command, package registry entry, release artifact, or compatibility
guarantee is available from this repository yet. Do not add unverified Ari code
examples here.
