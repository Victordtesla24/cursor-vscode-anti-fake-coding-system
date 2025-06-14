#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# 10x Engineer/Senior Developer Mode - Production-Only Code Standards
# ZERO FAKE CODE POLICY: No placeholders, TODOs, or mock implementations
# ─────────────────────────────────────────────────────────────────────────────

# Policy and Protocol File Generation Script - Project Agnostic with Complete Embedded Content
# Creates policy files for Cursor AI (VS Code) - works from any git clone location
# All template content embedded using heredoc - ZERO external dependencies
readonly SCRIPT_NAME="policy-file-generation"
readonly LOG_FILE="/var/log/cursor-setup.log"

# Ensure log file exists and is writable
if ! sudo test -f "$LOG_FILE"; then
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
fi

# Logging function with proper error handling
script_log() {
    local message="$1"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    # Safer logging with error handling to prevent directory creation bug
    if echo "[$ts] [$SCRIPT_NAME] $message" | sudo tee -a "$LOG_FILE" >/dev/null 2>&1; then
        echo "[$ts] [$SCRIPT_NAME] $message"
    else
        # Fallback if log file write fails - output to console only
        echo "[$ts] [$SCRIPT_NAME] $message"
    fi
}

# Error handler
error_exit() {
    local message="$1"
    script_log "ERROR: $message"
    exit 1
}

# Check for fake/placeholder code patterns (precise detection)
check_no_fake_code() {
    local file="$1"
    if [ -f "$file" ] && grep -q "TODO:\|FIXME:\|PLACEHOLDER:\|// TODO\|# TODO\|// FIXME\|# FIXME\|// \.\.\.\|# \.\.\." "$file" 2>/dev/null; then
        error_exit "BLOCKED: Fake/placeholder code detected in $file"
    fi
}

# Detect Cursor directory with correct macOS default path (no logging to prevent directory pollution)
detect_cursor_directory() {
    local cursor_dir="$HOME/Library/Application Support/Cursor"
    if [[ ! -d "$cursor_dir" ]]; then
        cursor_dir="$HOME/Library/Application Support/Code"
    fi
    echo "$cursor_dir"
}

# Detect project root (project-agnostic)
detect_project_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        pwd
    fi
}

# Detect if Cline AI extension is installed (enhanced detection)
detect_cline_extension() {
    if command -v code >/dev/null 2>&1; then
        if code --list-extensions 2>/dev/null | grep -q "saoudrizwan.claude-dev"; then
            script_log "Cline AI extension detected"
            return 0
        fi
    fi
    script_log "Cline AI extension not detected"
    return 1
}

# Create consolidated .cursorrules file with COMPLETE embedded content from templates
create_consolidated_cursorrules() {
    local project_dir="$1"
    local cursorrules_file="$project_dir/.cursorrules"

    # Direct atomic creation with COMPLETE embedded content from my-cursorrules.md
    cat > "$cursorrules_file" << 'EOF'
# Cursor AI Project Rules - Anti-Hallucination Configuration
# Production-Only Code Standards - ZERO FAKE CODE POLICY

## Global Cursor AI Rules

**Role: Always act like a 10x Engineer/Senior Developer when starting a new or existing `Task` or a `User Request.`**
   - Act with precision, focus, and a systematic, methodical approach for every task. Prioritize production-ready, robust solutions. Do not jump to conclusions; analyze thoroughly before acting.

---

**I. Strict Operational Constraints (Non-Negotiable)**

1.  **Production-Only Code:**
    *   **ABSOLUTELY PROHIBITED:** Implementing, replacing, or generating code using mockups, simulated fallback mechanisms, error masking, or warning suppression, especially within server-side production directories or code intended for production.
    *   All code generated or modified **MUST** be fully functional, robust, and meet production-grade standards.
2.  **No Duplication:**
    *   **STRICTLY FORBIDDEN:** Creating new, unnecessary, or duplicate files, code blocks, or scripts.
    *   **MANDATORY:** Before creating anything new, you **MUST** thoroughly search the existing codebase for files or modules with similar functionality. Reuse and refactor existing assets whenever possible, following the `my-directory-management-protocols.mdc`.
3.  **Task Completion Standard:**
    *   A task or request is considered "Completed" **ONLY** when **ALL** specified requirements have been fully, completely, and accurately implemented or addressed.

---

# **Project-Specific Rules**

**Role: 10x Engineer/Senior Developer**

## Core Principles

### 1. Zero Fake Code Policy
- NEVER generate placeholders
- ALWAYS complete implementations
- VERIFY all dependencies
- TEST logic before suggesting

### 2. File Size: 300 lines max, 250 warning

## Implementation Workflows

1. **Implementation:** Analyze→Check→Implement→Verify→Cache
2. **Error Resolution:** Cache→RCA→Fix→Verify→Cache
3. **Documentation:** Cache→Generate→Compress→Cache
EOF

    check_no_fake_code "$cursorrules_file"
    script_log "Created consolidated .cursorrules with COMPLETE embedded content from templates"
}

# Create directory management protocols with complete embedded content
create_directory_management_protocols() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/001-directory-management-protocols.mdc"

    # Direct atomic creation with complete content matching current implementation
    cat > "$mdc_file" << 'EOF'
---
description:
globs:
alwaysApply: true
---

### Directory Management Protocol

**Objective:** To organize, consolidate, and maintain the project's directory structure according to established conventions, ensuring code clarity, eliminating redundancy, and preserving functionality.

**Pre- and Post-Requisites:**
*   Utilize version control (e.g., `git stash` or branch) before initiating significant changes.
*   Follow all related protocols (`@my-error-fixing-protocols.mdc`) with absolute precision if errors arise during or after changes.

**Protocol Steps:**

1.  **Determine & Adhere to Project Structure Conventions:**
    *   Identify the established directory structure by checking:
        *   Known framework conventions (e.g., Next.js, Django, Flask).
        *   Project documentation (e.g., `README.md`, `CONTRIBUTING.md`).
        *   Existing patterns in the majority of the codebase.
        *   Configuration files (`.editorconfig`, linter configs).
    *   If conventions are unclear or conflicting, ask the user for clarification.
    *   Ensure all actions comply with VERCEL (or equivalent) deployment best practices regarding structure.

