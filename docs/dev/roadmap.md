# ari-lint Roadmap

Current status: skeleton initialized / Ari source skeleton started / internal
model skeleton started / registry-severity-config skeleton started /
known rule registry construction added / known rule registry lookup added /
registry-backed in-memory rule dispatch added /
first rule metadata entries added /
CLI metadata skeleton started / diagnostic output metadata skeleton started /
config override skeleton refined / rule module
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
stdout/stderr output boundary model added /
internal exit-code model added /
explicit-token list-rules command wiring added /
minimal stdout adapter added /
minimal stderr adapter added /
OS argv integration added /
minimal config text parser added /
config text known-rule validation added /
rule override semantic parser added /
rule override known-rule validation added /
data-only severity override resolution added /
single-diagnostic severity override application added /
in-memory lint severity override aggregation added /
file-backed lint severity override aggregation added /
CLI file lint rule override application added /
config precedence fixture plan added /
initial config precedence fixtures and lightweight checks added /
shell-only config precedence fixture checks added /
executable rule module API added /
minimal diagnostic JSON serializer added /
source input boundary model added /
in-memory trailing-whitespace execution added /
trailing-whitespace first diagnostic capture added /
in-memory missing-final-newline execution added /
missing-final-newline first diagnostic capture added /
in-memory lint run aggregation added /
lint aggregation first diagnostic capture added /
file read boundary added /
internal CLI file lint path added /
CLI source lint first diagnostic carry added /
main-facing first diagnostic stderr output added /
source-only parity runner skeleton added /
compiler-backed CI gate documented /
standalone build root wiring added /
standalone test entrypoint added /
release and compatibility policy documented /
main OS argv exit-code wiring added /
main-facing list-rules stdout output added /
main-facing first diagnostic stderr output added /
internal human diagnostic formatter added /
internal human diagnostic array formatter added /
no full user-facing diagnostic arrays or JSON output yet.

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
      shell function and returns success. Main wiring to the OS argv integration
      entry path, stdout/stderr output, JSON output, config parsing, compiler
      invocation, source scanning, lint execution, main-entry tests, and parity
      behavior remain future work.
- [x] Add an explicit OS argv boundary placeholder that records the future
      process-argument integration boundary without reading OS argv, reading
      environment variables, dispatching tokens, writing stdout/stderr output,
      invoking the compiler, scanning sources, or executing lint rules.
      Argv-boundary tests and user-facing CLI behavior remain future work.
- [x] Add an internal stdout/stderr output boundary model that records named
      future stdout and stderr sinks plus result status without writing real
      streams, calling output APIs, wiring user-facing CLI output, serializing
      JSON, invoking the compiler, scanning sources, or executing lint rules.
      Output-boundary tests and output adapter behavior remain future work.
- [x] Add an internal exit-code model carried by command results for success,
      usage-error, and unavailable states without calling process exit, running
      a user-facing CLI, reading OS argv, writing stdout/stderr output,
      invoking the compiler, scanning sources, or executing lint rules.
      Exit-code tests and process-exit behavior remain future work.
- [x] Wire a named explicit-token `--list-rules` command path to the existing
      parser, dispatcher, human-readable formatter, and exit-code model without
      reading OS argv, writing stdout/stderr output, running a user-facing CLI,
      serializing JSON, invoking the compiler, scanning sources, or executing
      lint rules. List-rules command tests and real output behavior remain
      future work.
- [x] Add a minimal stdout adapter using the verified Ari `std::io::print_string`
      API for caller-provided `String` text, returning local status data without
      reading OS argv, wiring command output to `main`, writing stderr,
      serializing JSON, invoking the compiler, scanning sources, executing lint
      rules, or calling process exit. Stdout-adapter tests and user-facing CLI
      output wiring remain future work.
- [x] Add a minimal stderr adapter using the verified Ari `std::io::eprint_string`
      API for caller-provided `String` text, returning local status data without
      reading OS argv, wiring diagnostic output, writing stdout, serializing
      JSON, invoking the compiler, scanning sources, executing lint rules, or
      calling process exit. The main-facing first diagnostic stderr path has
      since been wired; stderr-adapter tests and broader diagnostic output
      wiring remain future work.
