#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# MASTER CURSOR AI HARDENING ORCHESTRATION SCRIPT - WRAPPER
# ═══════════════════════════════════════════════════════════════════════════════
# Wrapper script to call the main master script from the scripts directory
# Following Directory Management Protocols for proper script organization
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the scripts directory
cd "$SCRIPT_DIR/scripts"

# Execute the main master script
exec bash "./master-cursor-hardening.sh" "$@"