2.  **Comprehensive File Scan & Inventory:**
    *   Recursively scan the entire repository to build an inventory of files, modules, scripts, and configurations.
    *   **Exclude:** `node_modules/`, `.venv/`, `.git/`, `.cursor/`, `.vscode/`, `build/`, `dist/`, `coverage/`, and any paths listed in `.gitignore`.
3.  **Duplicate/Overlap Detection & Consolidation:**
    *   **Strict Prohibition:** ***Never*** create a new file, script, or module if an existing one serves the same or a significantly overlapping purpose. This includes files with different names but similar functionality.
    *   **Detection Heuristics:** Identify potential duplicates/overlaps by analyzing:
        *   Exact file content matches.
        *   High code similarity scores (conceptual).
        *   Similar filenames or naming patterns.
        *   Matching function/class signatures and primary exports.
        *   Similar import dependencies.
        *   Similar core logic or purpose described in comments/docs.
    *   **Consolidation:** If duplicate or overlapping code/files are found:
        *   Determine the **canonical version** (prefer established locations, more complete implementations, or ask the user if ambiguous).
        *   Carefully **merge** necessary unique functionalities into the canonical version.
        *   **Remove** the redundant file(s)/code block(s).
    *   **User Approval:** ***Always*** solicit explicit user approval before creating any new file/module if there's a moderate-to-high confidence of functional overlap with existing code, or if ambiguity exists.

4.  **Strict "No Unrequested Files" Policy:**
    *   ***Do not*** create/generate any files, scripts, or code (even with different names) ***unless***:
        a. The user has explicitly requested the creation of that specific new file/module.
        b. The AI determines creation is *critically necessary* to fulfill the user's primary request *and* no existing file can be appropriately modified, *and* this necessity is confirmed with the user.

5.  **Correct Placement, Renaming & Reference Updates:**
    *   Relocate or rename any misplaced file/directory to conform to the established project structure (identified in Step 1).
    *   **Atomically Update References:** Immediately after moving or renaming, update *all* references across the codebase, including:
        *   Code imports/exports (`import`, `require`, `export`, etc.).
        *   Configuration files (`package.json`, `tsconfig.json`, `pyproject.toml`, CI/CD pipelines, etc.).
        *   Build scripts.
        *   Documentation (`.md` files referencing file paths).
        *   Test files.

6.  **Import & Path Integrity Verification:**
    *   After any move, rename, merge, or deletion:
        *   Run linters and static analysis tools to catch path issues.
        *   Attempt to build/compile the project.
        *   If any errors (import, path, build, etc.) occur, immediately invoke the **Error Fixing Protocol** (`@my-error-fixing-protocols.mdc`), specifically using the **Recursive Import Error Fixing Algorithm** if applicable, aiming for resolution within two attempts per error.

7.  **Clean-Up of Redundant Assets:**
    *   Identify and remove orphaned, unused, or superseded files, code blocks, and configuration entries resulting from consolidation or refactoring.
    *   **Verify Removal:** Double-check (e.g., using code search, `git grep`) that no residual references exist to the deleted items anywhere in the codebase or configuration.

8.  **Preserve Functionality (Zero Regression):**
    *   Ensure that all directory management actions do not alter existing functionality.
    *   Run all relevant unit, integration, and end-to-end test suites. All existing tests must pass.
    *   If test coverage is low for affected areas, perform manual sanity checks on core workflows or ask the user to verify.

9.  **Refactoring Large or Non-Cohesive Files:**
    *   Identify files that are overly long (e.g., exceeding ~600 lines) OR exhibit low cohesion / multiple distinct responsibilities.
    *   Propose a refactoring plan to the user to break the file into smaller, single-responsibility modules/components, adhering strictly to project structure and avoiding new duplication.
    *   Proceed with refactoring only after user approval, applying steps 5-8 for each new/modified file.

10. **Final Verification & Documentation:**
    *   Perform a final run of all relevant test suites and linters to confirm project health.
    *   Record a summary of significant structural changes (moves, merges, deletions, major refactoring) in the Memory Bank or as part of the commit message(s) for traceability. Use clear, atomic commits in VCS for distinct changes.

---

> **Critical Constraints (Mandatory Adherence)**
>   - **No Functionality Change:** Functionality may not be added or removed beyond the specific goal of organization, consolidation, or approved refactoring. Focus is on structure and eliminating redundancy.
>   - **Atomicity & Verification:** Apply changes in small, logical, atomic steps (e.g., move + update refs = one step). Verify integrity (linting, tests, build) immediately after each step. Use VCS checkpoints.
>   - **User Confirmation:** **Always** confirm with the user before:
>       *   Creating any new file/module suspected of overlapping with existing functionality.
>       *   Deleting files (especially if not obvious duplicates).
>       *   Undertaking major refactoring (Rule 9).
>   - **Strict Adherence:** Follow all protocol steps precisely. Do not introduce unrelated changes.

EOF

    check_no_fake_code "$mdc_file"
    script_log "Created complete directory management protocols: $mdc_file"
}

# Sudo-safe version without logging calls
create_directory_management_protocols_sudo() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/001-directory-management-protocols.mdc"

    # Direct atomic creation with complete content matching current implementation
    cat > "$mdc_file" << 'EOF'
---
description:
globs:
alwaysApply: true
---

### Directory Management Protocol

**Objective:** To organize, consolidate, and maintain the project's directory structure according to established conventions, ensuring code clarity, eliminating redundancy, and preserving functionality.

**Pre- and Post-Requisites:**
*   Utilize version control (e.g., `git stash` or branch) before initiating significant changes.
*   Follow all related protocols (`@my-error-fixing-protocols.mdc`) with absolute precision if errors arise during or after changes.

**Protocol Steps:**

1.  **Determine & Adhere to Project Structure Conventions:**
    *   Identify the established directory structure by checking:
        *   Known framework conventions (e.g., Next.js, Django, Flask).
        *   Project documentation (e.g., `README.md`, `CONTRIBUTING.md`).
        *   Existing patterns in the majority of the codebase.
        *   Configuration files (`.editorconfig`, linter configs).
    *   If conventions are unclear or conflicting, ask the user for clarification.
    *   Ensure all actions comply with VERCEL (or equivalent) deployment best practices regarding structure.

2.  **Comprehensive File Scan & Inventory:**
    *   Recursively scan the entire repository to build an inventory of files, modules, scripts, and configurations.
    *   **Exclude:** `node_modules/`, `.venv/`, `.git/`, `.cursor/`, `.vscode/`, `build/`, `dist/`, `coverage/`, and any paths listed in `.gitignore`.