- [x] Add internal OS argv integration using the verified Ari `std::env::args`
      API, dropping argv[0] and reusing the existing explicit-token parser and
      stdout-free dispatcher without reading environment variables, writing
      stdout/stderr, wiring `main`, serializing JSON, invoking the compiler,
      scanning sources, executing lint rules, or calling process exit.
      OS-argv integration tests and user-facing CLI process behavior remain
      future work.
- [x] Wire `main` to return the existing OS argv CLI command exit-code mapping,
      without writing stdout/stderr, serializing JSON, discovering config files,
      traversing directories, invoking the compiler, executing `ari --check`,
      calling `tools/lint`, or calling process exit. Main-entry tests,
      user-facing output, config-file discovery, and parity checks remain future
      work.
- [x] Wire the main-facing OS argv `--list-rules` path to write the existing
      human-readable list-rules text through the verified stdout adapter,
      without writing stderr, serializing JSON, printing diagnostics,
      discovering config files, traversing directories, invoking the compiler,
      executing `ari --check`, calling `tools/lint`, or calling process exit.
      First diagnostic stderr output has since been wired for source-file lint
      results; JSON output, broader stderr behavior, CLI output tests, and
      parity checks remain future work.
- [x] Add a minimal config text parser for caller-provided text using the
      documented `RULE = SEVERITY` shape, blank lines, and `#` comments,
      returning internal overrides and parse problems without reading
      `ari-lint.rules`, discovering config files, applying overrides, inspecting
      CLI input, emitting diagnostics, serializing JSON, scanning sources,
      invoking the compiler, or executing lint rules. Config parser tests,
      config discovery, `--config` behavior, and override application remain
      future work.
- [x] Add known-rule validation to caller-provided config text using the known
      rule registry lookup, returning internal parse problems for unknown rules
      without reading `ari-lint.rules`, discovering config files, applying
      overrides, inspecting CLI input, emitting diagnostics, serializing JSON,
      scanning sources, invoking the compiler, or executing lint rules. Config
      parser tests, config discovery, `--config` behavior, and override
      application remain future work.
- [x] Add a semantic parser for caller-provided `--rule` values using the
      documented `RULE=SEVERITY` shape, normalizing the documented short rule
      names to full lint rule codes and returning command-line-sourced internal
      overrides plus parse problems without applying overrides, reading config
      files, integrating with command dispatch, emitting diagnostics,
      serializing JSON, scanning sources, invoking the compiler, or executing
      lint rules. Rule override parser tests and override application remain
      future work.
- [x] Add known-rule validation to the caller-provided `--rule` semantic parser
      using the known rule registry lookup, returning internal parse problems
      for unknown rules without applying overrides, reading config files,
      integrating with command dispatch, emitting diagnostics, serializing
      JSON, scanning sources, invoking the compiler, or executing lint rules.
      Rule override parser tests and override application remain future work.
- [x] Add data-only severity override resolution for a caller-provided rule code
      and already-parsed override list, returning effective internal severity
      data without reading config files, discovering config paths, integrating
      with command dispatch, mutating diagnostics, applying config to lint
      execution, emitting output, serializing JSON, scanning sources, invoking
      the compiler, or executing lint rules. Severity resolution tests and
      lint-run config integration remain future work.
- [x] Add single-diagnostic severity override application for one already-built
      internal diagnostic and an already-parsed override list, returning a
      rebuilt diagnostic with the resolved severity without reading config
      files, discovering config paths, integrating with command dispatch,
      running lint rules, applying config to lint execution, emitting output,
      serializing JSON, scanning sources, invoking the compiler, or executing
      `ari --check`. Diagnostic severity application tests and lint-run config
      integration remain future work.
- [x] Add in-memory lint aggregation with already-parsed severity overrides for
      caller-provided source text, applying overrides only to the diagnostics
      returned by existing in-memory rule execution without reading config
      files, discovering config paths, integrating with command dispatch,
      reading files, scanning the filesystem, writing output, serializing JSON,
      invoking the compiler, executing `ari --check`, or calling `tools/lint`.
      In-memory override aggregation tests, file-backed config integration,
      CLI config integration, and config discovery remain future work.
