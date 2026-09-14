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

### Compiler Check Boundary

Original `tools/lint` invokes `ari --check` before running native lint rules.
The current standalone Ari-language `ari-lint` implementation does not invoke
`ari --check` yet.

Classification: expected known difference and `ari-lint`
implementation/design follow-up.

Impact:

- compiler diagnostics are not parity-covered by the current standalone path
- missing compiler behavior is not aligned yet
- include-path and compiler-boundary behavior remains future parity work

Follow-up:

- keep using `ari-foundry/ari` as the compiler behavior owner
- add compiler invocation only after the documented provisioning and invocation
  policy is ready
- do not hide compiler, standard library, or toolchain bugs in `ari-lint`

### Missing Compiler Invocation Output

Current standalone `ari-lint`, when run with `--json --ari` pointing at a
missing compiler and a clean source file, performs an intentional explicit
compiler-path preflight. It writes a short missing-path message to stderr,
returns top-level exit status `1`, emits no JSON, and does not spawn the path.
Original `tools/lint` attempts the compiler invocation and emits
`ari/compiler-check-failed` JSON on stdout with per-file `exitCode` `127` and
the missing compiler path.

Classification: expected known difference and `ari-lint` compiler-boundary
implementation/design follow-up. No Ari language/compiler/stdlib/toolchain bug
is identified by this report-only case.

Impact:

- exact missing-compiler output and exit-code parity are not expected yet
- current standalone preflight failure intentionally emits no JSON output
- release compatibility claims must not be made from the current report

Follow-up:

- revisit the intentional preflight difference when compiler invocation and
  strict parity fixtures are added

### Compiler Error Output

Current standalone `ari-lint`, when run with `--json --ari` on an invalid
temporary source file, reports clean lint results because compiler-backed
`ari --check` invocation is not implemented yet. Original `tools/lint` invokes
that compiler boundary and emits compiler-shaped JSON on stdout with
`ari/compiler` and a parse diagnostic for the same source path.

Classification: expected known difference and `ari-lint` compiler-boundary
implementation/design follow-up. No Ari language/compiler/stdlib/toolchain bug
is identified by this report-only case; the source is intentionally invalid.

Impact:

- exact compiler-error output and exit-code parity are not expected yet
- current standalone compiler-error JSON output is not defined
- release compatibility claims must not be made from the current report

Follow-up:

- decide the standalone compiler invocation contract before strict parity
  fixtures
- add strict compiler-error checks only after compiler provisioning and
  invocation behavior are documented and implemented

### JSON Diagnostic Shape

Current standalone `ari-lint` emits source-file diagnostics as a flat JSON
array with fields such as `filePath` and `ruleCode`.

Original `tools/lint` emits a top-level `files` array with per-file `path`,
`exitCode`, and `diagnostics` entries. Individual diagnostics use fields such
as `file`, `source`, and `code`.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic schema follow-up.

Impact:

- exact JSON equality is not expected yet
- clean-file JSON output shape differs because original `tools/lint` still
  reports a per-file entry while current standalone `ari-lint` can emit an
  empty diagnostic array
- golden JSON files should wait until the schema and path-normalization policy
  are defined

Follow-up:

- define the standalone JSON schema before strict parity fixtures
- decide whether compatibility requires preserving the original shape or
  documenting a new stable standalone shape

### Clean, Disabled, And Mixed File Path Accounting

For clean inputs, disabled-rule cases such as `config-off` and `rule-off`, and
the clean member of mixed clean/dirty invocations such as `multi-file-mixed`,
current standalone `ari-lint` emits no diagnostic file path entries in the local
report. Original `tools/lint` still emits a per-file JSON entry with empty
diagnostics for the same clean source path.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic schema follow-up.

Impact:

- exact clean JSON output parity is not expected yet
- file-path hit counts differ for clean, disabled-rule, and mixed clean/dirty
  cases even when both implementations agree that no lint diagnostic should be
  reported for the clean source
- strict clean/off golden checks should wait until the output schema contract
  is documented

Follow-up:

- decide whether standalone clean output should preserve original per-file
  entries or keep the current empty diagnostic output shape
- define clean, disabled-rule, and mixed clean/dirty JSON shape before strict
  parity fixtures

### Diagnostic Exit Status

For lint diagnostics, the current standalone `ari-lint` path currently reports
exit code `2` in the local parity smoke, while original `tools/lint` reports
exit code `1`. Both report success for clean inputs in the current smoke.

Classification: original `tools/lint` behavior difference and `ari-lint`
implementation/design follow-up.

Impact:

- exact exit-code parity is not established
- scripts should not treat the local parity report as a strict exit-code gate
- release compatibility claims must not be made from the current report

