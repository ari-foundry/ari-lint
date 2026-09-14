# Ari Compiler Invocation Contract

## Purpose

This document records the implemented standalone `ari-lint`
compiler-selection, per-file process, diagnostic parsing, and status boundary.
The near-term dependency model invokes an external Ari compiler with `--check`;
compiler behavior remains owned by `ari-foundry/ari`.

## Current Status

- The CLI accepts `--ari PATH` and `--ari=PATH`.
- Source commands resolve `--ari`, `ARI_COMPILER`, or `build/ari`, then execute
  one compiler process per positional source file.
- The CLI accepts both `-I DIR` and `-IDIR`, retains include paths in command
  order, and forwards them to every per-file compiler process.
- Compiler output is captured and reference-shaped diagnostic lines are added
  before discovered-config and native-rule diagnostics for that file.
- Both child streams are drained concurrently; at most 256 KiB per stream is
  retained, with an explicit error diagnostic whenever output is truncated.
- Parsed compiler diagnostics are bounded to 2,048 per file, 4,096 per run,
  and, together with raw compiler-failure fallback text, 1 MiB of repeated
  file/code/message payload per run; exceeding any bound adds an explicit error
  instead of exhausting the main arena.
- The raw compiler status is retained as each JSON file result's `exitCode`.
- Help and rule-listing commands do not select or execute a compiler.

The bundled implementation in `ari-foundry/ari` remains the behavior reference.
The relevant source evidence is `tools/lint/main.cpp`,
`tools/lint/checker.cpp`, `tools/ari_tooling/process.cpp`, and
`tools/ari_tooling/diagnostic.cpp`; the standalone code must not copy those
files.

## Selection Precedence

The standalone source command selects the compiler in this order:

1. `--ari PATH` or `--ari=PATH`
2. `ARI_COMPILER`, when the environment entry is present
3. the literal path `build/ari`

An explicit CLI value wins over the environment. A present-but-empty
`ARI_COMPILER` value is selected rather than treated as absent, matching the
observable reference selection behavior. The literal default is relative to
the command's working directory.

The compiler used by `scripts/build.sh` to build `ari-lint` is a separate
selection boundary. That script accepts a positional compiler path before its
own `ARI_COMPILER` fallback; the built binary still applies the runtime
precedence above when checking source files.

## Per-File Argument Contract

The standalone command launches one compiler process for each positional
source file, preserving source-file order and duplicate inputs. For every file,
arguments after the compiler program are:

```text
-I DIR ... SOURCE --check
```

Each include path is forwarded as a separate `-I`, `DIR` pair, in CLI order.
The source path keeps the user's spelling and `--check` is last. Multiple source
files are not grouped into one compiler invocation.

The older internal planning model remains available for pure boundary checks,
but source-command execution now uses the same argument contract directly.

## Process Status And Failures

The selected executable is invoked directly through the Ari process API,
without a shell. Its stdin pipe is closed immediately because compiler checks
are non-interactive. For every source file:

- a normal compiler exit code is preserved as the file result's `exitCode`
- termination by a signal is normalized to `128 + signal`
- an abnormal status without an exit code or signal is normalized to `1`
- program or argument conversion, process launch/setup, pipe polling/reading,
  and non-interrupted child waiting failures are currently normalized to `127`

An interrupted child wait is retried so the spawned process is reaped before
its final status is interpreted.

A launch or capture failure uses raw fallback text shaped as
`ari-tooling: exec failed: COMPILER_PATH\n`. Missing and non-executable paths
are therefore per-file compiler failures rather than an invocation-wide stderr
preflight. Processing continues with later source files.

This collapse is exact for ordinary missing or non-executable compiler paths,
but it is not reference parity for rare parent-side process infrastructure
errors. The bundled C++ path reports pipe, fork, read, and wait failures as one
invocation-wide stderr error with exit `1`; standalone currently reports the
same synthetic per-file JSON shape as a launch failure. This remains strict
contract work and is not an intentional process-boundary allowlist item.
Because the Ari API creates separate stdin, stdout, stderr, and setup pipes,
standalone also needs more free descriptors than the reference's shared output
pipe; a constrained descriptor limit can therefore fail standalone before the
same compiler command fails in the reference.

The top-level source command exits `1` when any file has a nonzero compiler
status or any enabled diagnostic. It otherwise exits `0`. CLI usage and
explicit-config errors retain their separate exit behavior.

## Diagnostic Parsing

The compiler parser recognizes these complete line shapes, where `SEVERITY` is
exactly `error`, `warning`, `note`, or `hint` and `[CODE]` is optional:

```text
ari: SEVERITY[CODE]: FILE:LINE:COLUMN: MESSAGE
ari: SEVERITY[CODE]: LINE:COLUMN: MESSAGE
FILE:LINE:COLUMN: SEVERITY[CODE]: MESSAGE
ari: SEVERITY[CODE]: MESSAGE
```

Locations without a file and general diagnostics use the positional source as
the fallback file. Decimal line and column zero are normalized to one. A parsed
diagnostic without an explicit code uses `ari/compiler`; every parsed compiler
diagnostic uses source `ari`. One trailing carriage return is removed from each
line, a final line without a newline is parsed, and unmatched lines are ignored.
A carriage return remaining inside a regex-dot file or message field makes that
candidate unmatched, as in the reference parser. File-bearing forms scan
location fields from the right so file paths may contain colons.

