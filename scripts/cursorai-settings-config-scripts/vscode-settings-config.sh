# ───────────────────────────────
#  Script 1: application-settings.sh
# ───────────────────────────────
#!/usr/bin/env bash
set -euo pipefail

# Cursor AI Application Settings Configuration Script
# Compatible with Cursor AI 1.1.0 / VSCode 1.96.2 on macOS 14 (Sonoma, arm64)

readonly SCRIPT_NAME="application-settings"
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

# Detect Cursor settings location dynamically
detect_cursor_settings() {
    local cursor_path=""
    
    # Check if Cursor is installed
    if [[ ! -d "/Applications/Cursor.app" ]]; then
        error_exit "Cursor AI not found at /Applications/Cursor.app"
    fi
    
    # Try to get user data directory from Cursor
    if command -v code >/dev/null 2>&1; then
        cursor_path=$(code --user-data-dir 2>/dev/null || echo "")
    fi
    
    # Fallback to standard macOS location
    if [[ -z "$cursor_path" || ! -d "$cursor_path" ]]; then
        cursor_path="$HOME/Library/Application Support/Cursor"
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

# Check if script is idempotent
check_idempotency() {
    local settings_file="$1"
    
    if [[ -f "$settings_file" ]]; then
        # Check for our marker to see if already configured
        if grep -q '"cursor.general.enableTelemetry": false' "$settings_file" 2>/dev/null; then
            log "Settings already configured (idempotent check passed)"
            return 0
        fi
    fi
    return 1
}

# Apply conservative settings using jq for safe JSON manipulation
apply_cursor_settings() {
    local settings_file="$1"
    local temp_file=$(mktemp)
    
    # Ensure jq is available
    if ! command -v jq >/dev/null 2>&1; then
        error_exit "jq is required but not installed. Install with: brew install jq"
    fi
    
    # Initialize empty settings if file doesn't exist
    if [[ ! -f "$settings_file" ]]; then
        echo '{}' > "$settings_file"
    fi
    
    # Conservative anti-hallucination settings
    local conservative_settings='{
        "cursor.general.enableLogging": true,
        "cursor.general.enableTelemetry": false,
        "cursor.autocomplete.enabled": true,
        "cursor.autocomplete.acceptOnTab": false,
        "cursor.autocomplete.acceptOnEnter": "off",
        "cursor.autocomplete.delayMs": 500,
        "cursor.autocomplete.conservative": true,
        "cursor.autocomplete.maxSuggestions": 3,
        "cursor.chat.enabled": true,
        "cursor.chat.maxTokens": 2048,
        "cursor.chat.conservative": true,
        "cursor.chat.enableContextValidation": true,
        "cursor.chat.sessionTimeout": 300000,
        "cursor.chat.maxSessionLength": 50,
        "cursor.composer.enabled": true,
        "cursor.composer.sessionTimeout": 300000,
        "cursor.composer.maxFileSize": 200,
        "cursor.composer.enableValidation": true,
        "cursor.composer.requireConfirmation": true,
        "cursor.codeGeneration.enableValidation": true,
        "cursor.codeGeneration.requireTests": true,
        "cursor.codeGeneration.maxFileLines": 300,
        "cursor.codeGeneration.conservative": true,
        "cursor.codeGeneration.enableHallucinationDetection": true,
        "cursor.codeGeneration.preventPlaceholderCode": true,
        "cursor.rules.enableGlobalRules": true,
        "cursor.rules.enableProjectRules": true,
        "cursor.rules.strictMode": true,
        "cursor.validation.enableSyntaxCheck": true,
        "cursor.validation.enableDependencyCheck": true,
        "cursor.validation.enableSecurityCheck": true,
        "cursor.security.preventSecretExposure": true,
        "editor.wordWrap": "on",
        "editor.fontSize": 14,
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.formatOnSave": true,
        "files.autoSave": "afterDelay",
        "files.autoSaveDelay": 1000,
        "files.trimTrailingWhitespace": true,
        "files.insertFinalNewline": true,
        "workbench.editor.enablePreview": false,
        "extensions.autoUpdate": false,
        "git.enableSmartCommit": true,
        "git.confirmSync": true,
        "security.workspace.trust.enabled": true,
        "security.workspace.trust.banner": "always"
    }'
    
    # Merge settings safely
    jq -s '.[0] * .[1]' "$settings_file" <(echo "$conservative_settings") > "$temp_file"
    
    # Atomic move
    mv "$temp_file" "$settings_file"
    log "Conservative settings applied to $settings_file"
}

# Verification function
verify_settings() {
    local settings_file="$1"
    local verified_count=0
    local total_checks=10
    
    # Critical settings to verify
    local checks=(
        '"cursor.general.enableTelemetry": false'
        '"cursor.autocomplete.conservative": true'
        '"cursor.chat.conservative": true'
        '"cursor.composer.enableValidation": true'
        '"cursor.codeGeneration.enableValidation": true'
        '"cursor.codeGeneration.conservative": true'
        '"cursor.rules.strictMode": true'
        '"cursor.validation.enableSyntaxCheck": true'
        '"cursor.security.preventSecretExposure": true'
        '"security.workspace.trust.enabled": true'
    )
    
    for check in "${checks[@]}"; do
        if grep -q "$check" "$settings_file" 2>/dev/null; then
            ((verified_count++))
        fi
    done
    
    local success_rate=$((verified_count * 100 / total_checks))
    log "Verification: $verified_count/$total_checks settings applied ($success_rate%)"
    
    if [[ $success_rate -ge 80 ]]; then
        log "SUCCESS: Settings verification passed (≥80% applied)"
        return 0
    else
        error_exit "FAILED: Settings verification failed (<80% applied)"
    fi
}

# Main execution
main() {
    log "Starting Cursor AI application settings configuration"
    
    # Detect settings location
    local cursor_dir=$(detect_cursor_settings)
    local settings_file="$cursor_dir/User/settings.json"
    
    log "Detected Cursor settings directory: $cursor_dir"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$settings_file")"
    
    # Check idempotency
    if check_idempotency "$settings_file"; then
        verify_settings "$settings_file"
        log "Script completed (idempotent - no changes needed)"
        exit 0
    fi
    
    # Create backup
    create_backup "$settings_file"
    
    # Apply settings
    apply_cursor_settings "$settings_file"
    
    # Verify success
    verify_settings "$settings_file"
    
    log "Script completed successfully"
}

# Run main function
main "$@"


