# ari-lint Known Parity Differences

## Purpose

This note records known differences between the current standalone `ari-lint`
implementation and the bundled/reference `tools/lint` implementation in
`ari-foundry/ari`.

The differences here come from the local report-only `scripts/parity.sh` smoke
and surrounding split documentation. They are not a stable compatibility
matrix, not a parity claim, and not a release policy.

## Current Report Scope

The local parity report currently compares report-only `--help`, `-h`, and
no-source-file usage, source read-error behavior, missing compiler path
behavior passed through `--ari`, compiler-error behavior, unknown-option usage,
missing config value usage, missing rule value usage, missing Ari value usage,
missing include value usage, malformed `--rule` usage, invalid `--rule`
severity usage, unknown `--rule` rule usage, `--list-rules`, and JSON
list-rules CLI cases plus temporary clean, trailing-whitespace,
missing-final-newline, missing-compiler, compiler-error, explicit-config,
config-short-name, config-off, config-read-error, invalid-config,
invalid-rule-override, invalid-rule-severity, unknown-rule-override, rule-off,
rule-override, include-path, discovered-config, multi-file, and
multi-file-mixed cases.

It reports signals only:

- exit code
- stdout and stderr presence
- help and short-help usage-option sightings
- no-source-file usage and missing-source-file text sightings
- source read-error text, compiler-diagnostic, JSON-shape, and path sightings
- missing compiler compiler-check-failed, JSON-shape, source-path, and
  compiler-path sightings
- compiler-error diagnostic-code, message, JSON-shape, and source-path sightings
- unknown-option usage and unknown-argument text sightings
- missing config value usage and missing-option text sightings
- config read-error text and config-path sightings
- invalid config output and config-path text sightings
- invalid rule override usage and expected-shape text sightings
- invalid rule severity usage and unknown-rule-or-severity text sightings
- unknown rule override usage and unknown-rule-or-severity text sightings
- missing rule value usage and missing-option text sightings
- missing Ari value usage and missing-option text sightings
- missing include value usage and missing-option text sightings
- list-rules and JSON list-rules rule-code, default-severity, and
  short-name-field sightings
- rule sightings
- severity sightings
- file-path hit counts
- line and column presence

Differences are non-gating. The report fails only for infrastructure problems
such as a missing compiler, missing Ari checkout, missing original lint command,
or local build failure.

## Known Differences

A future strict compiler-boundary suite must explicitly allowlist exactly five
intentional runtime categories from this section: cross-stream ordering,
retained-output capture, retained diagnostic material, non-interactive stdin,
and out-of-range coordinates. Process-infrastructure errors and other CLI or
output differences below remain unresolved implementation or contract work;
they must not pass a strict gate through this allowlist.

### Process Capture Infrastructure Errors

Standalone retries an interrupted child wait, then currently maps other process
launch/setup, pipe poll/read, and child-wait failures to per-file `exitCode`
`127` plus `ari/compiler-check-failed` JSON on stdout. The bundled reference
matches that shape for an `exec` failure, but
parent-side pipe, fork, read, or wait errors instead escape the checker, become
one invocation-wide `ari-lint: error: ...` message on stderr, and exit `1`.
For example, a sufficiently low file-descriptor limit can make pipe creation
take these different paths.

The standalone Ari process API creates separate stdin, stdout, stderr, and
setup pipes, while the reference uses one shared output pipe. In focused Linux
testing, descriptor soft limits from 5 through 10 still allowed the reference
`/bin/true` compiler check to succeed but made standalone report a launch
failure; both succeeded from 11 in that test environment. These measurements
describe the reproduced boundary, not a portable descriptor guarantee.

Classification: unresolved rare infrastructure-error contract difference,
not an intentional compiler-boundary allowlist.

Impact:

- normal compiler exits, signals, missing executables, and non-executable paths
  are unaffected
- resource exhaustion or a parent-side pipe/wait failure can change JSON,
  stream, scope, and exit-status behavior
- extremely constrained descriptor environments can reject an otherwise
  runnable compiler only on the standalone path

Follow-up:

- add a deterministic fault-injection or file-descriptor exhaustion case to
  the strict executable suite
- align the standalone invocation-wide error path with the reference or record
  a separate explicit contract decision before compatibility is claimed

### Compiler Output Cross-Stream Ordering

Ari's process API captures child stdout and stderr separately. For output below
the retention boundary, standalone `ari-lint` concatenates all stderr bytes
followed immediately by all stdout bytes without inserting a separator. Byte
order within each stream is preserved, but emission order across streams is
not.

The C++ reference redirects both streams to one pipe and observes their write
interleaving. Diagnostics emitted on alternating streams may therefore be
reordered. A stderr fragment without a final newline may also join the first
stdout fragment, so exact cross-stream raw-output and diagnostic-order parity
is not claimed.

