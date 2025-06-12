# ───────────────────────────────
#  Script 2: ai-extension-settings.sh
# ───────────────────────────────
#!/usr/bin/env bash
set -euo pipefail

# AI Extension Settings Hardening Script
# Hardens Cline AI and other AI extensions with anti-hallucination settings

readonly SCRIPT_NAME="ai-extension-settings"
readonly LOG_FILE="/var/log/cursor-setup.log"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Logging function
log() {
    local message="$1"
    echo "[$TIMESTAMP] [$SCRIPT_NAME] $message" | sudo tee -a "$LOG_FILE" >/dev/null
    echo "[$TIMESTAMP] [$SCRIPT_NAME] $message"
}

# Error handler
error_exit() {
    local message="$1"
    log "ERROR: $message"
    exit 1
}

# Get list of installed extensions
get_installed_extensions() {
    if ! command -v code >/dev/null 2>&1; then
        error_exit "VSCode/Cursor CLI 'code' command not available"
    fi
    
    code --list-extensions 2>/dev/null || echo ""
}

# Detect cursor settings directory
detect_cursor_settings() {
    local cursor_path="$HOME/Library/Application Support/Cursor"
    
    if [[ ! -d "$cursor_path" ]]; then
        cursor_path="$HOME/Library/Application Support/Code"
    fi
    
    echo "$cursor_path"
}

# Create timestamped backup
create_backup() {
    local file_path="$1"
    local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
    
    if [[ -f "$file_path" ]]; then
        cp "$file_path" "${file_path}.backup.${backup_timestamp}"
        log "Backup created: ${file_path}.backup.${backup_timestamp}"
    fi
}

# Configure Cline AI extension settings
configure_cline_settings() {
    local settings_file="$1"
    local temp_file=$(mktemp)
    
    # Ensure jq is available
    if ! command -v jq >/dev/null 2>&1; then
        error_exit "jq is required but not installed. Install with: brew install jq"
    fi
    
    # Anti-hallucination settings for Cline AI
    local cline_settings='{
        "cline.enableAutoApproval": false,
        "cline.enableValidation": true,
        "cline.maxFileSize": 200,
        "cline.sessionTimeout": 300000,
        "cline.enableHallucinationDetection": true,
        "cline.conservativeMode": true,
        "cline.requireExplicitInstructions": true,
        "cline.preventPlaceholderGeneration": true,
        "cline.enableSecurityScanning": true,
        "cline.maxTokensPerRequest": 2048,
        "cline.enableSyntaxValidation": true,
        "cline.enableDependencyCheck": true,
        "cline.enableContextValidation": true,
        "cline.memorySettings": {
            "enableMemory": true,
            "sessionExpiration": 86400,
            "maxMemorySize": 1000000
        },
        "cline.modelSettings": {
            "temperature": 0.1,
            "topP": 0.3,
            "maxTokens": 2048,
            "stopSequences": [
                "TODO:",
                "FIXME:",
                "PLACEHOLDER:",
                "// ...",
                "# ..."
            ]
        },
        "cline.validationRules": {
            "requireTests": true,
            "preventSecretExposure": true,
            "enableTypeChecking": true,
            "requireDocumentation": true
        }
    }'
    
    # Initialize empty settings if file doesn't exist
    if [[ ! -f "$settings_file" ]]; then
        echo '{}' > "$settings_file"
    fi
    
    # Merge settings safely
    jq -s '.[0] * .[1]' "$settings_file" <(echo "$cline_settings") > "$temp_file"
    
    # Atomic move
    mv "$temp_file" "$settings_file"
    log "Cline AI anti-hallucination settings applied"
}

# Configure GitHub Copilot settings (if installed)
configure_copilot_settings() {
    local settings_file="$1"
    local temp_file=$(mktemp)
    
    local copilot_settings='{
        "github.copilot.enable": {
            "*": true,
            "yaml": false,
            "plaintext": false,
            "markdown": false
        },
        "github.copilot.advanced": {
            "length": 500,
            "listCount": 3,
            "inlineSuggestCount": 3
        },
        "github.copilot.editor.enableAutoCompletions": true,
        "github.copilot.editor.enableCodeActions": false
    }'
    
    jq -s '.[0] * .[1]' "$settings_file" <(echo "$copilot_settings") > "$temp_file"
    mv "$temp_file" "$settings_file"
    log "GitHub Copilot conservative settings applied"
}