- [x] Add file-backed lint aggregation with already-parsed severity overrides
      for explicitly provided source paths, reusing the existing single-file
      read boundary and applying overrides only to diagnostics returned by the
      existing in-memory rule execution without reading config files,
      discovering config paths, integrating with command dispatch, traversing
      directories, writing output, serializing JSON, invoking the compiler,
      executing `ari --check`, or calling `tools/lint`. File-backed override
      aggregation tests, CLI config integration, and config discovery remain
      future work.
- [x] Apply caller-provided `--rule` overrides to the internal CLI source-file
      lint path by parsing already-captured rule override tokens and routing
      explicit source paths through file-backed lint aggregation with
      already-parsed overrides, without reading config files, discovering
      config paths, traversing directories, writing stdout/stderr, serializing
      JSON, invoking the compiler, executing `ari --check`, calling
      `tools/lint`, wiring `main`, or calling process exit. CLI rule override
      dispatch tests, config-file integration, output behavior, and parity
      checks remain future work.
- [x] Add a config precedence fixture plan for future default, config-file,
      explicit `--config`, and command-line `--rule` precedence coverage,
      without adding fixture files, reading config files, discovering
      `ari-lint.rules`, running CLI tests, writing output, serializing JSON,
      invoking the compiler, executing `ari --check`, calling `tools/lint`, or
      claiming stable config behavior. Actual config precedence fixture files,
      executable tests, and parity checks remain future work.
- [x] Start initial config precedence fixtures for discovered `ari-lint.rules`,
      explicit `--config`, command-line `--rule`, repeated override, unknown
      rule, invalid severity, and comment coverage, with lightweight fixture
      presence/content checks only. This does not execute the Ari parser, read
      config files from the CLI, discover config paths, run CLI tests, write
      output, serialize JSON, invoke the compiler, execute `ari --check`, call
      `tools/lint`, add golden output, or claim stable config behavior.
      Executable config precedence tests and parity checks remain future work.
- [x] Add shell-only executable config precedence fixture checks for exact
      fixture line order and key override values, without executing Ari parser
      code, reading config files through CLI behavior, discovering config
      paths, running CLI tests, writing output, serializing JSON, invoking the
      compiler, executing `ari --check`, calling `tools/lint`, or claiming
      stable config behavior. Ari-backed config precedence tests and parity
      checks remain future work.
- [x] Define a shared executable rule module API for caller-provided in-memory
      source, including shared rule input/result data and per-rule wrapper
      functions for `lint/trailing-whitespace` and
      `lint/missing-final-newline`, without reading files, scanning the
      filesystem, applying config, writing output, serializing JSON, invoking
      the compiler, executing `ari --check`, calling `tools/lint`, or adding
      tests. Registry-backed aggregation, config-aware rule execution,
      executable tests, and parity checks remain future work.
- [x] Add registry-backed in-memory rule dispatch for one exact known rule code
      using the existing registry lookup and shared rule wrappers, without
      reading files, scanning the filesystem, applying config, writing output,
      serializing JSON, invoking the compiler, executing `ari --check`, calling
      `tools/lint`, wiring lint aggregation or CLI dispatch, or adding tests.
      Registry-backed aggregation, config-aware dispatch, executable tests, and
      parity checks remain future work.
- [x] Add a minimal internal diagnostic JSON serialization placeholder for one
      diagnostic without claiming final field serialization, writing
      stdout/stderr, wiring CLI output, serializing diagnostic arrays, scanning
      sources, invoking the compiler, executing lint rules, or adding golden
      tests. JSON serializer tests and final schema stability remain future
      work.
- [x] Add an internal human-readable formatter for one already-built diagnostic,
      returning newline-terminated text in memory without writing stderr,
      wiring CLI output, serializing diagnostic arrays, scanning sources,
      invoking the compiler, executing lint rules, or adding golden tests.
      Human formatter tests, diagnostic arrays, stderr wiring, and parity
      checks remain future work.
- [x] Add an internal human-readable formatter for a caller-provided diagnostic
      array, joining already-built diagnostic lines in memory without collecting
      diagnostics from rule execution, writing stderr, wiring CLI output,
      serializing JSON, scanning sources, invoking the compiler, executing lint
      rules, or adding golden tests. Rule diagnostic collection, stderr wiring,
      JSON arrays, and parity checks remain future work.
