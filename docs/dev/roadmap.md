# ari-lint Roadmap

Current status: skeleton initialized / Ari source skeleton started / internal
model skeleton started / registry-severity-config skeleton started / first rule
metadata entries added / CLI metadata skeleton started / diagnostic output
metadata skeleton started / config override skeleton refined / rule module
layout started / trailing-whitespace design note added / minimal
trailing-whitespace helper started / trailing-whitespace fixture and test plan
added / initial trailing-whitespace fixtures and lightweight fixture check
started / trailing-whitespace diagnostic mapping skeleton started /
trailing-whitespace parity plan added / missing-final-newline design note added
/ minimal missing-final-newline helper started /
missing-final-newline fixture and test plan added / no real lint
implementation yet.

Current `tools/lint` in `ari-foundry/ari` remains the reference implementation
during this split. Compiler, standard library, and Ari toolchain bugs should be
filed in `ari-foundry/ari`; `ari-lint` should track lint tooling, model, docs,
and test work.

## Split Roadmap

- [x] Initialize repo skeleton.
- [ ] Migrate `docs/lint` from `ari-foundry/ari`; `docs/migration.md` tracks
      the documentation migration plan.
- [ ] Plan Ari-language reimplementation with behavior parity against current
      `tools/lint`; `docs/dev/ari-implementation-plan.md` tracks the staged
      implementation plan.
- [x] Start Ari source skeleton as the first step toward Ari-language
      implementation; real rule implementation, CLI parsing, diagnostics,
      compiler invocation, and tests remain future work.
- [x] Start internal data model skeleton as preparatory Ari source work only;
      rule implementation, CLI parsing, diagnostics output, config parsing,
      compiler invocation, implementation tests, and implementation CI remain
      future work.
- [x] Start registry, severity, and config skeleton as preparatory Ari source
      work only; trailing-whitespace and missing-final-newline behavior,
      registry execution, severity parsing, config parsing, CLI overrides,
      diagnostics output, compiler invocation, tests, and CI remain future
      work.
- [x] Add first planned rule metadata entries for
      `lint/trailing-whitespace` and `lint/missing-final-newline` as
      metadata-only Ari source placeholders; real rule behavior, source
      scanning, diagnostics output, config parsing, CLI behavior, compiler
      invocation, tests, and CI remain future work.
- [x] Start CLI metadata skeleton for positional source input, `--json`,
      `--ari`, `-I`, `--list-rules`, `--config`, and `--rule` as
      metadata-only Ari source placeholders; real CLI parsing, process
      argument reading, argument validation, config parsing, diagnostics
      output, JSON serialization, compiler invocation, tests, and CI remain
      future work.
- [x] Start diagnostic output metadata skeleton for human-readable output, JSON
      output, diagnostic location, file path, line, column, endLine, endColumn,
      severity, rule code, and message as metadata-only Ari source
      placeholders; real diagnostic output, human-readable formatting, JSON
      serialization, source scanning, CLI parsing, config parsing, compiler
      invocation, tests, and CI remain future work, and the JSON schema remains
      needs follow-up.
- [x] Refine config override skeleton for default config, `ari-lint.rules`,
      explicit `--config` file path, `--rule` command-line override, rule
      severity override, and documented override precedence as metadata-only Ari
      source placeholders; real config parsing, config discovery, config file
      reading, override application, CLI parsing, diagnostics output, compiler
      invocation, tests, and CI remain future work. Standalone config
      precedence fixtures remain needs follow-up before claiming stable config
      behavior.
- [x] Start non-executing rule module layout for planned
      `lint/trailing-whitespace` and `lint/missing-final-newline` child modules
      as layout/metadata-only Ari source placeholders; real trailing-whitespace
      behavior, missing-final-newline behavior, rule execution, source scanning,
      file content inspection, diagnostics, config interactions, CLI parsing,
      compiler invocation, tests, and CI remain future work.
- [x] Add `docs/rules/trailing-whitespace.md` as a design note for the planned
      `lint/trailing-whitespace` rule; real trailing-whitespace
      implementation, source scanning, diagnostic production, tests, fixtures,
      JSON serialization, CLI behavior, config parsing, compiler invocation,
      and CI remain future work.
- [x] Start a minimal internal single-line trailing-whitespace helper; full
      rule execution, source-file scanning, file reading, diagnostic
      production, CLI behavior, config parsing, JSON serialization, compiler
      invocation, tests, fixtures, and CI remain future work.
- [x] Add a fixture and test plan for `lint/trailing-whitespace`;
      `docs/rules/trailing-whitespace-fixtures.md` tracks planned fixture
      layout, expected cases, expected result strategy, parity strategy, and
      golden output policy, but fixtures, tests, golden files, test runner
      behavior, real rule execution, diagnostics, and CI remain future work.
- [x] Start first minimal trailing-whitespace fixture coverage with
      `tests/fixtures/trailing-whitespace/clean.ari` and
      `tests/fixtures/trailing-whitespace/trailing-spaces.ari`, plus a
      lightweight workflow check for fixture presence and intentional trailing
      spaces. Full rule execution, helper unit tests, source scanning,
      diagnostics, CLI tests, golden JSON, parity tests, compiler invocation,
      and a standalone test runner remain future work.
- [x] Start trailing-whitespace diagnostic mapping skeleton for one
      already-split line, mapping helper output to internal span/severity data.
      Full rule execution, full diagnostics, message/rule-code String value
      construction, source scanning, CLI output, JSON serialization, config
      integration, tests, parity checks, compiler invocation, and CI remain
      future work.
- [x] Add trailing-whitespace parity plan; `docs/rules/trailing-whitespace-parity.md`
      tracks future comparison against current bundled/reference `tools/lint`
      behavior, but the parity runner, parity tests, golden output,
      `tools/lint` execution, full rule execution, and CI parity jobs remain
      future work.
- [x] Add `docs/rules/missing-final-newline.md` as a design note for the
      planned `lint/missing-final-newline` rule; real missing-final-newline
      implementation, file reading, file content inspection, diagnostic
      production, tests, fixtures, JSON serialization, CLI behavior, config
      parsing, compiler invocation, and CI remain future work.
- [x] Start a minimal internal missing-final-newline content helper; full rule
      execution, file reading, source scanning, diagnostic production, CLI
      behavior, config parsing, JSON serialization, compiler invocation, tests,
      fixtures, and CI remain future work.
- [x] Add a fixture and test plan for `lint/missing-final-newline`;
      `docs/rules/missing-final-newline-fixtures.md` tracks planned fixture
      layout, expected cases, expected result strategy, parity strategy, and
      golden output policy, but fixtures, tests, golden files, test runner
      behavior, full rule execution, diagnostics, and CI remain future work.
- [ ] Plan parity testing against current `tools/lint`;
      `docs/dev/parity-test-plan.md` tracks the future fixture and golden
      output strategy, but parity tests and CI parity jobs are not implemented.
- [ ] Wire standalone build.
- [ ] Wire standalone tests.
- [ ] Define release and compatibility policy after inspecting Ari releases and
      Ari tags; define `ari-lint` compatibility only after Ari-language source
      and standalone tests exist.
- [ ] Move implementation toward Ari-language code when feasible, after the
      documented plan has enough verified compiler/toolchain support.
- [ ] Update Ari Foundry portal after repo is usable.

These steps are planned split work. Except for the initial skeleton, they are
not complete yet.
