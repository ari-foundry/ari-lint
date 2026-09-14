# ari-lint List-Rules Contract

## Scope

This page defines the standalone `ari-lint` rule-registry listing contract.
It is a pre-release contract: intentional changes must update this page and the
exact goldens together, but it does not establish an `ari-lint` release or an
Ari compiler compatibility claim.

Other CLI help and usage-error text remains provisional and is tracked in
[the parity-differences inventory](dev/parity-differences.md).

## Commands And Status

`ari-lint --list-rules` writes the human registry to stdout, writes nothing to
stderr, and exits `0`.

`ari-lint --json --list-rules` and `ari-lint --list-rules --json` write the
JSON registry to stdout, write nothing to stderr, and exit `0`.

Both outputs end with a line-feed byte and contain no extra blank line. Listing
rules does not invoke the selected Ari compiler and does not require a source
file.

## Registry Order And Fields

Registry order is deterministic:

1. `lint/trailing-whitespace`
2. `lint/missing-final-newline`

Both rules have default severity `warning`.

The human form contains one tab-separated row per rule:

```text
RULE_CODE<TAB>name=SHORT_NAME<TAB>default=SEVERITY<TAB>DESCRIPTION
```

`name` is the accepted short rule name used by config and command-line
overrides. It is not a display title.

The JSON form is a bare array. Each element is an object with these required
fields in emitted order:

- `ruleCode`: full rule identifier string
- `name`: accepted short rule name string
- `defaultSeverity`: default severity string
- `description`: user-facing description string

The exact current rows and byte serialization are recorded under
[the list-rules goldens](../tests/golden/list-rules/).

## Reference Boundary

The bundled `tools/lint` registry contains the same two rule codes and default
severities, but its human rows omit `name=SHORT_NAME`. It also emits that human
form for either ordering of `--json` and `--list-rules` instead of a JSON array.
The reference golden was verified at Ari tag `v0.1.0`, commit
`c615f1c2ce1a93835118b4da8867a7f3dfaf991a`; this is snapshot provenance, not
an Ari release compatibility claim.

The standalone short-name field and JSON array are intentional CLI contracts,
not compiler-runtime parity exceptions. The strict runner therefore checks
separate standalone and reference goldens rather than treating their bytes as
equal or adding them to the compiler-boundary allowlist.

## Change Policy

Adding, removing, renaming, or reordering a rule, changing its default
severity or description, or changing either output schema requires a matching
contract review and golden update. An accidental difference in output bytes,
stream selection, exit status, final newline, or JSON validity fails the strict
runner. A sentinel compiler invocation also fails every list-rules case.
