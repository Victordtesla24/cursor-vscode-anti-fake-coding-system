#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# 10x Engineer/Senior Developer Mode - Production-Only Code Standards
# ZERO FAKE CODE POLICY: No placeholders, TODOs, or mock implementations
# ─────────────────────────────────────────────────────────────────────────────

# Policy and Protocol File Generation Script
# Creates or updates policy files for Cursor AI (VS Code) - canonical source of truth
readonly SCRIPT_NAME="policy-file-generation"
readonly LOG_FILE="/var/log/cursor-setup.log"

# Ensure log file exists and is writable
if ! sudo test -f "$LOG_FILE"; then
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
fi

# Logging function
log() {
    local message="$1"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] [$SCRIPT_NAME] $message" | sudo tee -a "$LOG_FILE" >/dev/null
    echo "[$ts] [$SCRIPT_NAME] $message"
}

# Error handler
error_exit() {
    local message="$1"
    log "ERROR: $message"
    exit 1
}

# Check for fake/placeholder code patterns (more precise to avoid false positives)
check_no_fake_code() {
    local file="$1"
    if [ -f "$file" ] && grep -q "TODO:\|FIXME:\|PLACEHOLDER:\|// TODO\|# TODO\|// FIXME\|# FIXME\|// \.\.\.\|# \.\.\." "$file" 2>/dev/null; then
        error_exit "BLOCKED: Fake/placeholder code detected in $file"
    fi
}

# Apply file creation with verification
create_file_with_verification() {
    local target_file="$1"
    local temp_file="$2"
    
    # Move temporary file to target
    mv "$temp_file" "$target_file" || error_exit "Failed to create $target_file"
    
    # Verify the created file
    check_no_fake_code "$target_file"
    
    log "Created/updated file: $target_file"
}

# Function to backup an existing file with timestamp
backup_file() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        local timestamp backup_path
        timestamp=$(date '+%Y%m%d_%H%M%S')
        backup_path="${file_path}.backup.${timestamp}"
        cp "$file_path" "$backup_path"
        log "Backed up existing file $file_path to $backup_path"
    fi
}

