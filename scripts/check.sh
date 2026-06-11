#!/bin/sh

set -eu

fail() {
  printf '%s\n' "check.sh: $*" >&2
  exit 1
}

require_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

require_dir() {
  [ -d "$1" ] || fail "missing directory: $1"
}

require_grep() {
  grep -q -- "$1" "$2" || fail "missing expected text in $2: $1"
}

require_no_grep() {
  if grep -q -- "$1" "$2"; then
    fail "unexpected text in $2: $1"
  fi
}

require_final_newline() {
  last_byte=$(tail -c 1 "$1" | od -An -t x1 | tr -d ' \n')
  [ "$last_byte" = "0a" ] || fail "expected final newline: $1"
}

require_no_final_newline() {
  last_byte=$(tail -c 1 "$1" | od -An -t x1 | tr -d ' \n')
  [ "$last_byte" != "0a" ] || fail "expected no final newline: $1"
}

require_file README.md
require_file AGENTS.md
require_file .gitignore
require_file docs/README.md
require_file docs/migration.md
require_file docs/dev/compiler-invocation.md
require_file docs/dev/compiler-provisioning.md
require_file docs/dev/config-precedence-fixtures.md
require_file docs/dev/release-compatibility-policy.md
require_file docs/dev/roadmap.md
require_file docs/dev/ari-implementation-plan.md
require_file docs/dev/parity-test-plan.md
require_file docs/rules/trailing-whitespace.md
require_file docs/rules/trailing-whitespace-fixtures.md
require_file docs/rules/trailing-whitespace-parity.md
require_file docs/rules/missing-final-newline.md
require_file docs/rules/missing-final-newline-fixtures.md
require_file docs/rules/missing-final-newline-parity.md
require_file tests/fixtures/trailing-whitespace/clean.ari
require_file tests/fixtures/trailing-whitespace/trailing-spaces.ari
require_file tests/fixtures/missing-final-newline/with-final-newline.ari
require_file tests/fixtures/missing-final-newline/missing-final-newline.ari
require_file examples/README.md
require_file tests/README.md
require_file scripts/README.md
require_file scripts/build.sh
require_file scripts/test.sh
require_file .github/workflows/check.yml

require_grep "compiler-free" .github/workflows/check.yml
require_grep "scripts/check.sh" .github/workflows/check.yml
require_no_grep "scripts/build.sh" .github/workflows/check.yml
require_no_grep "ari --check" .github/workflows/check.yml
require_no_grep "ARI_COMPILER" .github/workflows/check.yml
require_no_grep "tools/lint" .github/workflows/check.yml
require_no_grep "npm " .github/workflows/check.yml
require_no_grep "cargo " .github/workflows/check.yml
require_no_grep "arix" .github/workflows/check.yml

[ -x scripts/build.sh ] || fail "scripts/build.sh is not executable"
[ -x scripts/test.sh ] || fail "scripts/test.sh is not executable"

require_grep "repo_root" scripts/test.sh
require_grep "scripts/check.sh" scripts/test.sh
require_no_grep "ari --check" scripts/test.sh
require_no_grep "ARI_COMPILER" scripts/test.sh
require_no_grep "tools/lint" scripts/test.sh
require_no_grep "scripts/build.sh" scripts/test.sh
require_no_grep "npm " scripts/test.sh
require_no_grep "cargo " scripts/test.sh
require_no_grep "arix" scripts/test.sh

require_dir src
src_readme=$(find src -name README.md -print -quit)
[ -z "$src_readme" ] || fail "source directory contains README.md: $src_readme"

non_ari_source=$(find src -type f ! -name '*.ari' -print -quit)
[ -z "$non_ari_source" ] || fail "source directory contains non-Ari file: $non_ari_source"

require_file src/main.ari
require_file src/model.ari
require_file src/cli.ari
require_file src/severity.ari
require_file src/diagnostic.ari
require_file src/output.ari
require_file src/rule.ari
require_file src/registry.ari
require_file src/rules.ari
require_file src/rules/trailing_whitespace.ari
require_file src/rules/missing_final_newline.ari
require_file src/config.ari
require_file src/source.ari
require_file src/lint.ari
require_file src/parity.ari

require_grep "RegistryLookupResult" src/registry.ari
require_grep "lookup_known_rule" src/registry.ari
require_grep "executes_rule: false" src/registry.ari
require_grep "scans_source: false" src/registry.ari

unexpected_trailing_fixture=$(find tests/fixtures/trailing-whitespace -type f ! -name clean.ari ! -name trailing-spaces.ari -print -quit)
[ -z "$unexpected_trailing_fixture" ] || fail "unexpected trailing-whitespace fixture: $unexpected_trailing_fixture"

unexpected_final_newline_fixture=$(find tests/fixtures/missing-final-newline -type f ! -name with-final-newline.ari ! -name missing-final-newline.ari -print -quit)
[ -z "$unexpected_final_newline_fixture" ] || fail "unexpected missing-final-newline fixture: $unexpected_final_newline_fixture"