3.  **Duplicate/Overlap Detection & Consolidation:**
    *   **Strict Prohibition:** ***Never*** create a new file, script, or module if an existing one serves the same or a significantly overlapping purpose. This includes files with different names but similar functionality.
    *   **Detection Heuristics:** Identify potential duplicates/overlaps by analyzing:
        *   Exact file content matches.
        *   High code similarity scores (conceptual).
        *   Similar filenames or naming patterns.
        *   Matching function/class signatures and primary exports.
        *   Similar import dependencies.
        *   Similar core logic or purpose described in comments/docs.
    *   **Consolidation:** If duplicate or overlapping code/files are found:
        *   Determine the **canonical version** (prefer established locations, more complete implementations, or ask the user if ambiguous).
        *   Carefully **merge** necessary unique functionalities into the canonical version.
        *   **Remove** the redundant file(s)/code block(s).
    *   **User Approval:** ***Always*** solicit explicit user approval before creating any new file/module if there's a moderate-to-high confidence of functional overlap with existing code, or if ambiguity exists.

4.  **Strict “No Unrequested Files” Policy:**
    *   ***Do not*** create/generate any files, scripts, or code (even with different names) ***unless***:
        a. The user has explicitly requested the creation of that specific new file/module.
        b. The AI determines creation is *critically necessary* to fulfill the user's primary request *and* no existing file can be appropriately modified, *and* this necessity is confirmed with the user.

5.  **Correct Placement, Renaming & Reference Updates:**
    *   Relocate or rename any misplaced file/directory to conform to the established project structure (identified in Step 1).
    *   **Atomically Update References:** Immediately after moving or renaming, update *all* references across the codebase, including:
        *   Code imports/exports (`import`, `require`, `export`, etc.).
        *   Configuration files (`package.json`, `tsconfig.json`, `pyproject.toml`, CI/CD pipelines, etc.).
        *   Build scripts.
        *   Documentation (`.md` files referencing file paths).
        *   Test files.

6.  **Import & Path Integrity Verification:**
    *   After any move, rename, merge, or deletion:
        *   Run linters and static analysis tools to catch path issues.
        *   Attempt to build/compile the project.
        *   If any errors (import, path, build, etc.) occur, immediately invoke the **Error Fixing Protocol** (`@my-error-fixing-protocols.mdc`), specifically using the **Recursive Import Error Fixing Algorithm** if applicable, aiming for resolution within two attempts per error.

7.  **Clean-Up of Redundant Assets:**
    *   Identify and remove orphaned, unused, or superseded files, code blocks, and configuration entries resulting from consolidation or refactoring.
    *   **Verify Removal:** Double-check (e.g., using code search, `git grep`) that no residual references exist to the deleted items anywhere in the codebase or configuration.

8.  **Preserve Functionality (Zero Regression):**
    *   Ensure that all directory management actions do not alter existing functionality.
    *   Run all relevant unit, integration, and end-to-end test suites. All existing tests must pass.
    *   If test coverage is low for affected areas, perform manual sanity checks on core workflows or ask the user to verify.

9.  **Refactoring Large or Non-Cohesive Files:**
    *   Identify files that are overly long (e.g., exceeding ~600 lines) OR exhibit low cohesion / multiple distinct responsibilities.
    *   Propose a refactoring plan to the user to break the file into smaller, single-responsibility modules/components, adhering strictly to project structure and avoiding new duplication.
    *   Proceed with refactoring only after user approval, applying steps 5-8 for each new/modified file.

10. **Final Verification & Documentation:**
    *   Perform a final run of all relevant test suites and linters to confirm project health.
    *   Record a summary of significant structural changes (moves, merges, deletions, major refactoring) in the Memory Bank or as part of the commit message(s) for traceability. Use clear, atomic commits in VCS for distinct changes.

---

> **Critical Constraints (Mandatory Adherence)**
>   - **No Functionality Change:** Functionality may not be added or removed beyond the specific goal of organization, consolidation, or approved refactoring. Focus is on structure and eliminating redundancy.
>   - **Atomicity & Verification:** Apply changes in small, logical, atomic steps (e.g., move + update refs = one step). Verify integrity (linting, tests, build) immediately after each step. Use VCS checkpoints.
>   - **User Confirmation:** **Always** confirm with the user before:
>       *   Creating any new file/module suspected of overlapping with existing functionality.
>       *   Deleting files (especially if not obvious duplicates).
>       *   Undertaking major refactoring (Rule 9).
>   - **Strict Adherence:** Follow all protocol steps precisely. Do not introduce unrelated changes.

EOF

    check_no_fake_code "$mdc_file"
}

# Create error fixing protocols with 30% optimized embedded content
create_error_fixing_protocols() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/002-error-fixing-protocols.mdc"

    # Direct atomic creation with 30% optimized content
    cat > "$mdc_file" << 'EOF'
---
description: Error fixing protocols with RCA and validation
globs: ["**/*"]
alwaysApply: true
---

## 002-error-fixing-protocols

**Objective:** To systematically identify, analyze, and resolve errors within the codebase efficiently and robustly, ensuring minimal disruption and maintaining code quality through AI-assisted root cause analysis and online research validation.

**Pre- and Post-Requisites:**

Follow all related protocols (`@001-directory-management-protocols.mdc`) with absolute precision before and after every change. Utilize version control (e.g., `git stash` or branch) before attempting fixes.

**Core Principle:** Adhere strictly to these protocols for **every** error. Employ a "Fail Fast" mindset with small, **incremental**, and **atomic** fixes. After each fix attempt, rigorously verify resolution through automated testing and validation.

### Key Components

#### 1. **AI-Powered Error Context Capture & Research**
Ensure the error is reproducible and conduct comprehensive online research for each identified issue. Capture complete context: full error messages, stack traces, relevant logs, OS/environment details, and steps to reproduce.

**Research Phase:**
  - Narrow down root cause(s) for every single error in console/terminal output
  - Conduct systematic online research for each root cause using proven search methodologies
  - Validate solutions against current best practices and framework documentation
  - Prioritize solutions with minimal code segment replacement/generation requirements

#### 2. **Root Cause Analysis (RCA)**
Investigate logs, code changes (using `git blame`/history), configurations (files, environment variables), dependency versions, and potential interactions. Utilize AI-driven classification algorithms to categorize defects and clustering algorithms to identify patterns and trends.
  - **Automated Pattern Recognition:** Leverage AI algorithms for anomaly detection and natural language processing of error reports
  - **Historical Analysis:** Use regression algorithms to predict failure occurrence based on historical data
  - **Relationship Mapping:** Apply association rule learning to find relationships between variables in error information