Classification: Ari process-API constraint and intentional standalone runtime
difference.

Impact:

- ordinary compiler output confined to one stream keeps its byte order
- strict parity must allowlist cross-stream ordering and boundary concatenation
- compiler exit status, recognized diagnostic shapes, and within-stream order
  remain covered independently

Follow-up:

- retain a focused fake-compiler smoke case for the deterministic
  stderr-then-stdout policy
- revisit only if Ari exposes a shared-pipe process API

### Compiler Output Capture Boundary

Standalone `ari-lint` concurrently drains both child streams but retains at
most 262,144 bytes from stderr and 262,144 bytes from stdout for each compiler
process. Bytes beyond either boundary are discarded while draining continues.
Only complete retained lines from a truncated stream are parsed. Every
truncated run adds an `ari/compiler-output-truncated` error, even when another
diagnostic exists or the compiler exits zero; this makes lost output
fail-closed instead of allowing a false-clean result. The actual compiler
status remains the per-file `exitCode`.

The C++ reference grows one merged output string without this explicit
per-stream boundary.

Classification: intentional bounded-memory standalone runtime difference.

Impact:

- ordinary compiler output below both boundaries is unaffected
- excessive output cannot fill a pipe or exhaust the per-process Ari scratch
  arena merely through unbounded capture
- a diagnostic emitted only after the retained prefix is not silently treated
  as a clean run
- exact diagnostic and raw-output parity is not claimed after either stream
  crosses its boundary

Follow-up:

- retain fake-compiler coverage that writes beyond both stream boundaries
- retain an exit-zero case whose diagnostic appears beyond the boundary and
  assert the explicit truncation error prevents a false-clean result
- revisit the size only with measured real-compiler output and memory evidence

### Compiler Diagnostic Material Boundary

Standalone `ari-lint` retains at most 2,048 parsed compiler diagnostics per
file, 4,096 per run, and 1,048,576 bytes per run when repeated file, code, and
message payloads are counted. Raw compiler-failure fallback text consumes the
same payload budget and is replaced by a fixed message when it would cross the
limit. A file whose recognized diagnostic or raw fallback material crosses one
of those limits receives an
`ari/compiler-diagnostics-truncated` error, so an exit-zero compiler cannot
turn omitted diagnostics into a clean result. The C++ reference does not apply
these explicit budgets.

Classification: intentional bounded-memory standalone runtime difference.

Impact:

- ordinary compiler output within all three budgets is unaffected
- adversarially dense short diagnostics cannot exhaust the fixed Ari main
  arena before JSON or human output is produced
- exact output parity is not claimed after a parsed-diagnostic budget is
  crossed

Follow-up:

- retain exact 2,048/2,049 boundary coverage and a dense diagnostic flood
- retain a repeated multi-file raw-fallback case that crosses the run payload
  budget without exhausting the arena
- include repeated logical payload size, not only distinct allocations, when
  reasoning about serialized output bounds

### Compiler Stdin Policy

Standalone `ari-lint` closes the compiler child's stdin pipe immediately. The
C++ reference leaves stdin inherited. Normal `ari FILE --check` execution is
non-interactive, but a custom compiler wrapper can observe EOF in standalone
where it could otherwise read the parent's stdin.

Classification: intentional non-interactive process-boundary policy.

Impact:

- normal Ari compiler checks are unaffected
- custom wrappers must not depend on interactive stdin

### Out-Of-Range Compiler Coordinates

The reference parser converts decimal line and column fields with C++ `stoi`.
Values above signed 32-bit range can therefore throw and abort the invocation;
an accepted value at the signed maximum can also expose 32-bit overflow when a
derived end position is formatted. Standalone `ari-lint` rejects coordinates
above `2147483647`, continues safely, and retains 64-bit derived positions.

Classification: intentional standalone robustness difference for malformed or
non-realistic compiler output.

Impact:

- ordinary positive compiler locations and zero-to-one normalization match
- strict fake-compiler parity must exclude or allowlist out-of-range locations

### Non-UTF-8 JSON Bytes

Standalone runtime JSON preserves valid UTF-8 and emits `\ufffd` for each
invalid input byte. This keeps the output document valid JSON for POSIX paths
that are not valid UTF-8. The bundled reference currently copies those bytes
directly, which can produce a document that UTF-8 JSON parsers reject.

Classification: intentional standalone JSON-validity extension.

Impact:

- ordinary UTF-8 paths and messages remain byte-compatible
- strict parity must allowlist only invalid UTF-8 input text
- the replacement rendering is not a byte-round-trip representation of the
  original POSIX path

### Inline Ari Compiler Option

Standalone `ari-lint` accepts both `--ari PATH` and `--ari=PATH`. The bundled
reference accepts only the separated form; it treats `--ari=PATH` as an unknown
option, writes usage to stderr, and exits `2`.