Follow-up:

- decide the standalone lint diagnostic exit-code contract before releases
- add strict exit-code parity only after the contract is documented

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

### Source Read Error Output

Current standalone `ari-lint` reports a missing or unreadable explicit source
path as a short stderr message such as `unable to read source file`. Original
`tools/lint`, when run with `--json --ari`, invokes the Ari compiler boundary
and emits compiler-shaped JSON on stdout with `cannot open input file` and
`ari/compiler` fields for the missing path.

Classification: expected known difference and `ari-lint` diagnostic/CLI
contract follow-up. No Ari language/compiler/stdlib/toolchain bug is identified
by this report-only case.

Impact:

- exact source read-error output parity is not expected yet
- current standalone read-error JSON output is not defined
- release compatibility claims must not be made from the current report

Follow-up:

- decide whether standalone source read-error behavior should preserve the
  original compiler-shaped JSON or define a new stable standalone diagnostic
  contract
- add strict read-error golden checks only after that contract is documented

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

Current standalone `ari-lint` reports an unreadable explicit config path as a
short stderr message such as `unable to read config file`. Original
`tools/lint`, when run with the same missing `--config` path, reports
`cannot open lint config` on stderr and uses a different exit status.

Classification: expected known difference and `ari-lint` diagnostic/CLI
contract follow-up. No Ari language/compiler/stdlib/toolchain bug is identified
by this report-only case.

Impact:

- exact config read-error output and exit-code parity are not expected yet
- release compatibility claims must not be made from the current report
- strict config read-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone config read-error text should preserve the original
  wording or define a new stable standalone diagnostic contract
- add strict config read-error output checks only after that contract is
  documented

### Invalid Config Output Text

Current standalone `ari-lint` reports an invalid config file as
`invalid command-line arguments`. Original `tools/lint` reports the config file
path and line with `unknown rule or severity`.

Classification: original `tools/lint` behavior difference and `ari-lint`
diagnostic/CLI contract follow-up.

Impact:

- exact invalid-config text equality is not expected yet
- release compatibility claims must not be made from the current report
- strict invalid-config golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone invalid-config text should preserve the original
  file/line shape or define a new stable standalone diagnostic contract
- add strict invalid-config output checks only after that contract is documented

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
- include-path behavior remains non-gating until the compiler boundary is
  specified
- release compatibility claims must not be made from the current report
- strict usage-error golden checks should wait until the CLI contract is
  documented

Follow-up:

- decide whether standalone missing-option text should preserve the original
  generic usage shape or define a new stable standalone diagnostic contract
- define include-path behavior together with future compiler invocation work
- add strict usage-error output checks only after that contract is documented

### List Rules Output Detail

Current standalone `ari-lint` emits short rule name fields in `--list-rules`
and `--json --list-rules` output, such as `name=trailing-whitespace` in human
output and `"name":"trailing-whitespace"` in JSON output. Original `tools/lint`
lists the same rule codes and default severities for both invocations but does
not emit those short name fields.

Classification: original `tools/lint` behavior difference and expected known
difference while standalone rule metadata remains implementation-owned by
`ari-lint`.

Impact:

- exact `--list-rules` or `--json --list-rules` text equality is not expected
  yet
- the local parity report records the difference without failing
- release compatibility claims must not be made from the current report

Follow-up:

- decide whether short rule name fields are part of the future standalone
  public output contract
- add strict list-rules golden checks only after the contract is documented

## Current Alignment Signals

The current local report shows useful matching signals for the smoke-sized
cases: both implementations report the expected lint rule names, severity names,
line/column presence, and dirty file paths for the covered rule/config/multi-file
cases, including the mixed clean/dirty multi-file case. The current local report
also includes disabled explicit config and command-line `--rule` cases where
the standalone implementation and original `tools/lint` suppress the configured
rule diagnostic, plus a short-name explicit config case for the same rule
severity signal.

These are smoke signals only. They do not replace source-controlled fixtures,
golden output, compiler-backed parity, or CI parity jobs.

## Non-Goals

- Do not move, delete, or modify `ari-foundry/ari` `tools/lint`.
- Do not copy `tools/lint` source into this repository.
- Do not add a strict parity gate in this step.
- Do not add golden files or broad parity suites in this step.
- Do not add compiler-backed CI in this step.
- Do not claim stable parity, release compatibility, or full replacement.

## Issue Routing

`ari-lint` issues are for lint tooling behavior, parity, diagnostics, config,
rules, tests, docs, and the Ari-language implementation.

Compiler, standard library, and Ari toolchain bugs belong in
`ari-foundry/ari`.

No Ari language/compiler/stdlib/toolchain bug is identified by this known
differences note.