#### 3. **Impact-Based Prioritization with Validation Loop**
Evaluate the error's impact on **core functionality, UI/UX, data integrity, and security**. Prioritize critical-impact errors. Include mandatory validation through re-running tests and quality checks.

#### 4. **Solution Research, Comparison & Online Validation**
Research external solutions using systematic online methodologies. **Compare** potential fixes based on:
  - **Effectiveness:** Verified resolution of root cause through online validation
  - **Minimalism:** Least amount of code change required
  - **Maintainability:** Alignment with project standards and best practices
  - **Performance:** No negative performance impact
  - **Security:** No introduction of vulnerabilities

#### 5. **Targeted Resolution with Continuous Validation**
  - **Attempt 1:** Implement minimal, targeted fix based on RCA and online research
  - **Attempt 2:** If failed, revert and apply refined solution based on additional research
  - **Attempt 3:** Integrate best vetted alternative solution with project-specific adaptations
  - **Continuous Validation:** Re-run automated tests, shellcheck, and quality validation after each attempt

#### 6. **Automated Verification & Quality Assurance**
After *each* attempt, execute comprehensive validation:
  - Run `@/cursor-optimization-policies.sh`, `shellcheck`, and all relevant tests
  - Validate through automated testing protocols and continuous integration checks
  - **File Integrity Check:** Ensure no unintended modifications or duplicate files
  - **Performance Validation:** Verify no degradation in system performance

#### 7. **Cross-Protocol Integration & Directory Management**
Seamlessly integrate with directory management protocols to maintain structural integrity while implementing fixes. Ensure no creation of unnecessary, duplicate, or redundant files during the error resolution process.

---

### **Recursive Error Resolution Algorithm**
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
|              **Step**                      |                           **Action**                           |         **Research Component**                   | **Validation Requirements** |  **Exit Condition**     |
|--------------------------------------------|----------------------------------------------------------------|--------------------------------------------------|-----------------------------|-------------------------|
| **1. Error Isolation & Research**          | Detect, reproduce, isolate error. Conduct systematic           | Search error patterns, validate against current  | Root causes researched      | Error context captured  |
|                                            | online research for each identified root cause                 | documentation, identify proven solutions         | and validated               | with research data      |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **2. AI-Assisted Root Cause Analysis**     | Perform analysis using classification                          | Cross-reference findings with online knowledge   | Research validation         | Potential causes        |
|                                            | and clustering algorithms                                      | base, validate against similar cases             | completed                   | identified and verified |
| **2A. Impact & Solution Assessment**       | Evaluate impact and research optimal solutions                 | Validate solution effectiveness through          | Solution research           | Impact assessed,        |
|                                            | online with minimal code replacement focus                     | online resources and community feedback          | documented                  | solutions prioritized   |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **3. Research-Informed Fix Attempt**       | **Checkpoint (Git)**. Apply minimal fix based on               | Implement solution following researched best     | Code follows researched     | Verification pending    |
|                                            | online research findings                                       | practices and minimal change principles          | methodology                 |                         |
| **3A. Verification & Testing**             | Run comprehensive tests: `@/cursor-optimization-policies.sh`,  | Validate against researched quality standards    | All tests pass, no          | Fix validated OR        |
|                                            | `shellcheck`, automated tests                                  | and performance benchmarks                       | errors/warnings remain      | Fix failed              |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **4. Iterative Research & Refinement**     | If failed, **Revert Fix (Git)**. Conduct additional online     | Deep-dive research into alternative solutions,   | Research                    | Refined solution        |
|                                            | research, refine approach                                      | validate through multiple sources                | completed                   | identified              |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **5. Alternative Solution Implementation** | **Checkpoint (Git)**. Implement researched alternative         | Apply community-validated solution with          | Follows minimal             | Error resolved          |
|                                            | solution with minimal code changes                             | project-specific adaptations                     | change principle            |                         |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **6. Final Validation & Compliance**       | Execute full test suite and quality validation until           | Validate against all researched quality          | Zero errors/warnings        | Task completion         |
|                                            |  zero errors/warnings remain                                   | standards and project requirements               | confirmed                   | verified                |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **7. Quality Assurance & Documentation**   | Ensure task completion only when ALL requirements fulfilled,   | Document researched solutions and validation     | Complete documentation      | Stable state confirmed  |
|                                            | document research findings                                     | results for future reference                     | provided                    |                         |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|

#### **Import Error Resolution Algorithm**
**Purpose:** To resolve import-related errors through systematic research and minimal code changes while maintaining directory structure integrity[17][18].

```ascii
+--------------------------------------------+
| START: Error Detection & Online Research   |
| (Research each import error systematically)|
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Conduct Online Research for Root Causes    |
| (Validate solutions against documentation) |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Apply Directory Management Protocols [1]   |
| (Ensure structural compliance)             |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Implement Research-Based Minimal Fix       |
| (Apply validated solution with minimal     |
| code changes)                              |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Run Comprehensive Validation Tests         |
| (@/cursor-optimization-policies.sh,        |
| shellcheck, automated tests)               |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Validation Passed? Zero Errors/Warnings?  |
+--------------------+-----------------------+
         YES                    NO
          ↓                     ↓
+--------------------+  +------------------+
| Document Solution  |  | Repeat Research  |
| & Complete Task    |  | & Refinement     |
+--------------------+  +------------------+
                             ↓
                    +------------------+
                    | Continue Until   |
                    | Zero Errors      |
                    +------------------+
```

---

## **Critical Constraints (Mandatory Adherence)**

### **Research & Validation Requirements**
  - **Systematic Online Research:** Every error must be researched online using proven methodologies
  - **Solution Validation:** All solutions must be validated against current documentation and best practices
  - **Minimal Code Changes:** Prioritize solutions requiring minimal code segment replacement
  - **Zero Tolerance:** Task completion only when ALL errors/warnings are eliminated

### **Cursor AI-Specific Optimizations**
  - **Atomicity:** Each fix must be the smallest possible change following researched best practices
  - **Version Control Integration:** Mandatory use of git checkpoints before each attempt
  - **Automated Testing:** Integration with Cursor AI's automated testing capabilities
  - **Context Awareness:** Leverage Cursor AI's codebase understanding for targeted fixes