# Find project root by indicators
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/package.json" ]] || [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/Cargo.toml" ]] || [[ -f "$dir/go.mod" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Create or overwrite .cursorrules file
create_cursorrules() {
    local project_dir="$1"
    local cursorrules_file="$project_dir/.cursorrules"
    
    # Skip if canonical version exists and is recent
    if [[ -f "$cursorrules_file" ]] && grep -q "Anti-Hallucination Configuration" "$cursorrules_file"; then
        log "Canonical .cursorrules already exists, skipping creation"
        return 0
    fi
    
    backup_file "$cursorrules_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
# Cursor AI Project Rules - Anti-Hallucination Configuration
# Production-Only Code Standards - ZERO FAKE CODE POLICY

## Role Definition
**Always act like a 10x Engineer/Senior Developer when starting any Task or User Request.**
- Act with precision, focus, and systematic methodology
- Prioritize production-ready, robust solutions
- Analyze thoroughly before acting - no jumping to conclusions

## ZERO FAKE CODE POLICY - ABSOLUTELY PROHIBITED
**NEVER GENERATE:**
- Mockups, simulated fallback mechanisms, or placeholder implementations
- TODO stubs, incomplete functions, or dummy code
- Fake data generation without explicit request
- Error masking or warning suppression in production code
- Non-functional code that appears to work but doesn't

**MANDATORY REQUIREMENTS:**
- All generated code MUST be fully functional and production-grade
- Every function must have real, working implementation
- All imports and dependencies must be valid and available
- Error handling must be comprehensive and real
- Follow consistent implementation pattern:
  1. Analyze requirements thoroughly
  2. Research existing implementation patterns in codebase
  3. Draft minimal, efficient solution
  4. Validate against requirements
  5. Optimize for performance and maintainability

## File Size Enforcement (300 Line Limit)
- Maximum file size: 300 lines
- Warning threshold: 250 lines
- Automatically split large files into logical modules
- Maintain functionality while enforcing modular structure

## Extended Thinking Mode Control
**Selective Engagement Only:**
- Complex mathematical or logical problems
- Multi-step coding implementations requiring planning
- Architecture design decisions with multiple options

**Structured Thought Process:**
1. Problem definition (concise)
2. Approach selection (with rationale)
3. Step-by-step execution (with validation)
4. Solution verification

## Error Resolution Protocol
**Root Cause Analysis First:** Always perform systematic RCA before attempting fixes
**Two-Attempt Maximum:**
1. First attempt: Apply targeted fix based on RCA
2. Second attempt: Apply broader fix incorporating context
**Solution Verification:** Verify effectiveness through explicit tests
**NO TRIAL AND ERROR:** Each fix attempt must be based on analysis

## Anti-Duplication Standards
**STRICTLY FORBIDDEN:**
- Creating new, unnecessary, or duplicate files
- Generating duplicate code blocks or scripts
- Recreating existing functionality

**MANDATORY:**
- Search existing codebase thoroughly before creating anything new
- Reuse and refactor existing assets whenever possible
- Consolidation first approach
- Follow Directory Management Protocol

## Output Optimization
- Default to terse, direct responses unless detailed explanation requested
- Code-only mode for implementation tasks
- Structured formats over narrative text
- Token-efficient context references

## Security Requirements
- Sanitize all user inputs
- Use parameterized queries for database access
- Implement proper authentication and authorization
- Follow OWASP security guidelines
- Protect against common vulnerabilities (XSS, CSRF, SQL injection)
- Handle sensitive data securely
- Never hardcode API keys, tokens, or credentials

## Quality Assurance Standards
- All code must be production-ready
- Include appropriate error handling
- Follow established coding conventions
- Implement proper testing where applicable
- Provide clear, actionable suggestions only
- Validate all external references and dependencies

## Verification Requirements
- Test all generated code before suggesting
- Verify imports and dependencies exist
- Ensure syntax correctness
- Validate logical consistency
- Check for potential runtime errors
EOF
    create_file_with_verification "$cursorrules_file" "$temp_file"
}

# Create comprehensive project rules markdown
create_project_rules_md() {
    local target_dir="$1"
    local prules_file="$target_dir/cursor_project_rules.md"
    
    # Skip if canonical version exists
    if [[ -f "$prules_file" ]] && grep -q "10x Engineer/Senior Developer" "$prules_file"; then
        log "Canonical cursor_project_rules.md already exists, skipping creation"
        return 0
    fi
    
    backup_file "$prules_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
# Cursor Project Rules - Production Standards

**Role:** Always act like a 10x Engineer/Senior Developer when starting a new or existing `Task` or a `User Request.`
- Act with precision, focus, and a systematic, methodical approach for every task
- Prioritize production-ready, robust solutions
- Do not jump to conclusions; analyze thoroughly before acting

## Core Principles

### 1. Zero Fake Code Policy
- **NEVER** generate placeholder, mock, or simulated code
- **ALWAYS** provide complete, functional implementations
- **VERIFY** all imports, dependencies, and references
- **TEST** code logic before suggesting

### 2. File Size Management
- **Maximum file size:** 300 lines
- **Warning threshold:** 250 lines

## Implementation Workflows

1. **Code Implementation Workflow:**  
   - **Step 1:** Analyze requirements and existing code patterns  
   - **Step 2:** Check cache for similar implementations  
   - **Step 3:** Implement solution (adhering to token budget)  
   - **Step 4:** Verify against requirements  
   - **Step 5:** Cache implementation pattern if meeting L1/L2 criteria  

2. **Error Resolution Workflow:**  
   - **Step 1:** Check cache for known resolution  
   - **Step 2:** If not found, perform root cause analysis  
   - **Step 3:** Implement targeted fix  
   - **Step 4:** Verify resolution  
   - **Step 5:** Cache resolution pattern if meeting criteria  

3. **Documentation/Explanation Workflow:**  
   - **Step 1:** Check cache for similar explanation  
   - **Step 2:** If not found, generate concise explanation  
   - **Step 3:** Organize using structural compression techniques  
   - **Step 4:** Cache explanation if meeting criteria  
EOF
    create_file_with_verification "$prules_file" "$temp_file"
}

# Create or overwrite 001-coding-protocols.mdc
create_coding_protocols_mdc() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/001-coding-protocols.mdc"
    backup_file "$mdc_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
---
description: Core coding protocols for anti-hallucination and precision
globs: ["**/*"]
alwaysApply: true
---

# Coding Protocols for Zero Fake Code Generation

## Role Definition
**Always act like a 10x Engineer/Senior Developer when starting any Task or User Request.**
- Act with precision, focus, and systematic methodology
- Prioritize production-ready, robust solutions
- Analyze thoroughly before acting - no jumping to conclusions

## Production-Only Code Standards
**ABSOLUTELY PROHIBITED:**
- Implementing, replacing, or generating mockups, simulated fallback mechanisms
- Error masking or warning suppression in production code
- Placeholder implementations or TODO stubs
- Fake data generation without explicit request

**MANDATORY REQUIREMENTS:**
- All generated code MUST be fully functional and production-grade
- Follow consistent implementation pattern:
  1. Analyze requirements thoroughly
  2. Research existing implementation patterns in codebase
  3. Draft minimal, efficient solution
  4. Validate against requirements
  5. Optimize for performance and maintainability

## Extended Thinking Mode Control
**Selective Engagement Only:**
- Complex mathematical or logical problems
- Multi-step coding implementations
- Architecture design decisions

**Structured Thought Process:**
1. Problem definition (concise)
2. Approach selection (with rationale)
3. Step-by-step execution (with validation)
4. Solution verification

## Error Resolution Protocol
**Root Cause Analysis First:** Always perform systematic RCA before attempting fixes  
**Two-Attempt Maximum:**  
1. First attempt: Apply targeted fix based on RCA  
2. Second attempt: Apply broader fix incorporating context  
**Solution Verification:** Verify effectiveness through explicit tests

## Anti-Duplication Standards
**STRICTLY FORBIDDEN:**
- Creating new, unnecessary, or duplicate files
- Generating duplicate code blocks or scripts
**MANDATORY:**
- Search existing codebase thoroughly before creating anything new
- Reuse and refactor existing assets whenever possible
- Consolidation first approach

## Output Optimization
- Default to terse, direct responses unless detailed explanation requested
- Code-only mode for implementation tasks
- Structured formats over narrative text
- Token-efficient context references
EOF
    create_file_with_verification "$mdc_file" "$temp_file"
}

# Create or overwrite 002-directory-management.mdc
create_directory_management_mdc() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/002-directory-management.mdc"
    backup_file "$mdc_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
---
description: Directory management protocols for code organization
globs: ["**/*"]
alwaysApply: true
---

# Directory Management Protocol

## Objective
Organize, consolidate, and maintain project directory structure according to established conventions, ensuring code clarity, eliminating redundancy, and preserving functionality.

## Pre-Requisites
- Utilize version control (git stash or branch) before significant changes
- Follow error-fixing protocols with absolute precision if errors arise

## Protocol Steps

### 1. Determine & Adhere to Project Structure Conventions
- Identify established directory structure by checking:
  - Known framework conventions (Next.js, Django, Flask)
  - Project documentation (README.md, CONTRIBUTING.md)
  - Existing patterns in majority of codebase
  - Configuration files (.editorconfig, linter configs)
- Ensure compliance with deployment best practices

### 2. Comprehensive File Scan & Inventory
- Recursively scan entire repository
- Build inventory of files, modules, scripts, configurations
- Exclude: node_modules/, .venv/, .git/, .cursor/, .vscode/, build/, dist/, coverage/

### 3. Duplicate/Overlap Detection & Consolidation
**Strict Prohibition:** Never create new file if existing one serves same purpose  
**Detection Methods:**  
- Exact file content matches  
- High code similarity scores  
- Similar filenames or naming patterns  
- Matching function/class signatures  
- Similar import dependencies  

### 4. "No Unrequested Files" Policy
Do NOT create files unless:
- User explicitly requested specific new file
- AI determines creation critically necessary AND confirms with user

### 5. Correct Placement & Reference Updates
- Relocate misplaced files to conform to project structure
- Atomically update ALL references:
  - Code imports/exports
  - Configuration files
  - Build scripts
  - Documentation
  - Test files

## Critical Constraints
- No functionality changes beyond organization/consolidation
- Apply changes in atomic steps with immediate verification
- Always confirm with user before major changes
- Strict adherence to protocol steps
EOF
    create_file_with_verification "$mdc_file" "$temp_file"
}

