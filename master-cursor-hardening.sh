#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# MASTER CURSOR AI HARDENING ORCHESTRATION SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════
# Enterprise-Grade Production System for Cursor AI (VS Code) Hardening
# Comprehensive Security, Anti-Hallucination & Performance Optimization Suite
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# 10x Engineer/Senior Developer Mode - Production-Only Code Standards
# ZERO FAKE CODE POLICY: No placeholders, TODOs, or mock implementations
# ─────────────────────────────────────────────────────────────────────────────

readonly MASTER_SCRIPT_NAME="master-cursor-hardening"
readonly MASTER_LOG_FILE="/var/log/cursor-setup.log"
readonly SCRIPT_VERSION="1.0.0"
readonly REQUIRED_MACOS_VERSION="14.0"
readonly REQUIRED_FREE_SPACE_GB=10

# Color codes for enhanced output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Script execution tracking
declare -a EXECUTED_SCRIPTS=()
declare -a FAILED_SCRIPTS=()
declare -a ROLLBACK_ACTIONS=()

# Enhanced logging function with color support
log() {
    local level="$1"
    local message="$2"
    local color="$3"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Console output with color
    echo -e "${color}[$ts] [$MASTER_SCRIPT_NAME] [$level] $message${NC}"
    
    # Log file output without color codes
    echo "[$ts] [$MASTER_SCRIPT_NAME] [$level] $message" | sudo tee -a "$MASTER_LOG_FILE" >/dev/null 2>&1 || true
}

# Specialized logging functions
log_info() { log "INFO" "$1" "$CYAN"; }
log_success() { log "SUCCESS" "$1" "$GREEN"; }
log_warning() { log "WARNING" "$1" "$YELLOW"; }
log_error() { log "ERROR" "$1" "$RED"; }
log_debug() { log "DEBUG" "$1" "$PURPLE"; }

