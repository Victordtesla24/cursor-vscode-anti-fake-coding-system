#!/bin/bash

# Master Script: cursor_ai_complete_setup.sh
# Executes all Cursor AI configuration scripts in proper sequence

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Cursor AI Complete Anti-Hallucination Setup${NC}"
echo -e "${BLUE}Comprehensive Configuration for MacBook Air M3${NC}"
echo ""

# Function to check if Cursor is installed
check_cursor_installation() {
    if [ ! -d "/Applications/Cursor.app" ]; then
        echo -e "${RED}❌ Cursor AI not found at /Applications/Cursor.app${NC}"
        echo -e "${YELLOW}Please install Cursor AI first from https://cursor.com${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Cursor AI installation verified${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}💾 Creating complete backup...${NC}"
    BACKUP_DIR="$HOME/.cursor-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$HOME/Library/Application Support/Cursor" ]; then
        cp -r "$HOME/Library/Application Support/Cursor" "$BACKUP_DIR/"
    fi
    
    if [ -d "$HOME/.cursor" ]; then
        cp -r "$HOME/.cursor" "$BACKUP_DIR/"
    fi
    
    echo -e "${GREEN}✅ Backup created at: $BACKUP_DIR${NC}"
}

# Function to make scripts executable
make_scripts_executable() {
    chmod +x cursor_app_settings_config.sh
    chmod +x cline_extension_config.sh
    chmod +x optimization_corrections_config.sh
    chmod +x mdc_files_rules_creation.sh
}

# Function to execute scripts in sequence
execute_scripts() {
    echo -e "${BLUE}📋 Executing configuration scripts in sequence...${NC}"
    
    echo -e "${YELLOW}🔧 Step 1: Configuring Cursor AI Application Settings...${NC}"
    ./cursor_app_settings_config.sh
    
    echo -e "${YELLOW}🔧 Step 2: Configuring Cline AI Extension...${NC}"
    ./cline_extension_config.sh
    
    echo -e "${YELLOW}🔧 Step 3: Implementing Optimizations and Corrections...${NC}"
    ./optimization_corrections_config.sh
    
    echo -e "${YELLOW}🔧 Step 4: Creating MDC Files and Rules...${NC}"
    ./mdc_files_rules_creation.sh
}

# Function to run post-setup validation
run_validation() {
    echo -e "${BLUE}🧪 Running post-setup validation...${NC}"
    
    # Check if all directories were created
    if [ -d "$HOME/.cursor/rules" ] && [ -d "$HOME/.cursor/validation" ] && [ -d "$HOME/.cursor/optimization" ]; then
        echo -e "${GREEN}✅ Directory structure validated${NC}"
    else
        echo -e "${RED}❌ Directory structure validation failed${NC}"
    fi
    
    # Check if key files exist
    if [ -f "$HOME/Library/Application Support/Cursor/User/settings.json" ]; then
        echo -e "${GREEN}✅ Cursor settings file validated${NC}"
    else
        echo -e "${RED}❌ Cursor settings validation failed${NC}"
    fi
    
    # Run file size monitor
    if [ -f "$HOME/.cursor/optimization/file-management/file-monitor.sh" ]; then
        "$HOME/.cursor/optimization/file-management/file-monitor.sh" "$PWD" > /dev/null 2>&1
        echo -e "${GREEN}✅ File monitoring script validated${NC}"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🎯 Starting Cursor AI Complete Setup${NC}"
    echo -e "${BLUE}Target: Zero Fake Code Generation Configuration${NC}"
    echo ""
    
    check_cursor_installation
    create_backup
    make_scripts_executable
    execute_scripts
    run_validation
    
    echo ""
    echo -e "${GREEN}🎉 Cursor AI Complete Setup Finished Successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Setup Summary:${NC}"
    echo -e "✅ Application settings configured with conservative parameters"
    echo -e "✅ Cline AI extension configured with anti-hallucination rules"
    echo -e "✅ RAG, MDC rules, and validation workflows implemented"
    echo -e "✅ Comprehensive MDC files and project templates created"
    echo ""
    echo -e "${YELLOW}📋 Final Steps:${NC}"
    echo -e "1. Restart Cursor AI to apply all settings"
    echo -e "2. Copy .cursorrules template to your projects"
    echo -e "3. Test configuration with a sample project"
    echo -e "4. Monitor validation logs in ~/.cursor/validation/"
    echo ""
    echo -e "${GREEN}🛡️ Your Cursor AI is now configured for zero fake code generation!${NC}"
}

# Run main function
main "$@"