- [x] Add an internal source input boundary model for caller-provided source
      text and path-only source entries, including a path-list boundary for
      already-parsed CLI paths without reading files, recursively scanning the
      filesystem, inspecting source text, producing diagnostics, invoking the
      compiler, or executing lint rules. Source input tests, file reading,
      directory traversal policy, CLI path execution, and rule execution remain
      future work.
- [x] Add in-memory `lint/trailing-whitespace` execution over caller-provided
      source text, returning an internal diagnostic count for lines ending in spaces or
      tabs without reading files, scanning the filesystem, applying config,
      producing user-facing output, serializing JSON, invoking the compiler, or
      calling `tools/lint`. Rule execution tests, file-backed linting, config
      integration, CLI wiring, output behavior, and parity checks remain future
      work.
- [x] Capture the first already-built internal diagnostic from in-memory
      `lint/trailing-whitespace` execution, while preserving diagnostic-count
      behavior and without reading files, scanning the filesystem, applying
      config, writing output, serializing JSON, invoking the compiler, executing
      `ari --check`, or calling `tools/lint`. Aggregation-level diagnostic
      collection, stderr wiring, tests, and parity checks remain future work.
- [x] Add in-memory `lint/missing-final-newline` execution over
      caller-provided source text, returning an internal diagnostic count for
      non-empty content that does not end with a newline without reading files,
      scanning the filesystem, applying config, producing user-facing output,
      serializing JSON, invoking the compiler, or calling `tools/lint`. Rule
      execution tests, file-backed linting, config integration, CLI wiring,
      output behavior, and parity checks remain future work.
- [x] Capture the first already-built internal diagnostic from in-memory
      `lint/missing-final-newline` execution, while preserving diagnostic-count
      behavior and without reading files, scanning the filesystem, applying
      config, writing output, serializing JSON, invoking the compiler, executing
      `ari --check`, or calling `tools/lint`. Aggregation-level diagnostic
      collection, stderr wiring, tests, and parity checks remain future work.
- [x] Add in-memory lint run aggregation over caller-provided source text,
      combining diagnostic counts from the in-memory
      `lint/trailing-whitespace` and `lint/missing-final-newline` rules without
      reading files, scanning the filesystem, applying config, producing
      user-facing output, serializing JSON, invoking the compiler, or calling
      `tools/lint`. Aggregation tests, config/severity override application,
      CLI wiring, file-backed linting, output behavior, and parity checks
      remain future work.
- [x] Capture the first already-built internal diagnostic at lint aggregation
      boundaries for caller-provided in-memory source and explicit file paths,
      while preserving diagnostic-count behavior and without collecting full
      diagnostic arrays, reading config files, discovering config paths,
      traversing directories, writing output, serializing JSON, invoking the
      compiler, executing `ari --check`, or calling `tools/lint`. Config-aware
      diagnostic rewriting, stderr wiring, tests, and parity checks remain
      future work.
- [x] Add an explicit file read boundary using the verified Ari
      `std::fs::read_detailed(ref mut zone, path)` API for one caller-provided
      path, preserving file read errors without scanning directories,
      discovering config files, applying config, producing user-facing output,
      serializing JSON, invoking the compiler, executing rules over file sets,
      or calling `tools/lint`. File-backed lint command wiring, directory
      traversal policy, config-file discovery, output behavior, tests, and
      parity checks remain future work.
- [x] Wire parsed source-file CLI input to the file-read boundary and
      in-memory lint aggregation as an internal command result, preserving
      diagnostic and read-error counts without writing stdout/stderr,
      serializing JSON, discovering config files, applying config, traversing
      directories, invoking the compiler, calling `ari --check`, calling
      `tools/lint`, or wiring `main` to user-facing process behavior. Output
      formatting, JSON arrays, config integration, compiler diagnostics, tests,
      and parity checks remain future work.
- [x] Carry the first already-built internal diagnostic from the source-file
      lint aggregation result into the internal CLI command result, without
      formatting diagnostics, writing stdout/stderr, serializing JSON,
      discovering config files, reading config files, traversing directories,
      invoking the compiler, executing `ari --check`, calling `tools/lint`, or
      calling process exit. Broader diagnostic output, JSON arrays, config
      integration, tests, and parity checks remain future work.