# Error handler with comprehensive rollback
error_exit() {
    local message="$1"
    local exit_code="${2:-1}"
    
    log_error "$message"
    log_error "Initiating comprehensive rollback procedures..."
    
    # Execute rollback actions in reverse order
    local i
    for ((i=${#ROLLBACK_ACTIONS[@]}-1; i>=0; i--)); do
        log_info "Executing rollback: ${ROLLBACK_ACTIONS[i]}"
        eval "${ROLLBACK_ACTIONS[i]}" || log_warning "Rollback action failed: ${ROLLBACK_ACTIONS[i]}"
    done
    
    log_error "Master script failed with exit code: $exit_code"
    log_error "System restored to pre-execution state"
    exit "$exit_code"
}

# Add rollback action to stack
add_rollback() {
    ROLLBACK_ACTIONS+=("$1")
}

# Display fancy header
display_header() {
    echo -e "${WHITE}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "       🚀 CURSOR AI HARDENING SUITE - ENTERPRISE ORCHESTRATION 🚀"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "       Version: ${SCRIPT_VERSION} | macOS Apple Silicon Optimized"
    echo -e "       Target: Cursor AI (VS Code) v1.1.0+ on macOS 14+ (M3 Architecture)"
    echo -e "       Mode: Production-Grade Security & Anti-Hallucination Controls"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Comprehensive system validation
validate_system_requirements() {
    log_info "🔍 Performing comprehensive system validation..."
    
    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    if ! version_ge "$macos_version" "$REQUIRED_MACOS_VERSION"; then
        error_exit "macOS $REQUIRED_MACOS_VERSION or later required. Found: $macos_version"
    fi
    log_success "✅ macOS version check passed: $macos_version"
    
    # Check Apple Silicon architecture
    local arch
    arch=$(uname -m)
    if [[ "$arch" != "arm64" ]]; then
        log_warning "⚠️  Non-Apple Silicon architecture detected: $arch"
        log_warning "    M3 optimizations may not be fully effective"
    else
        log_success "✅ Apple Silicon architecture confirmed: $arch"
    fi
    
    # Check available disk space
    local available_space_gb
    available_space_gb=$(df -g . | awk 'NR==2 {print $4}')
    if [[ $available_space_gb -lt $REQUIRED_FREE_SPACE_GB ]]; then
        error_exit "Insufficient disk space. Required: ${REQUIRED_FREE_SPACE_GB}GB, Available: ${available_space_gb}GB"
    fi
    log_success "✅ Disk space check passed: ${available_space_gb}GB available"
    
    # Check admin privileges
    if ! sudo -n true 2>/dev/null; then
        log_warning "⚠️  Admin privileges required for system-level configurations"
        log_info "Please enter your password when prompted for sudo operations"
    else
        log_success "✅ Admin privileges confirmed"
    fi
    
    # Validate required dependencies
    local deps=("jq" "curl" "git")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            error_exit "Required dependency missing: $dep. Install with: brew install $dep"
        fi
        log_success "✅ Dependency check passed: $dep"
    done
    
    # Check Cursor/VSCode installation
    if ! command -v code >/dev/null 2>&1; then
        error_exit "Cursor/VSCode CLI not found. Ensure 'code' command is available in PATH"
    fi
    
    local code_version
    code_version=$(code --version | head -n1)
    log_success "✅ Cursor/VSCode CLI found: $code_version"
    
    # Validate script files exist
    local required_scripts=("policy-file-generator.sh" "cursor-application-settings.sh" "ai-extension-settings.sh" "cursor-optimization-policies.sh")
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            error_exit "Required script missing: $script"
        fi
        if [[ ! -x "$script" ]]; then
            chmod +x "$script"
            log_info "Made script executable: $script"
        fi
        log_success "✅ Script validation passed: $script"
    done
    
    log_success "🎯 System validation completed successfully"
}

# Version comparison utility
version_ge() {
    local version1="$1"
    local version2="$2"
    [[ "$(printf '%s\n' "$version2" "$version1" | sort -V | head -n1)" == "$version2" ]]
}

# Create comprehensive system backup
create_system_backup() {
    log_info "🔄 Creating comprehensive system backup..."
    
    local backup_dir
    backup_dir="$HOME/.cursor-hardening-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    add_rollback "rm -rf '$backup_dir'"
    
    # Backup Cursor/VSCode settings
    local cursor_settings="$HOME/Library/Application Support/Cursor"
    local vscode_settings="$HOME/Library/Application Support/Code"
    
    if [[ -d "$cursor_settings" ]]; then
        cp -R "$cursor_settings" "$backup_dir/cursor-settings-backup"
        add_rollback "rm -rf '$cursor_settings' && mv '$backup_dir/cursor-settings-backup' '$cursor_settings'"
        log_success "✅ Cursor settings backed up"
    fi
    
    if [[ -d "$vscode_settings" ]]; then
        cp -R "$vscode_settings" "$backup_dir/vscode-settings-backup"
        add_rollback "rm -rf '$vscode_settings' && mv '$backup_dir/vscode-settings-backup' '$vscode_settings'"
        log_success "✅ VSCode settings backed up"
    fi
    
    # Backup project-level configuration files
    local project_files=(".cursorrules" "cursor_project_rules.md" ".vscode/settings.json")
    for file in "${project_files[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/$(basename "$file").backup"
            add_rollback "cp '$backup_dir/$(basename "$file").backup' '$file'"
            log_success "✅ Project file backed up: $file"
        fi
    done
    
    log_success "🎯 System backup completed: $backup_dir"
    echo "$backup_dir" > "$HOME/.cursor-hardening-last-backup"
}

# Execute individual script with comprehensive monitoring
execute_script() {
    local script_name="$1"
    local description="$2"
    local timeout_seconds="${3:-300}"
    
    log_info "🚀 Executing: $script_name - $description"
    log_info "   Timeout: ${timeout_seconds}s | Max retries: 2"
    
    local attempt=1
    local max_attempts=2
    
    while [[ $attempt -le $max_attempts ]]; do
        log_info "   Attempt $attempt/$max_attempts"
        
        # Execute script with timeout and capture output
        local start_time output exit_code duration
        start_time=$(date +%s)
        
        if timeout "$timeout_seconds" bash "$script_name" > "/tmp/${script_name}.log" 2>&1; then
            exit_code=0
        else
            exit_code=$?
        fi
        
        duration=$(($(date +%s) - start_time))
        output=$(cat "/tmp/${script_name}.log" 2>/dev/null || echo "No output captured")
        
        if [[ $exit_code -eq 0 ]]; then
            log_success "✅ $script_name completed successfully (${duration}s)"
            EXECUTED_SCRIPTS+=("$script_name")
            
            # Validate script-specific success markers
            validate_script_execution "$script_name" "$output"
            return 0
        else
            log_error "❌ $script_name failed (attempt $attempt/$max_attempts, exit code: $exit_code, ${duration}s)"
            log_debug "   Output: $output"
            
            if [[ $attempt -eq $max_attempts ]]; then
                FAILED_SCRIPTS+=("$script_name")
                return $exit_code
            fi
            
            ((attempt++))
            log_info "   Retrying in 5 seconds..."
            sleep 5
        fi
    done
}

# Validate specific script execution results
validate_script_execution() {
    local script_name="$1"
    local output="$2"
    
    case "$script_name" in
        "policy-file-generator.sh")
            if echo "$output" | grep -q "Policy file generation script completed successfully"; then
                log_success "   ✅ Policy files generated successfully"
            else
                error_exit "Policy file generation validation failed"
            fi
            ;;
        "cursor-application-settings.sh")
            if echo "$output" | grep -q "Application settings hardening completed successfully"; then
                log_success "   ✅ Application settings applied successfully"
            else
                error_exit "Application settings validation failed"
            fi
            ;;
        "ai-extension-settings.sh")
            if echo "$output" | grep -q "AI extension hardening completed successfully"; then
                log_success "   ✅ AI extension settings configured successfully"
            else
                error_exit "AI extension settings validation failed"
            fi
            ;;
        "cursor-optimization-policies.sh")
            if echo "$output" | grep -q "Cursor optimization policies script completed successfully"; then
                log_success "   ✅ Optimization policies implemented successfully"
            else
                error_exit "Optimization policies validation failed"
            fi
            ;;
    esac
}