# Create or overwrite 003-error-fixing.mdc
create_error_fixing_mdc() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/003-error-fixing.mdc"
    backup_file "$mdc_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
---
description: Systematic error fixing protocols with RCA and validation
globs: ["**/*"]
alwaysApply: true
---

# Error Fixing Protocol

## Objective
Systematically identify, analyze, and resolve errors efficiently while maintaining code quality and minimizing disruption.

## Core Principle
Employ "Fail Fast" mindset with small, incremental, atomic fixes. After each attempt, rigorously verify resolution.

### 1. Reproducibility & Context Capture
- Ensure error is reproducible
- Capture complete context: error messages, stack traces, logs, environment details
- Document steps to reproduce

### 2. Comprehensive Root Cause Analysis (RCA)
- Investigate logs, code changes (git blame/history)
- Review configurations, environment variables, dependency versions
- Analyze potential interactions
- Isolate specific conditions triggering error

### 3. Impact-Based Prioritization
Evaluate error impact on:
- Core functionality
- UI/UX
- Data integrity
- Security
Priority: critical-impact errors first

### 4. Solution Comparison & Selection
- Research external solutions if internal attempts fail
- Compare fixes based on:
  - Effectiveness (resolves root cause?)
  - Minimalism (least amount of change?)
  - Maintainability (readable, aligned with standards?)
  - Performance (no negative impact?)
  - Security (no vulnerabilities introduced?)