For each file, result diagnostics are ordered as:

1. parsed compiler diagnostics
2. `ari/compiler-output-truncated` when either stream crosses the retention
   boundary
3. `ari/compiler-diagnostics-truncated` when a parsed-diagnostic budget is
   exceeded
4. discovered-config `lint/config` diagnostics
5. native lint diagnostics
6. a compiler-failure fallback when the rule below requires one

If the compiler status is nonzero and that complete per-file diagnostic set is
otherwise empty apart from truncation diagnostics, `ari-lint` adds an error
at `1:1` with source `ari`, code `ari/compiler-check-failed`, and the captured
raw output as its message. An empty captured output uses `compiler check
failed`. A config or native diagnostic can therefore explain a nonzero
compiler result without an additional synthetic compiler-failure diagnostic,
matching the reference fallback rule. Neither truncation condition suppresses
or is suppressed by another diagnostic:
`ari/compiler-output-truncated` and `ari/compiler-diagnostics-truncated` are
errors, including when the compiler itself exits zero, while the per-file
`exitCode` continues to report that actual compiler status.

Raw failure output also consumes the run-wide payload budget. When copying it
would cross that budget, the fallback uses the fixed `compiler check failed`
message and adds `ari/compiler-diagnostics-truncated` if that condition has not
already been reported for the file.

Native file-read failure does not create a separate CLI stderr error in this
path. Compiler-visible status and diagnostics determine the per-file result;
native rules simply add no diagnostics when they cannot read the source.

## Captured Stream Ordering

The Ari process API exposes child stdout and stderr as separate pipes.
Standalone `ari-lint` polls and drains both pipes while the child runs so a full
pipe cannot deadlock the compiler. It retains at most 262,144 bytes from each
stream and continues draining and discarding bytes past that boundary.

When neither stream exceeds the boundary, diagnostic parsing concatenates all
stderr bytes followed immediately by all stdout bytes, without inserting a
separator. Byte order within each stream is preserved, but emission order
across the streams is not.

When a stream is truncated, only complete retained lines from that stream are
eligible for diagnostic parsing; its incomplete retained tail is dropped. The
two parseable prefixes remain in stderr-then-stdout order. The standalone
runtime then emits `ari/compiler-output-truncated` even if retained output
already produced another diagnostic or the compiler exited zero. If a nonzero
compiler result still has no parsed compiler, config, or native diagnostic, a
separate `ari/compiler-check-failed` fallback includes the retained
complete-line output. This bounded, fail-closed behavior avoids arena
exhaustion, child-pipe deadlock, and false-clean success, but is not
byte-for-byte parity for output beyond the capture boundary.

Parsed diagnostic material has a second bounded-memory guard. At most 2,048
compiler diagnostics are retained for one file, at most 4,096 are retained for
the complete run, and the sum of repeated file, selected code, and message byte
lengths—including retained raw failure fallback messages—is limited to
1,048,576 for the run. Once the applicable prefix is full, later recognized
compiler diagnostics and oversized raw fallback text are omitted and that file
receives `ari/compiler-diagnostics-truncated`. Counting a fallback file path
for every diagnostic models both its owned copy and its repeated serialized
cost. The main diagnostic vector reserves the run budget up front to avoid
arena loss to geometric vector growth.

The C++ reference redirects both streams to one pipe and observes their write
interleaving. Diagnostics emitted on alternating streams may therefore appear
in a different order in standalone output. If stderr does not end with a
newline, its final fragment can also join the first stdout fragment. This is a
known process-API difference: exact cross-stream raw-output and diagnostic-order
parity is not claimed.

## Test Contract

Compiler-free checks cover token parsing, planning data, source guards, and
repository invariants without executing a compiler. The local executable smoke
uses focused fake compilers to cover exact argv order, one invocation per file,
selection precedence including an empty environment value, output parsing,
missing and non-executable programs, nonzero exits, signals, diagnostic order,
embedded carriage returns, bounded output truncation, fallback suppression, and
no execution for help or rule listing.

Real-compiler compatibility evidence must use an explicitly provisioned,
pinned Ari release or commit and record that identity. The current local smoke
does not by itself establish a release compatibility claim.

## Security And Reproducibility

Compiler paths are never executed for help or metadata-only commands. Compiler
execution does not use a shell. CI must pin and verify any compiler artifact it
provisions and must not silently choose an unrelated executable.

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
- [x] Resolve `--ari` / `ARI_COMPILER` / `build/ari` at runtime.
- [x] Execute the compiler and capture output.
- [x] Parse and normalize compiler diagnostics.
- [x] Replace temporary explicit-path early failures with per-file results.
- [x] Add focused fake-compiler smoke coverage.
- [x] Bound retained compiler output while draining both pipes to completion.
- [ ] Record pinned real-compiler compatibility evidence.
- [ ] Add compiler-backed CI only after its provisioning policy is complete.

## Non-Goals Of The Current Slice

- No network download or compiler build is added.
- No compiler-backed CI or strict parity claim is added.
- No Ari compatibility or release claim is made.