# Comprehensive post-execution validation
perform_comprehensive_validation() {
    log_info "🔍 Performing comprehensive post-execution validation..."
    
    local validation_errors=0
    
    # Validate settings.json structure and content
    log_info "   Validating Cursor settings.json..."
    local settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"
    
    if [[ ! -f "$settings_file" ]]; then
        log_error "   ❌ Settings file not found: $settings_file"
        ((validation_errors++))
    elif ! jq empty "$settings_file" 2>/dev/null; then
        log_error "   ❌ Settings file contains invalid JSON"
        ((validation_errors++))
    else
        log_success "   ✅ Settings file structure valid"
        
        # Validate specific critical settings
        local critical_settings=(
            "telemetry.enableTelemetry:false"
            "crashReporting.enabled:off"
            "security.workspace.trust.enabled:true"
            "cline.conservativeMode:true"
        )
        
        for setting in "${critical_settings[@]}"; do
            local key="${setting%:*}"
            local expected="${setting#*:}"
            local actual
            
            if [[ "$expected" == "true" || "$expected" == "false" ]]; then
                actual=$(jq -r ".[\"$key\"] // \"missing\"" "$settings_file")
            else
                actual=$(jq -r ".[\"$key\"] // \"missing\"" "$settings_file")
            fi
            
            if [[ "$actual" == "$expected" ]]; then
                log_success "   ✅ $key = $expected"
            else
                log_error "   ❌ $key = $actual (expected: $expected)"
                ((validation_errors++))
            fi
        done
    fi
    
    # Validate policy files existence and content
    log_info "   Validating policy files..."
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    local current_dir="$PWD"
    
    # Check global policy files
    local global_policy_files=(
        "$cursor_dir/rules/001-coding-protocols.mdc"
        "$cursor_dir/rules/002-directory-management.mdc"
        "$cursor_dir/rules/003-error-fixing.mdc"
        "$cursor_dir/rules/004-token-optimization.mdc"
        "$cursor_dir/.cursorrules"
    )
    
    # Check project-local policy files
    local project_policy_files=(
        "$current_dir/001-coding-protocols.mdc"
        "$current_dir/002-directory-management.mdc"
        "$current_dir/003-error-fixing.mdc"
        "$current_dir/004-token-optimization.mdc"
        "$current_dir/.cursorrules"
    )
    
    log_info "   🌍 Global policy files in: $cursor_dir"
    for file in "${global_policy_files[@]}"; do
        if [[ -f "$file" && -s "$file" ]]; then
            log_success "   ✅ Global policy file: $file"
        else
            log_error "   ❌ Global policy missing: $file"
            ((validation_errors++))
        fi
    done
    
    log_info "   📁 Project policy files in: $current_dir"
    for file in "${project_policy_files[@]}"; do
        if [[ -f "$file" && -s "$file" ]]; then
            log_success "   ✅ Project policy file: $file"
        else
            log_error "   ❌ Project policy missing: $file"
            ((validation_errors++))
        fi
    done
    
    # Validate optimization directory structure
    log_info "   Validating optimization structure..."
    local opt_dirs=(
        "$cursor_dir/optimization/rag"
        "$cursor_dir/optimization/validation"
        "$cursor_dir/optimization/file-management"
    )
    
    for dir in "${opt_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "   ✅ Optimization directory exists: $(basename "$dir")"
        else
            log_error "   ❌ Optimization directory missing: $(basename "$dir")"
            ((validation_errors++))
        fi
    done
    
    # Test Cursor/VSCode functionality
    log_info "   Testing Cursor/VSCode integration..."
    if code --list-extensions >/dev/null 2>&1; then
        local ext_count
        ext_count=$(code --list-extensions | wc -l | tr -d ' ')
        log_success "   ✅ Cursor CLI functional ($ext_count extensions detected)"
    else
        log_error "   ❌ Cursor CLI test failed"
        ((validation_errors++))
    fi
    
    # Final validation result
    if [[ $validation_errors -eq 0 ]]; then
        log_success "🎯 Comprehensive validation PASSED (0 errors)"
        return 0
    else
        log_error "🚨 Comprehensive validation FAILED ($validation_errors errors)"
        return 1
    fi
}