### **Quality Assurance Standards**
  - **No Placeholders:** Complete implementation required, no temporary or placeholder code
  - **Directory Compliance:** Strict adherence to directory management protocols
  - **Performance Validation:** Ensure no degradation in system performance
  - **Security Compliance:** Validate against security best practices and vulnerability prevention

---

## **Implementation Guidelines for Cursor AI Integration**
### **Cursor AI-Specific Features Utilization**
  1. **Composer Integration:** Utilize Cursor's composer for multi-file error resolution while maintaining context awareness
  2. **Chat Optimization:** Implement structured prompting for systematic error resolution through chat interface
  3. **Automated Testing Integration:** Leverage Cursor's built-in testing capabilities for continuous validation
  4. **Context Management:** Optimize for Cursor's codebase understanding and reference capabilities

### **Quality Assurance Integration**

The error fixing protocols incorporate automated quality assurance methodologies that ensure:
  - **Continuous Integration Compatibility:** Seamless integration with CI/CD pipelines
  - **Performance Monitoring:** Real-time validation of system performance impact
  - **Security Validation:** Automated security compliance checking
  - **Documentation Standards:** Comprehensive documentation of research findings and solution rationale
EOF

    check_no_fake_code "$mdc_file"
    script_log "Created optimized error fixing protocols: $mdc_file"
}

# Sudo-safe version without logging calls
create_error_fixing_protocols_sudo() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/002-error-fixing-protocols.mdc"

    # Direct atomic creation with 30% optimized content
    cat > "$mdc_file" << 'EOF'
---
description: Systematic error fixing protocols with RCA and validation
globs: ["**/*"]
alwaysApply: true
---

## Error Fixing Protocol

## 002-error-fixing-protocols

**Objective:** To systematically identify, analyze, and resolve errors within the codebase efficiently and robustly, ensuring minimal disruption and maintaining code quality through AI-assisted root cause analysis and online research validation.

**Pre- and Post-Requisites:**

Follow all related protocols (`@001-directory-management-protocols.mdc`) with absolute precision before and after every change. Utilize version control (e.g., `git stash` or branch) before attempting fixes.

**Core Principle:** Adhere strictly to these protocols for **every** error. Employ a "Fail Fast" mindset with small, **incremental**, and **atomic** fixes. After each fix attempt, rigorously verify resolution through automated testing and validation.

### Key Components

#### 1. **AI-Powered Error Context Capture & Research**
Ensure the error is reproducible and conduct comprehensive online research for each identified issue. Capture complete context: full error messages, stack traces, relevant logs, OS/environment details, and steps to reproduce.

**Research Phase:**
  - Narrow down root cause(s) for every single error in console/terminal output
  - Conduct systematic online research for each root cause using proven search methodologies
  - Validate solutions against current best practices and framework documentation
  - Prioritize solutions with minimal code segment replacement/generation requirements

#### 2. **Root Cause Analysis (RCA)**
Investigate logs, code changes (using `git blame`/history), configurations (files, environment variables), dependency versions, and potential interactions. Utilize AI-driven classification algorithms to categorize defects and clustering algorithms to identify patterns and trends.
  - **Automated Pattern Recognition:** Leverage AI algorithms for anomaly detection and natural language processing of error reports
  - **Historical Analysis:** Use regression algorithms to predict failure occurrence based on historical data
  - **Relationship Mapping:** Apply association rule learning to find relationships between variables in error information

#### 3. **Impact-Based Prioritization with Validation Loop**
Evaluate the error's impact on **core functionality, UI/UX, data integrity, and security**. Prioritize critical-impact errors. Include mandatory validation through re-running tests and quality checks.

#### 4. **Solution Research, Comparison & Online Validation**
Research external solutions using systematic online methodologies. **Compare** potential fixes based on:
  - **Effectiveness:** Verified resolution of root cause through online validation
  - **Minimalism:** Least amount of code change required
  - **Maintainability:** Alignment with project standards and best practices
  - **Performance:** No negative performance impact
  - **Security:** No introduction of vulnerabilities

#### 5. **Targeted Resolution with Continuous Validation**
  - **Attempt 1:** Implement minimal, targeted fix based on RCA and online research
  - **Attempt 2:** If failed, revert and apply refined solution based on additional research
  - **Attempt 3:** Integrate best vetted alternative solution with project-specific adaptations
  - **Continuous Validation:** Re-run automated tests, shellcheck, and quality validation after each attempt

#### 6. **Automated Verification & Quality Assurance**
After *each* attempt, execute comprehensive validation:
  - Run `@/cursor-optimization-policies.sh`, `shellcheck`, and all relevant tests
  - Validate through automated testing protocols and continuous integration checks
  - **File Integrity Check:** Ensure no unintended modifications or duplicate files
  - **Performance Validation:** Verify no degradation in system performance

#### 7. **Cross-Protocol Integration & Directory Management**
Seamlessly integrate with directory management protocols to maintain structural integrity while implementing fixes. Ensure no creation of unnecessary, duplicate, or redundant files during the error resolution process.

---

