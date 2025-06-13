# ───────────────────────────────
#  Script 3: cursor-optimisation-policies.sh
# ───────────────────────────────
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME="cursor-optimisation"
readonly LOG_FILE="/var/log/cursor-setup.log"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Logging function
log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $message" | sudo tee -a "$LOG_FILE" >/dev/null
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $message"
}

# Error handler
error_exit() {
    local message="$1"
    log "ERROR: $message"
    exit 1
}

# Create optimization directories
create_optimization_directories() {
    local cursor_dir="$1"

    local dirs=(
        "$cursor_dir/optimization"
        "$cursor_dir/optimization/rag"
        "$cursor_dir/optimization/validation"
        "$cursor_dir/optimization/file-management"
        "$cursor_dir/optimization/workflows"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log "Created directory: $dir"
    done
}

# Implement RAG configuration
implement_rag_config() {
    local optimization_dir="$1"
    local rag_config="$optimization_dir/rag/rag-config.json"

    # Create timestamped backup if exists
    if [[ -f "$rag_config" ]]; then
        local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$rag_config" "${rag_config}.backup.${backup_timestamp}"
        log "Backup created: ${rag_config}.backup.${backup_timestamp}"
    fi

    cat > "$rag_config" << 'EOF'
{
    "ragSettings": {
        "enabled": true,
        "knowledgeBasePath": "~/.cursor/optimization/rag/knowledge-base",
        "indexingEnabled": true,
        "embeddingModel": "sentence-transformers/all-MiniLM-L6-v2",
        "retrievalThreshold": 0.8,
        "maxRetrievalResults": 5,
        "enableSemanticSearch": true,
        "enableFactChecking": true
    },
    "validationSettings": {
        "requireSourceValidation": true,
        "preventHallucinations": true,
        "uncertaintyThreshold": 0.7,
        "enableContextVerification": true
    },
    "promptTemplates": {
        "contextualPrompt": "Based on the retrieved information from the knowledge base: {context}\n\nPlease provide an accurate response to: {query}\n\nIf the information is insufficient, explicitly state your uncertainty.",
        "uncertaintyPrompt": "I don't have sufficient reliable information to answer this question accurately. Please provide more context or clarify your requirements."
    }
}
EOF

    # Create knowledge base structure
    mkdir -p "$optimization_dir/rag/knowledge-base"/{coding-standards,frameworks,security}

    log "RAG configuration implemented at $rag_config"
}

# Configure file size management
configure_file_size_management() {
    local optimization_dir="$1"
    local file_config="$optimization_dir/file-management/file-size-config.json"

    # Backup existing config
    if [[ -f "$file_config" ]]; then
        local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$file_config" "${file_config}.backup.${backup_timestamp}"
        log "Backup created: ${file_config}.backup.${backup_timestamp}"
    fi

    cat > "$file_config" << 'EOF'
{
    "fileSizeSettings": {
        "maxFileLines": 300,
        "warningThreshold": 250,
        "autoSplitEnabled": false,
        "splitStrategy": "logical-blocks",
        "preserveFunctionality": true
    },
    "monitoringSettings": {
        "enableContinuousMonitoring": true,
        "alertOnLargeFiles": true,
        "generateSizeReports": true,
        "reportInterval": "daily"
    },
    "optimizationRules": {
        "enableCodeMinification": false,
        "preserveComments": true,
        "maintainReadability": true,
        "enforceModularStructure": true
    }
}
EOF

    # Create file monitoring script
    local monitor_script="$optimization_dir/file-management/file-monitor.sh"
    # Backup existing script if present
    if [[ -f "$monitor_script" ]]; then
        local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$monitor_script" "${monitor_script}.backup.${backup_timestamp}"
        log "Backup created: ${monitor_script}.backup.${backup_timestamp}"
    fi

    cat > "$monitor_script" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# File Size Monitoring Script for Cursor AI

MAX_LINES=300
WARNING_LINES=250
PROJECT_ROOT=${1:-.}

echo "🔍 Monitoring file sizes in $PROJECT_ROOT..."

# Function to check file size and suggest optimizations
check_file_size() {
    local file="$1"
    local lines=$(wc -l < "$file" 2>/dev/null || echo 0)

    if [[ $lines -gt $MAX_LINES ]]; then
        echo "❌ CRITICAL: $file ($lines lines) exceeds maximum ($MAX_LINES lines)"
        echo "   🔧 Action required: Split into smaller modules"
        return 1
    elif [[ $lines -gt $WARNING_LINES ]]; then
        echo "⚠️  WARNING: $file ($lines lines) approaching limit ($MAX_LINES lines)"
        echo "   💡 Consider refactoring for better maintainability"
        return 2
    else
        echo "✅ OK: $file ($lines lines)"
        return 0
    fi
}

# Scan project files
find "$PROJECT_ROOT" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.php" -o -name "*.rb" -o -name "*.go" -o -name "*.rs" \) 2>/dev/null | while read -r file; do
    if [[ -f "$file" ]]; then
        check_file_size "$file"
    fi
done

echo "✅ File size monitoring complete"
EOF

    chmod +x "$monitor_script"
    log "File size management configured"
}

# Implement validation workflows
implement_validation_workflows() {
    local optimization_dir="$1"
    local validation_script="$optimization_dir/validation/validation-workflow.sh"

    # Backup existing script if present
    if [[ -f "$validation_script" ]]; then
        local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$validation_script" "${validation_script}.backup.${backup_timestamp}"
        log "Backup created: ${validation_script}.backup.${backup_timestamp}"
    fi

    cat > "$validation_script" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Comprehensive Validation Workflow for Cursor AI

PROJECT_ROOT=${1:-.}
VALIDATION_LOG="$HOME/.cursor/validation/validation.log"

mkdir -p "$(dirname "$VALIDATION_LOG")"
echo "🧪 Starting comprehensive validation workflow..." | tee -a "$VALIDATION_LOG"

# Pre-validation checks
pre_validation() {
    echo "🔍 Running pre-validation checks..." | tee -a "$VALIDATION_LOG"

    # Check project structure
    if [[ ! -f "$PROJECT_ROOT/package.json" ]] && [[ ! -f "$PROJECT_ROOT/requirements.txt" ]] && [[ ! -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        echo "⚠️ No package manager configuration found" | tee -a "$VALIDATION_LOG"
    fi

    # Check for .cursorrules
    if [[ ! -f "$PROJECT_ROOT/.cursorrules" ]]; then
        echo "⚠️ No .cursorrules file found" | tee -a "$VALIDATION_LOG"
    fi
}

# Syntax validation
syntax_validation() {
    echo "🔤 Running syntax validation..." | tee -a "$VALIDATION_LOG"

    # JavaScript/TypeScript validation
    find "$PROJECT_ROOT" -name "*.js" -o -name "*.ts" 2>/dev/null | while read -r file; do
        if command -v node >/dev/null 2>&1; then
            if ! node -c "$file" 2>/dev/null; then
                echo "❌ Syntax error in $file" | tee -a "$VALIDATION_LOG"
            fi
        fi
    done

    # Python validation
    find "$PROJECT_ROOT" -name "*.py" 2>/dev/null | while read -r file; do
        if command -v python3 >/dev/null 2>&1; then
            if ! python3 -m py_compile "$file" 2>/dev/null; then
                echo "❌ Syntax error in $file" | tee -a "$VALIDATION_LOG"
            fi
        fi
    done
}

# Security validation
security_validation() {
    echo "🔒 Running security validation..." | tee -a "$VALIDATION_LOG"

    # Check for hardcoded secrets
    if find "$PROJECT_ROOT" -type f \\( -name "*.js" -o -name "*.ts" -o -name "*.py" \\) -exec grep -l "api_key\\|password\\|secret\\|token" {} \\; 2>/dev/null | head -1 >/dev/null; then
        echo "❌ Potential hardcoded secrets detected" | tee -a "$VALIDATION_LOG"
    fi

    # Check for TODO/FIXME patterns
    if find "$PROJECT_ROOT" -type f \\( -name "*.js" -o -name "*.ts" -o -name "*.py" \\) -exec grep -l "TODO\\|FIXME\\|HACK\\|XXX" {} \\; 2>/dev/null | head -1 >/dev/null; then
        echo "⚠️ Code comments requiring attention found" | tee -a "$VALIDATION_LOG"
    fi
}

# Main validation execution
main() {
    pre_validation
    syntax_validation
    security_validation

    echo "✅ Comprehensive validation workflow completed" | tee -a "$VALIDATION_LOG"
}

main
EOF

    chmod +x "$validation_script"
    log "Validation workflows implemented"
}

# Configure performance optimization
configure_performance_optimization() {
    local optimization_dir="$1"
    local perf_config="$optimization_dir/performance-config.json"

    # Backup existing config
    if [[ -f "$perf_config" ]]; then
        local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$perf_config" "${perf_config}.backup.${backup_timestamp}"
        log "Backup created: ${perf_config}.backup.${backup_timestamp}"
    fi

    cat > "$perf_config" << 'EOF'
{
    "performanceSettings": {
        "enableCaching": true,
        "cacheSize": "500MB",
        "enableIndexing": true,
        "indexingMode": "selective",
        "enableBackgroundProcessing": true,
        "maxConcurrentTasks": 3
    },
    "memoryManagement": {
        "enableGarbageCollection": true,
        "gcInterval": 300000,
        "maxMemoryUsage": "2GB",
        "enableMemoryMonitoring": true
    },
    "contextOptimization": {
        "enableContextCompression": true,
        "maxContextSize": 32768,
        "enableSmartTruncation": true,
        "preserveImportantContext": true
    }
}
EOF

    log "Performance optimization configured"
}

# Check idempotency
check_optimization_idempotency() {
    local optimization_dir="$1"

    if [[ -f "$optimization_dir/rag/rag-config.json" ]] &&
       [[ -f "$optimization_dir/file-management/file-size-config.json" ]] &&
       [[ -f "$optimization_dir/validation/validation-workflow.sh" ]]; then
        return 0
    fi
    return 1
}

# Verification function
verify_optimisation_policies() {
    local optimization_dir="$1"
    local verified_count=0
    local total_checks=5

    # Check if RAG config exists and is valid
    if [[ -f "$optimization_dir/rag/rag-config.json" ]] &&
       jq -e '.ragSettings.enabled == true' "$optimization_dir/rag/rag-config.json" >/dev/null 2>&1; then
        ((verified_count++))
    fi

    # Check if file size management is configured
    if [[ -f "$optimization_dir/file-management/file-size-config.json" ]] &&
       jq -e '.fileSizeSettings.maxFileLines == 300' "$optimization_dir/file-management/file-size-config.json" >/dev/null 2>&1; then
        ((verified_count++))
    fi

    # Check if file monitor script exists and is executable
    if [[ -x "$optimization_dir/file-management/file-monitor.sh" ]]; then
        ((verified_count++))
    fi

    # Check if validation workflow exists and is executable
    if [[ -x "$optimization_dir/validation/validation-workflow.sh" ]]; then
        ((verified_count++))
    fi

    # Check if performance config exists
    if [[ -f "$optimization_dir/performance-config.json" ]]; then
        ((verified_count++))
    fi

    local success_rate=$((verified_count * 100 / total_checks))
    log "Optimisation verification: $verified_count/$total_checks policies implemented ($success_rate%)"

    if [[ $success_rate -ge 80 ]]; then
        log "SUCCESS: Optimisation policies verification passed (≥80% implemented)"
        return 0
    else
        error_exit "FAILED: Optimisation policies verification failed (<80% implemented)"
    fi
}

# Main execution
main() {
    log "Starting optimisation and correction policies implementation"

    # Detect cursor directory
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [[ ! -d "$cursor_dir" ]]; then
        cursor_dir="$HOME/Library/Application Support/Code"
    fi

    local optimization_dir="$cursor_dir/optimization"

    # Check idempotency
    if check_optimization_idempotency "$optimization_dir"; then
        verify_optimisation_policies "$optimization_dir"
        log "Script completed (idempotent - no changes needed)"
        exit 0
    fi

    # Ensure jq is available
    if ! command -v jq >/dev/null 2>&1; then
        error_exit "jq is required but not installed. Install with: brew install jq"
    fi

    # Create directories
    create_optimization_directories "$cursor_dir"

    # Implement configurations
    implement_rag_config "$optimization_dir"
    configure_file_size_management "$optimization_dir"
    implement_validation_workflows "$optimization_dir"
    configure_performance_optimization "$optimization_dir"

    # Verify success
    verify_optimisation_policies "$optimization_dir"

    log "Script completed successfully"
}

# Run main function
main "$@"