# Configure TabNine settings (if installed)
configure_tabnine_settings() {
    local settings_file="$1"
    local temp_file=$(mktemp)
    
    local tabnine_settings='{
        "tabnine.experimentalAutoImports": false,
        "tabnine.receiveBetaChannelUpdates": false,
        "tabnine.logFilePath": null,
        "tabnine.disable_file_regex": [
            ".*\\.log$",
            ".*\\.env$",
            ".*\\.key$",
            ".*\\.pem$"
        ]
    }'
    
    jq -s '.[0] * .[1]' "$settings_file" <(echo "$tabnine_settings") > "$temp_file"
    mv "$temp_file" "$settings_file"
    log "TabNine conservative settings applied"
}

# Check if extensions are already configured (idempotency)
check_extension_idempotency() {
    local settings_file="$1"
    
    if [[ -f "$settings_file" ]]; then
        if grep -q '"cline.conservativeMode": true' "$settings_file" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Verification function
verify_extension_settings() {
    local settings_file="$1"
    local extensions="$2"
    local verified_count=0
    local total_checks=0
    
    # Check Cline settings if Cline is installed
    if echo "$extensions" | grep -q "saoudrizwan.claude-dev"; then
        local cline_checks=(
            '"cline.conservativeMode": true'
            '"cline.enableValidation": true'
            '"cline.preventPlaceholderGeneration": true'
            '"cline.enableSecurityScanning": true'
            '"cline.requireExplicitInstructions": true'
        )
        total_checks=$((total_checks + ${#cline_checks[@]}))
        
        for check in "${cline_checks[@]}"; do
            if grep -q "$check" "$settings_file" 2>/dev/null; then
                ((verified_count++))
            fi
        done
    fi
    
    # Check Copilot settings if installed
    if echo "$extensions" | grep -q "GitHub.copilot"; then
        total_checks=$((total_checks + 2))
        if grep -q '"github.copilot.editor.enableAutoCompletions": true' "$settings_file" 2>/dev/null; then
            ((verified_count++))
        fi
        if grep -q '"github.copilot.editor.enableCodeActions": false' "$settings_file" 2>/dev/null; then
            ((verified_count++))
        fi
    fi
    
    # Check TabNine settings if installed
    if echo "$extensions" | grep -q "TabNine.tabnine-vscode"; then
        total_checks=$((total_checks + 1))
        if grep -q '"tabnine.experimentalAutoImports": false' "$settings_file" 2>/dev/null; then
            ((verified_count++))
        fi
    fi
    
    if [[ $total_checks -eq 0 ]]; then
        log "No AI extensions found to configure"
        return 0
    fi
    
    local success_rate=$((verified_count * 100 / total_checks))
    log "Extension verification: $verified_count/$total_checks settings applied ($success_rate%)"
    
    if [[ $success_rate -ge 80 ]]; then
        log "SUCCESS: Extension settings verification passed (≥80% applied)"
        return 0
    else
        error_exit "FAILED: Extension settings verification failed (<80% applied)"
    fi
}

# Main execution
main() {
    log "Starting AI extension settings hardening"
    
    # Get installed extensions
    local extensions=$(get_installed_extensions)
    log "Found extensions: $(echo "$extensions" | wc -l | tr -d ' ') total"
    
    # Detect settings location
    local cursor_dir=$(detect_cursor_settings)
    local settings_file="$cursor_dir/User/settings.json"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$settings_file")"
    
    # Check idempotency
    if check_extension_idempotency "$settings_file"; then
        verify_extension_settings "$settings_file" "$extensions"
        log "Script completed (idempotent - no changes needed)"
        exit 0
    fi
    
    # Create backup
    create_backup "$settings_file"
    
    # Configure extensions based on what's installed
    if echo "$extensions" | grep -q "saoudrizwan.claude-dev"; then
        log "Configuring Cline AI extension"
        configure_cline_settings "$settings_file"
    fi
    
    if echo "$extensions" | grep -q "GitHub.copilot"; then
        log "Configuring GitHub Copilot extension"
        configure_copilot_settings "$settings_file"
    fi
    
    if echo "$extensions" | grep -q "TabNine.tabnine-vscode"; then
        log "Configuring TabNine extension"
        configure_tabnine_settings "$settings_file"
    fi
    
    # Verify success
    verify_extension_settings "$settings_file" "$extensions"
    
    log "Script completed successfully"
}

# Run main function
main "$@"
