# ───────────────────────────────
#  Script 4: policy-file-generation.sh
# ───────────────────────────────
#!/usr/bin/env bash
set -euo pipefail

# Policy and Protocol File Generation Script
# Creates MDC files and rules from attached reference protocols

readonly SCRIPT_NAME="policy-file-generation"
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

# Check if file already exists (Directory Management Protocol compliance)
check_existing_file() {
    local file_path="$1"
    local file_type="$2"
    
    if [[ -f "$file_path" ]]; then
        log "Found existing $file_type at $file_path (following no-duplication protocol)"
        return 0
    fi
    return 1
}

# Create .cursorrules file
create_cursorrules() {
    local project_dir="$1"
    local cursorrules_file="$project_dir/.cursorrules"
    
    if check_existing_file "$cursorrules_file" ".cursorrules"; then
        return 0
    fi
    
    cat > "$cursorrules_file" << 'EOF'
# Cursor AI Project Rules - Anti-Hallucination Configuration
# Based on cline-coding-protocols.md

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

## Core Anti-Hallucination Rules
- NEVER generate fake, simulated, or placeholder code
- NEVER hardcode API keys, tokens, or sensitive data
- NEVER make assumptions about undefined variables or functions
- ALWAYS ask for clarification when requirements are ambiguous
- ALWAYS validate code syntax and logic before suggesting
- ALWAYS check that imports and dependencies exist
- ALWAYS prefer existing patterns and conventions in the codebase

## Quality Assurance
- All code must be production-ready
- Include appropriate error handling
- Follow established coding conventions
- Implement proper testing
- Provide clear, actionable suggestions only

## Security Requirements
- Sanitize all user inputs
- Use parameterized queries for database access
- Implement proper authentication and authorization
- Follow OWASP security guidelines
- Protect against common vulnerabilities (XSS, CSRF, SQL injection)
- Handle sensitive data securely
EOF
    
    log "Created .cursorrules file at $cursorrules_file"
}

# Create coding protocols MDC file
create_coding_protocols_mdc() {
    local rules_dir="$1"
    local mdc_file="$rules_dir/001-coding-protocols.mdc"
    
    if check_existing_file "$mdc_file" "coding protocols MDC"; then
        return 0
    fi
    
    mkdir -p "$rules_dir"
    
    cat > "$mdc_file" << 'EOF'
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
    
    log "Created coding protocols MDC file at $mdc_file"
}

# Create directory management MDC file
create_directory_management_mdc() {
    local rules_dir="$1"
    local mdc_file="$rules_dir/002-directory-management.mdc"
    
    if check_existing_file "$mdc_file" "directory management MDC"; then
        return 0
    fi
    
    cat > "$mdc_file" << 'EOF'
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
    
    log "Created directory management MDC file at $mdc_file"
}

# Create error fixing MDC file
create_error_fixing_mdc() {
    local rules_dir="$1"
    local mdc_file="$rules_dir/003-error-fixing.mdc"
    
    if check_existing_file "$mdc_file" "error fixing MDC"; then
        return 0
    fi
    
    cat > "$mdc_file" << 'EOF'
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

### Key Components

#### 1. Reproducibility & Context Capture
- Ensure error is reproducible
- Capture complete context: error messages, stack traces, logs, environment details
- Document steps to reproduce

#### 2. Comprehensive Root Cause Analysis (RCA)
- Investigate logs, code changes (git blame/history)
- Review configurations, environment variables, dependency versions
- Analyze potential interactions
- Isolate specific conditions triggering error

#### 3. Impact-Based Prioritization
Evaluate error impact on:
- Core functionality
- UI/UX
- Data integrity
- Security
Priority: critical-impact errors first

#### 4. Solution Comparison & Selection
Research external solutions if internal attempts fail
Compare fixes based on:
- Effectiveness (resolves root cause?)
- Minimalism (least amount of change?)
- Maintainability (readable, aligned with standards?)
- Performance (no negative impact?)
- Security (no vulnerabilities introduced?)

#### 5. Targeted Resolution Attempts (Max 2 Internal)
**Attempt 1:** Implement most likely minimal, targeted fix based on RCA
**Attempt 2:** If failed, revert change, refine analysis, apply revised minimal fix
**Attempt 3:** If failed, revert change, integrate best vetted external solution

#### 6. Rigorous Verification
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
    
    log "Created error fixing MDC file at $mdc_file"
}

