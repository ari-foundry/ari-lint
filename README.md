# ari-lint

`ari-lint` is lint tooling for the Ari language.

This repository is the active standalone split implementation of `ari-lint`.
It now carries Ari-language source, local build and smoke scripts, lint rule
metadata, config handling, diagnostic output wiring, and focused development
documentation for the split.

The near-term dependency model is invoking `ari --check` for compiler-backed
checking when that boundary is added. Compiler behavior remains owned by the
Ari compiler project. The current `tools/lint` implementation in
`ari-foundry/ari` remains the reference implementation for now.

The long-term implementation direction is to develop `ari-lint` in Ari when
the language and toolchain are ready.

## References

- Ari compiler/language project: https://github.com/ari-foundry/ari
- Ari releases: https://github.com/ari-foundry/ari/releases
- Ari tags: https://github.com/ari-foundry/ari/tags
- Ari Foundry portal: https://ari-foundry.github.io

## Current Scope

This repository owns `ari-lint` tooling, lint rule source, CLI behavior,
diagnostic behavior, configuration behavior, local validation scripts, focused
developer documentation, and future release notes.

Contributors should use `ari-foundry/ari` docs, examples, and tests as the
source of truth for current Ari language usage.

Future `ari-lint` compatibility policy should be based on real Ari releases and
tags. Do not claim compatibility with any Ari version unless it is verified from
an actual Ari release or tag.

Do not treat the current implementation as a stable release. No install
command, package registry entry, release artifact, or compatibility guarantee
is available from this repository yet. Do not add unverified Ari code examples
here.

## Current Capabilities

- Local build via `scripts/build.sh` with an explicit Ari compiler path or
  `ARI_COMPILER`.
- Local smoke validation via `scripts/smoke.sh` with an explicit Ari compiler
  path or `ARI_COMPILER`.
- CLI `--help` output.
- CLI `--list-rules` output.
- Source-file lint for all explicitly provided positional source files, using
  the currently implemented rules:
  `lint/trailing-whitespace` and `lint/missing-final-newline`.
- `--json` diagnostics for source-file lint results.
- Explicit config file loading with `--config`.
- Discovered `ari-lint.rules` config when `--config` is absent, searching from
  the current working directory upward and using the nearest file.
- `--rule` severity overrides. Current precedence is default severity <
  discovered config < explicit `--config` < CLI `--rule`.

## Current Limitations

- `tools/lint` in `ari-foundry/ari` remains the reference implementation for
  now.
- This repository has no stable `ari-lint` release yet.
- No Ari version compatibility claim is established yet.
- There is no parity runner or golden parity suite yet.
- CI is not compiler-backed yet.
- The implemented rule set is limited.
- Directory traversal and recursive source-tree scanning are not implemented;
  pass source files explicitly.
- Home, global, XDG, and environment-provided config locations are not part of
  the current config behavior.

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
the lightweight check script, which checks repository-shape, source, script,
documentation, and fixture invariants only. Use `scripts/smoke.sh` for local
compiler-backed build and CLI smoke validation.

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
./build/ari-lint --json --config /tmp/.../explicit.rules /tmp/.../trailing.ari
./build/ari-lint --json --config /tmp/.../explicit.rules --rule trailing-whitespace=note /tmp/.../trailing.ari
./build/ari-lint --json /tmp/.../trailing.ari
./build/ari-lint --json /tmp/.../one.ari /tmp/.../two.ari
```

These checks verify only that the local binary builds and the supported smoke
commands execute. They do not add golden output tests, parity checks,
compiler-backed CI, home/global/XDG config search, new lint semantics, or
compatibility claims. The config smoke uses explicit temporary files and a
temporary nested working directory containing `ari-lint.rules`; it checks only
the current JSON rule code and severity fields for config precedence. Focused
diagnostic smoke checks assert current `ruleCode`, `severity`, `message`,
`filePath`, `line`, and `column` fields for `lint/trailing-whitespace` and
`lint/missing-final-newline`, plus multi-file JSON diagnostics, a clean plus
dirty invocation, and a clean plus clean invocation. JSON list-rules output
assertions and broader golden output coverage remain future smoke coverage.