require_no_grep '[[:blank:]]$' tests/fixtures/trailing-whitespace/clean.ari
require_grep '[[:blank:]]$' tests/fixtures/trailing-whitespace/trailing-spaces.ari
require_final_newline tests/fixtures/missing-final-newline/with-final-newline.ari
require_no_final_newline tests/fixtures/missing-final-newline/missing-final-newline.ari

require_grep "source extraction from ari-foundry/ari has not happened yet" README.md
require_grep "https://github.com/ari-foundry/ari" README.md
require_grep "https://github.com/ari-foundry/ari/releases" README.md
require_grep "https://github.com/ari-foundry/ari/tags" README.md
require_grep "https://ari-foundry.github.io" README.md
require_grep "long-term implementation direction" README.md
require_grep "Ari" README.md
require_grep "scripts/check.sh" README.md
require_grep "scripts/test.sh" README.md
require_grep "scripts/build.sh" README.md
require_grep "not a full test suite yet" README.md
require_grep "explicit Ari compiler path" README.md
require_grep "local standalone build wiring has started" README.md
require_grep "local standalone test entrypoint" README.md
require_grep "relative compiler paths" README.md
require_grep "docs/migration.md" docs/README.md
require_grep "docs/dev/ari-implementation-plan.md" docs/README.md
require_grep "docs/dev/compiler-invocation.md" docs/README.md
require_grep "docs/dev/compiler-provisioning.md" docs/README.md
require_grep "docs/dev/release-compatibility-policy.md" docs/README.md
require_grep "docs/rules/trailing-whitespace.md" docs/README.md
require_grep "docs/rules/missing-final-newline.md" docs/README.md
require_grep "docs/dev/ari-implementation-plan.md" docs/dev/roadmap.md
require_grep "docs/dev/parity-test-plan.md" docs/dev/roadmap.md
require_grep "docs/dev/parity-test-plan.md" tests/README.md
require_grep "Do not invent compatibility claims" docs/migration.md
require_grep "Ari-language implementation" docs/dev/ari-implementation-plan.md
require_grep "compiler bugs belong in ari-foundry/ari" docs/dev/ari-implementation-plan.md
require_grep "standard library bugs belong in ari-foundry/ari" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/compiler-invocation.md" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/compiler-provisioning.md" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/config-precedence-fixtures.md" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/release-compatibility-policy.md" docs/dev/ari-implementation-plan.md
require_grep "ari-lint Config Precedence Fixture Plan" docs/dev/config-precedence-fixtures.md
require_grep "does not add fixture files" docs/dev/config-precedence-fixtures.md
require_grep "command-line .--rule. overrides" docs/dev/config-precedence-fixtures.md
require_grep "Config precedence must not be documented as stable" docs/dev/config-precedence-fixtures.md
require_grep "ari-lint Release And Compatibility Policy" docs/dev/release-compatibility-policy.md
require_grep "https://github.com/ari-foundry/ari/releases" docs/dev/release-compatibility-policy.md
require_grep "https://github.com/ari-foundry/ari/tags" docs/dev/release-compatibility-policy.md
require_grep "No Ari compatibility claims are established yet" docs/dev/release-compatibility-policy.md
require_grep "Do not invent version numbers" docs/dev/release-compatibility-policy.md
require_grep "compiler-backed .ari-lint. tests pass" docs/dev/release-compatibility-policy.md
require_grep "Do not add release automation in this step" docs/dev/release-compatibility-policy.md
require_grep "Do not claim support for any Ari release" docs/dev/release-compatibility-policy.md
require_grep "release and compatibility policy documented" docs/dev/roadmap.md
require_grep "release-compatibility-policy.md" tests/README.md
require_grep "ari-lint Parity Test Plan" docs/dev/parity-test-plan.md
require_grep "tools/lint" docs/dev/parity-test-plan.md
require_grep "docs/dev/compiler-invocation.md" docs/dev/parity-test-plan.md
require_grep "docs/dev/compiler-provisioning.md" docs/dev/parity-test-plan.md
require_grep "Do not add test fixtures in this step" docs/dev/parity-test-plan.md
require_grep "# lint/trailing-whitespace" docs/rules/trailing-whitespace.md
require_grep "Do not read files in this step" docs/rules/trailing-whitespace.md
require_grep "in-memory behavior" docs/rules/trailing-whitespace.md
require_grep "# lint/missing-final-newline" docs/rules/missing-final-newline.md
require_grep "Do not read files in this step" docs/rules/missing-final-newline.md
require_grep "in-memory behavior" docs/rules/missing-final-newline.md
require_grep "docs/rules/trailing-whitespace.md" docs/dev/ari-implementation-plan.md
require_grep "docs/rules/missing-final-newline.md" docs/dev/ari-implementation-plan.md
require_grep "docs/rules/trailing-whitespace.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/missing-final-newline.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/missing-final-newline-fixtures.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/missing-final-newline-parity.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/trailing-whitespace-fixtures.md" docs/rules/trailing-whitespace.md
require_grep "docs/rules/trailing-whitespace-fixtures.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/trailing-whitespace-fixtures.md" tests/README.md
require_grep "docs/rules/missing-final-newline-fixtures.md" docs/rules/missing-final-newline.md
require_grep "docs/rules/missing-final-newline-fixtures.md" tests/README.md
require_grep "Do not add broad fixture coverage in this step" docs/rules/missing-final-newline-fixtures.md
require_grep "docs/rules/missing-final-newline-parity.md" docs/rules/missing-final-newline.md
require_grep "docs/rules/missing-final-newline-parity.md" docs/rules/missing-final-newline-fixtures.md
require_grep "docs/rules/missing-final-newline-parity.md" tests/README.md
require_grep "Do not add a parity runner in this step" docs/rules/missing-final-newline-parity.md
require_grep "docs/rules/trailing-whitespace-parity.md" docs/rules/trailing-whitespace.md
require_grep "docs/rules/trailing-whitespace-parity.md" docs/rules/trailing-whitespace-fixtures.md
require_grep "docs/rules/trailing-whitespace-parity.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/trailing-whitespace-parity.md" tests/README.md
require_grep "Do not add a parity runner in this step" docs/rules/trailing-whitespace-parity.md
require_grep "parity plan exists but runner is not implemented" docs/rules/trailing-whitespace.md
require_grep "Fixture comparison is planned but not automated yet" docs/rules/trailing-whitespace-fixtures.md
require_grep "No executable parity runner exists yet" tests/README.md
require_grep "first minimal fixture coverage has started" docs/rules/trailing-whitespace-fixtures.md
require_grep "initial clean and trailing-spaces fixtures are started" docs/rules/trailing-whitespace.md
require_grep "trailing-whitespace design note" docs/dev/roadmap.md
require_grep "trailing-whitespace fixture and test plan" docs/dev/roadmap.md
require_grep "initial trailing-whitespace fixtures and lightweight fixture check" docs/dev/roadmap.md
require_grep "trailing-whitespace parity plan added" docs/dev/roadmap.md
require_grep "missing-final-newline design note added" docs/dev/roadmap.md
require_grep "minimal missing-final-newline helper started" docs/dev/roadmap.md
require_grep "missing-final-newline fixture and test plan added" docs/dev/roadmap.md
require_grep "missing-final-newline fixtures and lightweight fixture check started" docs/dev/roadmap.md
require_grep "missing-final-newline parity plan added" docs/dev/roadmap.md
require_grep "lightweight check runner skeleton" docs/dev/roadmap.md
require_grep "compiler invocation plan added" docs/dev/roadmap.md
require_grep "compiler provisioning plan added" docs/dev/roadmap.md
require_grep "local build scaffold and gitignore hygiene added" docs/dev/roadmap.md
require_grep "minimal main entry shell added" docs/dev/roadmap.md
require_grep "OS argv boundary placeholder added" docs/dev/roadmap.md
require_grep "stdout/stderr output boundary model added" docs/dev/roadmap.md
require_grep "internal exit-code model added" docs/dev/roadmap.md
require_grep "explicit-token list-rules command wiring added" docs/dev/roadmap.md
require_grep "minimal stdout adapter added" docs/dev/roadmap.md
require_grep "known rule registry lookup added" docs/dev/roadmap.md
require_grep "config text known-rule validation added" docs/dev/roadmap.md
require_grep "rule override known-rule validation added" docs/dev/roadmap.md
require_grep "data-only severity override resolution added" docs/dev/roadmap.md
require_grep "single-diagnostic severity override application added" docs/dev/roadmap.md
require_grep "in-memory lint severity override aggregation added" docs/dev/roadmap.md
require_grep "file-backed lint severity override aggregation added" docs/dev/roadmap.md
require_grep "CLI file lint rule override application added" docs/dev/roadmap.md
require_grep "config precedence fixture plan added" docs/dev/roadmap.md
require_grep "data-only lookup" docs/dev/ari-implementation-plan.md
require_grep "known-rule validation" docs/dev/ari-implementation-plan.md
require_grep "severity override resolver" docs/dev/ari-implementation-plan.md
require_grep "single-diagnostic application helper" docs/dev/ari-implementation-plan.md
require_grep "override aggregation path" docs/dev/ari-implementation-plan.md
require_grep "file-backed override aggregation path" docs/dev/ari-implementation-plan.md
require_grep "Apply caller-provided .--rule. overrides to the internal CLI file lint" docs/dev/ari-implementation-plan.md
require_grep "known rule registry lookup" tests/README.md
require_grep "known-rule validation" tests/README.md
require_grep "No executable severity override resolution tests are added yet" tests/README.md
require_grep "No executable diagnostic severity application tests are added yet" tests/README.md
require_grep "No executable in-memory lint severity override aggregation tests are added yet" tests/README.md
require_grep "No executable file-backed lint severity override aggregation tests are added yet" tests/README.md
require_grep 'parsed `--rule` override application' tests/README.md
require_grep "No config precedence fixture files are added yet" tests/README.md
require_grep "OS argv integration added" docs/dev/roadmap.md
require_grep "minimal config text parser added" docs/dev/roadmap.md
require_grep "rule override semantic parser added" docs/dev/roadmap.md
require_grep "minimal diagnostic JSON serializer added" docs/dev/roadmap.md
require_grep "source input boundary model added" docs/dev/roadmap.md
require_grep "in-memory trailing-whitespace execution added" docs/dev/roadmap.md
require_grep "in-memory missing-final-newline execution added" docs/dev/roadmap.md
require_grep "in-memory lint run aggregation added" docs/dev/roadmap.md
require_grep "file read boundary added" docs/dev/roadmap.md
require_grep "internal CLI file lint path added" docs/dev/roadmap.md
require_grep "source-only parity runner skeleton added" docs/dev/roadmap.md
require_grep "compiler-backed CI gate documented" docs/dev/roadmap.md
require_grep "standalone build root wiring added" docs/dev/roadmap.md
require_grep "standalone test entrypoint added" docs/dev/roadmap.md
require_grep "Wire local standalone test entrypoint" docs/dev/roadmap.md
require_grep "Initial trailing-whitespace fixtures have started" tests/README.md
require_grep "Initial missing-final-newline fixtures have started" tests/README.md
require_grep "lint run aggregation has also started" tests/README.md
require_grep "file-read boundary for one" tests/README.md
require_grep "internal CLI file lint path" tests/README.md
require_grep "source-only parity runner skeleton" tests/README.md
require_grep "GitHub Actions workflow is intentionally compiler-free" tests/README.md
require_grep "local standalone test entrypoint" tests/README.md
require_grep "No executable standalone build tests are added yet" tests/README.md
require_grep "relative compiler path preservation" tests/README.md
require_grep "docs/dev/compiler-invocation.md" tests/README.md
require_grep "docs/dev/compiler-provisioning.md" tests/README.md
require_grep "No executable missing-final-newline rule execution tests are added yet" tests/README.md
require_grep "No executable in-memory lint run aggregation tests are added yet" tests/README.md
require_grep "No executable file IO boundary tests are added yet" tests/README.md
require_grep "No executable CLI file lint path tests are added yet" tests/README.md
require_grep "No executable parity runner tests are added yet" tests/README.md
require_grep "Source directories should contain Ari source files only" docs/dev/ari-implementation-plan.md
require_grep "CLI file lint path is limited" docs/dev/ari-implementation-plan.md
require_grep "source-only parity runner skeleton" docs/dev/ari-implementation-plan.md
require_grep "compiler-backed CI gate" docs/dev/ari-implementation-plan.md
require_grep "local standalone test entrypoint" docs/dev/ari-implementation-plan.md
require_grep "Standalone build wiring is local-only" docs/dev/ari-implementation-plan.md
require_grep "relative compiler paths" docs/dev/ari-implementation-plan.md
require_grep "The current GitHub Actions workflow must not run" docs/dev/compiler-provisioning.md
require_grep "in-memory lint run aggregation path" docs/dev/ari-implementation-plan.md
require_grep "File-backed aggregation" docs/dev/ari-implementation-plan.md
require_grep "file-read boundary" docs/dev/ari-implementation-plan.md
require_grep "std::fs::read_detailed" docs/dev/ari-implementation-plan.md
require_grep "registry, severity, and config model skeleton" docs/dev/ari-implementation-plan.md
require_grep "registry, severity, and config skeleton" docs/dev/roadmap.md
require_grep "known rule registry construction" docs/dev/roadmap.md
require_grep "Known rule registry construction" tests/README.md
require_grep "known_rule_registry" src/registry.ari
require_grep "registry_entry_from_metadata" src/registry.ari
require_grep "RuleRegistry" src/registry.ari
require_grep "ReferenceOnly" src/registry.ari
require_grep "trailing_whitespace_rule_metadata" src/registry.ari
require_grep "missing_final_newline_rule_metadata" src/registry.ari
require_grep "does not run rules" src/registry.ari
require_grep "scan source" src/registry.ari
require_grep "first planned rule metadata entries" docs/dev/ari-implementation-plan.md
require_grep "first planned rule metadata entries" docs/dev/roadmap.md
require_grep "No rule metadata tests are added yet" tests/README.md
require_grep "CLI metadata skeleton" docs/dev/ari-implementation-plan.md
require_grep "CLI argument result model" docs/dev/ari-implementation-plan.md
require_grep "Minimal token-list parsing has started" docs/dev/ari-implementation-plan.md
require_grep "Actual OS process argument collection now has a" docs/dev/ari-implementation-plan.md
require_grep "minimal internal entry path" docs/dev/ari-implementation-plan.md
require_grep "std::env::args" docs/dev/ari-implementation-plan.md
require_grep "internal stdout-free command dispatcher" docs/dev/ari-implementation-plan.md
require_grep "Internal command results now carry data-only exit-code mappings" docs/dev/ari-implementation-plan.md
require_grep "named explicit-token .--list-rules. command entry" docs/dev/ari-implementation-plan.md
require_grep "minimal stdout adapter" docs/dev/ari-implementation-plan.md
require_grep "std::io::print_string" docs/dev/ari-implementation-plan.md
require_grep "CLI metadata skeleton" docs/dev/roadmap.md
require_grep "CLI argument model added" docs/dev/roadmap.md
require_grep "minimal CLI token parser added" docs/dev/roadmap.md
require_grep "stdout-free command dispatcher added" docs/dev/roadmap.md
require_grep "internal explicit-token entry path added" docs/dev/roadmap.md
require_grep "No CLI tests are added yet" tests/README.md
require_grep "No CLI model tests are added yet" tests/README.md
require_grep "No executable CLI parser tests are added yet" tests/README.md
require_grep "No executable dispatcher tests are added yet" tests/README.md
require_grep "No executable exit-code tests are added yet" tests/README.md
require_grep "No executable explicit-token entry tests are added yet" tests/README.md
require_grep "No executable explicit-token list-rules command tests are added yet" tests/README.md
require_grep "No executable main-entry tests are added yet" tests/README.md
require_grep "No executable OS argv integration tests are added yet" tests/README.md
require_grep "No executable stdout/stderr output boundary tests are added yet" tests/README.md
require_grep "No executable stdout adapter tests are added yet" tests/README.md
require_grep "scripts/build.sh" tests/README.md
require_grep "scripts/test.sh" tests/README.md
require_grep "diagnostic output metadata skeleton" docs/dev/ari-implementation-plan.md
require_grep "diagnostic output metadata skeleton" docs/dev/roadmap.md
require_grep "minimal internal single-diagnostic JSON" docs/dev/ari-implementation-plan.md
require_grep "serializer now builds JSON text" docs/dev/ari-implementation-plan.md
require_grep "User-facing diagnostic output" docs/dev/ari-implementation-plan.md
require_grep "internal list-rules output path" docs/dev/ari-implementation-plan.md
require_grep "internal human-readable list-rules formatter" docs/dev/ari-implementation-plan.md
require_grep "stdout/stderr output boundary model" docs/dev/ari-implementation-plan.md
require_grep "internal list-rules output path added" docs/dev/roadmap.md
require_grep "human-readable list-rules formatter added" docs/dev/roadmap.md
require_grep "No diagnostic output tests are added yet" tests/README.md
require_grep "No executable diagnostic JSON serializer tests are added yet" tests/README.md
require_grep "No executable source input boundary tests are added yet" tests/README.md
require_grep "No executable list-rules formatter tests are added yet" tests/README.md
require_grep "config override skeleton" docs/dev/ari-implementation-plan.md
require_grep "config override skeleton" docs/dev/roadmap.md
require_grep "config text parser now handles" docs/dev/ari-implementation-plan.md
require_grep "RULE = SEVERITY" docs/dev/ari-implementation-plan.md
require_grep "config discovery, config file reading, override" docs/dev/ari-implementation-plan.md
require_grep "No executable config parser tests are added yet" tests/README.md
require_grep "semantic parser for caller-provided .--rule. values" docs/dev/roadmap.md
require_grep "No executable rule override parser tests are added yet" tests/README.md
require_grep "No config override tests are added yet" tests/README.md
require_grep "Current rule module state" docs/dev/ari-implementation-plan.md
require_grep "rule module layout" docs/dev/roadmap.md
require_grep "in-memory rule execution" docs/dev/ari-implementation-plan.md
require_grep "Both rules now" docs/dev/ari-implementation-plan.md
require_grep "No rule module tests are added yet" tests/README.md
require_grep "minimal internal single-line helper" docs/dev/ari-implementation-plan.md
require_grep "single-line helper" docs/rules/trailing-whitespace.md
require_grep "trailing-whitespace helper started" docs/dev/roadmap.md
require_grep "No executable trailing-whitespace rule execution tests are added yet" tests/README.md
require_grep "fn main() -> i64" src/main.ari
require_grep "run_main_entry_shell" src/main.ari
require_grep "pub mod cli" src/model.ari
require_grep "pub mod output" src/model.ari
require_grep "pub mod config" src/model.ari
require_grep "pub mod rules" src/model.ari
require_grep "pub mod source" src/model.ari
require_grep "pub mod lint" src/model.ari
require_grep "CliSurfaceMetadata" src/cli.ari
require_grep "CliArgs" src/cli.ari
require_grep "CliParseResult" src/cli.ari
require_grep "CliRuleOverrideArg" src/cli.ari
require_grep "CliArgumentProblem" src/cli.ari
require_grep "CliCommandResultKind" src/cli.ari
require_grep "CliCommandResult" src/cli.ari
require_grep "file_lint_result" src/cli.ari
require_grep "CliExitCodeKind" src/cli.ari
require_grep "CliExitCodeMapping" src/cli.ari
require_grep "CliExitSuccess" src/cli.ari
require_grep "CliExitUsageError" src/cli.ari
require_grep "CliExitUnavailable" src/cli.ari
require_grep "cli_success_exit_code" src/cli.ari
require_grep "cli_usage_error_exit_code" src/cli.ari
require_grep "cli_unavailable_exit_code" src/cli.ari
require_grep "calls_process_exit: false" src/cli.ari
require_grep "positional source file input" src/cli.ari
require_grep "source_files" src/cli.ari
require_grep "--json" src/cli.ari
require_grep "json_requested" src/cli.ari
require_grep "--ari" src/cli.ari
require_grep "ari_compiler_path" src/cli.ari
require_grep "-I" src/cli.ari
require_grep "include_paths" src/cli.ari
require_grep "--list-rules" src/cli.ari
require_grep "list_rules_requested" src/cli.ari
require_grep "--config" src/cli.ari
require_grep "config_path" src/cli.ari
require_grep "--rule" src/cli.ari
require_grep "rule_overrides" src/cli.ari
require_grep "help_requested" src/cli.ari
require_grep "problems" src/cli.ari
require_grep "parse_cli_tokens" src/cli.ari
require_grep "dispatch_cli_command" src/cli.ari
require_grep "run_explicit_cli_tokens" src/cli.ari
require_grep "run_explicit_list_rules_command" src/cli.ari
require_grep "read_os_argv_tokens" src/cli.ari
require_grep "run_os_argv_cli" src/cli.ari
require_grep "parse_cli_rule_overrides" src/cli.ari
require_grep "cli_file_lint_exit_code" src/cli.ari
require_grep "lint_file_sources_with_overrides" src/cli.ari
require_grep "Rule override parse problems" src/cli.ari
require_grep "with rule overrides" src/cli.ari
require_grep "OsArgvBoundary" src/cli.ari
require_grep "os_argv_boundary" src/cli.ari
require_grep "std::env::args" src/cli.ari
require_grep "reads_process_argv: true" src/cli.ari
require_grep "CliListRulesText" src/cli.ari
require_grep "CliSourceLintResult" src/cli.ari
require_grep "lint_file_sources" src/cli.ari
require_grep "missing_value_problem" src/cli.ari
require_grep "unknown_argument_problem" src/cli.ari
require_grep "raw_rule_override" src/cli.ari
require_grep "optional_rule_override_part" src/cli.ari
require_grep "semantic rule override parsing bridge" src/cli.ari
require_grep "applying parsed --rule overrides" src/cli.ari
require_grep "does not read environment" src/cli.ari
require_grep "main wiring remains future work" src/cli.ari
require_grep "write stdout/stderr" src/cli.ari
require_grep "call process exit" src/cli.ari
require_grep "recursively scan source trees" src/cli.ari
require_grep "Source-file lint diagnostics are available internally" src/cli.ari
require_grep "future work" src/cli.ari
require_grep "DiagnosticOutputMetadata" src/output.ari
require_grep "Human" src/output.ari
require_grep "Json" src/output.ari
require_grep "file path" src/output.ari
require_grep "line" src/output.ari
require_grep "column" src/output.ari
require_grep "endLine" src/output.ari
require_grep "endColumn" src/output.ari
require_grep "severity" src/output.ari
require_grep "rule code" src/output.ari
require_grep "message" src/output.ari
require_grep "serialize_diagnostic_json" src/output.ari
require_grep "append_json_string" src/output.ari
require_grep "append_json_optional_position" src/output.ari
require_grep "diagnostic_severity_name" src/output.ari
require_grep "filePath" src/output.ari
require_grep "endLine" src/output.ari
require_grep "endColumn" src/output.ari
require_grep "does not write stdout/stderr" src/output.ari
require_grep "JSON schema stability remain follow-up" src/output.ari
require_grep "ListRuleRow" src/output.ari
require_grep "ListRulesOutput" src/output.ari
require_grep "list_rule_row_from_metadata" src/output.ari
require_grep "known_list_rules_output" src/output.ari
require_grep "format_list_rule_row_human" src/output.ari
require_grep "format_list_rules_human" src/output.ari
require_grep "final user-facing JSON output" src/output.ari
require_grep "list-rules CLI" src/output.ari
require_grep "OutputSinkName" src/output.ari
require_grep "OutputSinkBoundary" src/output.ari
require_grep "OutputBoundaryResult" src/output.ari
require_grep "stdout_stderr_output_boundary" src/output.ari
require_grep "writes_real_streams" src/output.ari
require_grep "does not call real output APIs" src/output.ari
require_grep "StdoutAdapterResult" src/output.ari
require_grep "write_stdout_text" src/output.ari
require_grep "std::io::print_string" src/output.ari
require_grep "ConfigSkeleton" src/config.ari
require_grep "ConfigSourceMetadata" src/config.ari
require_grep "OverridePrecedenceMetadata" src/config.ari
require_grep "ConfigParseResult" src/config.ari
require_grep "RuleOverrideParseResult" src/config.ari
require_grep "RuleSeverityResolution" src/config.ari
require_grep "DiagnosticSeverityApplication" src/config.ari
require_grep "resolve_rule_severity_from_overrides" src/config.ari
require_grep "ConfigParseProblemKind" src/config.ari
require_grep "ConfigMissingEquals" src/config.ari
require_grep "ConfigUnknownRule" src/config.ari
require_grep "ConfigInvalidSeverity" src/config.ari
require_grep "parse_config_text" src/config.ari
require_grep "parse_config_severity" src/config.ari
require_grep "parse_rule_override_texts" src/config.ari
require_grep "parse_rule_override_value" src/config.ari
require_grep "resolve_rule_severity" src/config.ari
require_grep "apply_rule_severity_to_diagnostic" src/config.ari
require_grep "apply_rule_severity_to_diagnostic_from_overrides" src/config.ari
require_grep "matched_override" src/config.ari
require_grep "applies_to_diagnostics: false" src/config.ari
require_grep "applies_to_diagnostics: true" src/config.ari
require_grep "applies_to_lint_execution: false" src/config.ari
require_grep "writes_output: false" src/config.ari
require_grep "serializes_json: false" src/config.ari
require_grep "normalized_rule_override_code" src/config.ari
require_grep "known_rule_code" src/config.ari
require_grep "lookup_known_rule" src/config.ari
require_grep "Unknown rule" src/config.ari
require_grep "DefaultConfig" src/config.ari
require_grep "AriLintRulesDiscovery" src/config.ari
require_grep "ExplicitConfigFile" src/config.ari
require_grep "CommandLineRuleOverride" src/config.ari
require_grep "ari-lint.rules" src/config.ari
require_grep "--config" src/config.ari
require_grep "--rule" src/config.ari
require_grep "not discover or read ari-lint.rules" src/config.ari
require_grep "RULE = SEVERITY" src/config.ari
require_grep "RULE=SEVERITY" src/config.ari
require_grep "CommandLineRuleOverride" src/config.ari
require_grep "future work" src/config.ari
require_grep "SourceInput" src/source.ari
require_grep "SourceInputSet" src/source.ari
require_grep "SourceInputOrigin" src/source.ari
require_grep "ProvidedText" src/source.ari
require_grep "PathOnly" src/source.ari
require_grep "FileRead" src/source.ari
require_grep "SourceFileReadBoundary" src/source.ari
require_grep "source_input_from_text" src/source.ari
require_grep "source_input_from_path" src/source.ari
require_grep "source_input_set_from_paths" src/source.ari
require_grep "source_file_read_boundary" src/source.ari
require_grep "source_input_from_file" src/source.ari
require_grep "std::fs::read_detailed" src/source.ari
require_grep "std::fs::PathError" src/source.ari
require_grep "reads_file: false" src/source.ari
require_grep "reads_file: true" src/source.ari
require_grep "recursively_scans_filesystem: false" src/source.ari
require_grep "read one explicitly provided path" src/source.ari
require_grep "recursively scan directories" src/source.ari
require_grep "discover ari-lint.rules" src/source.ari
require_grep "execute lint rules" src/source.ari
require_grep "InMemoryLintRunResult" src/lint.ari
require_grep "FileLintRunResult" src/lint.ari
require_grep "lint_in_memory_source" src/lint.ari
require_grep "lint_in_memory_source_from_overrides" src/lint.ari
require_grep "lint_in_memory_source_with_overrides" src/lint.ari
require_grep "lint_file_source" src/lint.ari
require_grep "lint_file_source_from_overrides" src/lint.ari
require_grep "lint_file_source_with_overrides" src/lint.ari
require_grep "lint_file_sources" src/lint.ari
require_grep "lint_file_sources_with_overrides" src/lint.ari
require_grep "append_diagnostics" src/lint.ari
require_grep "append_configured_diagnostics" src/lint.ari
require_grep "append_file_lint_result" src/lint.ari
require_grep "lint_trailing_whitespace_in_memory" src/lint.ari
require_grep "lint_missing_final_newline_in_memory" src/lint.ari
require_grep "source_input_from_file" src/lint.ari
require_grep "read_errors" src/lint.ari
require_grep "read_error_count" src/lint.ari
require_grep "source_count: 1" src/lint.ari
require_grep "reads_files: false" src/lint.ari
require_grep "reads_files: true" src/lint.ari
require_grep "scans_filesystem: false" src/lint.ari
require_grep "applies_config: false" src/lint.ari
require_grep "applies_config: true" src/lint.ari
require_grep "writes_output: false" src/lint.ari
require_grep "serializes_json: false" src/lint.ari
require_grep "invokes_compiler: false" src/lint.ari
require_grep "reads only explicit paths" src/lint.ari
require_grep "scan the filesystem" src/lint.ari
require_grep "apply config" src/lint.ari
require_grep "serialize JSON" src/lint.ari
require_grep "invoke ari --check" src/lint.ari
require_grep "tools/lint" src/lint.ari
require_grep "pub mod parity" src/model.ari
require_grep "ParityRunnerSkeleton" src/parity.ari
require_grep "parity_runner_skeleton" src/parity.ari
require_grep "source-only parity runner skeleton" src/parity.ari
require_grep "ari-foundry/ari tools/lint" src/parity.ari
require_grep "invokes_tools_lint: false" src/parity.ari
require_grep "invokes_ari_lint_binary: false" src/parity.ari
require_grep "invokes_compiler: false" src/parity.ari
require_grep "invokes_shell: false" src/parity.ari
require_grep "reads_files: false" src/parity.ari
require_grep "writes_files: false" src/parity.ari
require_grep "compares_outputs: false" src/parity.ari
require_grep "InitialRuleMetadata" src/rules.ari
require_grep "rule_descriptor" src/rule.ari
require_grep "pub mod trailing_whitespace" src/rules.ari
require_grep "pub mod missing_final_newline" src/rules.ari
require_grep "lint/trailing-whitespace" src/rules.ari
require_grep "trailing-whitespace" src/rules.ari
require_grep "lint/missing-final-newline" src/rules.ari
require_grep "missing-final-newline" src/rules.ari
require_grep "default severity warning" src/rules.ari
require_grep "trailing_whitespace_rule_metadata" src/rules.ari
require_grep "missing_final_newline_rule_metadata" src/rules.ari
require_grep "initial_rule_metadata" src/rules.ari
require_grep "future work" src/rules.ari
require_grep "does not run rules" src/rules.ari
require_grep "TrailingWhitespaceRuleModuleMetadata" src/rules/trailing_whitespace.ari
require_grep "lint/trailing-whitespace" src/rules/trailing_whitespace.ari
require_grep "line_has_trailing_whitespace" src/rules/trailing_whitespace.ari
require_grep "is_trailing_space_byte" src/rules/trailing_whitespace.ari
require_grep "TrailingWhitespaceDiagnosticMapping" src/rules/trailing_whitespace.ari
require_grep "trailing_whitespace_diagnostic_mapping" src/rules/trailing_whitespace.ari
require_grep "TrailingWhitespaceRuleResult" src/rules/trailing_whitespace.ari
require_grep "lint_trailing_whitespace_in_memory" src/rules/trailing_whitespace.ari
require_grep "push_trailing_whitespace_diagnostic" src/rules/trailing_whitespace.ari
require_grep "diagnostic_from_span" src/diagnostic.ari
require_grep "diagnostic_from_span" src/rules/trailing_whitespace.ari
require_grep "std::vec::Vec" src/rules/trailing_whitespace.ari
require_grep "diagnostics.push" src/rules/trailing_whitespace.ari
require_grep "reads_files: false" src/rules/trailing_whitespace.ari
require_grep "scans_filesystem: false" src/rules/trailing_whitespace.ari
require_grep "source_span_with_end" src/diagnostic.ari
require_grep "diagnostic mapping skeleton" docs/dev/ari-implementation-plan.md
require_grep "diagnostic mapping skeleton" docs/dev/roadmap.md
require_grep "No diagnostic mapping tests are added yet" tests/README.md
require_grep "does not read files" src/rules/trailing_whitespace.ari
require_grep "caller-provided source" src/rules/trailing_whitespace.ari
require_grep "future work" src/rules/trailing_whitespace.ari
require_grep "MissingFinalNewlineRuleModuleMetadata" src/rules/missing_final_newline.ari
require_grep "lint/missing-final-newline" src/rules/missing_final_newline.ari
require_grep "content_is_missing_final_newline" src/rules/missing_final_newline.ari
require_grep "MissingFinalNewlineDiagnosticMapping" src/rules/missing_final_newline.ari
require_grep "missing_final_newline_diagnostic_mapping" src/rules/missing_final_newline.ari
require_grep "MissingFinalNewlineFinalPosition" src/rules/missing_final_newline.ari
require_grep "MissingFinalNewlineRuleResult" src/rules/missing_final_newline.ari
require_grep "final_position_for_source" src/rules/missing_final_newline.ari
require_grep "lint_missing_final_newline_in_memory" src/rules/missing_final_newline.ari
require_grep "diagnostic_from_span" src/rules/missing_final_newline.ari
require_grep "diagnostics.push" src/rules/missing_final_newline.ari
require_grep "reads_files: false" src/rules/missing_final_newline.ari
require_grep "scans_filesystem: false" src/rules/missing_final_newline.ari
require_grep "source_span_with_end" src/rules/missing_final_newline.ari
require_grep "computes final position metadata" docs/dev/ari-implementation-plan.md
require_grep "missing-final-newline diagnostic mapping skeleton started" docs/dev/roadmap.md
require_grep "No missing-final-newline diagnostic mapping tests are added yet" tests/README.md
require_grep "does not read files" src/rules/missing_final_newline.ari
require_grep "does not" src/rules/missing_final_newline.ari
require_grep "future work" src/rules/missing_final_newline.ari
require_grep "provision the Ari compiler" scripts/README.md
require_grep "build.sh" scripts/README.md
require_grep "explicit Ari compiler path" scripts/README.md
require_grep "repository root before compiling" scripts/README.md
require_grep "relative compiler paths" scripts/README.md
require_grep "does not download or build the Ari compiler" scripts/README.md
require_grep "tools/lint" scripts/README.md
require_grep "ARI_COMPILER" scripts/build.sh
require_grep "original_pwd" scripts/build.sh
require_grep "repo_root" scripts/build.sh
require_grep 'cd "$repo_root"' scripts/build.sh
require_grep "src/main.ari" scripts/build.sh
require_grep "build/ari-lint" scripts/build.sh
require_grep "does not run" tests/README.md
require_no_grep "trailing-whitespace" src/main.ari
require_no_grep "missing-final-newline" src/main.ari

stale_source_metadata=$(grep -R "Metadata entry:" src || true)
[ -z "$stale_source_metadata" ] || fail "stale source metadata comment found"

stale_source_metadata_only=$(grep -R "metadata-only" src || true)
[ -z "$stale_source_metadata_only" ] || fail "stale source metadata-only comment found"

stale_source_not_added=$(grep -R "not added yet" src || true)
[ -z "$stale_source_not_added" ] || fail "stale source not-added-yet comment found"

printf '%s\n' "lightweight checks passed"