### **Recursive Error Resolution Algorithm**
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
|              **Step**                      |                           **Action**                           |         **Research Component**                   | **Validation Requirements** |  **Exit Condition**     |
|--------------------------------------------|----------------------------------------------------------------|--------------------------------------------------|-----------------------------|-------------------------|
| **1. Error Isolation & Research**          | Detect, reproduce, isolate error. Conduct systematic           | Search error patterns, validate against current  | Root causes researched      | Error context captured  |
|                                            | online research for each identified root cause                 | documentation, identify proven solutions         | and validated               | with research data      |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **2. AI-Assisted Root Cause Analysis**     | Perform analysis using classification                          | Cross-reference findings with online knowledge   | Research validation         | Potential causes        |
|                                            | and clustering algorithms                                      | base, validate against similar cases             | completed                   | identified and verified |
| **2A. Impact & Solution Assessment**       | Evaluate impact and research optimal solutions                 | Validate solution effectiveness through          | Solution research           | Impact assessed,        |
|                                            | online with minimal code replacement focus                     | online resources and community feedback          | documented                  | solutions prioritized   |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **3. Research-Informed Fix Attempt**       | **Checkpoint (Git)**. Apply minimal fix based on               | Implement solution following researched best     | Code follows researched     | Verification pending    |
|                                            | online research findings                                       | practices and minimal change principles          | methodology                 |                         |
| **3A. Verification & Testing**             | Run comprehensive tests: `@/cursor-optimization-policies.sh`,  | Validate against researched quality standards    | All tests pass, no          | Fix validated OR        |
|                                            | `shellcheck`, automated tests                                  | and performance benchmarks                       | errors/warnings remain      | Fix failed              |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **4. Iterative Research & Refinement**     | If failed, **Revert Fix (Git)**. Conduct additional online     | Deep-dive research into alternative solutions,   | Research                    | Refined solution        |
|                                            | research, refine approach                                      | validate through multiple sources                | completed                   | identified              |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **5. Alternative Solution Implementation** | **Checkpoint (Git)**. Implement researched alternative         | Apply community-validated solution with          | Follows minimal             | Error resolved          |
|                                            | solution with minimal code changes                             | project-specific adaptations                     | change principle            |                         |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **6. Final Validation & Compliance**       | Execute full test suite and quality validation until           | Validate against all researched quality          | Zero errors/warnings        | Task completion         |
|                                            |  zero errors/warnings remain                                   | standards and project requirements               | confirmed                   | verified                |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|
| **7. Quality Assurance & Documentation**   | Ensure task completion only when ALL requirements fulfilled,   | Document researched solutions and validation     | Complete documentation      | Stable state confirmed  |
|                                            | document research findings                                     | results for future reference                     | provided                    |                         |
|--------------------------------------------+----------------------------------------------------------------+--------------------------------------------------+-----------------------------+-------------------------|

#### **Import Error Resolution Algorithm**
**Purpose:** To resolve import-related errors through systematic research and minimal code changes while maintaining directory structure integrity[17][18].

```ascii
+--------------------------------------------+
| START: Error Detection & Online Research   |
| (Research each import error systematically)|
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Conduct Online Research for Root Causes    |
| (Validate solutions against documentation) |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Apply Directory Management Protocols [1]   |
| (Ensure structural compliance)             |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Implement Research-Based Minimal Fix       |
| (Apply validated solution with minimal     |
| code changes)                              |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Run Comprehensive Validation Tests         |
| (@/cursor-optimization-policies.sh,        |
| shellcheck, automated tests)               |
+--------------------------------------------+
                    ↓
+--------------------------------------------+
| Validation Passed? Zero Errors/Warnings?  |
+--------------------+-----------------------+
         YES                    NO
          ↓                     ↓
+--------------------+  +------------------+
| Document Solution  |  | Repeat Research  |
| & Complete Task    |  | & Refinement     |
+--------------------+  +------------------+
                             ↓
                    +------------------+
                    | Continue Until   |
                    | Zero Errors      |
                    +------------------+
```

---

## **Critical Constraints (Mandatory Adherence)**

### **Research & Validation Requirements**
  - **Systematic Online Research:** Every error must be researched online using proven methodologies
  - **Solution Validation:** All solutions must be validated against current documentation and best practices
  - **Minimal Code Changes:** Prioritize solutions requiring minimal code segment replacement
  - **Zero Tolerance:** Task completion only when ALL errors/warnings are eliminated

### **Cursor AI-Specific Optimizations**
  - **Atomicity:** Each fix must be the smallest possible change following researched best practices
  - **Version Control Integration:** Mandatory use of git checkpoints before each attempt
  - **Automated Testing:** Integration with Cursor AI's automated testing capabilities
  - **Context Awareness:** Leverage Cursor AI's codebase understanding for targeted fixes

### **Quality Assurance Standards**
  - **No Placeholders:** Complete implementation required, no temporary or placeholder code
  - **Directory Compliance:** Strict adherence to directory management protocols
  - **Performance Validation:** Ensure no degradation in system performance
  - **Security Compliance:** Validate against security best practices and vulnerability prevention

---

## **Implementation Guidelines for Cursor AI Integration**
### **Cursor AI-Specific Features Utilization**
  1. **Composer Integration:** Utilize Cursor's composer for multi-file error resolution while maintaining context awareness
  2. **Chat Optimization:** Implement structured prompting for systematic error resolution through chat interface
  3. **Automated Testing Integration:** Leverage Cursor's built-in testing capabilities for continuous validation
  4. **Context Management:** Optimize for Cursor's codebase understanding and reference capabilities

### **Quality Assurance Integration**

The error fixing protocols incorporate automated quality assurance methodologies that ensure:
  - **Continuous Integration Compatibility:** Seamless integration with CI/CD pipelines
  - **Performance Monitoring:** Real-time validation of system performance impact
  - **Security Validation:** Automated security compliance checking
  - **Documentation Standards:** Comprehensive documentation of research findings and solution rationale
EOF

    check_no_fake_code "$mdc_file"
}

# Create backend structure document with atomic creation
create_backend_structure_mdc() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/003-backend_structure_document.mdc"

    # Direct atomic creation
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

    check_no_fake_code "$mdc_file"
    script_log "Created backend structure document: $mdc_file"
}

# Sudo-safe version without logging calls
create_backend_structure_mdc_sudo() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/003-backend_structure_document.mdc"

    # Direct atomic creation
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

    check_no_fake_code "$mdc_file"
}

# Create tech stack document with atomic creation
create_tech_stack_mdc() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/004-tech_stack_document.mdc"

    # Direct atomic creation
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

    check_no_fake_code "$mdc_file"
    script_log "Created tech stack document: $mdc_file"
}

# Sudo-safe version without logging calls
create_tech_stack_mdc_sudo() {
    local rules_dir="$1"
    mkdir -p "$rules_dir"
    local mdc_file="$rules_dir/004-tech_stack_document.mdc"

    # Direct atomic creation
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

    check_no_fake_code "$mdc_file"
}