- [x] Wire the main-facing source-file lint path to format and write the first
      internal diagnostic to stderr through the verified stderr adapter, without
      collecting full diagnostic arrays, writing JSON, discovering config
      files, reading config files, traversing directories, invoking the
      compiler, executing `ari --check`, calling `tools/lint`, or calling
      process exit. Full diagnostic arrays, JSON output, config integration,
      tests, and parity checks remain future work.
- [x] Add a source-only parity runner skeleton that records the intended
      comparison boundary against current `tools/lint` without executing
      `tools/lint`, invoking an `ari-lint` binary, reading fixtures, writing
      files, comparing output, invoking the compiler, calling `ari --check`, or
      adding CI parity behavior. Executable parity runner behavior, fixtures,
      golden output, source execution, and CI parity jobs remain future work.
- [x] Record the compiler-backed CI gate by documenting that the GitHub Actions
      workflow remains compiler-free and runs only `scripts/check.sh` until
      explicit compiler provisioning, standalone tests, and compiler identity
      recording are ready. Actual compiler-backed CI, Ari compiler execution,
      `ari --check`, package manager commands, parity checks, release
      automation, and compatibility claims remain future work.
- [x] Wire local standalone build root handling in `scripts/build.sh` so the
      script resolves the repository root, uses the compiler root when
      `lib/std.arih` is available there, and compiles `src/main.ari` to
      `build/ari-lint` with an explicit compiler path, while preserving relative
      compiler paths from the caller's directory. CI build execution,
      compiler-backed checks, package manager files, release artifacts,
      standalone tests, and compatibility claims remain future work.
- [x] Start internal data model skeleton as preparatory Ari source work only;
      rule implementation, CLI parsing, diagnostics output, config parsing,
      compiler invocation, implementation tests, and implementation CI remain
      future work.
- [x] Start registry, severity, and config skeleton as preparatory Ari source
      work only; in-memory trailing-whitespace behavior has since started,
      in-memory missing-final-newline behavior has since started, while
      registry-backed aggregation, severity parsing, config parsing, CLI
      overrides, diagnostics output, compiler invocation, tests, and CI remain
      future work.
- [x] Add known rule registry construction from the existing
      `lint/trailing-whitespace` and `lint/missing-final-newline` metadata
      entries without executing rules, scanning sources, applying config,
      emitting diagnostics, invoking the compiler, or adding tests.
- [x] Add data-only known rule registry lookup by exact full rule code for
      `lint/trailing-whitespace` and `lint/missing-final-newline`, returning
      internal lookup data without executing rules, scanning sources, applying
      config, emitting diagnostics, invoking the compiler, or adding tests.
      Registry-backed in-memory dispatch has since started for one explicit
      known rule code, while lint aggregation and CLI dispatch are not wired to
      registry dispatch yet.
- [x] Add first planned rule metadata entries for
      `lint/trailing-whitespace` and `lint/missing-final-newline` as
      metadata-only Ari source placeholders; in-memory trailing-whitespace
      behavior and in-memory missing-final-newline behavior have since started,
      and registry-backed in-memory dispatch has since started. File-backed
      source scanning, diagnostics output, config parsing, CLI behavior,
      compiler invocation, tests, and CI remain future work.
- [x] Start CLI metadata skeleton for positional source input, `--json`,
      `--ari`, `-I`, `--list-rules`, `--config`, and `--rule` as
      metadata-only Ari source placeholders; full user-facing argument
      validation, config parsing, diagnostics output, JSON serialization,
      compiler invocation, tests, and CI remain future work.
- [x] Add CLI argument result model for future parser output, including
      positional files, `--json`, `--list-rules`, help requests, `--ari`, `-I`,
      `--config`, `--rule`, and parse problem data. CLI validation, config
      parsing, diagnostics output, JSON serialization, compiler invocation,
      tests, and CI remain future work.