### 5. Targeted Resolution Attempts (Max 2 Internal)
**Attempt 1:** Implement most likely minimal, targeted fix based on RCA  
**Attempt 2:** If failed, revert change, refine analysis, apply revised fix  
**Attempt 3:** If failed, revert change, integrate best vetted external solution  

### 6. Rigorous Verification
After each attempt:
- Run unit tests, integration tests, linters
- Manually verify specific functionality
- File integrity check (no unintended modifications)

## Critical Constraints
- **Atomicity:** Each fix must be smallest possible change  
- **Targeted Changes:** No functionality lost/added beyond specific fix  
- **No Placeholders:** Strictly prohibited - generate complete, correct code  
- **Attempt Limit:** Maximum 2 direct internal attempts before external solutions  
- **Verification Required:** Every fix followed by verification  
- **No Regressions:** Fix must not introduce new errors  
- **Focus:** Avoid unnecessary alterations beyond precise fix requirement
EOF
    create_file_with_verification "$mdc_file" "$temp_file"
}

# Create or overwrite 004-token-optimization.mdc
create_token_optimization_mdc() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/004-token-optimization.mdc"
    backup_file "$mdc_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
---
description: Token optimization protocols for efficient AI interactions
globs: ["**/*"]
alwaysApply: true
---

# Token Optimization Protocols

## Core Principles
- **Be Concise:** Use clear and concise language in all communications
- **Provide Context:** Include relevant context, avoid unnecessary information
- **Iterate:** Start with simple prompts, refine based on results
- **Specify Format:** If specific output format needed, specify explicitly
- **Limit Length:** Request concise responses when appropriate

## Prompt Optimization
- Use short, keyword-based queries for search
- Break complex queries into simple, sequential tasks
- Scale research intensity based on query complexity:
  - Simple factual queries: 10-30 sources minimum
  - Moderate research: 30-50 sources minimum
  - Complex research: 50-80+ sources minimum
  - Comprehensive analysis: 100+ sources when feasible

## Context Management
- Use only information provided in question or found during research
- Do not add inferred or extra information
- Reference current, up-to-date information when needed
- Maintain focus on specific requirements

## Code Generation Efficiency
- Generate minimal, focused code changes
- Avoid verbose explanations unless requested
- Use structured formats for clarity
- Implement token-efficient context references

## Response Optimization
- Default to direct, actionable responses
- Provide essential information first
- Offer details only if requested
- Use lists and tables instead of narrative text
- Cite code regions with line numbers rather than full blocks

## Memory Management
- Optimize context window usage
- Prioritize relevant information
- Compress non-essential context
- Use selective context loading
EOF
    create_file_with_verification "$mdc_file" "$temp_file"
}

# Create or overwrite backend_structure_document.mdc
create_backend_structure_mdc() {
    local templates_dir="$1"
    mkdir -p "$templates_dir"
    local mdc_file="$templates_dir/backend_structure_document.mdc"
    backup_file "$mdc_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
---
description: Backend structure guidelines and API documentation
globs: ["**/backend/**", "**/server/**", "**/api/**"]
alwaysApply: false
---

# Backend Structure Document

## API Architecture
- RESTful API design principles
- GraphQL implementation where appropriate
- Microservices architecture patterns
- Event-driven architecture considerations

## Database Schema
- Entity relationship definitions
- Data model specifications
- Migration strategies
- Index optimization

## Security Implementation
- Authentication mechanisms (JWT, OAuth2)
- Authorization patterns (RBAC, ABAC)
- Data encryption standards
- Input validation protocols

## Error Handling
- Standardized error response formats
- Logging strategies
- Monitoring and alerting
- Graceful degradation patterns

## Performance Optimization
- Caching strategies (Redis, Memcached)
- Database query optimization
- Load balancing configurations
- Rate limiting implementations

## Testing Protocols
- Unit testing standards
- Integration testing frameworks
- API testing methodologies
- Performance testing criteria

## Deployment Guidelines
- Container configuration (Docker)
- CI/CD pipeline requirements
- Environment management
- Health check implementations
EOF
    create_file_with_verification "$mdc_file" "$temp_file"
}