# Create Cline-specific coding protocols with 30% optimized embedded content
create_cline_coding_protocols() {
    local clinerules_dir="$1"
    mkdir -p "$clinerules_dir"
    local md_file="$clinerules_dir/001-cline-coding-protocols.md"

    # Direct atomic creation with 30% optimized embedded content
    cat > "$md_file" << 'EOF'
# Cline AI - Coding Protocols

**Role: 10x Engineer/Senior Developer for every Task/User Request**
- Precision, focus, systematic methodology
- Production-ready solutions only
- Analyze thoroughly before acting

**Production-Only Code:**
- **PROHIBITED:** mockups, simulations, error masking, warning suppression
- All code **MUST** be functional, robust, production-grade
- **Implementation Pattern:** Analyze→Research→Draft→Validate→Optimize

**Extended Thinking Control:**
- **Selective Engagement:** Complex problems, multi-step implementations, architecture decisions
- **Structure:** Problem→Approach→Execution→Verification
- **Visibility:** Only when necessary for verification

**Error Resolution:**
- **RCA First:** Systematic analysis before fixes
- **Template Caching:** Cache common resolution patterns
- **Two-Attempt Max:** Targeted fix→Broader fix→External solution
- **Pattern Recognition:** Prevent recurrence through caching

**No Duplication:**
- **FORBIDDEN:** new unnecessary files/scripts
- **MANDATORY:** Search existing before creating
- **Consolidation First:** Refactor over new implementations

**Output Optimization:**
- **Concise Format:** Direct responses unless detail requested
- **Code-Only Mode:** Generate code without explanations
- **Staged Delivery:** Essential first, details on request
- **Structural Compression:** Lists/tables over narrative

**Context Optimization:**
- **Selective Loading:** Relevant context only
- **Prioritize:** Code over documentation
- **Compress:** Non-essential sections
- **Token-Efficient:** Paths/line numbers over full content

# Core Protocols
- **Clarity:** Simple, maintainable code
- **Single Responsibility:** One purpose per function/class
- **DRY:** Avoid duplication
- **Testing:** Test new features/fixes
- **Documentation:** Comment complex logic
EOF

    check_no_fake_code "$md_file"
    script_log "Created optimized Cline coding protocols: $md_file"
}

# Create Cline-specific token optimization with 30% optimized embedded content
create_cline_token_optimization() {
    local clinerules_dir="$1"
    mkdir -p "$clinerules_dir"
    local md_file="$clinerules_dir/002-token-optimization.md"

    # Direct atomic creation with 30% optimized embedded content
    cat > "$md_file" << 'EOF'
# Cline AI - Token Optimization Protocols

## Core Principles
- **Concise:** Clear, concise language
- **Context:** Relevant context only
- **Iterate:** Simple prompts, refine based on results
- **Format:** Specify output format explicitly
- **Limit:** Request concise responses

## Prompt Optimization
- Short, keyword-based queries
- Break complex into sequential tasks
- Scale research intensity:
  - Simple: 10-30 sources
  - Moderate: 30-50 sources
  - Complex: 50-80+ sources
  - Comprehensive: 100+ sources

## Context Management
- Use provided/found information only
- No inferred/extra information
- Current, up-to-date references
- Focus on specific requirements

## Code Generation
- Minimal, focused changes
- Avoid verbose explanations
- Structured formats for clarity
- Token-efficient context references

## Response Optimization
- Direct, actionable responses
- Essential information first
- Details on request only
- Lists/tables over narrative
- Line number citations over full blocks

## Memory Management
- Optimize context window usage
- Prioritize relevant information
- Compress non-essential context
- Selective context loading
EOF

    check_no_fake_code "$md_file"
    script_log "Created optimized Cline token optimization: $md_file"
}

# Sudo-safe version without logging calls
create_cline_coding_protocols_sudo() {
    local clinerules_dir="$1"
    mkdir -p "$clinerules_dir"
    local md_file="$clinerules_dir/001-cline-coding-protocols.md"

    # Direct atomic creation with 30% optimized embedded content
    cat > "$md_file" << 'EOF'
# Cline AI - Coding Protocols

**Role: 10x Engineer/Senior Developer for every Task/User Request**
- Precision, focus, systematic methodology
- Production-ready solutions only
- Analyze thoroughly before acting

**Production-Only Code:**
- **PROHIBITED:** mockups, simulations, error masking, warning suppression
- All code **MUST** be functional, robust, production-grade
- **Implementation Pattern:** Analyze→Research→Draft→Validate→Optimize

**Extended Thinking Control:**
- **Selective Engagement:** Complex problems, multi-step implementations, architecture decisions
- **Structure:** Problem→Approach→Execution→Verification
- **Visibility:** Only when necessary for verification

**Error Resolution:**
- **RCA First:** Systematic analysis before fixes
- **Template Caching:** Cache common resolution patterns
- **Two-Attempt Max:** Targeted fix→Broader fix→External solution
- **Pattern Recognition:** Prevent recurrence through caching

**No Duplication:**
- **FORBIDDEN:** new unnecessary files/scripts
- **MANDATORY:** Search existing before creating
- **Consolidation First:** Refactor over new implementations

**Output Optimization:**
- **Concise Format:** Direct responses unless detail requested
- **Code-Only Mode:** Generate code without explanations
- **Staged Delivery:** Essential first, details on request
- **Structural Compression:** Lists/tables over narrative

**Context Optimization:**
- **Selective Loading:** Relevant context only
- **Prioritize:** Code over documentation
- **Compress:** Non-essential sections
- **Token-Efficient:** Paths/line numbers over full content

# Core Protocols
- **Clarity:** Simple, maintainable code
- **Single Responsibility:** One purpose per function/class
- **DRY:** Avoid duplication
- **Testing:** Test new features/fixes
- **Documentation:** Comment complex logic
EOF

    check_no_fake_code "$md_file"
}

# Sudo-safe version without logging calls
create_cline_token_optimization_sudo() {
    local clinerules_dir="$1"
    mkdir -p "$clinerules_dir"
    local md_file="$clinerules_dir/002-token-optimization.md"

    # Direct atomic creation with 30% optimized embedded content
    cat > "$md_file" << 'EOF'
# Cline AI - Token Optimization Protocols

## Core Principles
- **Concise:** Clear, concise language
- **Context:** Relevant context only
- **Iterate:** Simple prompts, refine based on results
- **Format:** Specify output format explicitly
- **Limit:** Request concise responses

## Prompt Optimization
- Short, keyword-based queries
- Break complex into sequential tasks
- Scale research intensity:
  - Simple: 10-30 sources
  - Moderate: 30-50 sources
  - Complex: 50-80+ sources
  - Comprehensive: 100+ sources

## Context Management
- Use provided/found information only
- No inferred/extra information
- Current, up-to-date references
- Focus on specific requirements

## Code Generation
- Minimal, focused changes
- Avoid verbose explanations
- Structured formats for clarity
- Token-efficient context references

## Response Optimization
- Direct, actionable responses
- Essential information first
- Details on request only
- Lists/tables over narrative
- Line number citations over full blocks

## Memory Management
- Optimize context window usage
- Prioritize relevant information
- Compress non-essential context
- Selective context loading
EOF

    check_no_fake_code "$md_file"
}

