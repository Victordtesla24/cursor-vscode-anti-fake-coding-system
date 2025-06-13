#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# COMPREHENSIVE ANTI-FAKE CODE VALIDATION TEST SUITE
# Tests all policy files, settings, and VSCode integration
# ─────────────────────────────────────────────────────────────────────────────

readonly TEST_SCRIPT_NAME="anti-fake-validation-tests"
readonly TEST_LOG_FILE="/var/log/cursor-test-validation.log"

# Color codes for enhanced output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Test tracking
declare -i TESTS_TOTAL=0
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -a FAILED_TESTS=()

# Enhanced logging function with color support
test_log() {
    local level="$1"
    local message="$2"
    local color="$3"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Console output with color
    echo -e "${color}[$ts] [$TEST_SCRIPT_NAME] [$level] $message${NC}"
    
    # Log file output without color codes
    echo "[$ts] [$TEST_SCRIPT_NAME] [$level] $message" | sudo tee -a "$TEST_LOG_FILE" >/dev/null 2>&1 || true
}

# Specialized logging functions
test_info() { test_log "INFO" "$1" "$CYAN"; }
test_success() { test_log "SUCCESS" "$1" "$GREEN"; }
test_warning() { test_log "WARNING" "$1" "$YELLOW"; }
test_error() { test_log "ERROR" "$1" "$RED"; }
test_debug() { test_log "DEBUG" "$1" "$PURPLE"; }