Classification: standalone CLI extension and explicit parity-contract
decision, not a compiler process-boundary allowlist.

Impact:

- `--ari PATH` remains the shared form for strict reference comparisons
- callers may use `--ari=PATH` with standalone `ari-lint`, but exact CLI parity
  is not claimed for that spelling
- the strict CLI contract must either retain this extension explicitly or
  remove it before compatibility is claimed

### End-Of-Options Separator

Standalone `ari-lint` treats `--` as an end-of-options separator and accepts a
following dash-prefixed source path. The bundled reference treats `--` itself
as an unknown option, writes usage to stderr, and exits `2`.

Classification: standalone CLI extension and explicit parity-contract
decision, not a compiler process-boundary allowlist.

Impact:

- ordinary source paths and option parsing are unaffected
- exact reference CLI parity is not claimed for `--`
- the strict CLI contract must decide whether the safer dash-prefixed-path
  escape remains a standalone extension

### Help Output Stream And Shape

Current standalone `ari-lint --help` and `ari-lint -h` emit multi-line help
text on stdout. Original `tools/lint --help` and `tools/lint -h` emit a
one-line usage message on stderr.

Classification: original `tools/lint` behavior difference and `ari-lint`
implementation/design follow-up.

Impact:

- exact help text equality is not expected yet
- stdout/stderr stream parity for help is not established
- release compatibility claims must not be made from the current report

Follow-up:

- decide whether standalone help text and stream behavior should preserve the
  original shape or define a new stable standalone contract
- add strict help golden checks only after the help contract is documented

### No Source File Usage Text

Current standalone `ari-lint` reports a no-argument invocation as
`missing source file`. Original `tools/lint` exits with a usage error but prints
generic usage text instead.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact no-source-file usage text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone no-source-file text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- add strict usage-error output checks only after that contract is documented

### Unknown Option Usage Text

Current standalone `ari-lint` reports the first unknown option in its usage
error text, such as `unknown argument: --definitely-unknown`. Original
`tools/lint` exits with a usage error but prints generic usage text instead.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact invalid-argument text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone invalid-argument text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- add strict usage-error output checks only after that contract is documented

### Missing Config Value Usage Text

Current standalone `ari-lint` reports a missing `--config` value as
`missing option value for --config`. Original `tools/lint` exits with a usage
error but prints generic usage text instead.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact missing-option-value text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone missing-option text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- add strict usage-error output checks only after that contract is documented

### Config Read Error Output

Current standalone `ari-lint` and original `tools/lint` both report the focused
missing explicit `--config` path as
`ari-lint: error: PATH: cannot open lint config` on stderr, leave stdout empty,
emit no JSON envelope even with `--json`, and exit `2`.

Classification: aligned for the focused explicit config read-error case. No Ari
language/compiler/stdlib/toolchain bug is identified by this report-only case.

Impact:

- focused explicit config read-error output and exit-code behavior are aligned
- release compatibility claims must not be made from the current report
- broader error-ordering and strict parity coverage remain incomplete

Follow-up:

- add source-controlled parity goldens when strict parity work is scoped
- retain coverage for combined-error ordering before making compatibility claims

### Invalid Config Output Text

Current standalone `ari-lint` and original `tools/lint` both report every bad
line in an explicit config on stderr as
`ari-lint: error: PATH:LINE: REASON`, using `expected RULE=SEVERITY` for a
missing equals sign and `unknown rule or severity` for other invalid settings.
Both stop before source linting, leave stdout empty, emit no JSON envelope, and
exit `2`.

Classification: aligned for the focused explicit invalid-config case.

Impact:

- focused explicit invalid-config text, stream, and exit behavior are aligned
- release compatibility claims must not be made from the current report
- broad parser and combined-error ordering parity remain incomplete

Follow-up:

- add source-controlled parity goldens when strict parity work is scoped
- retain discovered-config and multi-file error coverage before compatibility
  claims

### Invalid Rule Override Usage Text

Current standalone `ari-lint` reports a malformed `--rule` value as
`invalid --rule override; expected --rule RULE=SEVERITY`. Original
`tools/lint` reports `invalid rule setting` and the same expected
`RULE=SEVERITY` shape.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact malformed-rule text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict malformed-rule golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone malformed-rule text should preserve the original
  `invalid rule setting` wording or define a new stable standalone diagnostic
  contract
- add strict malformed-rule output checks only after that contract is
  documented

### Invalid Rule Severity Usage Text

Current standalone `ari-lint` reports an invalid `--rule` severity as
`invalid --rule override; expected --rule RULE=SEVERITY`. Original
`tools/lint` reports `invalid rule setting` with `unknown rule or severity`.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact invalid-severity text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict invalid-severity golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone invalid-severity text should preserve the original
  `unknown rule or severity` wording or define a new stable standalone
  diagnostic contract
