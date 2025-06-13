#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# 10x Engineer/Senior Developer Mode - Production-Only Code Standards
# ZERO FAKE CODE POLICY: No placeholders, TODOs, or mock implementations
# ─────────────────────────────────────────────────────────────────────────────

# Cursor Application Settings Configuration Script - Complete Project Agnostic Implementation
# Configures Cursor application settings for security and anti-hallucination
# Works from any git clone location with embedded configuration
readonly LOG_FILE="/var/log/cursor-setup.log"
readonly SCRIPT_TAG="[application-settings]"

# ──────────────────────────────────────────────────────────────────────────────
# Utility: timestamped logger
log() {
    local ts msg
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    msg="$1"
    echo "[$ts] $SCRIPT_TAG $msg" | tee -a "$LOG_FILE" || echo "[$ts] $SCRIPT_TAG $msg"
}

# Error handler with exit
error_exit() {
    log "ERROR: $*"
    exit 1
}

# Check for fake/placeholder code patterns (context-aware to avoid false positives)
check_no_fake_code() {
    local file="$1"
    if [ -f "$file" ]; then
        # Skip JSON configuration files with stopSequences (legitimate anti-fake-code config)
        if [[ "$file" == *.json ]] && grep -q '"stopSequences"' "$file" 2>/dev/null; then
            return 0
        fi
        # Check for actual placeholder patterns in code/comments (not config values)
        if grep -q "^\s*//.*TODO\|^\s*#.*TODO\|^\s*//.*FIXME\|^\s*#.*FIXME\|^\s*//.*PLACEHOLDER\|^\s*#.*PLACEHOLDER\|^\s*//\s*\.\.\.\|^\s*#\s*\.\.\." "$file" 2>/dev/null; then
            error_exit "BLOCKED: Fake/placeholder code detected in $file"
        fi
    fi
}

# Detect Cursor directory (project-agnostic)
detect_cursor_directory() {
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [ ! -d "$cursor_dir" ]; then
        cursor_dir="$HOME/Library/Application Support/Code"
        log "Cursor directory not found, using VSCode directory: $cursor_dir"
    else
        log "Using Cursor directory: $cursor_dir"
    fi
    echo "$cursor_dir"
}

# Apply settings atomically - ZERO BACKUP STRATEGY
apply_settings_atomic() {
    local settings_file="$1"
    
    # Direct atomic jq transformation - production grade
    local tmp
    tmp="$(dirname "$settings_file")/settings.tmp.$$"
    jq '
        # Clean telemetry settings (remove deprecated keys)
        del(.["telemetry.enableCrashReporter"])
        | .["telemetry.enableTelemetry"] = false
        | .["crashReporting.enabled"] = "off"
        | .["telemetry.telemetryLevel"] = "off"
        # Safe autocompletion with enhanced controls
        | .["editor.acceptSuggestionOnCommitCharacter"] = false
        | .["editor.acceptSuggestionOnEnter"] = "smart"
        | .["editor.tabCompletion"] = "onlySnippets"
        | .["editor.suggest.showSnippets"] = true
        | .["editor.suggest.maxVisibleSuggestions"] = 5
        | .["editor.suggest.insertMode"] = "replace"
        # Session management
        | .["files.hotExit"] = "onExitAndWindowClose"
        | .["window.restoreWindows"] = "all"
        | .["workbench.editor.restoreViewState"] = true
        | .["workbench.startupEditor"] = "welcomePage"
        # Security and strict rules
        | .["security.workspace.trust.enabled"] = true
        | .["security.untrustedFiles"] = "newWindow"
        | .["security.allowUnsafeExtensions"] = false
        | .["workbench.enableExperiments"] = false
        | .["workbench.settings.enableNaturalLanguageSearch"] = false
        # Updates and extensions
        | .["update.mode"] = "manual"
        | .["extensions.autoUpdate"] = false
        | .["extensions.autoCheckUpdates"] = true
        | .["extensions.ignoreRecommendations"] = false
        # macOS M3 optimizations (remove deprecated search settings)
        | .["editor.largeFileOptimizations"] = true
        | .["files.watcherExclude"] = {"**/.git/objects/**": true, "**/.DS_Store": true, "**/node_modules/**": true}
        | del(.["search.useRipgrep"])
        | del(.["search.usePCRE2"])
        # File size and performance settings
        | .["editor.wordWrap"] = "bounded"
        | .["editor.wordWrapColumn"] = 300
        | .["files.defaultLanguage"] = ""
        | .["files.trimTrailingWhitespace"] = true
        | .["files.insertFinalNewline"] = true
        | .["editor.rulers"] = [300]
        # Enhanced editor settings for code quality
        | .["editor.detectIndentation"] = true
        | .["editor.insertSpaces"] = true
        | .["editor.tabSize"] = 2
        | .["editor.formatOnSave"] = true
        | .["editor.formatOnPaste"] = true
        | .["editor.codeActionsOnSave"] = {"source.fixAll": true}
        # Git and version control
        | .["git.autofetch"] = false
        | .["git.confirmSync"] = true
        | .["git.enableSmartCommit"] = false
        | .["scm.diffDecorations"] = "all"
    ' "$settings_file" > "$tmp" || error_exit "Failed to apply settings transformation"
    
    # Preserve permissions and atomic move
    if command -v stat >/dev/null 2>&1; then
        local uid gid mode
        uid="$(stat -f %u "$settings_file" 2>/dev/null || stat -c %u "$settings_file")"
        gid="$(stat -f %g "$settings_file" 2>/dev/null || stat -c %g "$settings_file")"
        mode="$(stat -f %Lp "$settings_file" 2>/dev/null || stat -c %a "$settings_file")"

        if [[ -n $uid && -n $gid ]]; then
            chown "$uid:$gid" "$tmp" || true
        fi
        if [[ -n $mode ]]; then
            chmod "$mode" "$tmp" || true
        fi
    fi
    
    mv "$tmp" "$settings_file" || error_exit "Failed to finalize settings update"
}

