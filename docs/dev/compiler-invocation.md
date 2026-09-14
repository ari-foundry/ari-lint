# Ari Compiler Invocation Contract

## Purpose

This document records the standalone `ari-lint` compiler-selection and
argument-forwarding boundary. The near-term dependency model remains invoking
an external Ari compiler with `--check`; compiler execution itself is not yet
wired into the main command.

## Current Status

- The CLI accepts `--ari PATH` and `--ari=PATH`.
- Source-lint commands validate an explicit compiler path for existence and
  executability. Help and rule listing do not require a compiler.
- The CLI accepts both `-I DIR` and `-IDIR` and retains include paths in command
  order.
- Compiler argv is planned once per input file as `-I DIR ... FILE --check`.
- The planned boundary does not spawn the compiler or capture its output yet.
- `ARI_COMPILER` and the reference default `build/ari` fallback are not wired
  into the standalone command yet.

The bundled implementation in `ari-foundry/ari` remains the behavior reference.
The current source evidence is `tools/lint/main.cpp` and
`tools/lint/checker.cpp`; the standalone code must not copy those files.

## Selection Precedence

The reference implementation selects the compiler in this order:

1. `--ari PATH`
2. `ARI_COMPILER`, when the environment entry is present
3. the literal path `build/ari`

The standalone command currently implements only the explicit CLI selection.
Environment/default resolution must be added and tested before the standalone
tool claims full selection parity. A present-but-empty `ARI_COMPILER` value is
observable reference behavior and needs an explicit fixture.

## Per-File Argument Contract

The reference launches one compiler process for each positional source file,
preserving source-file order. For every file, arguments after the compiler
program are:

```text
-I DIR ... FILE --check
```

Each include path is forwarded as a separate `-I`, `DIR` pair, in CLI order.
The source path keeps the user's spelling. `--check` is last. Multiple source
files must not be grouped into one compiler invocation because the Ari driver
accepts one positional input for this path.

The current Ari implementation models this as:

- `planned_invocation_count`: the positional source count
- `planned_argument_count_per_invocation`: two arguments for `FILE --check`,
  plus two for every include path
- `uses_per_file_argv`: true

## Validation And Execution

The current explicit-path preflight distinguishes ready, missing, and
non-executable paths. This is a temporary standalone boundary: strict runtime
parity requires unavailable compilers to become per-file compiler failures
with an `ari/compiler-check-failed` diagnostic rather than a stderr-only early
return.

When execution is added, it must:

- invoke the selected executable directly, without a shell
- capture stderr and stdout for compiler diagnostic parsing
- preserve the raw per-file compiler status for JSON `exitCode`
- normalize process-launch failures consistently with the reference contract
- continue native lint rules after a per-file compiler failure
- never call or copy the bundled `tools/lint` implementation

## Test Contract

Compiler-free checks should cover token parsing and planned argv structure.
Fake executable fixtures should cover exact argv order, one invocation per
file, selection precedence, output capture, missing executables, nonzero exits,
and signals. Compiler-backed integration must use an explicitly provisioned,
pinned Ari release or commit and record that identity.

## Security And Reproducibility

Do not execute compiler paths for help or metadata-only commands. Do not invoke
the compiler through a shell. CI must pin and verify any downloaded compiler
artifact, and must not silently choose an unrelated executable.

## Issue Routing

Compiler, standard-library, and language/toolchain bugs belong in
`ari-foundry/ari`. Compiler-boundary parsing, forwarding, diagnostics, config,
tests, and documentation belong in `ari-lint`.

## Follow-up Checklist

- [x] Confirm `--ari` behavior from the reference source.
- [x] Confirm `ARI_COMPILER` and `build/ari` fallback behavior from source.
- [x] Confirm one-process-per-file `-I DIR ... FILE --check` ordering.
- [x] Parse `--ari`, `-I DIR`, and `-IDIR` in the standalone CLI.
- [x] Model the exact per-file compiler argv.
- [ ] Resolve `--ari` / `ARI_COMPILER` / `build/ari` at runtime.
- [ ] Execute the compiler and capture output.
- [ ] Parse and normalize compiler diagnostics.
- [ ] Replace temporary explicit-path early failures with per-file results.
- [ ] Add fake-compiler and pinned real-compiler tests.

## Non-Goals Of The Current Slice

- No compiler process is spawned.
- No network download or compiler build is added.
- No compiler-backed CI or strict parity claim is added.
- No Ari compatibility or release claim is made.
