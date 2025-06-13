#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

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

command -v jq >/dev/null 2>&1 || { log "ERROR: jq not installed"; exit 1; }
jq empty "$SETTINGS_FILE" >/dev/null 2>&1 || { log "ERROR: settings.json is invalid JSON"; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# Desired settings → "key expectedValue"
declare -a CHECK_SETTINGS=(
    # Telemetry and crash reporting
    'telemetry.enableTelemetry false'
    'telemetry.enableCrashReporter false'
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

    tmp="$(dirname "$SETTINGS_FILE")/settings.tmp.$$"
    jq '
        # Telemetry settings
        .["telemetry.enableTelemetry"] = false
        | .["telemetry.enableCrashReporter"] = false
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
    ' "$SETTINGS_FILE" > "$tmp"

    # Preserve original ownership & permissions
    if command -v stat >/dev/null 2>&1; then
        uid="$(stat -f %u "$SETTINGS_FILE" 2>/dev/null || stat -c %u "$SETTINGS_FILE")"
        gid="$(stat -f %g "$SETTINGS_FILE" 2>/dev/null || stat -c %g "$SETTINGS_FILE")"
        mode="$(stat -f %Lp "$SETTINGS_FILE" 2>/dev/null || stat -c %a "$SETTINGS_FILE")"

        if [[ -n $uid && -n $gid ]]; then
            chown "$uid:$gid" "$tmp" || true
        fi
        if [[ -n $mode ]]; then
            chmod "$mode" "$tmp" || true
        fi
    fi

    mv -f "$tmp" "$SETTINGS_FILE"
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
            printf '.["%s"] == $expected' "$key"
        fi
    )"

    if jq -e --arg expected "$expected_val" "$jq_filter" "$SETTINGS_FILE" >/dev/null 2>&1; then
        correct=$((correct + 1))
    fi
done

percent=$(( correct * 100 / total ))
if (( correct * 100 < 80 * total )); then
    log "ERROR: verification failed – $correct of $total settings applied (~${percent} %)."
    exit 1
else
    log "Verification passed – $correct/$total settings applied (~${percent} %)."
fi