# Create or overwrite tech_stack_document.mdc
create_tech_stack_mdc() {
    local templates_dir="$1"
    mkdir -p "$templates_dir"
    local mdc_file="$templates_dir/tech_stack_document.mdc"
    backup_file "$mdc_file"
    local temp_file
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
---
description: Technology stack specifications and dependencies
globs: ["package.json", "requirements.txt", "Cargo.toml", "pom.xml"]
alwaysApply: false
---

# Tech Stack Document

## Frontend Technologies
- Framework: React/Vue/Angular specifications
- State Management: Redux/Vuex/NgRx patterns
- Styling: CSS-in-JS/SASS/Tailwind configurations
- Build Tools: Webpack/Vite/Parcel setups

## Backend Technologies
- Runtime: Node.js/Python/Java/Go specifications
- Framework: Express/FastAPI/Spring/Gin configurations
- Database: PostgreSQL/MongoDB/Redis implementations
- ORM/ODM: Prisma/SQLAlchemy/Hibernate patterns

## Development Tools
- Version Control: Git workflows and branching strategies
- Package Management: npm/yarn/pip/cargo configurations
- Linting: ESLint/Pylint/Clippy configurations
- Formatting: Prettier/Black/Rustfmt setups

## Testing Stack
- Unit Testing: Jest/pytest/JUnit frameworks
- Integration Testing: Cypress/Selenium configurations
- API Testing: Postman/Insomnia/REST Assured
- Performance Testing: k6/JMeter/Artillery

## Infrastructure
- Cloud Platform: AWS/GCP/Azure services
- Containerization: Docker/Kubernetes configurations
- Monitoring: Prometheus/Grafana/DataDog setups
- Logging: ELK Stack/Fluentd configurations

## Security Tools
- Static Analysis: SonarQube/CodeQL configurations
- Dependency Scanning: Snyk/WhiteSource setups
- Vulnerability Assessment: OWASP ZAP/Burp Suite
- Secret Management: HashiCorp Vault/AWS Secrets Manager

## Documentation Standards
- API Documentation: OpenAPI/Swagger specifications
- Code Documentation: JSDoc/Sphinx/Rustdoc
- Architecture Documentation: ADR (Architecture Decision Records)
- User Documentation: GitBook/Notion/Confluence
EOF
    create_file_with_verification "$mdc_file" "$temp_file"
}

# Verify that >=80% of policy files exist
verify_policy_files() {
    local cursor_dir="$1"
    local rules_dir="$cursor_dir/rules"
    local templates_dir="$cursor_dir/project-templates"
    local verified_count=0
    local total_checks=6
    local files=(
        "$rules_dir/001-coding-protocols.mdc"
        "$rules_dir/002-directory-management.mdc"
        "$rules_dir/003-error-fixing.mdc"
        "$rules_dir/004-token-optimization.mdc"
        "$templates_dir/backend_structure_document.mdc"
        "$templates_dir/tech_stack_document.mdc"
    )
    for file in "${files[@]}"; do
        if [[ -f "$file" && -s "$file" ]]; then
            ((verified_count++))
        fi
    done
    local success_rate=$(( verified_count * 100 / total_checks ))
    log "Policy files verification: $verified_count/$total_checks files present ($success_rate%)"
    if [[ $success_rate -ge 80 ]]; then
        log "SUCCESS: Policy files verification passed (≥80% created)"
    else
        error_exit "FAILED: Policy files verification failed (<80% created)"
    fi
}

