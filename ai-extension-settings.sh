#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# 10x Engineer/Senior Developer Mode - Production-Only Code Standards
# ZERO FAKE CODE POLICY: No placeholders, TODOs, or mock implementations
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_NAME="ai-extension-settings"
LOG_FILE="/var/log/cursor-setup.log"

log() {
    TS=$(date '+%Y-%m-%d %H:%M:%S')
    # Append to log; on failure (e.g. permission), also echo to stdout
    echo "[$TS] [$SCRIPT_NAME] $*" | tee -a "$LOG_FILE" || echo "[$TS] [$SCRIPT_NAME] $*"
}

error_exit() {
    log "ERROR: $*"
    exit 1
}

# Check for fake/placeholder code patterns (exclude JSON config contexts)
check_no_fake_code() {
    local file="$1"
    if [ -f "$file" ]; then
        # Exclude lines that are JSON string values in stopSequences or similar config arrays
        if grep -v '"TODO:".*\|"FIXME:".*\|"PLACEHOLDER:".*\|"// \.\.\.".*\|"# \.\.\.".*' "$file" | \
           grep -q "TODO:\|FIXME:\|PLACEHOLDER:\|// TODO\|# TODO\|// FIXME\|# FIXME\|// \.\.\.\|# \.\.\." 2>/dev/null; then
            error_exit "BLOCKED: Fake/placeholder code detected in $file"
        fi
    fi
}

# Apply with backup and restore on failure
apply_with_backup() {
    local settings_file="$1"
    local backup_file="${settings_file}.temp.backup"
    
    # Create temporary backup
    if [ -f "$settings_file" ]; then
        cp "$settings_file" "$backup_file" || error_exit "Failed to create temporary backup"
    fi
    
    # Execute the configuration function passed as remaining arguments
    shift
    if ! "$@"; then
        # Restore backup on failure
        if [ -f "$backup_file" ]; then
            mv "$backup_file" "$settings_file"
            log "Restored backup due to configuration failure"
        fi
        error_exit "Configuration failed and backup restored"
    fi
    
    # Clean up temporary backup on success
    [ -f "$backup_file" ] && rm -f "$backup_file"
}

# Detect Cursor settings directory (Cursor vs. Code fallback)
detect_cursor_settings() {
    USERDATA="$HOME/Library/Application Support/Cursor"
    if [ ! -d "$USERDATA" ]; then
        USERDATA="$HOME/Library/Application Support/Code"
    fi
    echo "$USERDATA"
}

# Backup file with timestamp
create_backup() {
    FILE="$1"
    if [ -f "$FILE" ]; then
        TS=$(date '+%Y%m%d_%H%M%S')
        cp -p "$FILE" "${FILE}.bak.$TS"
        log "Backup created: ${FILE}.bak.$TS"
    fi
}

# Check if an existing hardening marker is present (idempotency)
check_extension_idempotency() {
    SETTINGS="$1"
    if [ -f "$SETTINGS" ] && grep -q '"cline.conservativeMode": true' "$SETTINGS"; then
        return 0
    fi
    return 1
}

# Configure Cline (Claude) settings
configure_cline_settings() {
    SETTINGS="$1"
    TMP=$(mktemp)
    [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
    cline_settings='{
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
            "stopSequences": ["TODO:","FIXME:","PLACEHOLDER:","// ...","# ..."]
        },
        "cline.validationRules": {
            "requireTests": true,
            "preventSecretExposure": true,
            "enableTypeChecking": true,
            "requireDocumentation": true
        }
    }'
    jq -s '.[0] * .[1]' "$SETTINGS" <(echo "$cline_settings") > "$TMP" || error_exit "Failed to merge Cline settings"
    mv "$TMP" "$SETTINGS"
    log "Cline (Claude) extension settings applied"
}

