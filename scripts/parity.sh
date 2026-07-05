#!/bin/sh

set -eu

fail() {
  printf '%s\n' "parity.sh: $*" >&2
  exit 1
}

usage() {
  printf '%s\n' "usage: scripts/parity.sh [ARI_COMPILER_PATH] [ARI_REPO_PATH] [ORIGINAL_LINT_PATH]" >&2
  printf '%s\n' "       or set ARI_COMPILER, ARI_REPO, and optionally ORIGINAL_LINT" >&2
}

resolve_from_original_pwd() {
  path="$1"
  case "$path" in
    "" | /*) printf '%s\n' "$path" ;;
    *) printf '%s\n' "$original_pwd/$path" ;;
  esac
}

resolve_dir_from_original_pwd() {
  path=$(resolve_from_original_pwd "$1")
  [ -d "$path" ] || fail "missing ari repository path: $path"
  (CDPATH= cd "$path" && pwd)
}

require_executable() {
  path="$1"
  description="$2"
  [ -n "$path" ] || fail "missing $description"
  [ -e "$path" ] || fail "$description does not exist: $path"
  [ -x "$path" ] || fail "$description is not executable: $path"
}

has_text() {
  if [ -s "$1" ]; then
    printf '%s' "yes"
  else
    printf '%s' "no"
  fi
}

has_fixed_text() {
  pattern="$1"
  file="$2"
  if grep -F -q -- "$pattern" "$file"; then
    printf '%s' "yes"
  else
    printf '%s' "no"
  fi
}

has_json_position() {
  field="$1"
  file="$2"
  if grep -E -q "\"$field\"[[:space:]]*:[[:space:]]*[0-9]+" "$file"; then
    printf '%s' "yes"
  else
    printf '%s' "no"
  fi
}

locate_original_lint() {
  explicit_path="${1:-}"
  if [ -n "$explicit_path" ]; then
    resolved=$(resolve_from_original_pwd "$explicit_path")
    require_executable "$resolved" "original tools/lint command"
    printf '%s\n' "$resolved"
    return
  fi

  [ -f "$ari_repo/Makefile" ] || fail "missing Ari Makefile: $ari_repo/Makefile"
  [ -f "$ari_repo/tools/lint/main.cpp" ] || fail "missing Ari lint entrypoint: $ari_repo/tools/lint/main.cpp"
  grep -q "LINT_TARGET" "$ari_repo/Makefile" || fail "unable to verify Ari Makefile lint target"
  grep -q "tools/lint" "$ari_repo/Makefile" || fail "unable to verify Ari Makefile tools/lint sources"
  grep -q "usage: ari-lint" "$ari_repo/tools/lint/main.cpp" || fail "unable to verify tools/lint/main.cpp as lint CLI entrypoint"

  candidate="$ari_repo/build/ari-lint"
  if [ -x "$candidate" ]; then
    printf '%s\n' "$candidate"
    return
  fi

  candidate_exe="$ari_repo/build/ari-lint.exe"
  if [ -x "$candidate_exe" ]; then
    printf '%s\n' "$candidate_exe"
    return
  fi

  fail "unable to locate executable original lint command; verified tools/lint/main.cpp and Makefile lint target, but build/ari-lint is not executable"
}

run_case_in_dir() {
  work_dir="$1"
  tool_name="$2"
  tool_path="$3"
  case_name="$4"
  stdout_path="$5"
  stderr_path="$6"
  status_path="$7"
  shift 7

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --json --ari "$compiler" "$@" > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_list_rules_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --list-rules > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_json_list_rules_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --json --list-rules > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_help_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --help > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_short_help_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" -h > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_no_source_file_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_unknown_argument_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --definitely-unknown > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_missing_config_value_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --config > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_missing_rule_value_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --rule > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_missing_ari_value_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" --ari > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

run_missing_include_value_in_dir() {
  work_dir="$1"
  tool_path="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"

  set +e
  (
    CDPATH= cd "$work_dir" &&
      "$tool_path" -I > "$stdout_path" 2> "$stderr_path"
  )
  status=$?
  set -e
  printf '%s\n' "$status" > "$status_path"
}

print_case_summary() {
  tool_name="$1"
  case_name="$2"
  stdout_path="$3"
  stderr_path="$4"
  status_path="$5"
  expected_paths="$6"

  status=$(cat "$status_path")
  trailing=$(has_fixed_text "lint/trailing-whitespace" "$stdout_path")
  missing=$(has_fixed_text "lint/missing-final-newline" "$stdout_path")
  config=$(has_fixed_text "lint/config" "$stdout_path")
  severity_error=$(has_fixed_text '"severity":"error"' "$stdout_path")
  severity_note=$(has_fixed_text '"severity":"note"' "$stdout_path")
  severity_warning=$(has_fixed_text '"severity":"warning"' "$stdout_path")
  line_present=$(has_json_position "line" "$stdout_path")
  column_present=$(has_json_position "column" "$stdout_path")
  expected_path_count=0
  expected_path_hit_count=0
  old_ifs="$IFS"
  IFS='|'
  set -- $expected_paths
  IFS="$old_ifs"
  for expected_path do
    expected_path_count=$((expected_path_count + 1))
    if grep -F -q -- "$expected_path" "$stdout_path"; then
      expected_path_hit_count=$((expected_path_hit_count + 1))
    fi
  done

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    trailing_whitespace_reported: $trailing"
  printf '%s\n' "    missing_final_newline_reported: $missing"
  printf '%s\n' "    config_diagnostic_reported: $config"
  printf '%s\n' "    severity_error_present: $severity_error"
  printf '%s\n' "    severity_note_present: $severity_note"
  printf '%s\n' "    severity_warning_present: $severity_warning"
  printf '%s\n' "    file_paths_present: $expected_path_hit_count/$expected_path_count"
  printf '%s\n' "    line_present: $line_present"
  printf '%s\n' "    column_present: $column_present"
}

print_invalid_config_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"
  config_path="$5"

  status=$(cat "$status_path")
  config_diagnostic_stdout=$(has_fixed_text "lint/config" "$stdout_path")
  invalid_arguments_stdout=$(has_fixed_text "invalid command-line arguments" "$stdout_path")
  invalid_arguments_stderr=$(has_fixed_text "invalid command-line arguments" "$stderr_path")
  unknown_rule_or_severity_stdout=$(has_fixed_text "unknown rule or severity" "$stdout_path")
  unknown_rule_or_severity_stderr=$(has_fixed_text "unknown rule or severity" "$stderr_path")
  config_path_stdout=$(has_fixed_text "$config_path" "$stdout_path")
  config_path_stderr=$(has_fixed_text "$config_path" "$stderr_path")
  config_line_one_stdout=$(has_fixed_text ":1:" "$stdout_path")
  config_line_one_stderr=$(has_fixed_text ":1:" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    config_diagnostic_in_stdout: $config_diagnostic_stdout"
  printf '%s\n' "    invalid_arguments_text_in_stdout: $invalid_arguments_stdout"
  printf '%s\n' "    invalid_arguments_text_in_stderr: $invalid_arguments_stderr"
  printf '%s\n' "    unknown_rule_or_severity_text_in_stdout: $unknown_rule_or_severity_stdout"
  printf '%s\n' "    unknown_rule_or_severity_text_in_stderr: $unknown_rule_or_severity_stderr"
  printf '%s\n' "    config_path_in_stdout: $config_path_stdout"
  printf '%s\n' "    config_path_in_stderr: $config_path_stderr"
  printf '%s\n' "    config_line_one_in_stdout: $config_line_one_stdout"
  printf '%s\n' "    config_line_one_in_stderr: $config_line_one_stderr"
}

print_config_read_error_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"
  config_path="$5"

  status=$(cat "$status_path")
  unable_read_stdout=$(has_fixed_text "unable to read config file" "$stdout_path")
  unable_read_stderr=$(has_fixed_text "unable to read config file" "$stderr_path")
  cannot_open_stdout=$(has_fixed_text "cannot open lint config" "$stdout_path")
  cannot_open_stderr=$(has_fixed_text "cannot open lint config" "$stderr_path")
  config_path_stdout=$(has_fixed_text "$config_path" "$stdout_path")
  config_path_stderr=$(has_fixed_text "$config_path" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    unable_to_read_config_text_in_stdout: $unable_read_stdout"
  printf '%s\n' "    unable_to_read_config_text_in_stderr: $unable_read_stderr"
  printf '%s\n' "    cannot_open_lint_config_text_in_stdout: $cannot_open_stdout"
  printf '%s\n' "    cannot_open_lint_config_text_in_stderr: $cannot_open_stderr"
  printf '%s\n' "    config_path_in_stdout: $config_path_stdout"
  printf '%s\n' "    config_path_in_stderr: $config_path_stderr"
}

print_invalid_rule_override_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  invalid_override_stdout=$(has_fixed_text "invalid --rule override" "$stdout_path")
  invalid_override_stderr=$(has_fixed_text "invalid --rule override" "$stderr_path")
  invalid_rule_setting_stdout=$(has_fixed_text "invalid rule setting" "$stdout_path")
  invalid_rule_setting_stderr=$(has_fixed_text "invalid rule setting" "$stderr_path")
  expected_shape_stdout=$(has_fixed_text "RULE=SEVERITY" "$stdout_path")
  expected_shape_stderr=$(has_fixed_text "RULE=SEVERITY" "$stderr_path")
  rule_value_stdout=$(has_fixed_text "trailing-whitespace" "$stdout_path")
  rule_value_stderr=$(has_fixed_text "trailing-whitespace" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    invalid_rule_override_text_in_stdout: $invalid_override_stdout"
  printf '%s\n' "    invalid_rule_override_text_in_stderr: $invalid_override_stderr"
  printf '%s\n' "    invalid_rule_setting_text_in_stdout: $invalid_rule_setting_stdout"
  printf '%s\n' "    invalid_rule_setting_text_in_stderr: $invalid_rule_setting_stderr"
  printf '%s\n' "    expected_rule_severity_text_in_stdout: $expected_shape_stdout"
  printf '%s\n' "    expected_rule_severity_text_in_stderr: $expected_shape_stderr"
  printf '%s\n' "    rule_value_in_stdout: $rule_value_stdout"
  printf '%s\n' "    rule_value_in_stderr: $rule_value_stderr"
}

print_invalid_rule_severity_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  invalid_override_stdout=$(has_fixed_text "invalid --rule override" "$stdout_path")
  invalid_override_stderr=$(has_fixed_text "invalid --rule override" "$stderr_path")
  invalid_rule_setting_stdout=$(has_fixed_text "invalid rule setting" "$stdout_path")
  invalid_rule_setting_stderr=$(has_fixed_text "invalid rule setting" "$stderr_path")
  unknown_rule_or_severity_stdout=$(has_fixed_text "unknown rule or severity" "$stdout_path")
  unknown_rule_or_severity_stderr=$(has_fixed_text "unknown rule or severity" "$stderr_path")
  expected_shape_stdout=$(has_fixed_text "RULE=SEVERITY" "$stdout_path")
  expected_shape_stderr=$(has_fixed_text "RULE=SEVERITY" "$stderr_path")
  rule_value_stdout=$(has_fixed_text "trailing-whitespace=loud" "$stdout_path")
  rule_value_stderr=$(has_fixed_text "trailing-whitespace=loud" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    invalid_rule_override_text_in_stdout: $invalid_override_stdout"
  printf '%s\n' "    invalid_rule_override_text_in_stderr: $invalid_override_stderr"
  printf '%s\n' "    invalid_rule_setting_text_in_stdout: $invalid_rule_setting_stdout"
  printf '%s\n' "    invalid_rule_setting_text_in_stderr: $invalid_rule_setting_stderr"
  printf '%s\n' "    unknown_rule_or_severity_text_in_stdout: $unknown_rule_or_severity_stdout"
  printf '%s\n' "    unknown_rule_or_severity_text_in_stderr: $unknown_rule_or_severity_stderr"
  printf '%s\n' "    expected_rule_severity_text_in_stdout: $expected_shape_stdout"
  printf '%s\n' "    expected_rule_severity_text_in_stderr: $expected_shape_stderr"
  printf '%s\n' "    rule_value_in_stdout: $rule_value_stdout"
  printf '%s\n' "    rule_value_in_stderr: $rule_value_stderr"
}

print_unknown_rule_override_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  invalid_override_stdout=$(has_fixed_text "invalid --rule override" "$stdout_path")
  invalid_override_stderr=$(has_fixed_text "invalid --rule override" "$stderr_path")
  invalid_rule_setting_stdout=$(has_fixed_text "invalid rule setting" "$stdout_path")
  invalid_rule_setting_stderr=$(has_fixed_text "invalid rule setting" "$stderr_path")
  unknown_rule_or_severity_stdout=$(has_fixed_text "unknown rule or severity" "$stdout_path")
  unknown_rule_or_severity_stderr=$(has_fixed_text "unknown rule or severity" "$stderr_path")
  expected_shape_stdout=$(has_fixed_text "RULE=SEVERITY" "$stdout_path")
  expected_shape_stderr=$(has_fixed_text "RULE=SEVERITY" "$stderr_path")
  rule_value_stdout=$(has_fixed_text "unknown-rule=warning" "$stdout_path")
  rule_value_stderr=$(has_fixed_text "unknown-rule=warning" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    invalid_rule_override_text_in_stdout: $invalid_override_stdout"
  printf '%s\n' "    invalid_rule_override_text_in_stderr: $invalid_override_stderr"
  printf '%s\n' "    invalid_rule_setting_text_in_stdout: $invalid_rule_setting_stdout"
  printf '%s\n' "    invalid_rule_setting_text_in_stderr: $invalid_rule_setting_stderr"
  printf '%s\n' "    unknown_rule_or_severity_text_in_stdout: $unknown_rule_or_severity_stdout"
  printf '%s\n' "    unknown_rule_or_severity_text_in_stderr: $unknown_rule_or_severity_stderr"
  printf '%s\n' "    expected_rule_severity_text_in_stdout: $expected_shape_stdout"
  printf '%s\n' "    expected_rule_severity_text_in_stderr: $expected_shape_stderr"
  printf '%s\n' "    rule_value_in_stdout: $rule_value_stdout"
  printf '%s\n' "    rule_value_in_stderr: $rule_value_stderr"
}

print_list_rules_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  trailing=$(has_fixed_text "lint/trailing-whitespace" "$stdout_path")
  missing=$(has_fixed_text "lint/missing-final-newline" "$stdout_path")
  default_warning=$(has_fixed_text "default=warning" "$stdout_path")
  short_name_field=$(has_fixed_text "name=trailing-whitespace" "$stdout_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    trailing_whitespace_listed: $trailing"
  printf '%s\n' "    missing_final_newline_listed: $missing"
  printf '%s\n' "    default_warning_present: $default_warning"
  printf '%s\n' "    short_rule_name_field_present: $short_name_field"
}

print_help_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  json_stdout=$(has_fixed_text "--json" "$stdout_path")
  json_stderr=$(has_fixed_text "--json" "$stderr_path")
  list_rules_stdout=$(has_fixed_text "--list-rules" "$stdout_path")
  list_rules_stderr=$(has_fixed_text "--list-rules" "$stderr_path")
  config_stdout=$(has_fixed_text "--config" "$stdout_path")
  config_stderr=$(has_fixed_text "--config" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    json_option_in_stdout: $json_stdout"
  printf '%s\n' "    json_option_in_stderr: $json_stderr"
  printf '%s\n' "    list_rules_option_in_stdout: $list_rules_stdout"
  printf '%s\n' "    list_rules_option_in_stderr: $list_rules_stderr"
  printf '%s\n' "    config_option_in_stdout: $config_stdout"
  printf '%s\n' "    config_option_in_stderr: $config_stderr"
}

print_no_source_file_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  source_file_text_stdout=$(has_fixed_text "missing source file" "$stdout_path")
  source_file_text_stderr=$(has_fixed_text "missing source file" "$stderr_path")
  file_operand_stdout=$(has_fixed_text "FILE..." "$stdout_path")
  file_operand_stderr=$(has_fixed_text "FILE..." "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    source_file_text_in_stdout: $source_file_text_stdout"
  printf '%s\n' "    source_file_text_in_stderr: $source_file_text_stderr"
  printf '%s\n' "    file_operand_in_stdout: $file_operand_stdout"
  printf '%s\n' "    file_operand_in_stderr: $file_operand_stderr"
}

print_read_error_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"
  source_path="$5"

  status=$(cat "$status_path")
  unable_read_stdout=$(has_fixed_text "unable to read source file" "$stdout_path")
  unable_read_stderr=$(has_fixed_text "unable to read source file" "$stderr_path")
  cannot_open_stdout=$(has_fixed_text "cannot open input file" "$stdout_path")
  cannot_open_stderr=$(has_fixed_text "cannot open input file" "$stderr_path")
  ari_compiler_stdout=$(has_fixed_text "ari/compiler" "$stdout_path")
  ari_compiler_stderr=$(has_fixed_text "ari/compiler" "$stderr_path")
  json_files_stdout=$(has_fixed_text "\"files\"" "$stdout_path")
  json_files_stderr=$(has_fixed_text "\"files\"" "$stderr_path")
  source_path_stdout=$(has_fixed_text "$source_path" "$stdout_path")
  source_path_stderr=$(has_fixed_text "$source_path" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    unable_to_read_source_text_in_stdout: $unable_read_stdout"
  printf '%s\n' "    unable_to_read_source_text_in_stderr: $unable_read_stderr"
  printf '%s\n' "    cannot_open_input_file_text_in_stdout: $cannot_open_stdout"
  printf '%s\n' "    cannot_open_input_file_text_in_stderr: $cannot_open_stderr"
  printf '%s\n' "    ari_compiler_code_in_stdout: $ari_compiler_stdout"
  printf '%s\n' "    ari_compiler_code_in_stderr: $ari_compiler_stderr"
  printf '%s\n' "    json_files_shape_in_stdout: $json_files_stdout"
  printf '%s\n' "    json_files_shape_in_stderr: $json_files_stderr"
  printf '%s\n' "    source_path_in_stdout: $source_path_stdout"
  printf '%s\n' "    source_path_in_stderr: $source_path_stderr"
}

print_missing_compiler_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"
  source_path="$5"
  compiler_path="$6"

  status=$(cat "$status_path")
  compiler_failed_stdout=$(has_fixed_text "ari/compiler-check-failed" "$stdout_path")
  compiler_failed_stderr=$(has_fixed_text "ari/compiler-check-failed" "$stderr_path")
  exec_failed_stdout=$(has_fixed_text "exec failed" "$stdout_path")
  exec_failed_stderr=$(has_fixed_text "exec failed" "$stderr_path")
  json_files_stdout=$(has_fixed_text "\"files\"" "$stdout_path")
  json_files_stderr=$(has_fixed_text "\"files\"" "$stderr_path")
  source_path_stdout=$(has_fixed_text "$source_path" "$stdout_path")
  source_path_stderr=$(has_fixed_text "$source_path" "$stderr_path")
  compiler_path_stdout=$(has_fixed_text "$compiler_path" "$stdout_path")
  compiler_path_stderr=$(has_fixed_text "$compiler_path" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    compiler_check_failed_code_in_stdout: $compiler_failed_stdout"
  printf '%s\n' "    compiler_check_failed_code_in_stderr: $compiler_failed_stderr"
  printf '%s\n' "    exec_failed_text_in_stdout: $exec_failed_stdout"
  printf '%s\n' "    exec_failed_text_in_stderr: $exec_failed_stderr"
  printf '%s\n' "    json_files_shape_in_stdout: $json_files_stdout"
  printf '%s\n' "    json_files_shape_in_stderr: $json_files_stderr"
  printf '%s\n' "    source_path_in_stdout: $source_path_stdout"
  printf '%s\n' "    source_path_in_stderr: $source_path_stderr"
  printf '%s\n' "    missing_compiler_path_in_stdout: $compiler_path_stdout"
  printf '%s\n' "    missing_compiler_path_in_stderr: $compiler_path_stderr"
}

print_compiler_error_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"
  source_path="$5"

  status=$(cat "$status_path")
  ari_compiler_stdout=$(has_fixed_text "ari/compiler" "$stdout_path")
  ari_compiler_stderr=$(has_fixed_text "ari/compiler" "$stderr_path")
  expected_decl_stdout=$(has_fixed_text "expected top-level declaration" "$stdout_path")
  expected_decl_stderr=$(has_fixed_text "expected top-level declaration" "$stderr_path")
  json_files_stdout=$(has_fixed_text "\"files\"" "$stdout_path")
  json_files_stderr=$(has_fixed_text "\"files\"" "$stderr_path")
  source_path_stdout=$(has_fixed_text "$source_path" "$stdout_path")
  source_path_stderr=$(has_fixed_text "$source_path" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    ari_compiler_code_in_stdout: $ari_compiler_stdout"
  printf '%s\n' "    ari_compiler_code_in_stderr: $ari_compiler_stderr"
  printf '%s\n' "    expected_top_level_declaration_text_in_stdout: $expected_decl_stdout"
  printf '%s\n' "    expected_top_level_declaration_text_in_stderr: $expected_decl_stderr"
  printf '%s\n' "    json_files_shape_in_stdout: $json_files_stdout"
  printf '%s\n' "    json_files_shape_in_stderr: $json_files_stderr"
  printf '%s\n' "    source_path_in_stdout: $source_path_stdout"
  printf '%s\n' "    source_path_in_stderr: $source_path_stderr"
}

print_unknown_argument_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  unknown_text_stdout=$(has_fixed_text "unknown argument" "$stdout_path")
  unknown_text_stderr=$(has_fixed_text "unknown argument" "$stderr_path")
  unknown_option_stdout=$(has_fixed_text "--definitely-unknown" "$stdout_path")
  unknown_option_stderr=$(has_fixed_text "--definitely-unknown" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    unknown_argument_text_in_stdout: $unknown_text_stdout"
  printf '%s\n' "    unknown_argument_text_in_stderr: $unknown_text_stderr"
  printf '%s\n' "    unknown_option_in_stdout: $unknown_option_stdout"
  printf '%s\n' "    unknown_option_in_stderr: $unknown_option_stderr"
}

print_missing_config_value_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  missing_text_stdout=$(has_fixed_text "missing option value" "$stdout_path")
  missing_text_stderr=$(has_fixed_text "missing option value" "$stderr_path")
  config_option_stdout=$(has_fixed_text "--config" "$stdout_path")
  config_option_stderr=$(has_fixed_text "--config" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    missing_option_value_text_in_stdout: $missing_text_stdout"
  printf '%s\n' "    missing_option_value_text_in_stderr: $missing_text_stderr"
  printf '%s\n' "    config_option_in_stdout: $config_option_stdout"
  printf '%s\n' "    config_option_in_stderr: $config_option_stderr"
}

print_missing_rule_value_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  missing_text_stdout=$(has_fixed_text "missing option value" "$stdout_path")
  missing_text_stderr=$(has_fixed_text "missing option value" "$stderr_path")
  rule_option_stdout=$(has_fixed_text "--rule" "$stdout_path")
  rule_option_stderr=$(has_fixed_text "--rule" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    missing_option_value_text_in_stdout: $missing_text_stdout"
  printf '%s\n' "    missing_option_value_text_in_stderr: $missing_text_stderr"
  printf '%s\n' "    rule_option_in_stdout: $rule_option_stdout"
  printf '%s\n' "    rule_option_in_stderr: $rule_option_stderr"
}

print_missing_ari_value_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  missing_text_stdout=$(has_fixed_text "missing option value" "$stdout_path")
  missing_text_stderr=$(has_fixed_text "missing option value" "$stderr_path")
  ari_option_stdout=$(has_fixed_text "--ari" "$stdout_path")
  ari_option_stderr=$(has_fixed_text "--ari" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    missing_option_value_text_in_stdout: $missing_text_stdout"
  printf '%s\n' "    missing_option_value_text_in_stderr: $missing_text_stderr"
  printf '%s\n' "    ari_option_in_stdout: $ari_option_stdout"
  printf '%s\n' "    ari_option_in_stderr: $ari_option_stderr"
}

print_missing_include_value_summary() {
  tool_name="$1"
  stdout_path="$2"
  stderr_path="$3"
  status_path="$4"

  status=$(cat "$status_path")
  usage_stdout=$(has_fixed_text "ari-lint" "$stdout_path")
  usage_stderr=$(has_fixed_text "ari-lint" "$stderr_path")
  missing_text_stdout=$(has_fixed_text "missing option value" "$stdout_path")
  missing_text_stderr=$(has_fixed_text "missing option value" "$stderr_path")
  include_option_stdout=$(has_fixed_text "-I" "$stdout_path")
  include_option_stderr=$(has_fixed_text "-I" "$stderr_path")

  printf '%s\n' "  $tool_name:"
  printf '%s\n' "    exit_code: $status"
  printf '%s\n' "    stdout_non_empty: $(has_text "$stdout_path")"
  printf '%s\n' "    stderr_non_empty: $(has_text "$stderr_path")"
  printf '%s\n' "    usage_in_stdout: $usage_stdout"
  printf '%s\n' "    usage_in_stderr: $usage_stderr"
  printf '%s\n' "    missing_option_value_text_in_stdout: $missing_text_stdout"
  printf '%s\n' "    missing_option_value_text_in_stderr: $missing_text_stderr"
  printf '%s\n' "    include_option_in_stdout: $include_option_stdout"
  printf '%s\n' "    include_option_in_stderr: $include_option_stderr"
}

report_help_case() {
  current_stdout="$tmp_dir/current-help.stdout"
  current_stderr="$tmp_dir/current-help.stderr"
  current_status="$tmp_dir/current-help.status"
  original_stdout="$tmp_dir/original-help.stdout"
  original_stderr="$tmp_dir/original-help.stderr"
  original_status="$tmp_dir/original-help.status"

  run_help_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_help_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: help"
  print_help_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_help_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_short_help_case() {
  current_stdout="$tmp_dir/current-short-help.stdout"
  current_stderr="$tmp_dir/current-short-help.stderr"
  current_status="$tmp_dir/current-short-help.status"
  original_stdout="$tmp_dir/original-short-help.stdout"
  original_stderr="$tmp_dir/original-short-help.stderr"
  original_status="$tmp_dir/original-short-help.status"

  run_short_help_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_short_help_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: short-help"
  print_help_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_help_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_no_source_file_case() {
  current_stdout="$tmp_dir/current-no-source-file.stdout"
  current_stderr="$tmp_dir/current-no-source-file.stderr"
  current_status="$tmp_dir/current-no-source-file.status"
  original_stdout="$tmp_dir/original-no-source-file.stdout"
  original_stderr="$tmp_dir/original-no-source-file.stderr"
  original_status="$tmp_dir/original-no-source-file.status"

  run_no_source_file_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_no_source_file_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: no-source-file"
  print_no_source_file_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_no_source_file_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_read_error_case() {
  current_stdout="$tmp_dir/current-read-error.stdout"
  current_stderr="$tmp_dir/current-read-error.stderr"
  current_status="$tmp_dir/current-read-error.status"
  original_stdout="$tmp_dir/original-read-error.stdout"
  original_stderr="$tmp_dir/original-read-error.stderr"
  original_status="$tmp_dir/original-read-error.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "read-error" "$current_stdout" "$current_stderr" "$current_status" "$read_error_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "read-error" "$original_stdout" "$original_stderr" "$original_status" "$read_error_source"

  printf '%s\n' "case: read-error"
  print_read_error_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status" "$read_error_source"
  print_read_error_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status" "$read_error_source"
  printf '%s\n' ""
}

report_missing_compiler_case() {
  current_stdout="$tmp_dir/current-missing-compiler.stdout"
  current_stderr="$tmp_dir/current-missing-compiler.stderr"
  current_status="$tmp_dir/current-missing-compiler.status"
  original_stdout="$tmp_dir/original-missing-compiler.stdout"
  original_stderr="$tmp_dir/original-missing-compiler.stderr"
  original_status="$tmp_dir/original-missing-compiler.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "missing-compiler" "$current_stdout" "$current_stderr" "$current_status" --ari "$missing_compiler_path" "$clean_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "missing-compiler" "$original_stdout" "$original_stderr" "$original_status" --ari "$missing_compiler_path" "$clean_source"

  printf '%s\n' "case: missing-compiler"
  print_missing_compiler_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status" "$clean_source" "$missing_compiler_path"
  print_missing_compiler_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status" "$clean_source" "$missing_compiler_path"
  printf '%s\n' ""
}

report_compiler_error_case() {
  current_stdout="$tmp_dir/current-compiler-error.stdout"
  current_stderr="$tmp_dir/current-compiler-error.stderr"
  current_status="$tmp_dir/current-compiler-error.status"
  original_stdout="$tmp_dir/original-compiler-error.stdout"
  original_stderr="$tmp_dir/original-compiler-error.stderr"
  original_status="$tmp_dir/original-compiler-error.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "compiler-error" "$current_stdout" "$current_stderr" "$current_status" "$compiler_error_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "compiler-error" "$original_stdout" "$original_stderr" "$original_status" "$compiler_error_source"

  printf '%s\n' "case: compiler-error"
  print_compiler_error_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status" "$compiler_error_source"
  print_compiler_error_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status" "$compiler_error_source"
  printf '%s\n' ""
}

report_unknown_argument_case() {
  current_stdout="$tmp_dir/current-unknown-argument.stdout"
  current_stderr="$tmp_dir/current-unknown-argument.stderr"
  current_status="$tmp_dir/current-unknown-argument.status"
  original_stdout="$tmp_dir/original-unknown-argument.stdout"
  original_stderr="$tmp_dir/original-unknown-argument.stderr"
  original_status="$tmp_dir/original-unknown-argument.status"

  run_unknown_argument_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_unknown_argument_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: unknown-argument"
  print_unknown_argument_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_unknown_argument_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_missing_config_value_case() {
  current_stdout="$tmp_dir/current-missing-config-value.stdout"
  current_stderr="$tmp_dir/current-missing-config-value.stderr"
  current_status="$tmp_dir/current-missing-config-value.status"
  original_stdout="$tmp_dir/original-missing-config-value.stdout"
  original_stderr="$tmp_dir/original-missing-config-value.stderr"
  original_status="$tmp_dir/original-missing-config-value.status"

  run_missing_config_value_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_missing_config_value_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: missing-config-value"
  print_missing_config_value_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_missing_config_value_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_missing_rule_value_case() {
  current_stdout="$tmp_dir/current-missing-rule-value.stdout"
  current_stderr="$tmp_dir/current-missing-rule-value.stderr"
  current_status="$tmp_dir/current-missing-rule-value.status"
  original_stdout="$tmp_dir/original-missing-rule-value.stdout"
  original_stderr="$tmp_dir/original-missing-rule-value.stderr"
  original_status="$tmp_dir/original-missing-rule-value.status"

  run_missing_rule_value_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_missing_rule_value_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: missing-rule-value"
  print_missing_rule_value_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_missing_rule_value_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_missing_ari_value_case() {
  current_stdout="$tmp_dir/current-missing-ari-value.stdout"
  current_stderr="$tmp_dir/current-missing-ari-value.stderr"
  current_status="$tmp_dir/current-missing-ari-value.status"
  original_stdout="$tmp_dir/original-missing-ari-value.stdout"
  original_stderr="$tmp_dir/original-missing-ari-value.stderr"
  original_status="$tmp_dir/original-missing-ari-value.status"

  run_missing_ari_value_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_missing_ari_value_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: missing-ari-value"
  print_missing_ari_value_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_missing_ari_value_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_missing_include_value_case() {
  current_stdout="$tmp_dir/current-missing-include-value.stdout"
  current_stderr="$tmp_dir/current-missing-include-value.stderr"
  current_status="$tmp_dir/current-missing-include-value.status"
  original_stdout="$tmp_dir/original-missing-include-value.stdout"
  original_stderr="$tmp_dir/original-missing-include-value.stderr"
  original_status="$tmp_dir/original-missing-include-value.status"

  run_missing_include_value_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_missing_include_value_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: missing-include-value"
  print_missing_include_value_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_missing_include_value_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_list_rules_case() {
  current_stdout="$tmp_dir/current-list-rules.stdout"
  current_stderr="$tmp_dir/current-list-rules.stderr"
  current_status="$tmp_dir/current-list-rules.status"
  original_stdout="$tmp_dir/original-list-rules.stdout"
  original_stderr="$tmp_dir/original-list-rules.stderr"
  original_status="$tmp_dir/original-list-rules.status"

  run_list_rules_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_list_rules_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: list-rules"
  print_list_rules_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_list_rules_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_json_list_rules_case() {
  current_stdout="$tmp_dir/current-json-list-rules.stdout"
  current_stderr="$tmp_dir/current-json-list-rules.stderr"
  current_status="$tmp_dir/current-json-list-rules.status"
  original_stdout="$tmp_dir/original-json-list-rules.stdout"
  original_stderr="$tmp_dir/original-json-list-rules.stderr"
  original_status="$tmp_dir/original-json-list-rules.status"

  run_json_list_rules_in_dir "$original_pwd" "$current_lint" "$current_stdout" "$current_stderr" "$current_status"
  run_json_list_rules_in_dir "$original_pwd" "$original_lint" "$original_stdout" "$original_stderr" "$original_status"

  printf '%s\n' "case: json-list-rules"
  print_list_rules_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_list_rules_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_case() {
  case_name="$1"
  work_dir="$2"
  expected_paths="$3"
  shift 3

  current_stdout="$tmp_dir/current-$case_name.stdout"
  current_stderr="$tmp_dir/current-$case_name.stderr"
  current_status="$tmp_dir/current-$case_name.status"
  original_stdout="$tmp_dir/original-$case_name.stdout"
  original_stderr="$tmp_dir/original-$case_name.stderr"
  original_status="$tmp_dir/original-$case_name.status"

  run_case_in_dir "$work_dir" "current ari-lint" "$current_lint" "$case_name" "$current_stdout" "$current_stderr" "$current_status" "$@"
  run_case_in_dir "$work_dir" "original tools/lint" "$original_lint" "$case_name" "$original_stdout" "$original_stderr" "$original_status" "$@"

  printf '%s\n' "case: $case_name"
  print_case_summary "current ari-lint" "$case_name" "$current_stdout" "$current_stderr" "$current_status" "$expected_paths"
  print_case_summary "original tools/lint" "$case_name" "$original_stdout" "$original_stderr" "$original_status" "$expected_paths"
  printf '%s\n' ""
}

report_invalid_config_case() {
  current_stdout="$tmp_dir/current-invalid-config.stdout"
  current_stderr="$tmp_dir/current-invalid-config.stderr"
  current_status="$tmp_dir/current-invalid-config.status"
  original_stdout="$tmp_dir/original-invalid-config.stdout"
  original_stderr="$tmp_dir/original-invalid-config.stderr"
  original_status="$tmp_dir/original-invalid-config.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "invalid-config" "$current_stdout" "$current_stderr" "$current_status" --config "$invalid_config_file" "$trailing_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "invalid-config" "$original_stdout" "$original_stderr" "$original_status" --config "$invalid_config_file" "$trailing_source"

  printf '%s\n' "case: invalid-config"
  print_invalid_config_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status" "$invalid_config_file"
  print_invalid_config_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status" "$invalid_config_file"
  printf '%s\n' ""
}

report_config_read_error_case() {
  current_stdout="$tmp_dir/current-config-read-error.stdout"
  current_stderr="$tmp_dir/current-config-read-error.stderr"
  current_status="$tmp_dir/current-config-read-error.status"
  original_stdout="$tmp_dir/original-config-read-error.stdout"
  original_stderr="$tmp_dir/original-config-read-error.stderr"
  original_status="$tmp_dir/original-config-read-error.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "config-read-error" "$current_stdout" "$current_stderr" "$current_status" --config "$config_read_error_file" "$trailing_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "config-read-error" "$original_stdout" "$original_stderr" "$original_status" --config "$config_read_error_file" "$trailing_source"

  printf '%s\n' "case: config-read-error"
  print_config_read_error_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status" "$config_read_error_file"
  print_config_read_error_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status" "$config_read_error_file"
  printf '%s\n' ""
}

report_invalid_rule_override_case() {
  current_stdout="$tmp_dir/current-invalid-rule-override.stdout"
  current_stderr="$tmp_dir/current-invalid-rule-override.stderr"
  current_status="$tmp_dir/current-invalid-rule-override.status"
  original_stdout="$tmp_dir/original-invalid-rule-override.stdout"
  original_stderr="$tmp_dir/original-invalid-rule-override.stderr"
  original_status="$tmp_dir/original-invalid-rule-override.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "invalid-rule-override" "$current_stdout" "$current_stderr" "$current_status" --rule trailing-whitespace "$trailing_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "invalid-rule-override" "$original_stdout" "$original_stderr" "$original_status" --rule trailing-whitespace "$trailing_source"

  printf '%s\n' "case: invalid-rule-override"
  print_invalid_rule_override_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_invalid_rule_override_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_invalid_rule_severity_case() {
  current_stdout="$tmp_dir/current-invalid-rule-severity.stdout"
  current_stderr="$tmp_dir/current-invalid-rule-severity.stderr"
  current_status="$tmp_dir/current-invalid-rule-severity.status"
  original_stdout="$tmp_dir/original-invalid-rule-severity.stdout"
  original_stderr="$tmp_dir/original-invalid-rule-severity.stderr"
  original_status="$tmp_dir/original-invalid-rule-severity.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "invalid-rule-severity" "$current_stdout" "$current_stderr" "$current_status" --rule trailing-whitespace=loud "$trailing_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "invalid-rule-severity" "$original_stdout" "$original_stderr" "$original_status" --rule trailing-whitespace=loud "$trailing_source"

  printf '%s\n' "case: invalid-rule-severity"
  print_invalid_rule_severity_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_invalid_rule_severity_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

report_unknown_rule_override_case() {
  current_stdout="$tmp_dir/current-unknown-rule-override.stdout"
  current_stderr="$tmp_dir/current-unknown-rule-override.stderr"
  current_status="$tmp_dir/current-unknown-rule-override.status"
  original_stdout="$tmp_dir/original-unknown-rule-override.stdout"
  original_stderr="$tmp_dir/original-unknown-rule-override.stderr"
  original_status="$tmp_dir/original-unknown-rule-override.status"

  run_case_in_dir "$original_pwd" "current ari-lint" "$current_lint" "unknown-rule-override" "$current_stdout" "$current_stderr" "$current_status" --rule unknown-rule=warning "$trailing_source"
  run_case_in_dir "$original_pwd" "original tools/lint" "$original_lint" "unknown-rule-override" "$original_stdout" "$original_stderr" "$original_status" --rule unknown-rule=warning "$trailing_source"

  printf '%s\n' "case: unknown-rule-override"
  print_unknown_rule_override_summary "current ari-lint" "$current_stdout" "$current_stderr" "$current_status"
  print_unknown_rule_override_summary "original tools/lint" "$original_stdout" "$original_stderr" "$original_status"
  printf '%s\n' ""
}

if [ "$#" -gt 3 ]; then
  usage
  exit 1
fi

original_pwd=$(pwd)
script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)

compiler=$(resolve_from_original_pwd "${1:-${ARI_COMPILER:-}}")
ari_repo_input="${2:-${ARI_REPO:-}}"
original_lint_input="${3:-${ORIGINAL_LINT:-}}"

if [ -z "$compiler" ]; then
  usage
  fail "missing Ari compiler path; pass it as the first argument or set ARI_COMPILER"
fi
require_executable "$compiler" "Ari compiler path"

if [ -z "$ari_repo_input" ]; then
  usage
  fail "missing ari repository path; pass it as the second argument or set ARI_REPO"
fi
ari_repo=$(resolve_dir_from_original_pwd "$ari_repo_input")
original_lint=$(locate_original_lint "$original_lint_input")

"$script_dir/build.sh" "$compiler" || fail "ari-lint build failed"
current_lint="$repo_root/build/ari-lint"
require_executable "$current_lint" "built ari-lint binary"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ari-lint-parity.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

trailing_source="$tmp_dir/trailing-whitespace.ari"
missing_source="$tmp_dir/missing-final-newline.ari"
clean_source="$tmp_dir/clean.ari"
read_error_source="$tmp_dir/read-error-missing.ari"
missing_compiler_path="$tmp_dir/missing-ari-compiler"
compiler_error_source="$tmp_dir/compiler-error.ari"
explicit_config_file="$tmp_dir/explicit.rules"
off_config_file="$tmp_dir/off.rules"
config_read_error_file="$tmp_dir/missing-config.rules"
invalid_config_file="$tmp_dir/invalid.rules"
discovery_parent="$tmp_dir/discovery"
discovery_child="$discovery_parent/child"
discovered_source="$discovery_child/discovered.ari"
multi_dirty_one="$tmp_dir/multi-dirty-one.ari"
multi_dirty_two="$tmp_dir/multi-dirty-two.ari"

{
  printf '%s  \n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$trailing_source"

printf '%s' "fn main() -> i64 { return 0; }" > "$missing_source"
printf '%s\n' "this is not valid Ari source" > "$compiler_error_source"

{
  printf '%s\n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$clean_source"

printf '%s\n' "lint/trailing-whitespace = error" > "$explicit_config_file"
printf '%s\n' "lint/trailing-whitespace = off" > "$off_config_file"
printf '%s\n' "lint/unknown-rule = warning" > "$invalid_config_file"

mkdir -p "$discovery_child"
printf '%s\n' "lint/trailing-whitespace = note" > "$discovery_parent/ari-lint.rules"
{
  printf '%s  \n' "fn main() -> i64 {"
  printf '%s\n' "  return 0;"
  printf '%s\n' "}"
} > "$discovered_source"

{
  printf '%s  \n' "fn main() -> i64 {"
  printf '%s\n' "  return 1;"
  printf '%s\n' "}"
} > "$multi_dirty_one"

printf '%s' "fn main() -> i64 { return 2; }" > "$multi_dirty_two"

printf '%s\n' "ari-lint local parity smoke report"
printf '%s\n' "current ari-lint: $current_lint"
printf '%s\n' "original tools/lint: $original_lint"
printf '%s\n' "ari compiler: $compiler"
printf '%s\n' "ari repo: $ari_repo"
printf '%s\n' "original entrypoint evidence: Makefile LINT_TARGET plus tools/lint/main.cpp usage"
printf '%s\n' ""

report_help_case
report_short_help_case
report_no_source_file_case
report_read_error_case
report_missing_compiler_case
report_compiler_error_case
report_unknown_argument_case
report_missing_config_value_case
report_missing_rule_value_case
report_missing_ari_value_case
report_missing_include_value_case
report_list_rules_case
report_json_list_rules_case

for case_name in trailing-whitespace missing-final-newline clean; do
  case "$case_name" in
    trailing-whitespace) source_path="$trailing_source" ;;
    missing-final-newline) source_path="$missing_source" ;;
    clean) source_path="$clean_source" ;;
    *) fail "unknown parity case: $case_name" ;;
  esac

  report_case "$case_name" "$original_pwd" "$source_path" "$source_path"
done

report_case "explicit-config" "$original_pwd" "$trailing_source" --config "$explicit_config_file" "$trailing_source"
report_case "config-off" "$original_pwd" "$trailing_source" --config "$off_config_file" "$trailing_source"
report_config_read_error_case
report_invalid_config_case
report_invalid_rule_override_case
report_invalid_rule_severity_case
report_unknown_rule_override_case
report_case "rule-off" "$original_pwd" "$trailing_source" --rule trailing-whitespace=off "$trailing_source"
report_case "rule-override" "$original_pwd" "$trailing_source" --config "$explicit_config_file" --rule trailing-whitespace=note "$trailing_source"
report_case "include-path" "$original_pwd" "$trailing_source" -I "$tmp_dir" "$trailing_source"
report_case "discovered-config" "$discovery_parent" "child/discovered.ari" "child/discovered.ari"
report_case "multi-file" "$original_pwd" "$multi_dirty_one|$multi_dirty_two" "$multi_dirty_one" "$multi_dirty_two"

printf '%s\n' "known differences:"
printf '%s\n' "- current Ari-language ari-lint does not invoke ari --check yet; original tools/lint does."
printf '%s\n' "- current JSON diagnostics are a flat array with filePath/ruleCode fields; original tools/lint emits a files array with path/diagnostics and code/source fields."
printf '%s\n' "- current clean and disabled-rule JSON outputs omit file path entries; original tools/lint keeps per-file entries with empty diagnostics."
printf '%s\n' "- diagnostic exit codes may differ while this repository has no stable exit-code compatibility claim."
printf '%s\n' "- current help output is multi-line stdout text; original tools/lint help is a one-line stderr usage."
printf '%s\n' "- current no-source-file usage output reports a missing source file; original tools/lint prints generic usage."
printf '%s\n' "- current read-error output reports a short stderr message; original tools/lint emits compiler-shaped JSON diagnostics on stdout."
printf '%s\n' "- current missing-compiler output reports clean lint results; original tools/lint emits compiler-check-failed JSON diagnostics."
printf '%s\n' "- current compiler-error output reports clean lint results; original tools/lint emits compiler-shaped JSON diagnostics."
printf '%s\n' "- current unknown-option usage output reports the first unknown argument; original tools/lint prints generic usage."
printf '%s\n' "- current missing-config-value usage output reports the missing option value; original tools/lint prints generic usage."
printf '%s\n' "- current config-read-error output reports a short unable-to-read message; original tools/lint reports cannot open lint config."
printf '%s\n' "- current missing-rule-value usage output reports the missing option value; original tools/lint prints generic usage."
printf '%s\n' "- current missing-ari-value usage output reports the missing option value; original tools/lint prints generic usage."
printf '%s\n' "- current missing-include-value usage output reports the missing option value; original tools/lint prints generic usage."
printf '%s\n' "- current list-rules output includes short rule name fields; original tools/lint list-rules output does not."
printf '%s\n' "- current JSON list-rules output includes short rule name fields; original tools/lint JSON list-rules output does not."
printf '%s\n' "- current invalid-config output reports invalid command-line arguments; original tools/lint reports the config file line and unknown rule or severity."
printf '%s\n' "- current invalid-rule-override output reports invalid --rule override; original tools/lint reports invalid rule setting."
printf '%s\n' "- current invalid-rule-severity output reports invalid --rule override; original tools/lint reports invalid rule setting and unknown rule or severity."
printf '%s\n' "- current unknown-rule-override output reports invalid --rule override; original tools/lint reports invalid rule setting and unknown rule or severity."
printf '%s\n' ""
printf '%s\n' "parity result: report-only; differences above do not fail this script."
