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

require_fixed_grep() {
  grep -Fq -- "$1" "$2" || fail "missing expected text in $2: $1"
}

require_fixed_line() {
  fixed_line_count=$(grep -Fxc -- "$1" "$2" || true)
  [ "$fixed_line_count" -eq 1 ] ||
    fail "expected exactly one line in $2: $1"
}

require_line_before() {
  earlier_line=$(grep -nFx -- "$1" "$3" | sed -n '1s/:.*//p')
  later_line=$(grep -nFx -- "$2" "$3" | sed -n '1s/:.*//p')
  [ -n "$earlier_line" ] && [ -n "$later_line" ] &&
    [ "$earlier_line" -lt "$later_line" ] ||
    fail "expected ordered lines in $3: $1 before $2"
}

file_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    fail "need sha256sum or shasum to verify $1"
  fi
}

require_sha256() {
  actual_sha256=$(file_sha256 "$2")
  [ "$actual_sha256" = "$1" ] ||
    fail "unexpected SHA-256 for $2: $actual_sha256"
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

require_line_equals() {
  actual=$(sed -n "$2p" "$1")
  [ "$actual" = "$3" ] || fail "expected line $2 in $1 to be: $3"
}

require_file README.md
require_file AGENTS.md
require_file .gitignore
require_file .gitattributes
require_file docs/README.md
require_file docs/features.md
require_file docs/config.md
require_file docs/rules.md
require_file docs/diagnostics.md
require_file docs/list-rules.md
require_file docs/migration.md
require_file docs/dev/compiler-invocation.md
require_file docs/dev/compiler-provisioning.md
require_file docs/dev/config-precedence-fixtures.md
require_file docs/dev/release-compatibility-policy.md
require_file docs/dev/roadmap.md
require_file docs/dev/ari-implementation-plan.md
require_file docs/dev/parity-test-plan.md
require_file docs/dev/parity-differences.md
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
require_file tests/fixtures/config-precedence/ari-lint.rules
require_file tests/fixtures/config-precedence/explicit-config.rules
require_file tests/fixtures/config-precedence/command-line-overrides.txt
require_file tests/fixtures/config-precedence/invalid.rules
require_file tests/fixtures/parity/compiler-ok.sh
require_file tests/fixtures/parity/compiler-diagnostic.sh
require_file tests/fixtures/parity/empty.rules
require_file tests/golden/config/cli-last-trailing-whitespace-error.json
require_file tests/golden/config/explicit-missing-final-newline.json
require_file tests/golden/config/explicit-missing-final-newline.txt
require_file tests/golden/config/explicit-off-trailing-whitespace.json
require_file tests/golden/compiler-boundary/diagnostic-native.json
require_file tests/golden/compiler-boundary/diagnostic-native.txt
require_file tests/golden/native/clean.json
require_file tests/golden/native/trailing-whitespace.json
require_file tests/golden/native/missing-final-newline.json
require_file tests/golden/native/ordered-multi-file-duplicate.json
require_file tests/golden/list-rules/standalone-human.txt
require_file tests/golden/list-rules/standalone.json
require_file tests/golden/list-rules/reference-human.txt
require_file examples/README.md
require_file tests/README.md
require_file scripts/README.md
require_file scripts/build.sh
require_file scripts/smoke.sh
require_file scripts/parity.sh
require_file scripts/parity-strict.sh
require_file scripts/test.sh
require_file .github/workflows/check.yml
require_file .github/workflows/compiler-smoke.yml

require_fixed_line ".github/workflows/*.yml text eol=lf" .gitattributes

# These workflows are deliberately small and security-sensitive. Whole-file
# pins make added steps, permission changes, and trigger re-parenting explicit
# review events instead of relying only on independent lexical assertions.
require_sha256 "918a40ab52a1ad1fa23be19f2dac8c9a68eeae83a158db74a0af33c76ea0d47e" .github/workflows/check.yml
require_sha256 "c73d553cda57fc9c7d3ba329e40a6b32bd262243a4fd4ad59fcc6e0d34f04524" .github/workflows/compiler-smoke.yml

require_grep "compiler-free" .github/workflows/check.yml
require_grep "scripts/test.sh" .github/workflows/check.yml
require_grep "ubuntu-24.04" .github/workflows/check.yml
require_grep "permissions:" .github/workflows/check.yml
require_grep "contents: read" .github/workflows/check.yml
require_grep "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1" .github/workflows/check.yml
require_fixed_line "        uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1" .github/workflows/check.yml
require_grep "persist-credentials: false" .github/workflows/check.yml
require_fixed_line "  pull_request:" .github/workflows/check.yml
require_fixed_line "  push:" .github/workflows/check.yml
require_fixed_line "    branches: [main]" .github/workflows/check.yml
require_no_grep "scripts/check.sh" .github/workflows/check.yml
require_no_grep "scripts/smoke.sh" .github/workflows/check.yml
require_no_grep "scripts/build.sh" .github/workflows/check.yml
require_no_grep "ari --check" .github/workflows/check.yml
require_no_grep "ARI_COMPILER" .github/workflows/check.yml
require_no_grep "tools/lint" .github/workflows/check.yml
require_no_grep "npm " .github/workflows/check.yml
require_no_grep "cargo " .github/workflows/check.yml
require_no_grep "arix" .github/workflows/check.yml
require_no_grep "actions/checkout@v" .github/workflows/check.yml
require_no_grep "pull_request_target" .github/workflows/check.yml
require_no_grep "write-all" .github/workflows/check.yml
require_no_grep "id-token:" .github/workflows/check.yml
require_no_grep "github.token" .github/workflows/check.yml

require_grep "Compiler Smoke" .github/workflows/compiler-smoke.yml
require_grep "ubuntu-24.04" .github/workflows/compiler-smoke.yml
require_grep "timeout-minutes: 20" .github/workflows/compiler-smoke.yml
require_grep "permissions:" .github/workflows/compiler-smoke.yml
require_grep "contents: read" .github/workflows/compiler-smoke.yml
require_grep "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1" .github/workflows/compiler-smoke.yml
require_fixed_line "        uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1" .github/workflows/compiler-smoke.yml
require_grep "persist-credentials: false" .github/workflows/compiler-smoke.yml
require_fixed_line "  pull_request:" .github/workflows/compiler-smoke.yml
require_fixed_line "  push:" .github/workflows/compiler-smoke.yml
require_fixed_line "    branches: [main]" .github/workflows/compiler-smoke.yml
require_grep "ARI_VERSION: v0.1.0" .github/workflows/compiler-smoke.yml
require_grep "ARI_COMMIT: c615f1c2ce1a93835118b4da8867a7f3dfaf991a" .github/workflows/compiler-smoke.yml
require_grep "ARI_TARGET: linux-x86_64" .github/workflows/compiler-smoke.yml
require_grep "ari-v0.1.0-linux-x86_64.tar.gz" .github/workflows/compiler-smoke.yml
require_grep "0af99459eb2ad4ad688ae8ba8e4e3bcce88358bba969f88bff65f5df3ced6da2" .github/workflows/compiler-smoke.yml
require_grep "6a9eaefbbc6aef083496e7d78749ec5e13ef87175301923ee000e45a9824baa6" .github/workflows/compiler-smoke.yml
require_grep "ARI_LLVM_CC: /usr/bin/clang-18" .github/workflows/compiler-smoke.yml
require_grep "LC_ALL: C.UTF-8" .github/workflows/compiler-smoke.yml
require_grep "--retry-all-errors" .github/workflows/compiler-smoke.yml
require_grep "--proto '=https'" .github/workflows/compiler-smoke.yml
require_grep "--proto-redir '=https'" .github/workflows/compiler-smoke.yml
require_grep "mktemp -d" .github/workflows/compiler-smoke.yml
require_grep "umask 077" .github/workflows/compiler-smoke.yml
require_grep "sha256sum --check" .github/workflows/compiler-smoke.yml
require_grep "--no-same-owner --no-same-permissions" .github/workflows/compiler-smoke.yml
require_grep "BUILDINFO" .github/workflows/compiler-smoke.yml
require_grep "share/ari/lib/std.arih" .github/workflows/compiler-smoke.yml
require_fixed_line '          printf '\''%s  %s\n'\'' "$ARI_ARCHIVE_SHA256" "$archive" | sha256sum --check -' .github/workflows/compiler-smoke.yml
require_fixed_line '          printf '\''%s  %s\n'\'' "$ARI_BUILDINFO_SHA256" "$buildinfo" | sha256sum --check -' .github/workflows/compiler-smoke.yml
require_fixed_line '          grep -Fx "ari_version=$ARI_VERSION" "$buildinfo"' .github/workflows/compiler-smoke.yml
require_fixed_line '          grep -Fx "git_commit=$ARI_COMMIT" "$buildinfo"' .github/workflows/compiler-smoke.yml
require_fixed_line '          grep -Fx "git_tag=$ARI_VERSION" "$buildinfo"' .github/workflows/compiler-smoke.yml
require_fixed_line '          grep -Fx "target=$ARI_TARGET" "$buildinfo"' .github/workflows/compiler-smoke.yml
require_fixed_line '          printf '\''ARI_COMPILER=%s\n'\'' "$compiler" >> "$GITHUB_ENV"' .github/workflows/compiler-smoke.yml
require_fixed_line '        run: scripts/test.sh "$ARI_COMPILER"' .github/workflows/compiler-smoke.yml
require_line_before '          printf '\''%s  %s\n'\'' "$ARI_ARCHIVE_SHA256" "$archive" | sha256sum --check -' '          tar --extract --gzip --file "$archive" --directory "$extract_dir" \' .github/workflows/compiler-smoke.yml
require_line_before '          tar --extract --gzip --file "$archive" --directory "$extract_dir" \' '          printf '\''%s  %s\n'\'' "$ARI_BUILDINFO_SHA256" "$buildinfo" | sha256sum --check -' .github/workflows/compiler-smoke.yml
require_line_before '          printf '\''%s  %s\n'\'' "$ARI_BUILDINFO_SHA256" "$buildinfo" | sha256sum --check -' '          grep -Fx "ari_version=$ARI_VERSION" "$buildinfo"' .github/workflows/compiler-smoke.yml
require_line_before '          grep -Fx "target=$ARI_TARGET" "$buildinfo"' '          printf '\''ARI_COMPILER=%s\n'\'' "$compiler" >> "$GITHUB_ENV"' .github/workflows/compiler-smoke.yml
require_line_before '          printf '\''ARI_COMPILER=%s\n'\'' "$compiler" >> "$GITHUB_ENV"' '        run: scripts/test.sh "$ARI_COMPILER"' .github/workflows/compiler-smoke.yml
require_grep "GITHUB_ENV" .github/workflows/compiler-smoke.yml
require_grep 'scripts/test.sh "$ARI_COMPILER"' .github/workflows/compiler-smoke.yml
require_no_grep "scripts/check.sh" .github/workflows/compiler-smoke.yml
require_no_grep "scripts/smoke.sh" .github/workflows/compiler-smoke.yml
require_no_grep "scripts/build.sh" .github/workflows/compiler-smoke.yml
require_no_grep "scripts/parity" .github/workflows/compiler-smoke.yml
require_no_grep "tools/lint" .github/workflows/compiler-smoke.yml
require_no_grep "actions/cache" .github/workflows/compiler-smoke.yml
require_no_grep "actions/checkout@v" .github/workflows/compiler-smoke.yml
require_no_grep "pull_request_target" .github/workflows/compiler-smoke.yml
require_no_grep "secrets\." .github/workflows/compiler-smoke.yml
require_no_grep "secrets\[" .github/workflows/compiler-smoke.yml
require_no_grep "github.token" .github/workflows/compiler-smoke.yml
require_no_grep "write-all" .github/workflows/compiler-smoke.yml
require_no_grep "id-token:" .github/workflows/compiler-smoke.yml
require_no_grep "sudo " .github/workflows/compiler-smoke.yml
require_no_grep "apt-get" .github/workflows/compiler-smoke.yml
require_no_grep "npm " .github/workflows/compiler-smoke.yml
require_no_grep "cargo " .github/workflows/compiler-smoke.yml
require_no_grep "arix" .github/workflows/compiler-smoke.yml

[ -x scripts/build.sh ] || fail "scripts/build.sh is not executable"
[ -x scripts/smoke.sh ] || fail "scripts/smoke.sh is not executable"
[ -x scripts/parity.sh ] || fail "scripts/parity.sh is not executable"
[ -x scripts/parity-strict.sh ] || fail "scripts/parity-strict.sh is not executable"
[ -x tests/fixtures/parity/compiler-ok.sh ] || fail "parity fixture compiler is not executable"
[ -x tests/fixtures/parity/compiler-diagnostic.sh ] || fail "diagnostic parity compiler is not executable"
[ -x scripts/test.sh ] || fail "scripts/test.sh is not executable"

require_grep "strict native parity goldens passed" scripts/parity-strict.sh
require_grep "strict explicit-config parity goldens passed" scripts/parity-strict.sh
require_grep "strict compiler-boundary parity goldens passed" scripts/parity-strict.sh
require_grep "strict list-rules contract goldens passed" scripts/parity-strict.sh
require_grep "list-rules-json" scripts/parity-strict.sh
require_grep "reference-human.txt" scripts/parity-strict.sh
require_grep "metadata_sentinel_marker" scripts/parity-strict.sh
require_grep "unexpectedly invoked the Ari compiler" scripts/parity-strict.sh
require_grep "ordered-multi-file-duplicate" scripts/parity-strict.sh
require_grep "--config" scripts/parity-strict.sh
require_grep "compiler-ok.sh" scripts/parity-strict.sh
require_grep "compiler-diagnostic.sh" scripts/parity-strict.sh
require_grep "diagnostic-native.json" scripts/parity-strict.sh
require_grep "diagnostic-native.txt" scripts/parity-strict.sh
require_grep "explicit-config-missing-final-newline-json" scripts/parity-strict.sh
require_grep "explicit-config-missing-final-newline-human" scripts/parity-strict.sh
require_grep "explicit-off-trailing-whitespace" scripts/parity-strict.sh
require_grep "cli-last-trailing-whitespace-error" scripts/parity-strict.sh
require_fixed_grep '--config "$selected_config"' scripts/parity-strict.sh
require_fixed_grep '--rule trailing-whitespace=error' scripts/parity-strict.sh
require_grep "cmp -s" scripts/parity-strict.sh
require_grep "python3" scripts/parity-strict.sh
require_grep "exit 0" tests/fixtures/parity/compiler-ok.sh
require_no_grep "tools/lint" tests/fixtures/parity/compiler-ok.sh
require_grep 'expected_source="tests/fixtures/trailing-whitespace/trailing-spaces.ari"' tests/fixtures/parity/compiler-diagnostic.sh
require_grep '"\$#" -ne 2' tests/fixtures/parity/compiler-diagnostic.sh
require_fixed_grep '"$1" != "$expected_source"' tests/fixtures/parity/compiler-diagnostic.sh
require_grep '"\$2" != "--check"' tests/fixtures/parity/compiler-diagnostic.sh
require_grep "ari: error.E1.: fake.ari:2:3: compiler first" tests/fixtures/parity/compiler-diagnostic.sh
require_grep "exit 7" tests/fixtures/parity/compiler-diagnostic.sh
require_no_grep "tools/lint" tests/fixtures/parity/compiler-diagnostic.sh

require_grep "explicit-config" scripts/parity.sh
require_grep "config-short-name" scripts/parity.sh
require_grep "config-off" scripts/parity.sh
require_grep "short_config_file" scripts/parity.sh
require_grep "off_config_file" scripts/parity.sh
require_grep "case: help" scripts/parity.sh
require_grep "case: short-help" scripts/parity.sh
require_grep "case: no-source-file" scripts/parity.sh
require_grep "case: read-error" scripts/parity.sh
require_grep "case: multi-file-read-error" scripts/parity.sh
require_grep "case: missing-compiler" scripts/parity.sh
require_grep "case: compiler-error" scripts/parity.sh
require_grep "case: unknown-argument" scripts/parity.sh
require_grep "case: missing-config-value" scripts/parity.sh
require_grep "case: missing-rule-value" scripts/parity.sh
require_grep "case: missing-ari-value" scripts/parity.sh
require_grep "case: missing-include-value" scripts/parity.sh
require_grep "list-rules" scripts/parity.sh
require_grep "case: json-list-rules" scripts/parity.sh
require_grep "case: config-read-error" scripts/parity.sh
require_grep "case: invalid-config" scripts/parity.sh
require_grep "case: invalid-rule-override" scripts/parity.sh
require_grep "case: invalid-rule-severity" scripts/parity.sh
require_grep "case: unknown-rule-override" scripts/parity.sh
require_grep "rule-override" scripts/parity.sh
require_grep "rule-off" scripts/parity.sh
require_grep "multi-file-config-rule" scripts/parity.sh
require_grep "include-path" scripts/parity.sh
require_grep "discovered-config" scripts/parity.sh
require_grep "multi-file-discovered-config" scripts/parity.sh
require_grep "multi-file-discovered-rule" scripts/parity.sh
require_grep "multi-file" scripts/parity.sh
require_grep "multi-file-mixed" scripts/parity.sh
require_grep "file_paths_present" scripts/parity.sh
require_grep "source_file_text_in_stderr" scripts/parity.sh
require_grep "file_operand_in_stderr" scripts/parity.sh
require_grep "unable_to_read_source_text_in_stderr" scripts/parity.sh
require_grep "unable_to_read_multiple_sources_text_in_stderr" scripts/parity.sh
require_grep "cannot_open_input_file_text_in_stdout" scripts/parity.sh
require_grep "ari_compiler_code_in_stdout" scripts/parity.sh
require_grep "compiler_check_failed_code_in_stdout" scripts/parity.sh
require_grep "exec_failed_text_in_stdout" scripts/parity.sh
require_grep "missing_compiler_path_in_stdout" scripts/parity.sh
require_grep "expected_top_level_declaration_text_in_stdout" scripts/parity.sh
require_grep "aligned native runtime contract" scripts/parity.sh
require_grep "unable_to_read_config_text_in_stderr" scripts/parity.sh
require_grep "cannot_open_lint_config_text_in_stderr" scripts/parity.sh
require_grep "unknown_argument_text_in_stderr" scripts/parity.sh
require_grep "missing_option_value_text_in_stderr" scripts/parity.sh
require_grep "unknown_rule_or_severity_text_in_stderr" scripts/parity.sh
require_grep "config_path_in_stderr" scripts/parity.sh
require_grep "invalid_rule_override_text_in_stderr" scripts/parity.sh
require_grep "invalid_rule_setting_text_in_stderr" scripts/parity.sh
require_grep "trailing-whitespace=loud" scripts/parity.sh
require_grep "unknown-rule=warning" scripts/parity.sh
require_grep "rule_option_in_stderr" scripts/parity.sh
require_grep "ari_option_in_stderr" scripts/parity.sh
require_grep "include_option_in_stderr" scripts/parity.sh
require_grep "severity_note_present" scripts/parity.sh
require_grep "ari-lint Known Parity Differences" docs/dev/parity-differences.md
require_grep "Compiler Output Cross-Stream Ordering" docs/dev/parity-differences.md
require_grep "retention boundary" docs/dev/parity-differences.md
require_grep "Compiler Output Capture Boundary" docs/dev/parity-differences.md
require_grep "Compiler Diagnostic Material Boundary" docs/dev/parity-differences.md
require_grep "exactly five" docs/dev/parity-differences.md
require_grep "Process Capture Infrastructure Errors" docs/dev/parity-differences.md
require_grep "Compiler Stdin Policy" docs/dev/parity-differences.md
require_grep "Out-Of-Range Compiler Coordinates" docs/dev/parity-differences.md
require_grep "Inline Ari Compiler Option" docs/dev/parity-differences.md
require_grep "End-Of-Options Separator" docs/dev/parity-differences.md
require_grep "same top-level .files. JSON" docs/dev/parity-differences.md
require_grep "exit .1. for enabled lint diagnostics" docs/dev/parity-differences.md
require_grep "Help Output Stream And Shape" docs/dev/parity-differences.md
require_grep "No Source File Usage Text" docs/dev/parity-differences.md
require_grep "exitCode. .127" docs/dev/parity-differences.md
require_grep "aligned compiler runtime signals" scripts/parity.sh
require_grep "concatenates stderr then stdout" scripts/parity.sh
require_grep "Non-UTF-8 JSON Bytes" docs/dev/parity-differences.md
require_grep "Unknown Option Usage Text" docs/dev/parity-differences.md
require_grep "Missing Config Value Usage Text" docs/dev/parity-differences.md
require_grep "Config Read Error Output" docs/dev/parity-differences.md
require_grep "Invalid Config Output Text" docs/dev/parity-differences.md
require_grep "Invalid Rule Override Usage Text" docs/dev/parity-differences.md
require_grep "Invalid Rule Severity Usage Text" docs/dev/parity-differences.md
require_grep "Unknown Rule Override Usage Text" docs/dev/parity-differences.md
require_grep "Missing Rule Value Usage Text" docs/dev/parity-differences.md
require_grep "Missing Ari Value Usage Text" docs/dev/parity-differences.md
require_grep "Missing Include Value Usage Text" docs/dev/parity-differences.md
require_grep "List Rules Output Detail" docs/dev/parity-differences.md
require_grep "No Ari language/compiler/stdlib/toolchain bug" docs/dev/parity-differences.md
require_grep "docs/dev/parity-differences.md" docs/dev/parity-test-plan.md
require_fixed_grep '- [x] Add an initial deterministic compiler-boundary parity fixture with exact' docs/dev/parity-test-plan.md
require_grep "tests/golden/compiler-boundary/" docs/dev/parity-test-plan.md
require_fixed_grep '- [x] Add an initial strict explicit-config severity, `off`, and CLI-last' docs/dev/parity-test-plan.md
require_grep "tests/golden/config/" docs/dev/parity-test-plan.md
require_grep "deterministic fake-compiler boundary case" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/parity-differences.md" tests/README.md
require_grep "tests/golden/compiler-boundary/" tests/README.md
require_grep "tests/golden/config/" tests/README.md
require_grep "report-only config, .--rule., discovered config" docs/dev/ari-implementation-plan.md
require_grep "explicit .--config." docs/dev/parity-test-plan.md
require_grep "no-source-file usage" scripts/README.md
require_grep "source read-error behavior" scripts/README.md
require_grep "missing compiler path behavior" scripts/README.md
require_grep "compiler-error behavior" scripts/README.md
require_grep "config-read-error" scripts/README.md
require_grep "short-help" scripts/README.md
require_grep "unknown-argument usage" scripts/README.md
require_grep "missing config value usage" scripts/README.md
require_grep "invalid config" scripts/README.md
require_grep "invalid rule override" scripts/README.md
require_grep "invalid rule severity" scripts/README.md
require_grep "unknown rule override" scripts/README.md
require_grep "missing rule value usage" scripts/README.md
require_grep "missing ari value usage" scripts/README.md
require_grep "missing include value usage" scripts/README.md
require_grep "config-short-name" scripts/README.md
require_grep "config-off" scripts/README.md
require_grep "rule-off" scripts/README.md
require_grep "include-path" scripts/README.md
require_grep "multi-file-mixed" scripts/README.md
require_grep "JSON list-rules" scripts/README.md
require_grep "discovered-config, multi-file, and" scripts/README.md
require_grep "multi-file-mixed" docs/dev/parity-test-plan.md
require_grep "multi-file-mixed" docs/dev/parity-differences.md

require_grep "build.sh" scripts/smoke.sh
require_grep "ARI_COMPILER" scripts/smoke.sh
require_no_grep "ari --check" scripts/smoke.sh
require_no_grep "tools/lint" scripts/smoke.sh
require_grep "./build/ari-lint --help" README.md
require_grep "./build/ari-lint --list-rules" README.md
require_grep "./build/ari-lint --json --list-rules" README.md
require_grep "./build/ari-lint --json --config" README.md
require_grep "./build/ari-lint --json /tmp/.../one.ari /tmp/.../two.ari" README.md
require_grep "--rule trailing-whitespace=note" README.md
require_grep "short rule names in explicit config" README.md
require_grep "disabled rules from explicit config" README.md
require_grep "and CLI .--rule." README.md
require_grep "--config" scripts/smoke.sh
require_grep "run_stdout_success_smoke" scripts/smoke.sh
require_grep "run_stderr_usage_smoke" scripts/smoke.sh
require_grep "run_stderr_unavailable_smoke" scripts/smoke.sh
require_grep "require_text_grep" scripts/smoke.sh
require_grep "missing_compiler_path" scripts/smoke.sh
require_grep "newline_compiler_path" scripts/smoke.sh
require_grep "non_executable_compiler_path" scripts/smoke.sh
require_grep "sentinel_compiler_marker" scripts/smoke.sh
require_grep '"exitCode":127' scripts/smoke.sh
require_grep '"code":"ari/compiler-check-failed"' scripts/smoke.sh
require_grep "ari-tooling: exec failed:" scripts/smoke.sh
require_grep "compiler-large-output.ari" scripts/smoke.sh
require_grep "compiler-large-suppressed.ari" scripts/smoke.sh
require_grep "compiler-late-diagnostic.ari" scripts/smoke.sh
require_grep "compiler-early-and-late.ari" scripts/smoke.sh
require_grep "compiler-many-diagnostics.ari" scripts/smoke.sh
require_grep "compiler-limit-2048.ari" scripts/smoke.sh
require_grep "compiler-limit-2049.ari" scripts/smoke.sh
require_grep "compiler-global-limit" scripts/smoke.sh
require_grep "compiler-large-lines.ari" scripts/smoke.sh
require_grep "compiler-embedded-cr.ari" scripts/smoke.sh
require_grep '"code":"ari/compiler-output-truncated"' scripts/smoke.sh
require_grep '"code":"ari/compiler-diagnostics-truncated"' scripts/smoke.sh
require_grep "expected source command to invoke sentinel compiler" scripts/smoke.sh
require_grep "list_rules_output" scripts/smoke.sh
require_grep "json_list_rules_output" scripts/smoke.sh
require_grep "Reports spaces or tabs at the end of a source line." scripts/smoke.sh
require_grep "Reports non-empty source files that do not end with a newline." scripts/smoke.sh
require_grep "invalid --rule override" src/cli.ari
require_grep "missing option value for" src/cli.ari
require_grep "unknown argument:" src/cli.ari
require_grep "--rule RULE=SEVERITY" scripts/smoke.sh
require_grep "missing option value for --config" scripts/smoke.sh
require_grep "missing option value for --rule" scripts/smoke.sh
require_grep "missing option value for --ari" scripts/smoke.sh
require_grep "--ari=" scripts/smoke.sh
require_grep "inline_ari_output" scripts/smoke.sh
require_grep "unknown argument: --definitely-unknown" scripts/smoke.sh
require_grep "--config PATH" src/cli.ari
require_grep "run_json_diagnostic_smoke" scripts/smoke.sh
require_grep "run_json_success_smoke" scripts/smoke.sh
require_grep "require_json_document" scripts/smoke.sh
require_grep "require_final_newline" scripts/smoke.sh
require_grep "python3 -c" scripts/smoke.sh
require_fixed_grep 'json.JSONDecoder(parse_constant=reject_constant).raw_decode(text)' scripts/smoke.sh
require_grep "expected strict JSON validation to reject NaN" scripts/smoke.sh
require_fixed_grep 'require_json_document "$json_list_rules_output"' scripts/smoke.sh
require_grep "ari/compiler-check-failed.*compiler check failed" scripts/smoke.sh
require_grep "ari/compiler-check-failed.*plain noise" scripts/smoke.sh
require_grep "expected empty stdout" scripts/smoke.sh
require_grep "missing_source_output" scripts/smoke.sh
require_grep "json_missing_source_output" scripts/smoke.sh
require_grep '"severity":"error"' scripts/smoke.sh
require_grep '"severity":"note"' scripts/smoke.sh
require_grep '"severity":"warning"' scripts/smoke.sh
require_grep "trailing-whitespace = error" scripts/smoke.sh
require_grep "trailing-whitespace = off" scripts/smoke.sh
require_grep "trailing-whitespace=off" scripts/smoke.sh
require_grep "config_off_output" scripts/smoke.sh
require_grep "rule_off_output" scripts/smoke.sh
require_grep "missing-final-newline = warning" scripts/smoke.sh
require_grep "discovery_parent" scripts/smoke.sh
require_grep "discovery_child" scripts/smoke.sh
require_grep "nearest_discovery_output" scripts/smoke.sh
require_grep "multi_dirty_one" scripts/smoke.sh
require_grep "multi_dirty_two" scripts/smoke.sh
require_grep "multi_expected" scripts/smoke.sh
require_grep "stress_path_count" scripts/smoke.sh
require_grep "invalid_utf8_path_output" scripts/smoke.sh
require_grep "expected empty stderr" scripts/smoke.sh
require_grep "clean_source_two" scripts/smoke.sh
require_grep "clean_output" scripts/smoke.sh
require_grep "mixed_output" scripts/smoke.sh
require_grep "require_json_no_grep" scripts/smoke.sh
require_grep "field_config_file" scripts/smoke.sh
require_grep "trailing_field_output" scripts/smoke.sh
require_grep "missing_final_newline_field_output" scripts/smoke.sh
require_grep '"message":"trailing whitespace"' scripts/smoke.sh
require_grep '"message":"missing final newline"' scripts/smoke.sh
require_grep '"line":1' scripts/smoke.sh
require_grep '"column":2' scripts/smoke.sh
require_grep "ari-lint.rules" scripts/smoke.sh
require_grep "scripts/smoke.sh" docs/dev/ari-implementation-plan.md
require_grep "local smoke validation added" docs/dev/roadmap.md
require_grep "minimal config override smoke coverage added" docs/dev/roadmap.md
require_grep "current-directory config discovery added" docs/dev/roadmap.md
require_grep "parent-directory config discovery added" docs/dev/roadmap.md
require_grep "multi-file source linting added" docs/dev/roadmap.md
require_grep "focused diagnostic field smoke coverage added" docs/dev/roadmap.md
require_grep "focused list-rules output assertions" docs/dev/roadmap.md
require_grep "scripts/smoke.sh" tests/README.md

require_grep "repo_root" scripts/test.sh
require_grep "scripts/check.sh" scripts/test.sh
require_grep "scripts/smoke.sh" scripts/test.sh
require_grep "usage: scripts/test.sh" scripts/test.sh
require_grep "Ari compiler path must not be empty" scripts/test.sh
require_no_grep "ari --check" scripts/test.sh
require_no_grep "ARI_COMPILER" scripts/test.sh
require_no_grep "tools/lint" scripts/test.sh
require_no_grep "scripts/build.sh" scripts/test.sh
require_no_grep "scripts/parity" scripts/test.sh
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
require_file src/compiler.ari
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

unexpected_config_precedence_fixture=$(find tests/fixtures/config-precedence -type f ! -name ari-lint.rules ! -name explicit-config.rules ! -name command-line-overrides.txt ! -name invalid.rules -print -quit)
[ -z "$unexpected_config_precedence_fixture" ] || fail "unexpected config-precedence fixture: $unexpected_config_precedence_fixture"

unexpected_parity_fixture=$(find tests/fixtures/parity -type f ! -name compiler-ok.sh ! -name compiler-diagnostic.sh ! -name empty.rules -print -quit)
[ -z "$unexpected_parity_fixture" ] || fail "unexpected parity fixture: $unexpected_parity_fixture"

unexpected_compiler_golden=$(find tests/golden/compiler-boundary -type f ! -name diagnostic-native.json ! -name diagnostic-native.txt -print -quit)
[ -z "$unexpected_compiler_golden" ] || fail "unexpected compiler-boundary golden: $unexpected_compiler_golden"

unexpected_config_golden=$(find tests/golden/config -type f ! -name cli-last-trailing-whitespace-error.json ! -name explicit-missing-final-newline.json ! -name explicit-missing-final-newline.txt ! -name explicit-off-trailing-whitespace.json -print -quit)
[ -z "$unexpected_config_golden" ] || fail "unexpected config golden: $unexpected_config_golden"

unexpected_native_golden=$(find tests/golden/native -type f ! -name clean.json ! -name trailing-whitespace.json ! -name missing-final-newline.json ! -name ordered-multi-file-duplicate.json -print -quit)
[ -z "$unexpected_native_golden" ] || fail "unexpected native golden: $unexpected_native_golden"

unexpected_list_rules_golden=$(find tests/golden/list-rules -type f ! -name standalone-human.txt ! -name standalone.json ! -name reference-human.txt -print -quit)
[ -z "$unexpected_list_rules_golden" ] || fail "unexpected list-rules golden: $unexpected_list_rules_golden"

require_no_grep '[[:blank:]]$' tests/fixtures/trailing-whitespace/clean.ari
require_grep '[[:blank:]]$' tests/fixtures/trailing-whitespace/trailing-spaces.ari
require_final_newline tests/fixtures/missing-final-newline/with-final-newline.ari
require_no_final_newline tests/fixtures/missing-final-newline/missing-final-newline.ari
[ "$(wc -c < tests/fixtures/parity/empty.rules)" -eq 1 ] || fail "expected one blank line in empty parity config"
require_final_newline tests/fixtures/parity/empty.rules
require_final_newline tests/golden/config/cli-last-trailing-whitespace-error.json
require_final_newline tests/golden/config/explicit-missing-final-newline.json
require_final_newline tests/golden/config/explicit-missing-final-newline.txt
require_final_newline tests/golden/config/explicit-off-trailing-whitespace.json
require_final_newline tests/golden/compiler-boundary/diagnostic-native.json
require_final_newline tests/golden/compiler-boundary/diagnostic-native.txt
require_final_newline tests/golden/native/clean.json
require_final_newline tests/golden/native/trailing-whitespace.json
require_final_newline tests/golden/native/missing-final-newline.json
require_final_newline tests/golden/native/ordered-multi-file-duplicate.json
require_final_newline tests/golden/list-rules/standalone-human.txt
require_final_newline tests/golden/list-rules/standalone.json
require_final_newline tests/golden/list-rules/reference-human.txt
require_grep '"diagnostics":\[\]' tests/golden/native/clean.json
require_grep '"exitCode":7' tests/golden/compiler-boundary/diagnostic-native.json
require_grep '"file":"fake.ari"' tests/golden/compiler-boundary/diagnostic-native.json
require_grep '"code":"E1"' tests/golden/compiler-boundary/diagnostic-native.json
require_grep '"code":"lint/trailing-whitespace"' tests/golden/compiler-boundary/diagnostic-native.json
require_grep 'fake.ari:2:3: error: \[E1\] compiler first' tests/golden/compiler-boundary/diagnostic-native.txt
require_grep 'warning: \[lint/trailing-whitespace\] trailing whitespace' tests/golden/compiler-boundary/diagnostic-native.txt
require_grep '"severity":"error"' tests/golden/config/cli-last-trailing-whitespace-error.json
require_grep '"code":"lint/trailing-whitespace"' tests/golden/config/cli-last-trailing-whitespace-error.json
require_grep '"severity":"error"' tests/golden/config/explicit-missing-final-newline.json
require_grep '"code":"lint/missing-final-newline"' tests/golden/config/explicit-missing-final-newline.json
require_grep 'error: \[lint/missing-final-newline\] missing final newline' tests/golden/config/explicit-missing-final-newline.txt
require_grep '"path":"tests/fixtures/trailing-whitespace/trailing-spaces.ari"' tests/golden/config/explicit-off-trailing-whitespace.json
require_grep '"diagnostics":\[\]' tests/golden/config/explicit-off-trailing-whitespace.json
require_grep '"code":"lint/trailing-whitespace"' tests/golden/native/trailing-whitespace.json
require_grep '"code":"lint/missing-final-newline"' tests/golden/native/missing-final-newline.json
require_grep '"path":"tests/fixtures/trailing-whitespace/trailing-spaces.ari"' tests/golden/native/ordered-multi-file-duplicate.json
require_grep 'name=trailing-whitespace' tests/golden/list-rules/standalone-human.txt
require_grep '"ruleCode":"lint/trailing-whitespace"' tests/golden/list-rules/standalone.json
require_grep '"name":"missing-final-newline"' tests/golden/list-rules/standalone.json
require_no_grep 'name=' tests/golden/list-rules/reference-human.txt
require_grep "lint/trailing-whitespace = off" tests/fixtures/config-precedence/ari-lint.rules
require_grep "lint/missing-final-newline = warning" tests/fixtures/config-precedence/ari-lint.rules
require_grep "explicit --config" tests/fixtures/config-precedence/explicit-config.rules
require_grep "lint/missing-final-newline = error" tests/fixtures/config-precedence/explicit-config.rules
require_grep "trailing-whitespace=warning" tests/fixtures/config-precedence/command-line-overrides.txt
require_grep "lint/trailing-whitespace=error" tests/fixtures/config-precedence/command-line-overrides.txt
require_grep "missing-final-newline=off" tests/fixtures/config-precedence/command-line-overrides.txt
require_grep "lint/unknown-rule = warning" tests/fixtures/config-precedence/invalid.rules
require_grep "lint/trailing-whitespace = loud" tests/fixtures/config-precedence/invalid.rules
require_line_equals tests/fixtures/config-precedence/ari-lint.rules 2 "lint/trailing-whitespace = off"
require_line_equals tests/fixtures/config-precedence/ari-lint.rules 3 "lint/missing-final-newline = warning"
require_line_equals tests/fixtures/config-precedence/explicit-config.rules 3 "lint/trailing-whitespace = warning"
require_line_equals tests/fixtures/config-precedence/explicit-config.rules 4 "lint/missing-final-newline = error"
require_line_equals tests/fixtures/config-precedence/command-line-overrides.txt 2 "trailing-whitespace=warning"
require_line_equals tests/fixtures/config-precedence/command-line-overrides.txt 3 "lint/trailing-whitespace=error"
require_line_equals tests/fixtures/config-precedence/command-line-overrides.txt 4 "missing-final-newline=off"
require_line_equals tests/fixtures/config-precedence/invalid.rules 2 "lint/unknown-rule = warning"
require_line_equals tests/fixtures/config-precedence/invalid.rules 3 "lint/trailing-whitespace = loud"

require_grep "active standalone split implementation" README.md
require_grep "Current Capabilities" README.md
require_grep "Current Limitations" README.md
require_grep "remains the reference implementation" README.md
require_grep "https://github.com/ari-foundry/ari" README.md
require_grep "https://github.com/ari-foundry/ari/releases" README.md
require_grep "https://github.com/ari-foundry/ari/tags" README.md
require_grep "https://ari-foundry.github.io" README.md
require_grep "implementation is written in Ari" README.md
require_grep "Ari" README.md
require_grep "scripts/check.sh" README.md
require_grep "scripts/test.sh" README.md
require_grep "scripts/build.sh" README.md
require_grep "not a complete unit/parity suite" README.md
require_grep "explicit Ari compiler path" README.md
require_grep "Local build via" README.md
require_grep "Local smoke validation via" README.md
require_grep "all explicitly provided positional source files" README.md
require_grep "Focused diagnostic" README.md
require_grep "docs/diagnostics.md" README.md
require_grep "local standalone test entrypoint" README.md
require_grep "relative compiler paths" README.md
require_grep "docs/migration.md" docs/README.md
require_fixed_grep '[Features](features.md)' docs/README.md
require_fixed_grep '[Configuration](config.md)' docs/README.md
require_fixed_grep '[Rules](rules.md)' docs/README.md
require_grep "docs/diagnostics.md" docs/README.md
require_grep "docs/list-rules.md" docs/README.md
require_grep "docs/dev/ari-implementation-plan.md" docs/README.md
require_grep "docs/dev/compiler-invocation.md" docs/README.md
require_grep "docs/dev/compiler-provisioning.md" docs/README.md
require_grep "docs/dev/release-compatibility-policy.md" docs/README.md
require_grep "docs/rules/trailing-whitespace.md" docs/README.md
require_grep "docs/rules/missing-final-newline.md" docs/README.md
require_grep "docs/dev/ari-implementation-plan.md" docs/dev/roadmap.md
require_grep "docs/dev/parity-test-plan.md" docs/dev/roadmap.md
require_grep "docs/dev/parity-test-plan.md" tests/README.md
require_grep "scripts/parity-strict.sh" README.md
require_grep "parity-strict.sh" scripts/README.md
require_grep "scripts/parity-strict.sh" tests/README.md
require_grep "scripts/parity-strict.sh" docs/dev/parity-test-plan.md
require_grep "strict native parity goldens and runner added" docs/dev/roadmap.md
require_grep "c615f1c2ce1a93835118b4da8867a7f3dfaf991a" tests/README.md
require_grep "ari-lint List-Rules Contract" docs/list-rules.md
require_grep "tests/golden/list-rules/" docs/list-rules.md
require_grep "intentional CLI contracts" docs/list-rules.md
require_grep "docs/list-rules.md" docs/dev/parity-differences.md
require_grep "standalone list-rules contract and strict goldens added" docs/dev/roadmap.md
require_grep "source diagnostic output contract published" docs/dev/roadmap.md
require_grep "Do not invent compatibility claims" docs/migration.md
require_fixed_grep '- [x] Adapt `docs/lint/features.md` into `ari-lint` `docs/features.md`' docs/migration.md
require_fixed_grep '- [x] Adapt `docs/lint/README.md` into `ari-lint` README/docs entry points' docs/migration.md
require_fixed_grep '- [x] Split config documentation into `docs/config.md`' docs/migration.md
require_fixed_grep '- [x] Split diagnostics documentation into `docs/diagnostics.md`' docs/migration.md
require_fixed_grep '- [x] Split rule reference into `docs/rules.md`' docs/migration.md
require_fixed_grep '- [ ] Update the upstream handoff wording after local user docs are primary' docs/migration.md
require_fixed_grep '- [ ] Update Ari Foundry portal after docs are usable (separate portal PR)' docs/migration.md
require_grep "ari-lint Features" docs/features.md
require_grep "Explicit Source Checks" docs/features.md
require_fixed_grep '-I DIR ... SOURCE --check' docs/features.md
require_grep "ARI_COMPILER" docs/features.md
require_fixed_grep '`--` treats every following token as a source operand.' docs/features.md
require_fixed_grep '[Configuration](config.md)' docs/features.md
require_fixed_grep '[the rule reference](rules.md)' docs/features.md
require_fixed_grep '[Diagnostic Output](diagnostics.md)' docs/features.md
require_grep "ari-lint Configuration" docs/config.md
require_grep "File Format" docs/config.md
require_grep "Discovery And Selection" docs/config.md
require_grep "nearest readable" docs/config.md
require_fixed_grep 'A selected directory named `ari-lint.rules` is treated as an empty config and' docs/config.md
require_fixed_grep 'masks higher candidates. Likewise, an explicit directory path is treated as an' docs/config.md
require_grep "Home, global, XDG" docs/config.md
require_grep "Precedence" docs/config.md
require_grep "Invalid Configuration" docs/config.md
require_grep "lint/config" docs/config.md
require_fixed_grep 'An explicit `--config PATH` or `--config=PATH` applies the same file to every' docs/config.md
require_fixed_grep '- Severity names are the exact lowercase values `off`, `hint`, `note`,' docs/config.md
require_fixed_grep '1. the registry default' docs/config.md
require_fixed_grep '2. settings from the selected discovered or explicit config file' docs/config.md
require_fixed_grep '3. command-line `--rule` settings, in command-line order' docs/config.md
require_grep "ari-lint Rules" docs/rules.md
require_fixed_grep '| `lint/trailing-whitespace` | `trailing-whitespace` | `warning` | Reports spaces or tabs at the end of a source line. |' docs/rules.md
require_fixed_grep '| `lint/missing-final-newline` | `missing-final-newline` | `warning` | Reports non-empty source files that do not end with a newline. |' docs/rules.md
require_grep "Severity Control" docs/rules.md
require_grep "Diagnostic Order And Status" docs/rules.md
require_grep "ari/compiler-check-failed" docs/rules.md
require_fixed_grep '[the list-rules contract](list-rules.md)' docs/rules.md
require_grep "docs/features.md" README.md
require_grep "docs/config.md" README.md
require_grep "docs/rules.md" README.md
require_grep "Ari-language implementation source is active" AGENTS.md
require_grep "Standalone build, checks, smoke, parity" AGENTS.md
require_grep "release-compatibility-policy.md" AGENTS.md
require_no_grep "implementation source has not been added yet" AGENTS.md
require_no_grep "docs migration from ari-foundry/ari has not happened yet" AGENTS.md
require_no_grep "standalone build/test wiring has not happened yet" AGENTS.md
require_grep "standalone CLI is wired" examples/README.md
require_grep "./build/ari-lint --ari" examples/README.md
require_grep "./build/ari-lint --json --ari" examples/README.md
require_grep "placeholder, not an Ari-language example" examples/README.md
require_no_grep "Examples will be added after source extraction" examples/README.md
require_no_grep "standalone .ari-lint. CLI is not wired" examples/README.md
require_grep "Diagnostic Output Contract" docs/diagnostics.md
require_grep "JSON Source Result" docs/diagnostics.md
require_grep "Diagnostic Ordering" docs/diagnostics.md
require_grep "Encoding And Termination" docs/diagnostics.md
require_grep "Streams And Top-Level Status" docs/diagnostics.md
require_grep "exitCode" docs/diagnostics.md
require_grep "not the top-level .ari-lint. status" docs/diagnostics.md
require_grep "exactly one final LF" docs/diagnostics.md
require_grep "invalid UTF-8 byte as" docs/diagnostics.md
require_grep "retained stderr bytes followed" docs/diagnostics.md
require_grep "retained complete-line" docs/diagnostics.md
require_grep "exceptional fallback can" docs/diagnostics.md
require_grep "not an .ari-lint. release" docs/diagnostics.md
require_grep "docs/diagnostics.md" docs/dev/ari-implementation-plan.md
require_no_grep "JSON diagnostic schema may still be unstable." docs/dev/ari-implementation-plan.md
require_no_grep "JSON diagnostic schema may still be unstable." docs/dev/parity-test-plan.md
require_no_grep "once.*schema.*stable" docs/rules/trailing-whitespace-fixtures.md
require_no_grep "once.*schema.*stable" docs/rules/missing-final-newline-fixtures.md
require_no_grep "JSON golden tests should wait" docs/dev/compiler-provisioning.md
require_grep "Ari-language implementation" docs/dev/ari-implementation-plan.md
require_grep "compiler bugs belong in ari-foundry/ari" docs/dev/ari-implementation-plan.md
require_grep "standard library bugs belong in ari-foundry/ari" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/compiler-invocation.md" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/compiler-provisioning.md" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/config-precedence-fixtures.md" docs/dev/ari-implementation-plan.md
require_grep "docs/dev/release-compatibility-policy.md" docs/dev/ari-implementation-plan.md
require_grep "ari-lint Config Precedence Fixture Plan" docs/dev/config-precedence-fixtures.md
require_grep "does not add dedicated Ari parser tests" docs/dev/config-precedence-fixtures.md
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
require_grep "short-name config" docs/dev/parity-test-plan.md
require_grep "disabled explicit config" docs/dev/parity-test-plan.md
require_grep "disabled command-line .--rule." docs/dev/parity-test-plan.md
require_grep "disabled explicit config and" docs/dev/parity-differences.md
require_grep "short-name" docs/dev/parity-differences.md
require_grep "tools/lint" docs/dev/parity-test-plan.md
require_grep "docs/dev/compiler-invocation.md" docs/dev/parity-test-plan.md
require_grep "docs/dev/compiler-provisioning.md" docs/dev/parity-test-plan.md
require_grep "Do not add source-controlled test fixtures in this step" docs/dev/parity-test-plan.md
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
require_grep "Do not add a strict parity gate in this step" docs/rules/missing-final-newline-parity.md
require_grep "docs/rules/trailing-whitespace-parity.md" docs/rules/trailing-whitespace.md
require_grep "docs/rules/trailing-whitespace-parity.md" docs/rules/trailing-whitespace-fixtures.md
require_grep "docs/rules/trailing-whitespace-parity.md" docs/dev/parity-test-plan.md
require_grep "docs/rules/trailing-whitespace-parity.md" tests/README.md
require_grep "Do not add a strict parity gate in this step" docs/rules/trailing-whitespace-parity.md
require_grep "local native parity case exist" docs/rules/trailing-whitespace-fixtures.md
require_grep "local native parity case exist" docs/rules/missing-final-newline-fixtures.md
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
require_grep "minimal stderr adapter added" docs/dev/roadmap.md
require_grep "main-facing list-rules stdout output added" docs/dev/roadmap.md
require_grep "main-facing first diagnostic stderr output added" docs/dev/roadmap.md
require_grep "internal diagnostic vector collection added" docs/dev/roadmap.md
require_grep "CLI diagnostic vector collection added" docs/dev/roadmap.md
require_grep "main-facing human diagnostics stderr output added" docs/dev/roadmap.md
require_grep "main-facing source-file JSON stdout output added" docs/dev/roadmap.md
require_grep "main-facing CLI parse problem stderr output added" docs/dev/roadmap.md
require_grep "main-facing CLI help stdout output added" docs/dev/roadmap.md
require_grep "main-facing missing source stderr output added" docs/dev/roadmap.md
require_grep "main-facing file read error stderr output added" docs/dev/roadmap.md
require_grep "run_os_argv_cli_with_main_output" src/cli.ari
require_grep "write_stdout_text" src/cli.ari
require_grep "write_run_result_human_stdout" src/cli.ari
require_grep "write_run_result_json_stdout" src/cli.ari
require_grep "write_cli_parse_problem_stderr" src/cli.ari
require_grep "write_cli_parse_detail_stderr" src/cli.ari
require_grep "parse_explicit_config_file_into_with_error_text" src/cli.ari
require_grep "write_cli_help_stdout" src/cli.ari
require_grep "write_missing_source_stderr" src/cli.ari
require_grep "write_file_read_error_stderr" src/cli.ari
require_grep "write_config_read_error_stderr" src/cli.ari
require_grep "Usage: ari-lint" src/cli.ari
require_grep "invalid command-line arguments" src/cli.ari
require_grep "missing source file" src/cli.ari
require_grep "unable to read source file" src/cli.ari
require_grep "unable to read one or more source files" src/cli.ari
require_grep "cannot open lint config" src/cli.ari
require_grep "collect_cli_source_diagnostics" src/cli.ari
require_grep "collect_explicit_cli_diagnostics" src/cli.ari
require_grep "write_stderr_text" src/output.ari
require_grep "std::io::eprint_string" src/output.ari
require_grep "run_os_argv_cli_with_main_output" src/main.ari
require_grep "known rule registry lookup added" docs/dev/roadmap.md
require_grep "registry-backed in-memory rule dispatch added" docs/dev/roadmap.md
require_grep "config text known-rule validation added" docs/dev/roadmap.md
require_grep "rule override known-rule validation added" docs/dev/roadmap.md
require_grep "data-only severity override resolution added" docs/dev/roadmap.md
require_grep "single-diagnostic severity override application added" docs/dev/roadmap.md
require_grep "in-memory lint severity override aggregation added" docs/dev/roadmap.md
require_grep "file-backed lint severity override aggregation added" docs/dev/roadmap.md
require_grep "CLI file lint rule override application added" docs/dev/roadmap.md
require_grep "CLI diagnostic severity override application added" docs/dev/roadmap.md
require_grep "CLI explicit config path capture added" docs/dev/roadmap.md
require_grep "explicit config file parse boundary added" docs/dev/roadmap.md
require_grep "explicit config override application added" docs/dev/roadmap.md
require_grep "config precedence fixture plan added" docs/dev/roadmap.md
require_grep "initial config precedence fixtures and lightweight checks added" docs/dev/roadmap.md
require_grep "shell-only config precedence fixture checks added" docs/dev/roadmap.md
require_grep "executable rule module API added" docs/dev/roadmap.md
require_grep "shared executable rule module API" docs/dev/roadmap.md
require_grep "data-only lookup" docs/dev/ari-implementation-plan.md
require_grep "known-rule validation" docs/dev/ari-implementation-plan.md
require_grep "apply_rule_severity_to_diagnostic_from_overrides" src/config.ari
require_grep "single-diagnostic application helper" docs/dev/ari-implementation-plan.md
require_grep "collect_lint_diagnostics_in_memory_with_overrides" src/lint.ari
require_grep "collect_file_lint_diagnostics_with_override_refs" src/lint.ari
require_grep "retains all positional source file paths" docs/dev/ari-implementation-plan.md
require_grep "explicit config file parse boundary" docs/dev/ari-implementation-plan.md
require_grep "default severity < selected config <" docs/dev/ari-implementation-plan.md
require_grep "Validate caller-provided .--rule. overrides in the internal CLI file lint" docs/dev/ari-implementation-plan.md
require_grep "shared rule execution input/result API" docs/dev/ari-implementation-plan.md
require_grep "shared rule module API" docs/dev/ari-implementation-plan.md
require_grep "registry-backed in-memory dispatch" docs/dev/ari-implementation-plan.md
require_grep "known rule registry lookup" tests/README.md
require_grep "Registry-backed in-memory rule dispatch" tests/README.md
require_grep "No executable registry dispatch tests are added yet" tests/README.md
require_grep "known-rule validation" tests/README.md
require_grep "No executable severity override resolution tests are added yet" tests/README.md
require_grep "No executable diagnostic severity application tests are added yet" tests/README.md
require_grep "No executable in-memory lint severity override aggregation tests are added yet" tests/README.md
require_grep "No executable file-backed lint severity override aggregation tests are added yet" tests/README.md
require_grep 'parsed `--rule` override validation' tests/README.md
require_grep 'explicit `--config` path is captured' tests/README.md
require_grep "config read and parse errors use the reference stderr shape" tests/README.md
require_grep 'defaults <' tests/README.md
require_grep "shell smoke executes this path" tests/README.md
require_grep "Dedicated Ari config unit tests" tests/README.md
require_grep "Initial config precedence fixtures exist" tests/README.md
require_grep "OS argv integration added" docs/dev/roadmap.md
require_grep "minimal config text parser added" docs/dev/roadmap.md
require_grep "rule override semantic parser added" docs/dev/roadmap.md
require_grep "minimal diagnostic JSON serializer added" docs/dev/roadmap.md
require_grep "source input boundary model added" docs/dev/roadmap.md
require_grep "in-memory trailing-whitespace execution added" docs/dev/roadmap.md
require_grep "in-memory missing-final-newline execution added" docs/dev/roadmap.md
require_grep "in-memory lint run aggregation added" docs/dev/roadmap.md
require_grep "lint aggregation first diagnostic capture added" docs/dev/roadmap.md
require_grep "file read boundary added" docs/dev/roadmap.md
require_grep "internal CLI file lint path added" docs/dev/roadmap.md
require_grep "CLI source lint first diagnostic carry added" docs/dev/roadmap.md
require_grep "source-only parity runner skeleton added" docs/dev/roadmap.md
require_grep "compiler-backed CI gate documented" docs/dev/roadmap.md
require_grep "pinned compiler-smoke CI added" docs/dev/roadmap.md
require_grep "standalone build root wiring added" docs/dev/roadmap.md
require_grep "standalone test entrypoint added" docs/dev/roadmap.md
require_grep "main OS argv exit-code wiring added" docs/dev/roadmap.md
require_grep "Wire local standalone test entrypoint" docs/dev/roadmap.md
require_grep "Initial trailing-whitespace fixtures have started" tests/README.md
require_grep "Initial missing-final-newline fixtures have started" tests/README.md
require_grep "lint run aggregation has also started" tests/README.md
require_grep "file-read boundary for one" tests/README.md
require_grep "internal CLI file lint path" tests/README.md
require_grep "first diagnostic command-result carrying" tests/README.md
require_grep "source-only parity runner skeleton" tests/README.md
require_grep "lightweight GitHub Actions workflow is intentionally compiler-free" tests/README.md
require_grep "local standalone test entrypoint" tests/README.md
require_grep "No executable standalone build tests are added yet" tests/README.md
require_grep "relative compiler path preservation" tests/README.md
require_grep "docs/dev/compiler-invocation.md" tests/README.md
require_grep "docs/dev/compiler-provisioning.md" tests/README.md
require_grep "No executable missing-final-newline rule execution tests are added yet" tests/README.md
require_grep "No executable in-memory lint run aggregation tests are added yet" tests/README.md
require_grep "first-diagnostic preservation" tests/README.md
require_grep "No executable file IO boundary tests are added yet" tests/README.md
require_grep "No executable CLI file lint path tests are added yet" tests/README.md
require_grep "No dedicated tests of the parity-runner infrastructure are added yet" tests/README.md
require_grep "Source directories should contain Ari source files only" docs/dev/ari-implementation-plan.md
require_grep "current standalone path implements explicit-file native rule execution" docs/dev/ari-implementation-plan.md
require_grep "source-only parity runner skeleton" docs/dev/ari-implementation-plan.md
require_grep "compiler-smoke.yml" docs/dev/ari-implementation-plan.md
require_grep "local standalone test entrypoint" docs/dev/ari-implementation-plan.md
require_grep "Standalone build wiring remains explicit" docs/dev/ari-implementation-plan.md
require_grep "relative compiler paths" docs/dev/ari-implementation-plan.md
require_grep "The compiler baseline is" docs/dev/compiler-provisioning.md
require_grep "immutable: false" docs/dev/compiler-provisioning.md
require_grep "scripts/test.sh .\$ARI_COMPILER." docs/dev/compiler-provisioning.md
require_grep "in-memory lint run aggregation path" docs/dev/ari-implementation-plan.md
require_grep "first already-built internal diagnostic" docs/dev/ari-implementation-plan.md
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
require_grep "RuleDispatchResult" src/registry.ari
require_grep "dispatch_known_rule_in_memory" src/registry.ari
require_grep "empty_rule_execution_result" src/registry.ari
require_grep "rule_dispatch_result" src/registry.ari
require_grep "ReferenceOnly" src/registry.ari
require_grep "trailing_whitespace_rule_metadata" src/registry.ari
require_grep "missing_final_newline_rule_metadata" src/registry.ari
require_grep "Lookup is" src/registry.ari
require_grep "caller-provided" src/registry.ari
require_grep "reads_files: false" src/registry.ari
require_grep "scans_filesystem: false" src/registry.ari
require_grep "applies_config: false" src/registry.ari
require_grep "writes_output: false" src/registry.ari
require_grep "serializes_json: false" src/registry.ari
require_grep "invokes_compiler: false" src/registry.ari
require_grep "first planned rule metadata entries" docs/dev/ari-implementation-plan.md
require_grep "first planned rule metadata entries" docs/dev/roadmap.md
require_grep "No rule metadata tests are added yet" tests/README.md
require_grep "CLI metadata skeleton" docs/dev/ari-implementation-plan.md
require_grep "CLI argument result model" docs/dev/ari-implementation-plan.md
require_grep "Minimal token-list parsing has started" docs/dev/ari-implementation-plan.md
require_grep "compiler-selection environment handling are implemented" docs/dev/ari-implementation-plan.md
require_grep "Actual OS process argument" docs/dev/ari-implementation-plan.md
require_grep "std::env::args" docs/dev/ari-implementation-plan.md
require_grep "internal stdout-free command dispatcher" docs/dev/ari-implementation-plan.md
require_grep "main entry shell" docs/dev/ari-implementation-plan.md
require_grep "returns the internal exit-code mapping" docs/dev/ari-implementation-plan.md
require_grep "Internal command results now carry data-only exit-code mappings" docs/dev/ari-implementation-plan.md
require_grep "named explicit-token .--list-rules. command entry" docs/dev/ari-implementation-plan.md
require_grep "minimal stdout adapter" docs/dev/ari-implementation-plan.md
require_grep "std::io::print_string" docs/dev/ari-implementation-plan.md
require_grep "CLI metadata skeleton" docs/dev/roadmap.md
require_grep "CLI argument model added" docs/dev/roadmap.md
require_grep "minimal CLI token parser added" docs/dev/roadmap.md
require_grep "stdout-free command dispatcher added" docs/dev/roadmap.md
require_grep "internal explicit-token entry path added" docs/dev/roadmap.md
require_grep "Executable shell CLI smoke now covers" tests/README.md
require_grep "No CLI model tests are added yet" tests/README.md
require_grep "No executable CLI parser tests are added yet" tests/README.md
require_grep "No executable dispatcher tests are added yet" tests/README.md
require_grep "No dedicated Ari exit-code model tests are added yet" tests/README.md
require_grep "No executable explicit-token entry tests are added yet" tests/README.md
require_grep "No dedicated Ari explicit-token list-rules command tests are added yet" tests/README.md
require_grep "Executable shell smoke enters through .main. and OS argv" tests/README.md
require_grep "No executable stdout/stderr output boundary tests are added yet" tests/README.md
require_grep "No executable stdout adapter tests are added yet" tests/README.md
require_grep "No executable stderr adapter tests are added yet" tests/README.md
require_grep "scripts/build.sh" tests/README.md
require_grep "scripts/test.sh" tests/README.md
require_grep "Runtime output uses a flat diagnostic store" docs/dev/ari-implementation-plan.md
require_grep "diagnostic output metadata skeleton" docs/dev/roadmap.md
require_grep "internal human diagnostic formatter added" docs/dev/roadmap.md
require_grep "internal human diagnostic array formatter added" docs/dev/roadmap.md
require_grep "trailing-whitespace first diagnostic capture added" docs/dev/roadmap.md
require_grep "missing-final-newline first diagnostic capture added" docs/dev/roadmap.md
require_grep ".FileResult./.RunResult. serializers used by" docs/dev/ari-implementation-plan.md
require_grep "internal diagnostic JSON field serialization added" docs/dev/roadmap.md
require_grep "internal diagnostic JSON array serialization added" docs/dev/roadmap.md
require_grep "Human source results use" docs/dev/ari-implementation-plan.md
require_grep "caller-provided diagnostics" docs/dev/ari-implementation-plan.md
require_grep "first already-built" docs/dev/ari-implementation-plan.md
require_grep "reference-shaped human or JSON output to stdout" docs/dev/ari-implementation-plan.md
require_grep "CLI parse problems, missing source-file input" docs/dev/ari-implementation-plan.md
require_grep "concise text to stdout" docs/dev/ari-implementation-plan.md
require_grep "missing source-file input, and explicit config" docs/dev/ari-implementation-plan.md
require_grep "Source commands select an Ari" docs/dev/ari-implementation-plan.md
require_grep "Bad discovered config lines are inserted as ordered per-file" docs/dev/ari-implementation-plan.md
require_grep "overrides are applied after the selected config for every source" docs/dev/ari-implementation-plan.md
require_grep "read-error JSON output" docs/dev/ari-implementation-plan.md
require_grep "internal list-rules output path" docs/dev/ari-implementation-plan.md
require_grep "human-readable list-rules formatter" docs/dev/ari-implementation-plan.md
require_grep "stdout/stderr output boundary model" docs/dev/ari-implementation-plan.md
require_grep "internal list-rules output path added" docs/dev/roadmap.md
require_grep "human-readable list-rules formatter added" docs/dev/roadmap.md
require_grep "Executable diagnostic output smoke tests" tests/README.md
require_grep "All JSON cases are syntax-checked" tests/README.md
require_grep "No executable trailing-whitespace first-diagnostic capture tests are added yet" tests/README.md
require_grep "No executable missing-final-newline first-diagnostic capture tests are added yet" tests/README.md
require_grep "Executable CLI smoke tests now validate the runtime JSON envelope" tests/README.md
require_grep "No executable source input boundary tests are added yet" tests/README.md
require_grep "No dedicated Ari list-rules formatter unit tests are added yet" tests/README.md
require_grep "config override skeleton" docs/dev/ari-implementation-plan.md
require_grep "config override skeleton" docs/dev/roadmap.md
require_grep "config text parser now handles" docs/dev/ari-implementation-plan.md
require_grep "RULE = SEVERITY" docs/dev/ari-implementation-plan.md
require_grep "per-source nearest readable config discovery" docs/dev/ari-implementation-plan.md
require_grep "No executable config parser tests are added yet" tests/README.md
require_grep "semantic parser for caller-provided .--rule. values" docs/dev/roadmap.md
require_grep "No executable rule override parser tests are added yet" tests/README.md
require_grep "No config override tests are added yet" tests/README.md
require_grep "Current rule module state" docs/dev/ari-implementation-plan.md
require_grep "rule module layout" docs/dev/roadmap.md
require_grep "in-memory rule execution" docs/dev/ari-implementation-plan.md
require_grep "Both rules now" docs/dev/ari-implementation-plan.md
require_grep "shared rule module API" tests/README.md
require_grep "No executable shared rule module API tests are added yet" tests/README.md
require_grep "minimal internal single-line helper" docs/dev/ari-implementation-plan.md
require_grep "single-line helper" docs/rules/trailing-whitespace.md
require_grep "trailing-whitespace helper started" docs/dev/roadmap.md
require_grep "No executable trailing-whitespace rule execution tests are added yet" tests/README.md
require_grep "fn main() -> i64" src/main.ari
require_grep "run_main_entry_shell" src/main.ari
require_grep "region(16777216)" src/main.ari
require_grep "mod cli" src/main.ari
require_grep "mod lint" src/main.ari
require_grep "cli::run_os_argv_cli" src/main.ari
require_grep "result.exit_code.code" src/main.ari
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
require_grep "CliCompilerCheckPlan" src/cli.ari
require_grep "CliCompilerCheckExecutionBoundary" src/cli.ari
require_grep "CliCompilerPathValidationKind" src/cli.ari
require_grep "CliCompilerPathValidationResult" src/cli.ari
require_grep "CliCompilerPathNotProvided" src/cli.ari
require_grep "CliCompilerPathRecordedNotChecked" src/cli.ari
require_grep "CliCompilerPathMissing" src/cli.ari
require_grep "CliCompilerPathNotExecutable" src/cli.ari
require_grep "CliCompilerPathReady" src/cli.ari
require_grep "CliCompilerCheckResultKind" src/cli.ari
require_grep "CliCompilerCheckResult" src/cli.ari
require_grep "CliCompilerCheckNotRun" src/cli.ari
require_grep "CliCompilerCheckSucceeded" src/cli.ari
require_grep "CliCompilerCheckFailed" src/cli.ari
require_grep "CliArgumentProblem" src/cli.ari
require_grep "CliCommandResultKind" src/cli.ari
require_grep "CliCompilerPathError" src/cli.ari
require_grep "CliCommandResult" src/cli.ari
require_grep "diagnostic_count" src/cli.ari
require_grep "first_diagnostic" src/cli.ari
require_grep "read_error_count" src/cli.ari
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
require_grep "source_count" src/cli.ari
require_grep "first_source_file" src/cli.ari
require_grep "source_files" src/cli.ari
require_grep "std::allocator::of" src/cli.ari
require_grep "--json" src/cli.ari
require_grep "json_requested" src/cli.ari
require_grep "--ari" src/cli.ari
require_grep "--ari=" src/cli.ari
require_grep "ari_compiler_path_present" src/cli.ari
require_grep "ari_compiler_path: Slice" src/cli.ari
require_grep "ari_compiler_path = std::string::substring" src/cli.ari
require_grep "compiler_check_plan_from_cli_args" src/cli.ari
require_grep "plan_explicit_cli_compiler_check" src/cli.ari
require_grep "compiler_check_argv_from_plan" src/cli.ari
require_grep "compiler_check_argv_for_source_from_plan" src/cli.ari
require_grep "plan_explicit_cli_compiler_check_argv" src/cli.ari
require_grep "compiler_check_execution_boundary_from_plan" src/cli.ari
require_grep "plan_explicit_cli_compiler_check_execution_boundary" src/cli.ari
require_grep "compiler_path_validation_from_boundary" src/cli.ari
require_grep "missing_compiler_path_validation_result" src/cli.ari
require_grep "non_executable_compiler_path_validation_result" src/cli.ari
require_grep "compiler_check_result_not_run_from_boundary" src/cli.ari
require_grep "plan_explicit_cli_compiler_check_result" src/cli.ari
require_grep "check_argument: \"--check\"" src/cli.ari
require_grep "calls_tools_lint: false" src/cli.ari
require_grep "source_files: args.source_files" src/cli.ari
require_grep "argv.push(std::string::from_slice_in(zone, source_file))" src/cli.ari
require_grep "argv.push(std::string::from_slice_in(zone, plan.check_argument))" src/cli.ari
require_grep "uses_planned_argv: true" src/cli.ari
require_grep "planned_invocation_count: plan.source_count" src/cli.ari
require_grep "planned_argument_count_per_invocation: 2 + (plan.include_path_count" src/cli.ari
require_grep "uses_per_file_argv: true" src/cli.ari
require_grep "exit_code_available: false" src/cli.ari
require_grep "stdout_available: false" src/cli.ari
require_grep "stderr_available: false" src/cli.ari
require_grep "checks_filesystem: checks_filesystem" src/cli.ari
require_grep "can_execute_compiler: can_execute_compiler" src/cli.ari
require_grep "compiler-path/missing" src/cli.ari
require_grep "compiler-path/not-executable" src/cli.ari
require_grep "std::fs::can_execute" src/cli.ari
require_grep "write_compiler_path_error_stderr" src/cli.ari
require_grep "Ari compiler path does not exist" src/cli.ari
require_grep "Ari compiler path is not executable" src/cli.ari
require_grep "Compiler check result is modeled but not executed" src/cli.ari
require_grep "mod compiler;" src/main.ari
require_grep "selected_ari_compiler_path" src/cli.ari
require_grep 'std::env::var(zone, "ARI_COMPILER")' src/cli.ari
require_grep "run_compiler_capture" src/cli.ari
require_grep "std::process::Command::with_args" src/compiler.ari
require_grep "spawn_piped" src/compiler.ari
require_grep "poll_read_millis" src/compiler.ari
require_grep "is_interrupted" src/compiler.ari
require_grep "compiler_stream_capture_limit" src/compiler.ari
require_grep "compiler output truncated at 262144 bytes per stream" src/compiler.ari
require_grep "ari/compiler-output-truncated" src/compiler.ari
require_grep "ari/compiler-diagnostics-truncated" src/compiler.ari
require_grep "compiler_diagnostic_vector_capacity" src/compiler.ari
require_grep "arg_bytes" src/compiler.ari
require_grep "parse_ari_diagnostics_into" src/compiler.ari
require_grep "ari/compiler-check-failed" src/compiler.ari
require_grep "ari-tooling: exec failed:" src/compiler.ari
require_grep "stderr_bytes.as_slice()" src/compiler.ari
require_grep "stdout_bytes.as_slice()" src/compiler.ari
require_grep "-I" src/cli.ari
require_grep "include_path_count" src/cli.ari
require_grep "first_include_path" src/cli.ari
require_grep "include_paths: std::vec::Vec" src/cli.ari
require_grep "include_paths.push" src/cli.ari
require_grep "include_paths: args.include_paths" src/cli.ari
require_grep "token.starts_with(\"-I\")" src/cli.ari
require_grep "--ari PATH" src/cli.ari
require_grep "-I DIR" src/cli.ari
require_grep "--list-rules" src/cli.ari
require_grep "list_rules_requested" src/cli.ari
require_grep "--config" src/cli.ari
require_grep "config_path_present" src/cli.ari
require_grep "config_file_path" src/cli.ari
require_grep "--rule" src/cli.ari
require_grep "rule_override_count" src/cli.ari
require_grep "rule_override_problem_count" src/cli.ari
require_grep "first_rule_override_problem" src/cli.ari
require_grep "first_read_error_path" src/cli.ari
require_grep "help_requested" src/cli.ari
require_grep "problem_count" src/cli.ari
require_grep "parse_cli_tokens" src/cli.ari
require_grep "dispatch_cli_command" src/cli.ari
require_grep "run_explicit_cli_tokens" src/cli.ari
require_grep "run_explicit_list_rules_command" src/cli.ari
require_grep "run_explicit_json_list_rules_command" src/cli.ari
require_grep "tokens.push(std::string::from(zone, \"--json\"));" src/cli.ari
require_grep "CliListRulesJson result" src/cli.ari
require_grep "read_os_argv_tokens" src/cli.ari
require_grep "run_os_argv_cli" src/cli.ari
require_grep "parse_cli_rule_overrides" src/cli.ari
require_grep "cli_file_lint_exit_code" src/cli.ari
require_grep "lint_file_source" src/cli.ari
require_grep "rule override problem" src/cli.ari
require_grep "applies discovered or explicit config and --rule severity overrides" src/cli.ari
require_grep "collect_cli_rule_overrides_from_tokens" src/cli.ari
require_grep "collect_cli_source_diagnostics_from_tokens" src/cli.ari
require_grep "parse_rule_override_text_into" src/config.ari
require_grep "parse_explicit_config_file_into_with_error_text" src/cli.ari
require_grep "parse_discovered_config_file_into_with_diagnostics" src/cli.ari
require_grep "discovered_config_file_path_for_source" src/cli.ari
require_grep "std::fs::can_read" src/cli.ari
require_grep "std::fs::is_dir" src/config.ari
require_grep "std::path::parent" src/cli.ari
require_grep "std::path::join_in" src/cli.ari
require_grep "collect_file_lint_diagnostics_with_overrides" src/lint.ari
require_grep "collect_file_lint_diagnostics_with_override_refs" src/lint.ari
require_grep "OsArgvBoundary" src/cli.ari
require_grep "os_argv_boundary" src/cli.ari
require_grep "std::env::args" src/cli.ari
require_grep "reads_process_argv: true" src/cli.ari
require_grep "CliListRulesText" src/cli.ari
require_grep "CliListRulesJson" src/cli.ari
require_grep "CliSourceLintResult" src/cli.ari
require_grep "CliConfigReadError" src/cli.ari
require_grep "lint_file_source" src/cli.ari
require_grep "missing_value_problem" src/cli.ari
require_grep "unknown_argument_problem" src/cli.ari
require_grep "raw_rule_override" src/cli.ari
require_grep "semantic rule override parsing bridge" src/cli.ari
require_grep "applies discovered or explicit config and --rule severity overrides" src/cli.ari
require_grep "Source commands select --ari, then ARI_COMPILER, then build/ari" src/cli.ari
require_grep "The main-facing wrapper adds" src/cli.ari
require_grep "write stdout/stderr" src/cli.ari
require_grep "call process exit" src/cli.ari
require_grep "recursively scan source trees" src/cli.ari
require_grep "Source-file lint diagnostics are available internally" src/cli.ari
require_grep "first internal diagnostic without writing output" src/cli.ari
require_grep "future work" src/cli.ari
require_grep "OptionalDiagnostic" src/diagnostic.ari
require_grep "first_available_diagnostic" src/diagnostic.ari
require_grep "source: Slice" src/diagnostic.ari
require_grep "code: Slice" src/diagnostic.ari
require_grep "compiler_diagnostic_from_span" src/diagnostic.ari
require_grep "diagnostic_with_severity" src/diagnostic.ari
require_grep "DiagnosticOutputMetadata" src/output.ari
require_grep "Human" src/output.ari
require_grep "Json" src/output.ari
require_grep "line" src/output.ari
require_grep "column" src/output.ari
require_grep "endLine" src/output.ari
require_grep "endColumn" src/output.ari
require_grep "severity" src/output.ari
require_grep "message" src/output.ari
require_grep "serialize_diagnostic_json" src/output.ari
require_grep "serialize_diagnostics_json" src/output.ari
require_grep "FileResult" src/output.ari
require_grep "RunResult" src/output.ari
require_grep "diagnostic_start" src/output.ari
require_grep "diagnostic_count <= diagnostic_total - diagnostic_start" src/output.ari
require_grep "expected_start == diagnostics.len()" src/output.ari
require_grep "diagnostics.len() - diagnostic_start" src/cli.ari
require_grep "serialize_run_result_json" src/output.ari
require_grep "format_run_result_human" src/output.ari
require_grep "format_json_string" src/output.ari
require_grep "resolved_end_position" src/output.ari
require_grep "\\u00" src/output.ari
require_grep "\\ufffd" src/output.ari
require_grep "diagnostic_severity_name" src/output.ari
require_grep "format_diagnostic_human" src/output.ari
require_grep "format_diagnostics_human" src/output.ari
require_grep "append_i64_fixed" src/output.ari
require_grep "reference_diagnostic_json_capacity" src/output.ari
require_grep "file_result_json_capacity" src/output.ari
require_grep '"{\\"files\\":\[' src/output.ari
require_grep "compiler_exit_code" src/output.ari
require_grep "diagnostic.source" src/output.ari
require_grep "diagnostic.code" src/output.ari
require_grep "endLine" src/output.ari
require_grep "endColumn" src/output.ari
require_grep "stream writes happen only" src/output.ari
require_grep "Source-lint runtime output follows the bundled reference contract" src/output.ari
require_grep "ListRuleRow" src/output.ari
require_grep "ListRulesOutput" src/output.ari
require_grep "list_rule_row_from_metadata" src/output.ari
require_grep "known_list_rules_output" src/output.ari
require_grep "format_list_rule_row_human" src/output.ari
require_grep "format_list_rules_human" src/output.ari
require_grep "format_list_rule_row_json" src/output.ari
require_grep "format_list_rules_json" src/output.ari
require_grep "List-rules JSON remains a documented standalone" src/output.ari
require_grep "OutputSinkName" src/output.ari
require_grep "OutputSinkBoundary" src/output.ari
require_grep "OutputBoundaryResult" src/output.ari
require_grep "stdout_stderr_output_boundary" src/output.ari
require_grep "writes_real_streams" src/output.ari
require_grep "writes_real_stream: false" src/output.ari
require_grep "StdoutAdapterResult" src/output.ari
require_grep "write_stdout_text" src/output.ari
require_grep "std::io::print_string" src/output.ari
require_grep "StderrAdapterResult" src/output.ari
require_grep "write_stderr_text" src/output.ari
require_grep "std::io::eprint_string" src/output.ari
require_grep "ConfigSkeleton" src/config.ari
require_grep "ConfigSourceMetadata" src/config.ari
require_grep "OverridePrecedenceMetadata" src/config.ari
require_grep "ConfigParseResult" src/config.ari
require_grep "ConfigFileParseResult" src/config.ari
require_grep "first_problem_line" src/config.ari
require_grep "first_problem_text" src/config.ari
require_grep "first_problem_detail" src/config.ari
require_grep "RuleOverrideParseResult" src/config.ari
require_grep "RuleSeverityResolution" src/config.ari
require_grep "DiagnosticSeverityApplication" src/config.ari
require_grep "resolve_rule_severity_from_overrides" src/config.ari
require_grep "ConfigParseProblemKind" src/config.ari
require_grep "ConfigMissingEquals" src/config.ari
require_grep "ConfigUnknownRule" src/config.ari
require_grep "ConfigInvalidSeverity" src/config.ari
require_grep "parse_config_text" src/config.ari
require_grep "parse_config_text_into" src/config.ari
require_grep "parse_explicit_config_file" src/config.ari
require_grep "parse_explicit_config_file_into" src/config.ari
require_grep "parse_explicit_config_file_into_with_error_text" src/config.ari
require_grep "parse_discovered_config_file" src/config.ari
require_grep "parse_discovered_config_file_into" src/config.ari
require_grep "parse_discovered_config_file_into_with_diagnostics" src/config.ari
require_grep "lint/config" src/config.ari
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
require_grep "reads_config_files: true" src/config.ari
require_grep "discovers_config_files: discovers_config_files" src/config.ari
require_grep "writes_output: false" src/config.ari
require_grep "serializes_json: false" src/config.ari
require_grep "normalized_lint_rule_code" src/config.ari
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
require_grep "ari-lint.rules discovery is decided by the CLI layer" src/config.ari
require_grep "Config-file discovery" src/config.ari
require_grep "RULE = SEVERITY" src/config.ari
require_grep "RULE=SEVERITY" src/config.ari
require_grep "CommandLineRuleOverride" src/config.ari
require_grep "remain outside this" src/config.ari
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
require_grep "first_diagnostic" src/lint.ari
require_grep "lint_in_memory_source" src/lint.ari
require_grep "lint_in_memory_source_from_overrides" src/lint.ari
require_grep "lint_in_memory_source_with_overrides" src/lint.ari
require_grep "lint_file_source" src/lint.ari
require_grep "lint_file_source_from_overrides" src/lint.ari
require_grep "lint_file_source_with_overrides" src/lint.ari
require_grep "lint_file_sources" src/lint.ari
require_grep "lint_file_sources_with_overrides" src/lint.ari
require_grep "collect_lint_diagnostics_in_memory" src/lint.ari
require_grep "collect_file_lint_diagnostics" src/lint.ari
require_grep "severity_is_enabled" src/lint.ari
require_grep "suppress diagnostics configured to Off" src/lint.ari
require_grep "enabled_diagnostic_count" src/lint.ari
require_grep "append_file_lint_result" src/lint.ari
require_grep "lint_trailing_whitespace_in_memory" src/lint.ari
require_grep "lint_missing_final_newline_in_memory" src/lint.ari
require_grep "source_input_from_file" src/lint.ari
require_grep "diagnostic_count" src/lint.ari
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
require_no_grep "rebuild diagnostics only" src/lint.ari
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
require_grep "RuleExecutionInput" src/rule.ari
require_grep "RuleExecutionResult" src/rule.ari
require_grep "rule_execution_input_from_source" src/rule.ari
require_grep "rule_execution_result" src/rule.ari
require_grep "reads_files: false" src/rule.ari
require_grep "scans_filesystem: false" src/rule.ari
require_grep "writes_output: false" src/rule.ari
require_grep "serializes_json: false" src/rule.ari
require_grep "invokes_compiler: false" src/rule.ari
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
require_grep "registry dispatch can select" src/rules.ari
require_grep "does not run rules" src/rules.ari
require_grep "TrailingWhitespaceRuleModuleMetadata" src/rules/trailing_whitespace.ari
require_grep "lint/trailing-whitespace" src/rules/trailing_whitespace.ari
require_grep "line_has_trailing_whitespace" src/rules/trailing_whitespace.ari
require_grep "is_trailing_space_byte" src/rules/trailing_whitespace.ari
require_grep "TrailingWhitespaceDiagnosticMapping" src/rules/trailing_whitespace.ari
require_grep "TrailingWhitespaceLineResult" src/rules/trailing_whitespace.ari
require_grep "trailing_whitespace_diagnostic_mapping" src/rules/trailing_whitespace.ari
require_grep "TrailingWhitespaceRuleResult" src/rules/trailing_whitespace.ari
require_grep "first_diagnostic" src/rules/trailing_whitespace.ari
require_grep "lint_trailing_whitespace_in_memory" src/rules/trailing_whitespace.ari
require_grep "collect_trailing_whitespace_diagnostics_in_memory" src/rules/trailing_whitespace.ari
require_grep "lint_trailing_whitespace_rule" src/rules/trailing_whitespace.ari
require_grep "RuleExecutionInput" src/rules/trailing_whitespace.ari
require_grep "RuleExecutionResult" src/rules/trailing_whitespace.ari
require_grep "trailing_whitespace_line_diagnostic_count" src/rules/trailing_whitespace.ari
require_grep "diagnostic_from_span" src/diagnostic.ari
require_grep "diagnostic_from_span" src/rules/trailing_whitespace.ari
require_grep "diagnostic_count" src/rules/trailing_whitespace.ari
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
require_grep "first_diagnostic" src/rules/missing_final_newline.ari
require_grep "final_position_for_source" src/rules/missing_final_newline.ari
require_grep "lint_missing_final_newline_in_memory" src/rules/missing_final_newline.ari
require_grep "collect_missing_final_newline_diagnostics_in_memory" src/rules/missing_final_newline.ari
require_grep "lint_missing_final_newline_rule" src/rules/missing_final_newline.ari
require_grep "RuleExecutionInput" src/rules/missing_final_newline.ari
require_grep "RuleExecutionResult" src/rules/missing_final_newline.ari
require_grep "diagnostic_from_span" src/rules/missing_final_newline.ari
require_grep "diagnostic_count" src/rules/missing_final_newline.ari
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
require_grep "compiler root" scripts/README.md
require_grep "relative compiler paths" scripts/README.md
require_grep "does not download or build the Ari compiler" scripts/README.md
require_grep "tools/lint" scripts/README.md
require_grep "ARI_COMPILER" scripts/build.sh
require_grep "original_pwd" scripts/build.sh
require_grep "repo_root" scripts/build.sh
require_grep "compiler_root" scripts/build.sh
require_grep "build_workdir" scripts/build.sh
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