- [x] Add a minimal CLI token parser over explicit caller-provided token lists,
      reusing the CLI argument result model for positional files, `--json`,
      `--list-rules`, `--help`/`-h`, `--ari`, `-I`, `--config`, raw `--rule`
      values, missing-value problems, and unknown-argument problems. Main
      wiring, `ARI_COMPILER`, compiler path validation, config parsing,
      compiler invocation, output behavior, tests, and CI parser execution
      remain future work.
- [x] Add an internal list-rules output path that converts existing known rule
      metadata into a count for `lint/trailing-whitespace` and
      `lint/missing-final-newline`, including rule code, short name, default
      severity, and description. User-facing `--list-rules` CLI completion,
      CLI main integration, stdout/stderr formatting, JSON output, config
      parsing, compiler invocation, tests, and parity behavior remain future
      work.
- [x] Add an internal human-readable list-rules formatter that converts the
      existing list-rules metadata into newline-terminated text containing rule code,
      short name, default severity, and description. User-facing
      `--list-rules` CLI completion now writes stdout through the main-facing
      OS argv path. Stderr output, JSON output, config parsing, compiler
      invocation, formatter tests, and parity behavior remain future work.
- [x] Add an internal stdout-free command dispatcher that maps parsed CLI args
      to internal command results, routes list-rules requests to the existing
      human-readable formatter, and returns explicit future-work placeholders for
      parse-problem, help, source-file linting, and unsupported command paths.
      User-facing CLI completion, `main` wiring, stdout/stderr output,
      JSON output, source scanning, lint execution, config parsing, compiler
      invocation, dispatcher tests, and parity behavior remain future work.
- [x] Add an internal explicit-token entry path that accepts a caller-provided
      token list, composes the existing explicit-token parser with the
      stdout-free command dispatcher, and returns a `CliCommandResult`.
      Environment handling, stdout/stderr output, JSON output,
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
      placeholders; minimal internal single-diagnostic JSON serialization has
      started, but real diagnostic output, human-readable formatting,
      diagnostic arrays, source scanning, CLI parsing, config parsing, compiler
      invocation, tests, and CI remain future work, and the JSON schema remains
      needs follow-up.
- [x] Refine config override skeleton for default config, `ari-lint.rules`,
      explicit `--config` file path, `--rule` command-line override, rule
      severity override, and documented override precedence as metadata-only Ari
      source placeholders; caller-provided config text parsing has started, but
      config discovery, config file reading, override application, CLI parsing,
      diagnostics output, compiler invocation, tests, and CI remain future work.
      Initial standalone config precedence fixture files and shell-only
      executable checks now exist, but Ari-backed checks remain needs follow-up
      before claiming stable config behavior; the fixture plan is documented in
      `docs/dev/config-precedence-fixtures.md`.
- [x] Start rule module layout for planned
      `lint/trailing-whitespace` and `lint/missing-final-newline` child modules
      as layout/metadata-only Ari source placeholders; in-memory
      trailing-whitespace execution has since started, while
      in-memory missing-final-newline execution has since started. A shared
      executable rule module API now wraps the in-memory rule functions for
      caller-provided source text. File-backed linting, config interactions,
      CLI parsing, compiler invocation, tests, and CI remain future work.
- [x] Add `docs/rules/trailing-whitespace.md` as a design note for the planned
      `lint/trailing-whitespace` rule; in-memory implementation has since
      started, while file reading, filesystem scanning, tests, fixtures, JSON
      serialization, CLI behavior, config parsing, compiler invocation, and CI
      remain future work.
- [x] Start a minimal internal single-line trailing-whitespace helper; the
      helper now feeds in-memory rule execution, while source-file scanning,
      file reading, user-facing diagnostic output, CLI behavior, config
      parsing, JSON serialization, compiler invocation, tests, fixtures, and CI
      remain future work.
- [x] Add a fixture and test plan for `lint/trailing-whitespace`;
      `docs/rules/trailing-whitespace-fixtures.md` tracks planned fixture
      layout, expected cases, expected result strategy, parity strategy, and
      golden output policy, but fixtures, tests, golden files, test runner
      behavior, file-backed rule execution, user-facing diagnostics, and CI
      remain future work.
