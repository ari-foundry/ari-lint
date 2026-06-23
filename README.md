# ari-lint

`ari-lint` is lint tooling for the Ari language.

This repository is being initialized as part of the `ari-lint` split from
`ari-foundry/ari`. It is a skeleton only at this stage:

- source extraction from ari-foundry/ari has not happened yet
- docs migration from ari-foundry/ari has not happened yet
- local standalone build wiring has started with an explicit compiler path
- local standalone test entrypoint wiring has started with compiler-free checks

The near-term dependency model is invoking `ari --check` for compiler-backed
checking. Compiler behavior remains owned by the Ari compiler project.

The long-term implementation direction is to develop `ari-lint` in Ari when
the language and toolchain are ready.

## References

- Ari compiler/language project: https://github.com/ari-foundry/ari
- Ari releases: https://github.com/ari-foundry/ari/releases
- Ari tags: https://github.com/ari-foundry/ari/tags
- Ari Foundry portal: https://ari-foundry.github.io

## Current Scope

This repository will eventually hold `ari-lint` source, CLI documentation, rule
documentation, diagnostic documentation, configuration docs, tests, and release
notes.

Contributors should use `ari-foundry/ari` docs, examples, and tests as the
source of truth for current Ari language usage.

Future `ari-lint` compatibility policy should be based on real Ari releases and
tags. Do not claim compatibility with any Ari version unless it is verified from
an actual Ari release or tag.

Do not treat this skeleton as a stable release or a fully standalone tool. No
install command, package registry entry, release artifact, or compatibility
guarantee is available from this repository yet. Do not add unverified Ari code
examples here.

## Local Checks

Run the lightweight repository-shape check with:

```sh
scripts/check.sh
```

Run the local standalone test entrypoint with:

```sh
scripts/test.sh
```

This is not a full test suite yet. The standalone test entrypoint delegates to
the lightweight check script, which checks skeleton files and fixture
invariants only.

## Local Build Scaffold

Build the current Ari-language entrypoint locally with an explicit Ari compiler path:

```sh
scripts/build.sh /path/to/ari
```

You may also set `ARI_COMPILER`; a positional compiler path takes precedence if
both are provided. The build script resolves the repository root, uses the
compiler root when `lib/std.arih` is available there, writes `build/ari-lint`,
does not download or build the Ari compiler, and does not run `tools/lint`. It
preserves relative compiler paths from the caller's directory.

CI does not run compiler-backed builds or tests yet, and this repository is not
a standalone release.

## Local Smoke Validation

Run the local build plus minimal CLI smoke checks with an explicit Ari compiler
path:

```sh
scripts/smoke.sh /path/to/ari
```

You may also set `ARI_COMPILER`:

```sh
ARI_COMPILER=/path/to/ari scripts/smoke.sh
```

The smoke script delegates build behavior to `scripts/build.sh`. After the build
succeeds, it runs these current safe CLI invocations:

```sh
./build/ari-lint --help
./build/ari-lint --list-rules
./build/ari-lint --json --list-rules
./build/ari-lint --config /tmp/.../explicit.rules /tmp/.../clean.ari
```

These checks verify only that the local binary builds and the supported smoke
commands execute. They do not add golden output tests, parity checks,
compiler-backed CI, config discovery, new lint semantics, or compatibility
claims. The config smoke uses an explicit temporary config file only. JSON
list-rules output assertions remain future smoke coverage.