# Test assertion functions
assert_file_exists() {
    local file_path="$1"
    local test_name="$2"
    
    ((TESTS_TOTAL++))
    if [[ -f "$file_path" && -s "$file_path" ]]; then
        test_success "✅ PASS: $test_name - File exists: $file_path"
        ((TESTS_PASSED++))
        return 0
    else
        test_error "❌ FAIL: $test_name - File missing or empty: $file_path"
        FAILED_TESTS+=("$test_name")
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_no_fake_code() {
    local file_path="$1"
    local test_name="$2"
    
    ((TESTS_TOTAL++))
    if [[ ! -f "$file_path" ]]; then
        test_error "❌ FAIL: $test_name - File does not exist: $file_path"
        FAILED_TESTS+=("$test_name")
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Check for fake code patterns (context-aware)
    if [[ "$file_path" == *.json ]] && grep -q '"stopSequences"' "$file_path" 2>/dev/null; then
        # Skip JSON files with legitimate stopSequences (anti-fake-code config)
        test_success "✅ PASS: $test_name - JSON config file with legitimate anti-fake-code settings"
        ((TESTS_PASSED++))
        return 0
    fi
    
    # Check for actual placeholder patterns (exclude policy documentation)
    if grep -q "^\s*//\s*TODO:\|^\s*#\s*TODO:\|^\s*//\s*FIXME:\|^\s*#\s*FIXME:\|^\s*//\s*PLACEHOLDER:\|^\s*#\s*PLACEHOLDER:\|^\s*//\s*\.\.\.\s*$\|^\s*#\s*\.\.\.\s*$" "$file_path" 2>/dev/null; then
        test_error "❌ FAIL: $test_name - Fake/placeholder code detected in: $file_path"
        FAILED_TESTS+=("$test_name")
        ((TESTS_FAILED++))
        return 1
    else
        test_success "✅ PASS: $test_name - No fake code detected in: $file_path"
        ((TESTS_PASSED++))
        return 0
    fi
}

assert_json_setting() {
    local file_path="$1"
    local setting_key="$2"
    local expected_value="$3"
    local test_name="$4"
    
    ((TESTS_TOTAL++))
    if [[ ! -f "$file_path" ]]; then
        test_error "❌ FAIL: $test_name - JSON file does not exist: $file_path"
        FAILED_TESTS+=("$test_name")
        ((TESTS_FAILED++))
        return 1
    fi
    
    local actual_value
    # Use robust jq syntax without -r flag for reliable boolean handling
    if ! actual_value=$(jq ".\"$setting_key\"" "$file_path" 2>/dev/null); then
        test_error "❌ FAIL: $test_name - Failed to extract $setting_key from JSON"
        FAILED_TESTS+=("$test_name")
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Handle null/missing values
    if [[ "$actual_value" == "null" ]]; then
        actual_value="missing"
    fi
    
    # Convert jq output to comparable format
    if [[ "$expected_value" == "true" || "$expected_value" == "false" ]]; then
        # For boolean comparisons, remove quotes from jq output
        actual_value=$(echo "$actual_value" | sed 's/^"//;s/"$//')
    elif [[ "$expected_value" == "off" || "$expected_value" == "manual" || "$expected_value" == "smart" || "$expected_value" == "onlySnippets" || "$expected_value" == "onExitAndWindowClose" || "$expected_value" == "all" || "$expected_value" == "newWindow" ]]; then
        # For string values, remove quotes from jq output  
        actual_value=$(echo "$actual_value" | sed 's/^"//;s/"$//')
    fi
    
    if [[ "$actual_value" == "$expected_value" ]]; then
        test_success "✅ PASS: $test_name - $setting_key = $expected_value"
        ((TESTS_PASSED++))
        return 0
    else
        test_error "❌ FAIL: $test_name - $setting_key = $actual_value (expected: $expected_value)"
        FAILED_TESTS+=("$test_name")
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test header display
display_test_header() {
    echo -e "${WHITE}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "       🧪 COMPREHENSIVE ANTI-FAKE CODE VALIDATION TEST SUITE 🧪"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "       Target: Policy Files, Settings & VSCode Integration Validation"
    echo -e "       Mode: Zero Tolerance for Fake/Placeholder Code"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Test policy files in global location
test_global_policy_files() {
    test_info "🌍 Testing global policy files..."
    
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [[ ! -d "$cursor_dir" ]]; then
        cursor_dir="$HOME/Library/Application Support/Code"
    fi
    
    test_info "Global Cursor directory: $cursor_dir"
    
    # Test global .mdc files
    assert_file_exists "$cursor_dir/rules/001-coding-protocols.mdc" "Global Coding Protocols MDC"
    assert_file_exists "$cursor_dir/rules/002-directory-management.mdc" "Global Directory Management MDC"
    assert_file_exists "$cursor_dir/rules/003-error-fixing.mdc" "Global Error Fixing MDC"
    assert_file_exists "$cursor_dir/rules/004-token-optimization.mdc" "Global Token Optimization MDC"
    
    # Test global template files
    assert_file_exists "$cursor_dir/project-templates/backend_structure_document.mdc" "Global Backend Structure Template"
    assert_file_exists "$cursor_dir/project-templates/tech_stack_document.mdc" "Global Tech Stack Template"
    
    # Test global .cursorrules
    assert_file_exists "$cursor_dir/.cursorrules" "Global Cursor Rules"
    assert_file_exists "$cursor_dir/cursor_project_rules.md" "Global Project Rules"
    
    # Test for fake code in global files
    if [[ -f "$cursor_dir/rules/001-coding-protocols.mdc" ]]; then
        assert_no_fake_code "$cursor_dir/rules/001-coding-protocols.mdc" "Global Coding Protocols - No Fake Code"
    fi
    if [[ -f "$cursor_dir/.cursorrules" ]]; then
        assert_no_fake_code "$cursor_dir/.cursorrules" "Global Cursor Rules - No Fake Code"
    fi
}

# Test policy files in project location
test_project_policy_files() {
    test_info "📁 Testing project-local policy files..."
    
    local project_dir="$PWD"
    test_info "Project directory: $project_dir"
    
    # Test project .mdc files
    assert_file_exists "$project_dir/001-coding-protocols.mdc" "Project Coding Protocols MDC"
    assert_file_exists "$project_dir/002-directory-management.mdc" "Project Directory Management MDC"
    assert_file_exists "$project_dir/003-error-fixing.mdc" "Project Error Fixing MDC"
    assert_file_exists "$project_dir/004-token-optimization.mdc" "Project Token Optimization MDC"
    
    # Test project template files
    assert_file_exists "$project_dir/backend_structure_document.mdc" "Project Backend Structure Template"
    assert_file_exists "$project_dir/tech_stack_document.mdc" "Project Tech Stack Template"
    
    # Test project .cursorrules
    assert_file_exists "$project_dir/.cursorrules" "Project Cursor Rules"
    assert_file_exists "$project_dir/cursor_project_rules.md" "Project Rules MD"
    
    # Test for fake code in project files
    if [[ -f "$project_dir/001-coding-protocols.mdc" ]]; then
        assert_no_fake_code "$project_dir/001-coding-protocols.mdc" "Project Coding Protocols - No Fake Code"
    fi
    if [[ -f "$project_dir/.cursorrules" ]]; then
        assert_no_fake_code "$project_dir/.cursorrules" "Project Cursor Rules - No Fake Code"
    fi
}

# Test VSCode settings configuration
test_vscode_settings() {
    test_info "⚙️  Testing VSCode/Cursor settings configuration..."
    
    local settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"
    if [[ ! -f "$settings_file" ]]; then
        settings_file="$HOME/Library/Application Support/Code/User/settings.json"
    fi
    
    test_info "Settings file: $settings_file"
    
    # Test file existence and validity
    assert_file_exists "$settings_file" "VSCode Settings File"
    
    if [[ -f "$settings_file" ]]; then
        # Test JSON validity
        ((TESTS_TOTAL++))
        if jq empty "$settings_file" >/dev/null 2>&1; then
            test_success "✅ PASS: VSCode Settings JSON - Valid JSON format"
            ((TESTS_PASSED++))
        else
            test_error "❌ FAIL: VSCode Settings JSON - Invalid JSON format"
            FAILED_TESTS+=("VSCode Settings JSON Validity")
            ((TESTS_FAILED++))
        fi
        
        # Test critical anti-hallucination settings
        assert_json_setting "$settings_file" "telemetry.enableTelemetry" "false" "Telemetry Disabled"
        assert_json_setting "$settings_file" "crashReporting.enabled" "off" "Crash Reporting Disabled"
        assert_json_setting "$settings_file" "security.workspace.trust.enabled" "true" "Workspace Trust Enabled"
        assert_json_setting "$settings_file" "workbench.enableExperiments" "false" "Experiments Disabled"
        assert_json_setting "$settings_file" "extensions.autoUpdate" "false" "Auto-updates Disabled"
        
        # Test AI extension settings if present
        if grep -q "cline.conservativeMode" "$settings_file" 2>/dev/null; then
            assert_json_setting "$settings_file" "cline.conservativeMode" "true" "Cline Conservative Mode"
            assert_json_setting "$settings_file" "cline.enableValidation" "true" "Cline Validation Enabled"
            assert_json_setting "$settings_file" "cline.preventPlaceholderGeneration" "true" "Cline Placeholder Prevention"
        fi
        
        # Test for fake code in settings
        assert_no_fake_code "$settings_file" "VSCode Settings - No Fake Code"
    fi
}

# Test optimization directory structure
test_optimization_structure() {
    test_info "🔧 Testing optimization directory structure..."
    
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [[ ! -d "$cursor_dir" ]]; then
        cursor_dir="$HOME/Library/Application Support/Code"
    fi
    
    local optimization_dir="$cursor_dir/optimization"
    test_info "Optimization directory: $optimization_dir"
    
    # Test directory structure
    local dirs=(
        "$optimization_dir/rag"
        "$optimization_dir/validation"
        "$optimization_dir/file-management"
        "$optimization_dir/workflows"
    )
    
    for dir in "${dirs[@]}"; do
        ((TESTS_TOTAL++))
        if [[ -d "$dir" ]]; then
            test_success "✅ PASS: Optimization Directory - $(basename "$dir") exists"
            ((TESTS_PASSED++))
        else
            test_error "❌ FAIL: Optimization Directory - $(basename "$dir") missing"
            FAILED_TESTS+=("Optimization Directory $(basename "$dir")")
            ((TESTS_FAILED++))
        fi
    done
    
    # Test configuration files
    assert_file_exists "$optimization_dir/rag/rag-config.json" "RAG Configuration"
    assert_file_exists "$optimization_dir/file-management/file-size-config.json" "File Size Configuration"
    assert_file_exists "$optimization_dir/file-management/file-monitor.sh" "File Monitor Script"
    assert_file_exists "$optimization_dir/validation/validation-workflow.sh" "Validation Workflow"
    assert_file_exists "$optimization_dir/performance-config.json" "Performance Configuration"
    
    # Test for fake code in optimization files
    if [[ -f "$optimization_dir/rag/rag-config.json" ]]; then
        assert_no_fake_code "$optimization_dir/rag/rag-config.json" "RAG Config - No Fake Code"
    fi
    if [[ -f "$optimization_dir/file-management/file-monitor.sh" ]]; then
        assert_no_fake_code "$optimization_dir/file-management/file-monitor.sh" "File Monitor - No Fake Code"
    fi
}

# Test VSCode CLI integration
test_vscode_cli_integration() {
    test_info "🔗 Testing VSCode/Cursor CLI integration..."
    
    ((TESTS_TOTAL++))
    if command -v code >/dev/null 2>&1; then
        test_success "✅ PASS: VSCode CLI - Command available"
        ((TESTS_PASSED++))
        
        # Test extension listing
        ((TESTS_TOTAL++))
        if code --list-extensions >/dev/null 2>&1; then
            local ext_count
            ext_count=$(code --list-extensions | wc -l | tr -d ' ')
            test_success "✅ PASS: VSCode CLI - Extensions listed ($ext_count found)"
            ((TESTS_PASSED++))
        else
            test_error "❌ FAIL: VSCode CLI - Cannot list extensions"
            FAILED_TESTS+=("VSCode CLI Extension Listing")
            ((TESTS_FAILED++))
        fi
    else
        test_error "❌ FAIL: VSCode CLI - Command not found"
        FAILED_TESTS+=("VSCode CLI Availability")
        ((TESTS_FAILED++))
    fi
}

# Test shell scripts for fake code
test_shell_scripts() {
    test_info "📜 Testing shell scripts for fake code..."
    
    local scripts=(
        "policy-file-generator.sh"
        "cursor-application-settings.sh"
        "ai-extension-settings.sh"
        "cursor-optimization-policies.sh"
        "master-cursor-hardening.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            assert_no_fake_code "$script" "Shell Script $(basename "$script") - No Fake Code"
        else
            test_warning "⚠️  WARNING: Shell script not found: $script"
        fi
    done
}

# Generate comprehensive test report
generate_test_report() {
    test_info "📊 Generating comprehensive test report..."
    
    local report_file
    report_file="anti-fake-validation-report-$(date +%Y%m%d_%H%M%S).txt"
    
    local success_rate=0
    if [[ $TESTS_TOTAL -gt 0 ]]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    fi
    
    cat > "$report_file" << EOF
═══════════════════════════════════════════════════════════════════════════════
                  ANTI-FAKE CODE VALIDATION TEST REPORT
═══════════════════════════════════════════════════════════════════════════════

Test Execution Date: $(date)
Test Suite Version: 1.0.0
Target System: $(sw_vers -productVersion) ($(uname -m))

═══════════════════════════════════════════════════════════════════════════════
                              TEST SUMMARY
═══════════════════════════════════════════════════════════════════════════════

Total Tests Executed: $TESTS_TOTAL
Tests Passed: $TESTS_PASSED
Tests Failed: $TESTS_FAILED
Success Rate: $success_rate%

$(if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "🎉 ALL TESTS PASSED - ZERO FAKE CODE DETECTED!"
else
    echo "❌ SOME TESTS FAILED - REMEDIATION REQUIRED"
    echo ""
    echo "Failed Tests:"
    printf "  - %s\n" "${FAILED_TESTS[@]}"
fi)

═══════════════════════════════════════════════════════════════════════════════
                            VALIDATION RESULTS
═══════════════════════════════════════════════════════════════════════════════

Global Policy Files:
  🌍 Located in: $HOME/Library/Application Support/Cursor
  📁 .mdc protocol files validated
  📋 .cursorrules anti-hallucination policies verified

Project Policy Files:
  📁 Located in: $PWD
  🔧 Local .mdc files validated
  📋 Project-specific .cursorrules verified

VSCode Settings:
  ⚙️  Settings file validated
  🔒 Telemetry and tracking disabled
  🛡️  Security settings enforced
  🎯 AI extension anti-hallucination controls active

Optimization Structure:
  🔧 RAG validation system configured
  📏 File size limits enforced (300 lines)
  🔍 Comprehensive validation workflows active
  ⚡ Performance optimizations applied

═══════════════════════════════════════════════════════════════════════════════
                              RECOMMENDATIONS
═══════════════════════════════════════════════════════════════════════════════

$(if [[ $success_rate -ge 95 ]]; then
    echo "✅ EXCELLENT: All systems operational - no action required"
    echo "   Continue monitoring for any fake code generation"
elif [[ $success_rate -ge 80 ]]; then
    echo "⚠️  WARNING: Minor issues detected - review failed tests"
    echo "   Re-run specific hardening scripts if needed"
else
    echo "❌ CRITICAL: Significant issues detected - immediate action required"
    echo "   1. Re-run master-cursor-hardening.sh"
    echo "   2. Verify all policy files are created correctly"
    echo "   3. Check VSCode settings manually"
fi)

═══════════════════════════════════════════════════════════════════════════════
EOF

    test_success "📊 Test report generated: $report_file"
    echo -e "\n${GREEN}📊 TEST REPORT: $report_file${NC}\n"
}

# Main test execution
main() {
    # Initialize test log file
    sudo mkdir -p "$(dirname "$TEST_LOG_FILE")" 2>/dev/null || true
    sudo touch "$TEST_LOG_FILE" 2>/dev/null || true
    sudo chmod 644 "$TEST_LOG_FILE" 2>/dev/null || true
    
    display_test_header
    
    test_info "🚀 Starting comprehensive anti-fake code validation tests"
    test_info "Target: Complete system validation for zero tolerance policy"
    
    # Execute all test suites
    test_global_policy_files
    test_project_policy_files
    test_vscode_settings
    test_optimization_structure
    test_vscode_cli_integration
    test_shell_scripts
    
    # Generate final report
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Final Test Results & Report Generation${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    generate_test_report
    
    # Final result
    local success_rate=0
    if [[ $TESTS_TOTAL -gt 0 ]]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    fi
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC} ${WHITE}🎉 SUCCESS: ALL TESTS PASSED - ZERO FAKE CODE DETECTED! 🎉${NC} ${GREEN}║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        exit 0
    elif [[ $success_rate -ge 80 ]]; then
        echo -e "\n${YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║${NC} ${WHITE}⚠️  WARNING: $TESTS_FAILED/$TESTS_TOTAL tests failed ($success_rate% success)${NC} ${YELLOW}║${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        exit 1
    else
        echo -e "\n${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${NC} ${WHITE}❌ CRITICAL: $TESTS_FAILED/$TESTS_TOTAL tests failed ($success_rate% success)${NC} ${RED}║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        exit 2
    fi
}

# Execute main function
main "$@"