# Main execution
main() {
    log "Starting policy and protocol file generation"

    # Detect global cursor directory
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [[ ! -d "$cursor_dir" ]]; then
        cursor_dir="$HOME/Library/Application Support/Code"
    fi
    # Ensure global directories exist (with sudo)
    local rules_dir="$cursor_dir/rules"
    local templates_dir="$cursor_dir/project-templates"
    sudo mkdir -p "$rules_dir"
    sudo mkdir -p "$templates_dir"

    # Create or update global files (with sudo for global operations)
    sudo bash -c "$(declare -f create_coding_protocols_mdc check_no_fake_code create_file_with_verification backup_file log error_exit); create_coding_protocols_mdc '$rules_dir'"
    sudo bash -c "$(declare -f create_directory_management_mdc check_no_fake_code create_file_with_verification backup_file log error_exit); create_directory_management_mdc '$rules_dir'"
    sudo bash -c "$(declare -f create_error_fixing_mdc check_no_fake_code create_file_with_verification backup_file log error_exit); create_error_fixing_mdc '$rules_dir'"
    sudo bash -c "$(declare -f create_token_optimization_mdc check_no_fake_code create_file_with_verification backup_file log error_exit); create_token_optimization_mdc '$rules_dir'"
    sudo bash -c "$(declare -f create_backend_structure_mdc check_no_fake_code create_file_with_verification backup_file log error_exit); create_backend_structure_mdc '$templates_dir'"
    sudo bash -c "$(declare -f create_tech_stack_mdc check_no_fake_code create_file_with_verification backup_file log error_exit); create_tech_stack_mdc '$templates_dir'"
    sudo bash -c "$(declare -f create_cursorrules check_no_fake_code create_file_with_verification backup_file log error_exit); create_cursorrules '$cursor_dir'"
    sudo bash -c "$(declare -f create_project_rules_md check_no_fake_code create_file_with_verification backup_file log error_exit); create_project_rules_md '$cursor_dir'"

    # Always create files in current working directory (project-specific)
    local current_dir="$PWD"
    log "Creating project-specific policy files in current directory: $current_dir"
    create_coding_protocols_mdc "$current_dir"
    create_directory_management_mdc "$current_dir"
    create_error_fixing_mdc "$current_dir"
    create_token_optimization_mdc "$current_dir"
    create_backend_structure_mdc "$current_dir"
    create_tech_stack_mdc "$current_dir"
    create_cursorrules "$current_dir"
    create_project_rules_md "$current_dir"
    
    # Also check for traditional project root (additional coverage)
    if project_root=$(find_project_root); then
        if [[ "$project_root" != "$current_dir" ]]; then
            log "Additional project root found at $project_root. Applying rules there too."
            create_coding_protocols_mdc "$project_root"
            create_directory_management_mdc "$project_root"
            create_error_fixing_mdc "$project_root"
            create_token_optimization_mdc "$project_root"
            create_backend_structure_mdc "$project_root"
            create_tech_stack_mdc "$project_root"
            create_cursorrules "$project_root"
            create_project_rules_md "$project_root"
        fi
    fi

    # Verify global policy files
    verify_policy_files "$cursor_dir"
    # Final verification of all created files
    local verification_files=(
        "$cursor_dir/.cursorrules"
        "$cursor_dir/cursor_project_rules.md"
        "$rules_dir/001-coding-protocols.mdc"
        "$rules_dir/002-directory-management.mdc"
        "$rules_dir/003-error-fixing.mdc"
        "$rules_dir/004-token-optimization.mdc"
        "$templates_dir/backend_structure_document.mdc"
        "$templates_dir/tech_stack_document.mdc"
    )
    
    for file in "${verification_files[@]}"; do
        if [ -f "$file" ]; then
            check_no_fake_code "$file"
        fi
    done
    
    log "Policy file generation script completed successfully"

    # File watcher to monitor changes
    local watch_files=(
        "$cursor_dir/.cursorrules"
        "$cursor_dir/cursor_project_rules.md"
        "$rules_dir/001-coding-protocols.mdc"
        "$rules_dir/002-directory-management.mdc"
        "$rules_dir/003-error-fixing.mdc"
        "$rules_dir/004-token-optimization.mdc"
        "$templates_dir/backend_structure_document.mdc"
        "$templates_dir/tech_stack_document.mdc"
    )
    if command -v fswatch >/dev/null 2>&1; then
        log "Starting file watcher for policy files"
        fswatch -0 "${watch_files[@]}" | while IFS= read -r -d '' event; do
            log "Detected change in $event"
        done &
    else
        log "File watcher not started: fswatch not found"
    fi
}

# Run main
main