- [x] Start first minimal trailing-whitespace fixture coverage with
      `tests/fixtures/trailing-whitespace/clean.ari` and
      `tests/fixtures/trailing-whitespace/trailing-spaces.ari`, plus a
      lightweight workflow check for fixture presence and intentional trailing
      spaces. In-memory execution has since started, while helper unit tests,
      file-backed source scanning, diagnostics output, CLI tests, golden JSON,
      parity tests, compiler invocation, and a standalone test runner remain
      future work.
- [x] Start trailing-whitespace diagnostic mapping skeleton for one
      already-split line, mapping helper output to internal span/severity data.
      In-memory rule execution now returns a diagnostic count while preserving
      message/rule-code constants, while file-backed source scanning, CLI output,
      JSON serialization, config integration, tests, parity checks, compiler
      invocation, and CI remain future work.
- [x] Add trailing-whitespace parity plan; `docs/rules/trailing-whitespace-parity.md`
      tracks future comparison against current bundled/reference `tools/lint`
      behavior, but the parity runner, parity tests, golden output,
      `tools/lint` execution, file-backed rule execution, and CI parity jobs
      remain future work.
- [x] Add `docs/rules/missing-final-newline.md` as a design note for the
      planned `lint/missing-final-newline` rule; in-memory implementation has
      since started, while file reading, filesystem scanning, tests, fixtures,
      JSON serialization, CLI behavior, config parsing, compiler invocation,
      and CI remain future work.
- [x] Start a minimal internal missing-final-newline content helper; the helper
      now feeds in-memory rule execution, while file reading, user-facing
      diagnostic output, CLI behavior, config parsing, JSON serialization,
      compiler invocation, tests, fixtures, and CI remain future work.
- [x] Add a fixture and test plan for `lint/missing-final-newline`;
      `docs/rules/missing-final-newline-fixtures.md` tracks planned fixture
      layout, expected cases, expected result strategy, parity strategy, and
      golden output policy, but fixtures, tests, golden files, test runner
      behavior, file-backed rule execution, user-facing diagnostics, and CI
      remain future work.
- [x] Start first minimal missing-final-newline fixture coverage with
      `tests/fixtures/missing-final-newline/with-final-newline.ari` and
      `tests/fixtures/missing-final-newline/missing-final-newline.ari`, plus a
      lightweight workflow check for fixture presence and final newline
      presence/absence. In-memory execution has since started, while helper
      unit tests, file-backed source scanning, diagnostics output, CLI tests,
      golden JSON, parity tests, compiler invocation, and a standalone test
      runner remain future work.
- [x] Start missing-final-newline diagnostic mapping skeleton for explicit
      caller-provided final position metadata, mapping helper output to internal
      span/severity data. In-memory rule execution now computes final position
      metadata and returns a diagnostic count while preserving message/rule-code
      constants, while file-backed source scanning, CLI output, JSON serialization,
      config integration, tests, parity checks, compiler invocation, and CI
      remain future work.
- [x] Add missing-final-newline parity plan;
      `docs/rules/missing-final-newline-parity.md` tracks future comparison
      against current bundled/reference `tools/lint` behavior, but the parity
      runner, parity tests, golden output, `tools/lint` execution, file-backed
      rule execution, and CI parity jobs remain future work.
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
- [x] Add source-only parity runner skeleton in `src/parity.ari`; executable
      parity runner behavior, fixture comparison, golden output, `tools/lint`
      execution, Ari compiler execution, and CI parity jobs remain future work.
- [x] Record compiler-backed CI gate; `.github/workflows/check.yml` remains
      lightweight and compiler-free until standalone tests and explicit Ari
      compiler provisioning exist.
- [x] Wire local standalone build script root handling; build execution remains
      explicit/local and is not part of CI.
- [x] Wire local standalone test entrypoint; executable compiler-backed, rule,
      CLI, parity, and golden-output tests remain future work.
- [x] Define initial release and compatibility policy in
      `docs/dev/release-compatibility-policy.md` after inspecting Ari releases
      and Ari tags; actual `ari-lint` compatibility entries still require
      Ari-language source, compiler-backed standalone tests, and recorded Ari
      compiler identity.
- [ ] Move implementation toward Ari-language code when feasible, after the
      documented plan has enough verified compiler/toolchain support.
- [ ] Update Ari Foundry portal after repo is usable.

These steps are planned split work. Except for the initial skeleton, they are
not complete yet.