# Main function with project-agnostic approach
main() {
    log "Starting Cursor application settings configuration (project-agnostic)"

    # ──────────────────────────────────────────────────────────────────────────────
    # Locate settings.json (project-agnostic detection)
    local cursor_dir settings_file
    cursor_dir=$(detect_cursor_directory)
    settings_file="$cursor_dir/User/settings.json"

    # Ensure the file exists and is valid JSON
    if [ ! -f "$settings_file" ]; then
        log "settings.json not found – creating a new one at: $settings_file"
        mkdir -p "$(dirname "$settings_file")"
        echo '{}' > "$settings_file"
        log "Created new settings file: $settings_file"
    fi
    log "Using settings file (full path): $settings_file"

    # Additional logging for backup location tracking
    local settings_dir
    settings_dir="$(dirname "$settings_file")"
    log "Settings directory: $settings_dir"
    log "Working with Cursor User directory: $(dirname "$settings_dir")"

    command -v jq >/dev/null 2>&1 || error_exit "jq not installed"
    jq empty "$settings_file" >/dev/null 2>&1 || error_exit "settings.json is invalid JSON"
    check_no_fake_code "$settings_file"

    # ──────────────────────────────────────────────────────────────────────────────
    # Enhanced settings validation (updated schema)
    declare -a CHECK_SETTINGS=(
        # Modern telemetry and crash reporting
        'telemetry.enableTelemetry false'
        'crashReporting.enabled "off"'
        'telemetry.telemetryLevel "off"'
        # Safe autocompletion
        'editor.acceptSuggestionOnCommitCharacter false'
        'editor.acceptSuggestionOnEnter "smart"'
        'editor.tabCompletion "onlySnippets"'
        # Session management
        'files.hotExit "onExitAndWindowClose"'
        'window.restoreWindows "all"'
        'workbench.editor.restoreViewState true'
        # Security and strict rules
        'security.workspace.trust.enabled true'
        'security.untrustedFiles "newWindow"'
        'security.allowUnsafeExtensions false'
        'workbench.enableExperiments false'
        'workbench.settings.enableNaturalLanguageSearch false'
        # Updates and extensions
        'update.mode "manual"'
        'extensions.autoUpdate false'
        'extensions.autoCheckUpdates true'
        # macOS M3 optimizations and file management
        'editor.largeFileOptimizations true'
        'editor.wordWrapColumn 300'
        'files.trimTrailingWhitespace true'
        'files.insertFinalNewline true'
        'editor.formatOnSave true'
        # Git settings
        'git.autofetch false'
        'git.confirmSync true'
        'git.enableSmartCommit false'
    )

    # ──────────────────────────────────────────────────────────────────────────────
    # Check if an update is necessary
    local need_update="no"
    for setting in "${CHECK_SETTINGS[@]}"; do
        local key expected_val jq_filter
        key="${setting%% *}"
        expected_val="${setting#* }"

        jq_filter="$(
            if [[ $expected_val == \"* || $expected_val == "true" || $expected_val == "false" || $expected_val =~ ^[0-9]+$ ]]; then
                printf '.["%s"] == %s' "$key" "$expected_val"
            else
                # shellcheck disable=SC2016
                printf '.["%s"] == $expected' "$key"
            fi
        )"

        if ! jq -e --arg expected "$expected_val" "$jq_filter" "$settings_file" >/dev/null 2>&1; then
            need_update="yes"
            break
        fi
    done

    # ──────────────────────────────────────────────────────────────────────────────
    # Apply updates atomically - ZERO BACKUP STRATEGY
    if [[ $need_update == "yes" ]]; then
        apply_settings_atomic "$settings_file"
        log "Settings updated successfully."
    else
        log "All targeted settings already configured – no changes needed."
    fi

    # ──────────────────────────────────────────────────────────────────────────────
    # Post-update verification: ≥ 80 % success threshold
    local total correct
    total=${#CHECK_SETTINGS[@]}
    correct=0
    
    for setting in "${CHECK_SETTINGS[@]}"; do
        local key expected_val jq_filter
        key="${setting%% *}"
        expected_val="${setting#* }"

        jq_filter="$(
            if [[ $expected_val == \"* || $expected_val == "true" || $expected_val == "false" || $expected_val =~ ^[0-9]+$ ]]; then
                printf '.["%s"] == %s' "$key" "$expected_val"
            else
                # shellcheck disable=SC2016
                printf '.["%s"] == $expected' "$key"
            fi
        )"

        if jq -e --arg expected "$expected_val" "$jq_filter" "$settings_file" >/dev/null 2>&1; then
            correct=$((correct + 1))
        fi
    done

    local percent=$(( correct * 100 / total ))
    if (( correct * 100 < 80 * total )); then
        error_exit "verification failed – $correct of $total settings applied (~${percent} %)"
    else
        log "Verification passed – $correct/$total settings applied (~${percent} %)."
        check_no_fake_code "$settings_file"
        log "Application settings hardening completed successfully"
    fi
}

# Run main function
main "$@"
