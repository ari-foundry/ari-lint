# Diagnostic Output Contract

## Scope

This document defines the current pre-release output contract for standalone
`ari-lint` source-file commands. It covers source-result JSON, human diagnostic
lines, output streams, process status, ordering, and bounded compiler output.

The registry output from `--list-rules` has a separate contract in
[list-rules.md](list-rules.md). Ari compiler diagnostics remain owned by the
[Ari compiler project](https://github.com/ari-foundry/ari); this document only
defines how `ari-lint` carries them alongside lint diagnostics.

This is a tested standalone contract, but it is not an `ari-lint` release or an
Ari-version compatibility claim. Until a stable release exists, contract
changes require an explicit documentation and golden-test update.

## JSON Source Result

`ari-lint --json SOURCE...` writes one compact JSON object followed by one LF
to stdout. Stderr is empty for a completed source run, including a run that
reports diagnostics or compiler failures.

The document has this shape:

```json
{"files":[{"path":"source.ari","exitCode":0,"diagnostics":[{"file":"source.ari","line":1,"column":5,"endLine":1,"endColumn":7,"severity":"warning","message":"trailing whitespace","source":"ari-lint","code":"lint/trailing-whitespace"}]}]}
```

JSON object members are emitted in the order shown for deterministic golden
tests. Consumers should address members by name rather than depending on JSON
member order.

### File result fields

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `files` | array | yes | One file result for every positional source argument. |
| `path` | string | yes | The positional path spelling for this invocation. Paths are not canonicalized. |
| `exitCode` | integer | yes | The normalized status of this file's Ari compiler process, not the top-level `ari-lint` status. |
| `diagnostics` | array | yes | The ordered compiler, config, and native lint diagnostics for this file. |

The `files` array preserves positional argument order. Repeated source
arguments produce repeated file results and repeated compiler invocations.
Clean files remain present with `exitCode: 0` and an empty `diagnostics` array.

`exitCode` has these compiler-boundary meanings:

- normal compiler exits retain their numeric status
- signal termination becomes `128 + signal`
- a status with neither a code nor signal becomes `1`
- program conversion, launch, capture, or non-retryable wait failures become
  `127`

A file can have `exitCode: 0` and lint diagnostics. Conversely, a nonzero
`exitCode` can be accompanied by a config or native diagnostic without a
synthetic compiler-failure diagnostic. The top-level process status is computed
from both compiler status and enabled diagnostics, as described below.

### Diagnostic fields

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `file` | string | yes | Diagnostic path. A compiler diagnostic without a path uses the positional source path. |
| `line` | integer | yes | One-based start line. Parsed zero coordinates are normalized to `1`. |
| `column` | integer | yes | One-based start column. Parsed zero coordinates are normalized to `1`. |
| `endLine` | integer | yes | One-based end line. A missing or nonpositive internal end uses `line`. |
| `endColumn` | integer | yes | One-based end column. A missing or nonpositive internal end uses `column + 1`. |
| `severity` | string | yes | `hint`, `note`, `warning`, or `error` for emitted diagnostics. Severity `off` suppresses matching native-rule diagnostics before output. |
| `message` | string | yes | Diagnostic message text. |
| `source` | string | yes | `ari` for compiler diagnostics or `ari-lint` for config and native lint diagnostics. |
| `code` | string | no | Compiler code, lint rule code, or `ari-lint` fallback code. It is omitted only when the internal diagnostic code is empty. |

Coordinates are producer coordinates. Compiler coordinate semantics remain an
Ari compiler concern; consumers should not reinterpret them as byte offsets or
Unicode scalar offsets.

Current `ari-lint`-owned codes are:

- `lint/trailing-whitespace`
- `lint/missing-final-newline`
- `lint/config`

Compiler-related fallback codes are:

- `ari/compiler` when a parsed compiler diagnostic has no explicit code
- `ari/compiler-check-failed` when a nonzero compiler result has no other
  diagnostic that explains it
- `ari/compiler-output-truncated` when retained child output crosses its limit
- `ari/compiler-diagnostics-truncated` when a diagnostic or payload budget is
  exhausted

An Ari compiler can also supply its own explicit diagnostic codes. Those codes
are carried unchanged with `source: "ari"`.

## Diagnostic Ordering

All diagnostics for one file are contiguous. Files remain in positional input
order. Within each file, the current order is:

1. parsed Ari compiler diagnostics
2. `ari/compiler-output-truncated`, when required
3. `ari/compiler-diagnostics-truncated`, when required
4. discovered-config `lint/config` diagnostics
5. native lint diagnostics in registry order
6. `ari/compiler-check-failed`, when the fallback rule requires it

Compiler stderr and stdout are drained concurrently but retained separately.
For an untruncated capture, parsing receives all retained stderr bytes followed
immediately by all retained stdout bytes, without an inserted separator. When a
stream crosses its retention limit, only that stream's retained complete-line
prefix is parsed; an incomplete retained tail is omitted. This deterministic
standalone order can differ from the bundled C++ reference, which merges both
child streams into one pipe and observes their write interleaving. An
untruncated stderr fragment without a final newline can also join the first
stdout fragment. Exact cross-stream interleaving parity is not claimed.

The full parsing and fallback rules are in
[dev/compiler-invocation.md](dev/compiler-invocation.md). Known intentional and
unresolved reference differences are in
[dev/parity-differences.md](dev/parity-differences.md).

## Encoding And Termination

Source-result JSON is one compact document with exactly one final LF in the
current serializer. It has no byte-order mark and no diagnostic text outside
the JSON document on stdout.

JSON strings:

- preserve valid UTF-8
- escape quotes, backslashes, and JSON control characters
- encode other bytes below `0x20` as lowercase `\u00xx`
- encode each invalid UTF-8 byte as `\ufffd`

This replacement policy keeps standalone output valid JSON. It is a known
difference from the bundled reference for invalid path bytes.

## Human Source Result

Without `--json`, a clean file with a successful compiler check writes:

```text
PATH: ok
```

A diagnostic formatter writes this prefix, the diagnostic message bytes, and
one final LF:

```text
FILE:LINE:COLUMN: SEVERITY: [CODE] MESSAGE
```

The `[CODE] ` segment is omitted when the diagnostic code is empty. A
diagnostic without its own file uses the positional file path. Results and
diagnostics use the same ordering as JSON and are written to stdout.

Human output does not escape file paths or message bytes. A diagnostic occupies
one physical line only when those values contain no carriage return or LF. In
particular, a source or config path containing a line ending can make a native
or config diagnostic span multiple physical lines. Use JSON when escaped,
machine-readable boundaries are required.

An unexplained nonzero compiler result becomes an
`ari/compiler-check-failed` diagnostic. With no retained compiler text its
human form is:

```text
PATH:1:1: error: [ari/compiler-check-failed] compiler check failed
```

When unmatched compiler text is retained and fits the run-wide payload budget,
that text is used verbatim as this fallback diagnostic's message. It can
contain embedded or trailing line endings, so this exceptional fallback can
occupy multiple physical lines; the formatter still appends its own final LF.
If the text does not fit, it is omitted, the applicable truncation diagnostic
is added, and the fixed `compiler check failed` message is used.

Human wording outside the shapes above, including help and detailed usage
messages, remains pre-release CLI work and is not declared byte-stable here.

## Streams And Top-Level Status

`--json` selects JSON only after a source or list-rules command is successfully
dispatched. It does not convert CLI parsing or explicit-config errors into JSON.

| Situation | Stdout | Stderr | Status |
| --- | --- | --- | --- |
| Help | help text | empty | `0` |
| Human source run, clean | file results | empty | `0` |
| JSON source run, clean | JSON source result | empty | `0` |
| Source run with any enabled diagnostic | human or JSON file results | empty | `1` |
| Source run with any nonzero compiler status | human or JSON file results | empty | `1` |
| Missing or non-executable compiler | per-file human or JSON failure result | empty | `1` |
| No positional source, invalid option, missing option value, or invalid `--rule` | empty | text summary | `2` |
| Explicit config cannot be read or parsed | empty | text diagnostics | `2` |
| Discovered config contains invalid lines | human or JSON file diagnostics | empty | `1` |

For multiple files, top-level status is `1` when any file has an enabled
diagnostic or nonzero compiler status; otherwise it is `0`. Every file still
retains its own compiler `exitCode` in JSON.

The list-rules stream and status rules are defined separately in
[list-rules.md](list-rules.md).

## Bounded Compiler Material

Standalone `ari-lint` drains compiler pipes to completion while bounding
retained and serialized material:

- 262,144 retained bytes for each child stream
- 2,048 parsed compiler diagnostics for one file
- 4,096 parsed compiler diagnostics for one run
- 1,048,576 bytes of repeated file, code, message, and raw fallback payload for
  one run

Crossing a bound omits later material and adds the applicable truncation error
diagnostic. The command therefore fails closed even when the compiler itself
exits `0`. The file's `exitCode` continues to report the actual compiler status.

Rare parent-side process setup, pipe read, and wait failures are not yet strict
reference parity. Standalone currently normalizes these with the same per-file
`127` path used for launch/capture failure; the bundled reference can report an
invocation-wide stderr error instead.

## Validation And Change Policy

The current contract is exercised by:

- checked-in exact native JSON goldens under `tests/golden/native/`
- checked-in exact config JSON and human goldens under `tests/golden/config/`
- checked-in combined compiler/native JSON and human goldens under
  `tests/golden/compiler-boundary/`
- exact JSON and human compiler/config cases in `scripts/smoke.sh`
- strict status, stream, final-LF, and JSON parsing assertions
- the checksum-pinned Ari compiler-smoke workflow

Changing required fields, field types or meanings, path/diagnostic ordering,
encoding, stream selection, final-newline behavior, or status mapping requires
a matching update to this document and the relevant exact tests. Adding a
stable release or Ari compatibility entry requires the separate policy in
[dev/release-compatibility-policy.md](dev/release-compatibility-policy.md); this
document alone does not establish one.