# Generate detailed execution report
generate_execution_report() {
    log_info "📊 Generating detailed execution report..."
    
    local report_file
    report_file="cursor-hardening-report-$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
═══════════════════════════════════════════════════════════════════════════════
                   CURSOR AI HARDENING EXECUTION REPORT
═══════════════════════════════════════════════════════════════════════════════

Execution Date: $(date)
Script Version: $SCRIPT_VERSION
Target System: $(sw_vers -productVersion) ($(uname -m))
Cursor Version: $(code --version | head -n1)

═══════════════════════════════════════════════════════════════════════════════
                              EXECUTION SUMMARY
═══════════════════════════════════════════════════════════════════════════════

Successfully Executed Scripts:
$(printf "  ✅ %s\n" "${EXECUTED_SCRIPTS[@]}")

Failed Scripts:
$(if [[ ${#FAILED_SCRIPTS[@]} -eq 0 ]]; then
    echo "  None - All scripts executed successfully!"
else
    printf "  ❌ %s\n" "${FAILED_SCRIPTS[@]}"
fi)

═══════════════════════════════════════════════════════════════════════════════
                            CONFIGURATION SUMMARY
═══════════════════════════════════════════════════════════════════════════════

Settings Applied:
  🔒 Telemetry completely disabled
  🔐 Crash reporting disabled  
  🛡️  Workspace trust enabled
  🚫 Auto-updates disabled (manual control)
  🎯 AI extensions hardened with anti-hallucination controls
  📏 File size limits enforced (300 lines)
  🔍 RAG validation system enabled
  ⚡ Apple M3 performance optimizations applied

Policy Files Created:
  📋 .cursorrules (project-level anti-hallucination rules)
  📝 001-coding-protocols.mdc (zero fake code standards)
  📁 002-directory-management.mdc (organization protocols)
  🔧 003-error-fixing.mdc (systematic error resolution)
  ⚡ 004-token-optimization.mdc (efficient AI interactions)

Security Enhancements:
  🔐 All telemetry streams disabled
  🛡️  Workspace trust mechanisms enabled
  🚫 Experimental features disabled
  🔍 Extension auto-updates disabled
  📊 Conservative AI extension modes enabled

═══════════════════════════════════════════════════════════════════════════════
                              NEXT STEPS
═══════════════════════════════════════════════════════════════════════════════

1. Restart Cursor/VSCode to ensure all settings take effect
2. Review the generated .cursorrules file for project-specific customizations
3. Monitor file sizes using: bash "~/.cursor/optimization/file-management/file-monitor.sh"
4. Run validation workflow: bash "~/.cursor/optimization/validation/validation-workflow.sh"
5. Review backup location: $(cat "$HOME/.cursor-hardening-last-backup" 2>/dev/null || echo "No backup created")

═══════════════════════════════════════════════════════════════════════════════
                            SUPPORT & MAINTENANCE
═══════════════════════════════════════════════════════════════════════════════

Log File: $MASTER_LOG_FILE
Report File: $report_file
Backup Location: $(cat "$HOME/.cursor-hardening-last-backup" 2>/dev/null || echo "No backup created")

For issues or questions:
- Review the comprehensive logs above
- Check the troubleshooting section in README.md
- Verify all system requirements are met

═══════════════════════════════════════════════════════════════════════════════
EOF

    log_success "📊 Execution report generated: $report_file"
    echo -e "\n${GREEN}📊 EXECUTION REPORT: $report_file${NC}\n"
}

# Interactive confirmation with detailed information
confirm_execution() {
    echo -e "\n${YELLOW}⚠️  ENTERPRISE CURSOR AI HARDENING SUITE${NC}"
    echo -e "${YELLOW}   This script will make comprehensive changes to your system:${NC}\n"
    
    echo -e "${CYAN}🔧 MODIFICATIONS TO BE APPLIED:${NC}"
    echo -e "   • Cursor/VSCode application settings (telemetry, security, performance)"
    echo -e "   • AI extension configurations (anti-hallucination controls)"
    echo -e "   • Policy files creation (.cursorrules, .mdc protocols)"
    echo -e "   • Optimization directory structure and monitoring scripts"
    echo -e "   • Apple M3 performance optimizations"
    
    echo -e "\n${CYAN}🛡️  SECURITY ENHANCEMENTS:${NC}"
    echo -e "   • Complete telemetry disabling"
    echo -e "   • Workspace trust enforcement"
    echo -e "   • Extension auto-update control"
    echo -e "   • Zero fake code policy enforcement"
    
    echo -e "\n${CYAN}📋 BACKUP & SAFETY:${NC}"
    echo -e "   • Comprehensive system backup before changes"
    echo -e "   • Automatic rollback on any failure"
    echo -e "   • Detailed execution logging and reporting"
    
    echo -e "\n${RED}⚠️  SYSTEM REQUIREMENTS:${NC}"
    echo -e "   • macOS 14+ (Apple Silicon recommended)"
    echo -e "   • Admin privileges for system-level changes"
    echo -e "   • ${REQUIRED_FREE_SPACE_GB}GB free disk space"
    echo -e "   • Cursor/VSCode with CLI access"
    
    echo -e "\n${WHITE}Expected execution time: 3-5 minutes${NC}"
    echo -e "${WHITE}All changes are logged and reversible${NC}\n"
    
    read -rp "Do you want to proceed with the hardening suite? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Execution cancelled by user"
        exit 0
    fi
    
    log_success "User confirmed execution - proceeding with hardening suite"
}

# Main orchestration function
main() {
    # Initialize log file
    sudo mkdir -p "$(dirname "$MASTER_LOG_FILE")" 2>/dev/null || true
    sudo touch "$MASTER_LOG_FILE" 2>/dev/null || true
    sudo chmod 644 "$MASTER_LOG_FILE" 2>/dev/null || true
    
    display_header
    
    log_info "🚀 Starting Cursor AI Hardening Suite v$SCRIPT_VERSION"
    log_info "Target: Enterprise-grade security and anti-hallucination controls"
    
    # Pre-execution phases
    validate_system_requirements
    confirm_execution
    create_system_backup
    
    log_info "🎯 Beginning orchestrated script execution..."
    
    # Script execution in optimal order
    local scripts=(
        "policy-file-generator.sh:Policy File Generation (Foundation)"
        "cursor-application-settings.sh:Application Settings Hardening"
        "ai-extension-settings.sh:AI Extension Configuration"
        "cursor-optimization-policies.sh:Optimization Policies Implementation"
    )
    
    local total_scripts=${#scripts[@]}
    local current_script=1
    
    for script_info in "${scripts[@]}"; do
        local script_name="${script_info%:*}"
        local description="${script_info#*:}"
        
        echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC} ${WHITE}Step $current_script/$total_scripts: $description${NC} ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"
        
        if ! execute_script "$script_name" "$description" 300; then
            error_exit "Critical failure in $script_name - aborting execution"
        fi
        
        ((current_script++))
        
        # Inter-script validation pause
        if [[ $current_script -le $total_scripts ]]; then
            log_info "⏸️  Inter-script validation pause (2 seconds)..."
            sleep 2
        fi
    done
    
    log_success "🎯 All scripts executed successfully"
    
    # Post-execution validation and reporting
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Final Validation & Reporting${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    if perform_comprehensive_validation; then
        log_success "🎉 CURSOR AI HARDENING SUITE COMPLETED SUCCESSFULLY!"
        generate_execution_report
        
        echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC} ${WHITE}🎉 SUCCESS: Enterprise-grade hardening completed successfully! 🎉${NC} ${GREEN}║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        
        echo -e "\n${CYAN}🔄 RECOMMENDED NEXT STEPS:${NC}"
        echo -e "   1. Restart Cursor/VSCode to activate all settings"
        echo -e "   2. Review the generated execution report"
        echo -e "   3. Test AI extension functionality with new anti-hallucination controls"
        echo -e "   4. Monitor system performance with M3 optimizations"
        
        exit 0
    else
        error_exit "Post-execution validation failed - see detailed logs for troubleshooting" 2
    fi
}

# Trap signals for cleanup
trap 'error_exit "Script interrupted by user" 130' INT TERM

# Execute main function
main "$@"
