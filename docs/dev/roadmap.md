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
missing-final-newline fixture and test plan added / initial
missing-final-newline fixtures and lightweight fixture check started /
missing-final-newline diagnostic mapping skeleton started /
missing-final-newline parity plan added / lightweight check runner skeleton
added / compiler provisioning plan added / compiler invocation plan added /
CLI argument model added / local build scaffold and gitignore hygiene added /
minimal CLI token parser added / internal list-rules output path added /
human-readable list-rules formatter added /
stdout-free command dispatcher added /
internal explicit-token entry path added /
minimal main entry shell added /
OS argv boundary placeholder added /
no real lint implementation yet.

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
- [x] Add a minimal main entry shell that delegates through a local internal
      shell function and returns success. OS argv integration, stdout/stderr
      output, JSON output, config parsing, compiler invocation, source scanning,
      lint execution, main-entry tests, and parity behavior remain future work.
- [x] Add an explicit OS argv boundary placeholder that records the future
      process-argument integration boundary without reading OS argv, reading
      environment variables, dispatching tokens, writing stdout/stderr output,
      invoking the compiler, scanning sources, or executing lint rules.
      Argv-boundary tests and user-facing CLI behavior remain future work.
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
      metadata-only Ari source placeholders; OS process argument reading,
      argument validation, config parsing, diagnostics output, JSON
      serialization, compiler invocation, tests, and CI remain future work.
- [x] Add CLI argument result model for future parser output, including
      positional files, `--json`, `--list-rules`, help requests, `--ari`, `-I`,
      `--config`, `--rule`, and parse problem data. Process argument parsing,
      CLI validation, config parsing, diagnostics output, JSON serialization,
      compiler invocation, tests, and CI remain future work.
- [x] Add a minimal CLI token parser over explicit caller-provided token lists,
      reusing the CLI argument result model for positional files, `--json`,
      `--list-rules`, `--help`/`-h`, `--ari`, `-I`, `--config`, raw `--rule`
      values, missing-value problems, and unknown-argument problems. OS process
      argv reading, `ARI_COMPILER`, compiler path validation, config parsing,
      semantic `--rule` parsing, compiler invocation, output behavior, tests,
      and CI parser execution remain future work.
- [x] Add an internal list-rules output path that converts existing known rule
      metadata into rows for `lint/trailing-whitespace` and
      `lint/missing-final-newline`, including rule code, short name, default
      severity, and description. User-facing `--list-rules` CLI completion,
      CLI main integration, stdout/stderr formatting, JSON output, config
      parsing, compiler invocation, tests, and parity behavior remain future
      work.
- [x] Add an internal human-readable list-rules formatter that converts the
      existing list-rules rows into newline-terminated text containing rule code,
      short name, default severity, and description. User-facing
      `--list-rules` CLI completion, CLI main integration, stdout/stderr output,
      JSON output, config parsing, compiler invocation, formatter tests, and
      parity behavior remain future work.
- [x] Add an internal stdout-free command dispatcher that maps parsed CLI args
      to internal command results, routes list-rules requests to the existing
      human-readable formatter, and returns explicit future-work placeholders for
      parse-problem, help, source-file linting, and unsupported command paths.
      User-facing CLI completion, OS argv/main wiring, stdout/stderr output,
      JSON output, source scanning, lint execution, config parsing, compiler
      invocation, dispatcher tests, and parity behavior remain future work.
- [x] Add an internal explicit-token entry path that accepts a caller-provided
      token list, composes the existing explicit-token parser with the
      stdout-free command dispatcher, and returns a `CliCommandResult`.
      OS argv reading, environment handling, stdout/stderr output, JSON output,
      source scanning, lint execution, config parsing, compiler invocation,
      entry-path tests, and parity behavior remain future work.
- [x] Add local build scaffold and `.gitignore` hygiene for local/generated
      artifacts. `scripts/build.sh` requires an explicit Ari compiler path and
      builds `src/main.ari` to `build/ari-lint` for local use only; CI compiler
      execution, release builds, compiler-backed tests, package manager
      integration, parity runner behavior, and compatibility claims remain
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
- [x] Start first minimal missing-final-newline fixture coverage with
      `tests/fixtures/missing-final-newline/with-final-newline.ari` and
      `tests/fixtures/missing-final-newline/missing-final-newline.ari`, plus a
      lightweight workflow check for fixture presence and final newline
      presence/absence. Full rule execution, helper unit tests, source
      scanning, diagnostics, CLI tests, golden JSON, parity tests, compiler
      invocation, and a standalone test runner remain future work.
- [x] Start missing-final-newline diagnostic mapping skeleton for explicit
      caller-provided final position metadata, mapping helper output to internal
      span/severity data. Full rule execution, full diagnostics,
      message/rule-code String value construction, file reading, source scanning,
      CLI output, JSON serialization, config integration, tests, parity checks,
      compiler invocation, and CI remain future work.
- [x] Add missing-final-newline parity plan;
      `docs/rules/missing-final-newline-parity.md` tracks future comparison
      against current bundled/reference `tools/lint` behavior, but the parity
      runner, parity tests, golden output, `tools/lint` execution, full rule
      execution, and CI parity jobs remain future work.
- [x] Add lightweight check runner skeleton with `scripts/check.sh` for
      repository shape and fixture invariants only; Ari compiler execution,
      `ari --check`, `tools/lint` execution, parity runner behavior, CLI tests,
      JSON golden tests, package manager files, release workflow, and
      compatibility claims remain future work.
- [x] Add Ari compiler provisioning plan in
      `docs/dev/compiler-provisioning.md` for future compiler-backed tests and
      boundary behavior; compiler execution, compiler-backed tests, CI compiler
      setup, compiler download/build automation, parity runner behavior, and a
      compatibility matrix remain future work.
- [x] Add Ari compiler invocation plan in
      `docs/dev/compiler-invocation.md` for future `--ari PATH` and
      `ARI_COMPILER` selection behavior; `--ari` implementation,
      `ARI_COMPILER` handling, compiler execution, compiler-backed tests,
      parity runner behavior, and a compatibility matrix remain future work.
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
