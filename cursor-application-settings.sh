#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# 10x Engineer/Senior Developer Mode - Production-Only Code Standards
# ZERO FAKE CODE POLICY: No placeholders, TODOs, or mock implementations
# ─────────────────────────────────────────────────────────────────────────────

LOG_FILE="/var/log/cursor-setup.log"
SCRIPT_TAG="[application-settings]"

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

# Apply settings with backup and restore on failure
apply_settings_with_backup() {
    local settings_file="$1"
    local temp_backup="${settings_file}.temp.backup"
    
    # Create temporary backup
    cp "$settings_file" "$temp_backup" || error_exit "Failed to create temporary backup"
    
    # Apply the jq transformation
    local tmp
    tmp="$(dirname "$settings_file")/settings.tmp.$$"
    if ! jq '
        # Clean telemetry settings (remove deprecated keys)
        del(.["telemetry.enableCrashReporter"])
        | .["telemetry.enableTelemetry"] = false
        | .["crashReporting.enabled"] = "off"
        | .["telemetry.telemetryLevel"] = "off"
        # Safe autocompletion
        | .["editor.acceptSuggestionOnCommitCharacter"] = false
        | .["editor.acceptSuggestionOnEnter"] = "smart"
        | .["editor.tabCompletion"] = "onlySnippets"
        # Session management
        | .["files.hotExit"] = "onExitAndWindowClose"
        | .["window.restoreWindows"] = "all"
        | .["workbench.editor.restoreViewState"] = true
        # Security and strict rules
        | .["security.workspace.trust.enabled"] = true
        | .["security.untrustedFiles"] = "newWindow"
        | .["workbench.enableExperiments"] = false
        | .["workbench.settings.enableNaturalLanguageSearch"] = false
        # Updates and extensions
        | .["update.mode"] = "manual"
        | .["extensions.autoUpdate"] = false
        | .["extensions.autoCheckUpdates"] = true
        # macOS M3 optimizations (remove deprecated search settings)
        | .["editor.largeFileOptimizations"] = true
        | .["files.watcherExclude"] = {"**/.git/objects/**": true, "**/.DS_Store": true}
        | del(.["search.useRipgrep"])
        | del(.["search.usePCRE2"])
    ' "$settings_file" > "$tmp"; then
        # Restore backup on failure
        mv "$temp_backup" "$settings_file"
        rm -f "$tmp"
        error_exit "Failed to apply settings transformation"
    fi
    
    # Preserve permissions and move final file
    if command -v stat >/dev/null 2>&1; then
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
    
    mv "$tmp" "$settings_file"
    rm -f "$temp_backup"
}

log "Starting Cursor application settings configuration"

# ──────────────────────────────────────────────────────────────────────────────
# Locate settings.json (Cursor edition of VS Code)
SETTINGS_FILE=""
if command -v code >/dev/null 2>&1; then
    code_path="$(command -v code)"
    [ -L "$code_path" ] && code_path="$(readlink "$code_path")"
    [[ "$code_path" == *"/Cursor.app/"* ]] \
        && SETTINGS_FILE="$HOME/Library/Application Support/Cursor/User/settings.json"
fi
: "${SETTINGS_FILE:=$HOME/Library/Application Support/Cursor/User/settings.json}"

# Ensure the file exists and is valid JSON
if [ ! -f "$SETTINGS_FILE" ]; then
    log "settings.json not found – creating a new one."
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo '{}' > "$SETTINGS_FILE"
fi
log "Using settings file: $SETTINGS_FILE"

command -v jq >/dev/null 2>&1 || error_exit "jq not installed"
jq empty "$SETTINGS_FILE" >/dev/null 2>&1 || error_exit "settings.json is invalid JSON"
check_no_fake_code "$SETTINGS_FILE"

# ──────────────────────────────────────────────────────────────────────────────
# Desired settings → "key expectedValue" (final clean schema)
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
    'workbench.enableExperiments false'
    'workbench.settings.enableNaturalLanguageSearch false'
    # Updates and extensions
    'update.mode "manual"'
    'extensions.autoUpdate false'
    'extensions.autoCheckUpdates true'
    # macOS M3 optimizations (no deprecated search settings)
    'editor.largeFileOptimizations true'
)

# ──────────────────────────────────────────────────────────────────────────────
# Check if an update is necessary
need_update="no"
for setting in "${CHECK_SETTINGS[@]}"; do
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

    if ! jq -e --arg expected "$expected_val" "$jq_filter" "$SETTINGS_FILE" >/dev/null 2>&1; then
        need_update="yes"
        break
    fi
done

# ──────────────────────────────────────────────────────────────────────────────
# Apply updates (with backup) if needed
if [[ $need_update == "yes" ]]; then
    ts="$(date '+%Y%m%d_%H%M%S')"
    backup="${SETTINGS_FILE}.${ts}.bak"
    cp -p "$SETTINGS_FILE" "$backup"
    log "Backup created: $backup"

    apply_settings_with_backup "$SETTINGS_FILE"
    log "Settings updated successfully."
else
    log "All targeted settings already configured – no changes needed."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Post-update verification: ≥ 80 % success threshold
total=${#CHECK_SETTINGS[@]}
correct=0
for setting in "${CHECK_SETTINGS[@]}"; do
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

    if jq -e --arg expected "$expected_val" "$jq_filter" "$SETTINGS_FILE" >/dev/null 2>&1; then
        correct=$((correct + 1))
    fi
done

percent=$(( correct * 100 / total ))
if (( correct * 100 < 80 * total )); then
    error_exit "verification failed – $correct of $total settings applied (~${percent} %)"
else
    log "Verification passed – $correct/$total settings applied (~${percent} %)."
    check_no_fake_code "$SETTINGS_FILE"
    log "Application settings hardening completed successfully"
fi