# Create token optimization MDC file
create_token_optimization_mdc() {
    local rules_dir="$1"
    local mdc_file="$rules_dir/004-token-optimization.mdc"
    
    if check_existing_file "$mdc_file" "token optimization MDC"; then
        return 0
    fi
    
    cat > "$mdc_file" << 'EOF'
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
    
    log "Created token optimization MDC file at $mdc_file"
}

# Create backend structure document
create_backend_structure_mdc() {
    local templates_dir="$1"
    local mdc_file="$templates_dir/backend_structure_document.mdc"
    
    if check_existing_file "$mdc_file" "backend structure document"; then
        return 0
    fi
    
    mkdir -p "$templates_dir"
    
    cat > "$mdc_file" << 'EOF'
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
    
    log "Created backend structure document at $mdc_file"
}

# Create tech stack document
create_tech_stack_mdc() {
    local templates_dir="$1"
    local mdc_file="$templates_dir/tech_stack_document.mdc"
    
    if check_existing_file "$mdc_file" "tech stack document"; then
        return 0
    fi
    
    cat > "$mdc_file" << 'EOF'
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
    
    log "Created tech stack document at $mdc_file"
}

# Check idempotency for policy files
check_policy_idempotency() {
    local cursor_dir="$1"
    local rules_dir="$cursor_dir/rules"
    local templates_dir="$cursor_dir/project-templates"
    
    # Check if key files exist
    if [[ -f "$rules_dir/001-coding-protocols.mdc" ]] && 
       [[ -f "$rules_dir/002-directory-management.mdc" ]] && 
       [[ -f "$rules_dir/003-error-fixing.mdc" ]] && 
       [[ -f "$rules_dir/004-token-optimization.mdc" ]] && 
       [[ -f "$templates_dir/backend_structure_document.mdc" ]] && 
       [[ -f "$templates_dir/tech_stack_document.mdc" ]]; then
        return 0
    fi
    return 1
}

# Verification function
verify_policy_files() {
    local cursor_dir="$1"
    local rules_dir="$cursor_dir/rules"
    local templates_dir="$cursor_dir/project-templates"
    local verified_count=0
    local total_checks=6
    
    # Check each required file
    local files=(
        "$rules_dir/001-coding-protocols.mdc"
        "$rules_dir/002-directory-management.mdc"
        "$rules_dir/003-error-fixing.mdc"
        "$rules_dir/004-token-optimization.mdc"
        "$templates_dir/backend_structure_document.mdc"
        "$templates_dir/tech_stack_document.mdc"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]] && [[ -s "$file" ]]; then
            ((verified_count++))
        fi
    done
    
    local success_rate=$((verified_count * 100 / total_checks))
    log "Policy files verification: $verified_count/$total_checks files created ($success_rate%)"
    
    if [[ $success_rate -ge 80 ]]; then
        log "SUCCESS: Policy files verification passed (≥80% created)"
        return 0
    else
        error_exit "FAILED: Policy files verification failed (<80% created)"
    fi
}

# Main execution
main() {
    log "Starting policy and protocol file generation"
    
    # Detect cursor directory
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [[ ! -d "$cursor_dir" ]]; then
        cursor_dir="$HOME/Library/Application Support/Code"
    fi
    
    local rules_dir="$cursor_dir/rules"
    local templates_dir="$cursor_dir/project-templates"
    
    # Check idempotency
    if check_policy_idempotency "$cursor_dir"; then
        verify_policy_files "$cursor_dir"
        log "Script completed (idempotent - no changes needed)"
        exit 0
    fi
    
    # Create project .cursorrules in current directory if it's a project
    if [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "Cargo.toml" ]]; then
        create_cursorrules "$PWD"
    fi
    
    # Create MDC files
    create_coding_protocols_mdc "$rules_dir"
    create_directory_management_mdc "$rules_dir"
    create_error_fixing_mdc "$rules_dir"
    create_token_optimization_mdc "$rules_dir"
    
    # Create template documents
    create_backend_structure_mdc "$templates_dir"
    create_tech_stack_mdc "$templates_dir"
    
    # Verify success
    verify_policy_files "$cursor_dir"
    
    log "Script completed successfully"
}

# Run main function
main "$@"