# Configure GitHub Copilot settings
configure_copilot_settings() {
    SETTINGS="$1"
    TMP=$(mktemp)
    [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
    copilot_settings='{
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
    jq -s '.[0] * .[1]' "$SETTINGS" <(echo "$copilot_settings") > "$TMP" || error_exit "Failed to merge Copilot settings"
    mv "$TMP" "$SETTINGS"
    log "GitHub Copilot settings applied"
}

# Configure TabNine settings
configure_tabnine_settings() {
    SETTINGS="$1"
    TMP=$(mktemp)
    [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
    tabnine_settings='{
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
    jq -s '.[0] * .[1]' "$SETTINGS" <(echo "$tabnine_settings") > "$TMP" || error_exit "Failed to merge TabNine settings"
    mv "$TMP" "$SETTINGS"
    log "TabNine settings applied"
}

# Configure Continue extension settings
configure_continue_settings() {
    SETTINGS="$1"
    TMP=$(mktemp)
    [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
    continue_settings='{
        "continue.enableTabAutocomplete": false,
        "continue.telemetryEnabled": false,
        "continue.enableAdvancedFeatures": false,
        "continue.experimentalFeatures": false
    }'
    jq -s '.[0] * .[1]' "$SETTINGS" <(echo "$continue_settings") > "$TMP" || error_exit "Failed to merge Continue settings"
    mv "$TMP" "$SETTINGS"
    log "Continue extension settings applied"
}

# Verify that ≥80% of expected settings are present
verify_extension_settings() {
    SETTINGS="$1"
    EXTENSIONS="$2"
    checks=0
    hits=0

    # Cline checks
    if echo "$EXTENSIONS" | grep -q "saoudrizwan.claude-dev"; then
        expected='"cline.conservativeMode": true'
        checks=$((checks+1))
        grep -q "$expected" "$SETTINGS" && hits=$((hits+1))
        expected='"cline.enableValidation": true'
        checks=$((checks+1))
        grep -q "$expected" "$SETTINGS" && hits=$((hits+1))
        expected='"cline.preventPlaceholderGeneration": true'
        checks=$((checks+1))
        grep -q "$expected" "$SETTINGS" && hits=$((hits+1))
        expected='"cline.enableSecurityScanning": true'
        checks=$((checks+1))
        grep -q "$expected" "$SETTINGS" && hits=$((hits+1))
        expected='"cline.requireExplicitInstructions": true'
        checks=$((checks+1))
        grep -q "$expected" "$SETTINGS" && hits=$((hits+1))
    fi

    # Copilot checks
    if echo "$EXTENSIONS" | grep -q "GitHub.copilot"; then
        checks=$((checks+2))
        grep -q '"github.copilot.editor.enableAutoCompletions": true' "$SETTINGS" && hits=$((hits+1))
        grep -q '"github.copilot.editor.enableCodeActions": false' "$SETTINGS" && hits=$((hits+1))
    fi

    # TabNine checks
    if echo "$EXTENSIONS" | grep -q "TabNine.tabnine-vscode"; then
        checks=$((checks+1))
        grep -q '"tabnine.experimentalAutoImports": false' "$SETTINGS" && hits=$((hits+1))
    fi

    # Continue checks
    if echo "$EXTENSIONS" | grep -q "Continue.continue"; then
        checks=$((checks+1))
        grep -q '"continue.telemetryEnabled": false' "$SETTINGS" && hits=$((hits+1))
    fi

    if [ "$checks" -eq 0 ]; then
        log "No targeted AI extensions found"
        return 0
    fi

    percent=$(( hits * 100 / checks ))
    log "Extension verification: $hits/$checks settings applied ($percent%)"
    if [ "$percent" -ge 80 ]; then
        log "SUCCESS: ≥80% of extension settings applied"
        return 0
    else
        error_exit "FAILED: Less than 80% of extension settings applied"
    fi
}

# Main routine
log "Starting AI extension settings hardening"
# Ensure `code` CLI is available
if ! command -v code >/dev/null 2>&1; then
    error_exit "'code' CLI not found. Install VSCode/Cursor CLI."
fi

# Detect settings file path
CURSOR_DIR=$(detect_cursor_settings)
SETTINGS_FILE="$CURSOR_DIR/User/settings.json"
mkdir -p "$(dirname "$SETTINGS_FILE")"
log "Using settings file: $SETTINGS_FILE"

# Check jq
if ! command -v jq >/dev/null 2>&1; then
    error_exit "jq is required but not installed."
fi
# Verify JSON and check for fake code
if ! jq empty "$SETTINGS_FILE" >/dev/null 2>&1; then
    error_exit "Existing settings file is not valid JSON."
fi
check_no_fake_code "$SETTINGS_FILE"

# Gather installed extensions
EXTENSIONS=$(code --list-extensions 2>/dev/null || echo "")
log "Found $(echo "$EXTENSIONS" | wc -l | tr -d ' ') extensions installed"

# Idempotency: skip if already configured
if check_extension_idempotency "$SETTINGS_FILE"; then
    verify_extension_settings "$SETTINGS_FILE" "$EXTENSIONS"
    log "No changes needed (already hardened)"
    exit 0
fi

# Backup original settings
create_backup "$SETTINGS_FILE"

# Apply settings per extension with backup protection
echo "$EXTENSIONS" | grep -q "saoudrizwan.claude-dev"   && apply_with_backup "$SETTINGS_FILE" configure_cline_settings   "$SETTINGS_FILE"
echo "$EXTENSIONS" | grep -q "GitHub.copilot"           && apply_with_backup "$SETTINGS_FILE" configure_copilot_settings "$SETTINGS_FILE"
echo "$EXTENSIONS" | grep -q "TabNine.tabnine-vscode"   && apply_with_backup "$SETTINGS_FILE" configure_tabnine_settings "$SETTINGS_FILE"
echo "$EXTENSIONS" | grep -q "Continue.continue"        && apply_with_backup "$SETTINGS_FILE" configure_continue_settings "$SETTINGS_FILE"

# Final verification with anti-hallucination check
verify_extension_settings "$SETTINGS_FILE" "$EXTENSIONS"
check_no_fake_code "$SETTINGS_FILE"

log "AI extension hardening completed successfully"