# Remove duplicate files after restructuring - ZERO BACKUP STRATEGY
cleanup_duplicate_files() {
    local project_dir="$1"

    # Remove old duplicate files that are now redundant
    local old_files=(
        "$project_dir/cursor_project_rules.md"
        "$project_dir/001-coding-protocols.mdc"
        "$project_dir/004-token-optimization.mdc"
        "$project_dir/002-directory-management.mdc"
        "$project_dir/003-error-fixing.mdc"
    )

    for file in "${old_files[@]}"; do
        if [[ -f "$file" ]]; then
            # Direct atomic removal - no backup strategy
            rm -f "$file" || script_log "Warning: Failed to remove $file"
            script_log "Removed duplicate file: $file"
        fi
    done
}

# Verify that ≥80% of policy files exist
verify_policy_files() {
    local cursor_dir="$1"
    local project_dir="$2"
    local verified_count=0
    local total_checks=8

    # Global files
    local global_files=(
        "$cursor_dir/rules/001-directory-management-protocols.mdc"
        "$cursor_dir/rules/002-error-fixing-protocols.mdc"
        "$cursor_dir/rules/003-backend_structure_document.mdc"
        "$cursor_dir/rules/004-tech_stack_document.mdc"
    )

    # Project files
    local project_files=(
        "$project_dir/.cursor/rules/001-directory-management-protocols.mdc"
        "$project_dir/.cursor/rules/002-error-fixing-protocols.mdc"
        "$project_dir/.cursor/rules/003-backend_structure_document.mdc"
        "$project_dir/.cursor/rules/004-tech_stack_document.mdc"
    )

    for file in "${global_files[@]}" "${project_files[@]}"; do
        if [[ -f "$file" && -s "$file" ]]; then
            ((verified_count++))
        fi
    done

    local success_rate=$(( verified_count * 100 / total_checks ))
    script_log "Policy files verification: $verified_count/$total_checks files present ($success_rate%)"
    if [[ $success_rate -ge 80 ]]; then
        script_log "SUCCESS: Policy files verification passed (≥80% created)"
    else
        error_exit "FAILED: Policy files verification failed (<80% created)"
    fi
}

# Main execution with complete project-agnostic implementation
main() {
    script_log "Starting project-agnostic policy file generation with complete embedded content"

    # Detect cursor directory (macOS default path)
    local cursor_dir
    cursor_dir=$(detect_cursor_directory)

    # Detect project root (project-agnostic)
    local project_dir
    project_dir=$(detect_project_root)
    script_log "Project directory: $project_dir"

    # Create directory structure with correct macOS defaults
    local global_rules_dir="$cursor_dir/rules"
    sudo mkdir -p "$global_rules_dir"
    script_log "Created global rules directory (macOS default): $global_rules_dir"

    local project_rules_dir="$project_dir/.cursor/rules"
    mkdir -p "$project_rules_dir"
    script_log "Created project rules directory: $project_rules_dir"

    # Create global policy files with embedded content - ZERO BACKUP STRATEGY
    script_log "Creating global policy files with embedded content..."
    sudo bash -c "$(declare -f create_directory_management_protocols_sudo check_no_fake_code); create_directory_management_protocols_sudo '$global_rules_dir'"
    sudo bash -c "$(declare -f create_error_fixing_protocols_sudo check_no_fake_code); create_error_fixing_protocols_sudo '$global_rules_dir'"
    sudo bash -c "$(declare -f create_backend_structure_mdc_sudo check_no_fake_code); create_backend_structure_mdc_sudo '$global_rules_dir'"
    sudo bash -c "$(declare -f create_tech_stack_mdc_sudo check_no_fake_code); create_tech_stack_mdc_sudo '$global_rules_dir'"

    # Create project policy files with identical embedded content
    script_log "Creating project policy files with embedded content..."
    create_directory_management_protocols "$project_rules_dir"
    create_error_fixing_protocols "$project_rules_dir"
    create_backend_structure_mdc "$project_rules_dir"
    create_tech_stack_mdc "$project_rules_dir"

    # Create consolidated .cursorrules with embedded dual sections
    script_log "Creating consolidated .cursorrules with embedded content..."
    create_consolidated_cursorrules "$project_dir"

    # Conditional Cline extension-specific files with .md extension
    if detect_cline_extension; then
        script_log "Creating Cline AI extension-specific policies (.md extension)..."
        local global_clinerules_dir="$cursor_dir/.clinerules"
        local project_clinerules_dir="$project_dir/.clinerules"

        # Create global Cline rules - ZERO BACKUP STRATEGY
        sudo mkdir -p "$global_clinerules_dir"
        sudo bash -c "$(declare -f create_cline_coding_protocols_sudo check_no_fake_code); create_cline_coding_protocols_sudo '$global_clinerules_dir'"
        sudo bash -c "$(declare -f create_cline_token_optimization_sudo check_no_fake_code); create_cline_token_optimization_sudo '$global_clinerules_dir'"

        # Create project Cline rules with .md extension
        mkdir -p "$project_clinerules_dir"
        create_cline_coding_protocols "$project_clinerules_dir"
        create_cline_token_optimization "$project_clinerules_dir"

        script_log "Cline extension policies created in both global and project locations"
    else
        script_log "Cline AI extension not detected - .clinerules directories NOT created"
    fi

    # Cleanup duplicate files following directory management protocols
    script_log "Cleaning up duplicate files (zero backup strategy)..."
    cleanup_duplicate_files "$project_dir"

    # Verify policy files with ≥80% success threshold
    verify_policy_files "$cursor_dir" "$project_dir"

    # Final verification of embedded content integrity
    local verification_files=(
        "$project_dir/.cursorrules"
        "$global_rules_dir/001-directory-management-protocols.mdc"
        "$project_rules_dir/001-directory-management-protocols.mdc"
    )

    for file in "${verification_files[@]}"; do
        if [ -f "$file" ]; then
            check_no_fake_code "$file"
        fi
    done

    script_log "✅ Project-agnostic policy file generation completed successfully"
    script_log "✅ All content embedded using heredoc - ZERO external template dependencies"
    script_log "✅ Complete portability achieved - works from any git clone location"
    script_log "Policy file generation script completed successfully"
}

# Run main
main