- add strict invalid-severity output checks only after that contract is
  documented

### Unknown Rule Override Usage Text

Current standalone `ari-lint` reports an unknown `--rule` rule name as
`invalid --rule override; expected --rule RULE=SEVERITY`. Original
`tools/lint` reports `invalid rule setting` with `unknown rule or severity`.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact unknown-rule override text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict unknown-rule override golden checks should wait until the CLI contract
  is documented

Follow-up:

- decide whether standalone unknown-rule override text should preserve the
  original `unknown rule or severity` wording or define a new stable
  standalone diagnostic contract
- add strict unknown-rule override output checks only after that contract is
  documented

### Missing Rule Value Usage Text

Current standalone `ari-lint` reports a missing `--rule` value as
`missing option value for --rule`. Original `tools/lint` exits with a usage
error but prints generic usage text instead.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact missing-option-value text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone missing-option text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- add strict usage-error output checks only after that contract is documented

### Missing Ari Value Usage Text

Current standalone `ari-lint` reports a missing `--ari` value as
`missing option value for --ari`. Original `tools/lint` exits with a usage
error but prints generic usage text instead.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact missing-option-value text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone missing-option text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- add strict usage-error output checks only after that contract is documented

### Missing Include Value Usage Text

Current standalone `ari-lint` reports a missing `-I` value as
`missing option value for -I`. Original `tools/lint` exits with a usage error
but prints generic usage text instead.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact missing-option-value text equality is not expected yet
- include paths are forwarded to the implemented compiler boundary, but the
  report remains non-gating
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone missing-option text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- retain exact `-I DIR` forwarding coverage in strict compiler fixtures
- add strict usage-error output checks only after that contract is documented

### List Rules Output Detail

Current standalone `ari-lint` emits short rule name fields in `--list-rules`
and `--json --list-rules` output, such as `name=trailing-whitespace` in human
output and `"name":"trailing-whitespace"` in JSON output. Original `tools/lint`
lists the same rule codes and default severities for both invocations but does
not emit those short name fields.

Classification: explicit standalone CLI contract difference. Rule metadata and
the JSON registry form are implementation-owned by `ari-lint` and documented in
`docs/list-rules.md`.

Impact:

- exact standalone/reference byte equality is intentionally not expected
- the local parity report records the difference without failing
- the strict runner gates separate exact standalone and reference snapshots
- this contract decision does not establish release compatibility

Follow-up:

- update `docs/list-rules.md` and its exact goldens together for an intentional
  registry or schema change
- keep this CLI contract difference outside the five compiler-runtime
  allowlist categories

## Current Alignment Signals

The current local report shows useful matching signals for the smoke-sized
native-rule cases. Both implementations use the same top-level `files` JSON
shape, keep every input file in order (including clean and duplicate inputs),
emit the same per-diagnostic field names and numeric end positions, and return
exit `1` for enabled lint diagnostics. Human source output also follows the
reference `PATH: ok` and `[CODE]` forms on stdout.

Both implementations report the expected rule names, severity names,
line/column presence, and dirty file paths for the covered
rule/config/multi-file cases; disabled explicit config and command-line
`--rule` cases suppress the configured diagnostic, and short-name config uses
the same severity signal.

The focused explicit config read-error and invalid-config cases also use the
same stderr shape, leave stdout empty without a JSON envelope, and exit `2` in
both implementations.

Focused compiler-backed runs also align for direct per-source invocation,
include-path forwarding, ordinary compiler diagnostics, missing compiler
`exitCode` `127` and `ari/compiler-check-failed` output, and missing-source
`ari/compiler` JSON. The overall process exits `1` whenever any per-file
compiler exit is nonzero or any diagnostic remains. These are local smoke
signals, not a compatibility claim.

These report-only signals do not replace the strict subsets or compiler-backed
CI. Separate source-controlled native and list-rules goldens now gate their
documented scopes; broader CLI, config, and compiler-boundary parity remains
open.

## Non-Goals

- Do not move, delete, or modify `ari-foundry/ari` `tools/lint`.
- Do not copy `tools/lint` source into this repository.
- Keep the broad local parity report non-gating; strict subsets are separately
  approved and documented.
- Do not treat compiler-smoke CI as reference parity coverage.
- Do not claim stable parity, release compatibility, or full replacement.

## Issue Routing

`ari-lint` issues are for lint tooling behavior, parity, diagnostics, config,
rules, tests, docs, and the Ari-language implementation.

Compiler, standard library, and Ari toolchain bugs belong in
`ari-foundry/ari`.

No Ari language/compiler/stdlib/toolchain bug is identified by this known
differences note.
