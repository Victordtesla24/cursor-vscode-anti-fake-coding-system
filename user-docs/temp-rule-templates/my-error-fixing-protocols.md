---
description: 
globs: 
alwaysApply: true
---
## Error Fixing Protocol

**Objective:** To systematically identify, analyze, and resolve errors within the codebase efficiently and robustly, ensuring minimal disruption and maintaining code quality.

**Pre- and Post-Requisites:**
Follow all related protocols (`@my-error-fixing-protocols.mdc`) with absolute precision before and after every change. Utilize version control (e.g., `git stash` or branch) before attempting fixes.

**Core Principle:** Adhere strictly to these protocols for **every** error. Employ a “Fail Fast” mindset with small, **incremental**, and **atomic** fixes. After each fix attempt, rigorously verify resolution. If unresolved, refine the approach or source **vetted alternative solutions** from external resources (e.g., documentation, trusted forums).

### Key Components

1.  **Reproducibility & Context Capture:** Ensure the error is reproducible. Capture complete context: full error messages, stack traces, relevant logs, OS/environment details, and steps to reproduce.
2.  **Comprehensive Root Cause Analysis (RCA):**
    *   Investigate logs, code changes (using `git blame`/history), configurations (files, environment variables), dependency versions, and potential interactions.
    *   Isolate the specific conditions triggering the error.
3.  **Impact-Based Prioritization:** Evaluate the error's impact on **core functionality, UI/UX, data integrity, and security**. Prioritize critical-impact errors. If impact is negligible and fixing is complex, consider documenting and deprecating the related feature/test after evaluation (Step 2A in Algorithm).
4.  **Solution Comparison & Selection:** If internal attempts fail, research external solutions. **Compare** potential fixes based on:
    *   **Effectiveness:** Does it fully resolve the root cause?
    *   **Minimalism:** Does it introduce the least amount of change?
    *   **Maintainability:** Is the fix readable and aligned with project standards?
    *   **Performance:** Does it negatively impact performance?
    *   **Security:** Does it introduce vulnerabilities?
    *   Select the **most optimal** fix based on these criteria.
5.  **Targeted Resolution Attempts (Max 2 Internal):**
    *   **Attempt 1:** Implement the most likely minimal, targeted fix based on RCA. Verify immediately.
    *   **Attempt 2 (If Needed):** If Attempt 1 fails, **revert the change**, refine the analysis or hypothesis, and apply a revised minimal fix. Verify immediately.
    *   **Attempt 3 (External/Hybrid):** If Attempt 2 fails, **revert the change**, integrate the **best vetted** alternative solution identified in Component 4, adapting it carefully to the project context. Verify immediately.
6.  **Rigorous Verification:** After *each* attempt:
    *   Run relevant **unit tests, integration tests, and linters/static analysis tools**.
    *   Manually verify the specific functionality if tests are insufficient.
    *   **File Integrity Check:** Ensure **no unintended modifications** or placeholder code were introduced.
7.  **Cross-Protocol Calls:**
    *   If errors stem from directory structure or import issues, invoke the **Directory Management Protocol** first to ensure structural correctness, then return here if needed.
    *   If directory changes cause errors, apply this **Error Fixing Protocol** to resolve them.
8.  **Documentation:** Briefly document the final chosen solution and rationale within code comments or commit messages, especially for non-obvious fixes or those derived from external sources.

---

### **Recursive Error Resolution Algorithm**
| :--------------------------------------| :--------------------------------------------------------------------------------------------------------------------------------------| :----------------| :------------------------------|
| Step                                   | Action                                                                                                                                 | Attempt Limit    | Exit Condition                 |
| :------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------| :--------------- | :----------------------------- |
| **1. Error Isolation & Context**       | Detect, reproduce, and isolate the error. Capture complete context (logs, stack traces, environment, reproduction steps).              | -                | Error context captured         |
| **2. Root Cause Analysis (RCA)**       | Perform exhaustive analysis (logs, code history, config, dependencies, environment) to list potential causes.                          | —                | Potential causes identified    |
| **2A. Contextual Impact Analysis**     | Evaluate error impact (functionality, UI/UX, data, security). If minimal & complex, document rationale & consider removal/deprecation. | -                | Impact assessed                |
| **3. First Fix Attempt**               | **Checkpoint (Git)**. Apply **minimal, atomic** fix based on RCA. Modify **only** necessary code—no placeholders/extraneous changes.   | 1 of 2 (Internal)| Verification passed            |
| **3A. Verification & Integrity**       | Run tests (unit, integration), lint. Verify file integrity (no unintended changes).                                                    | —                | Fix validated OR Fix failed    |
| **4. Recursive Retry / Refinement**    | If verification fails (<2 attempts), **Revert Fix (Git)**. Refine RCA/fix. Go to Step 3.                                               | 2 of 2 (Internal)| Error resolved                 |
| **5. Alternative Sourcing & Eval**     | If verification fails after 2 attempts, **Revert Fix (Git)**. Research external solutions. Evaluate using Component 4 criteria.        | —                | Optimal external fix chosen    |
| **6. Final Application & Verification**| **Checkpoint (Git)**. Implement the chosen (potentially adapted) external/hybrid fix. Go to Step 3A for final verification.            | 1 (External)     | Error resolved & documented    |
| **7. Rollback (Safety Net)**           | If final verification fails or introduces regressions, **Revert Fix (Git)**. Document failure. Escalate or reconsider approach.        | —                | Stable state restored          |
|:---------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------|:-----------------|:-------------------------------|

#### **Recursive Error Resolution Algorithm Conceptual Implementation (Illustrative):**

```python
# Conceptual representation - adapt logic as needed
def handle_error(error_context, attempt=1, max_internal_attempts=2):
    # Step 1 & 2: Assume error_context includes RCA findings.
    root_causes = error_context['rca_findings']

    # Step 2A: Assess impact.
    impact = assess_impact(error_context)
    if impact == "minimal_acceptable":
        document_rationale_and_deprecate(error_context)
        return {"status": "resolved_by_deprecation"}

    # Checkpoint before modifying
    checkpoint_vcs("before_attempt_" + str(attempt))

    if attempt <= max_internal_attempts:
        # Step 3: Generate minimal fix based on current hypothesis
        solution = generate_minimal_fix(root_causes, attempt)
    else:
        # Step 5: Source and evaluate external solutions
        external_solution = research_and_evaluate_external_fix(error_context)
        if not external_solution:
             revert_vcs("before_attempt_" + str(attempt)) # Rollback if no viable external solution
             return {"status": "failed", "reason": "No viable internal or external solution found"}
        solution = adapt_external_solution(external_solution, error_context['project_context'])

    # Apply the proposed solution to the codebase (conceptually)
    apply_fix(solution)

    # Step 3A / 6 (Verification)
    verification_passed, verification_details = verify_fix(solution)

    if verification_passed:
        document_fix(solution, error_context, attempt > max_internal_attempts) # Step 8
        return {"status": "resolved", "solution": solution}
    else:
        # Revert the failed attempt
        revert_vcs("before_attempt_" + str(attempt))

        if attempt < max_internal_attempts:
            # Step 4: Refine and retry (internal)
            return handle_error(error_context, attempt + 1, max_internal_attempts)
        elif attempt == max_internal_attempts:
             # Step 5 triggered on next conceptual 'attempt' call
             return handle_error(error_context, attempt + 1, max_internal_attempts)
        else:
            # Step 7: Final external attempt failed
             return {"status": "failed", "reason": "External solution failed verification", "details": verification_details}
```

#### **Recursive Error Resolution Algorithm Process & Data Flowchart (Illustrative):**

```ascii
+-------------------------------------------------+
| START handle_error(error_context, attempt, ...) |
+--------------------+----------------------------+
                     |
                     v
+--------------------+------------------------------+
| (Steps 1&2) Extract root_causes from error_context|
+--------------------+------------------------------+
                     |
                     v
+--------------------+------------------------------+
| (Step 2A) Assess Impact (impact = assess_impact())|
+--------------------+------------------------------+
                     |
        +------------+------------+
        |                         |
+-------v--------------+   +------v--------------+
| impact ==            |   | impact !=           |
| "minimal_acceptable"?|   | "minimal_acceptable"|
| (Decision)           |   | (Proceed with fix)  |
+-------+--------------+   +------------+--------+
        | Yes                           | No
        v                               v
+-------+--------------------------+  +-+------------------------------------+
| document_rationale_and_deprecate()  | checkpoint_vcs("before_attempt_...") |
+-------+--------------------------+  +--------------+-----------------------+
        |                                            |
        v                                            v
+-------+--------------------------+  +--------------+-----------------------+
| return {"status": "resolved_by_  |  | attempt <= max_internal_attempts?    |
| deprecation"}                    |  | (Decision)                           |
+----------------------------------+  +--------------+-----------------------+
        |                                            | Yes
      [END]                                          v
                                      +--------------+-----------------------+
                                      | solution = generate_minimal_fix()    |
                                      +--------------+-----------------------+
                                                     |
                                                     |         +----------------------------------------------------------+
                                                     | No      | external_solution = research_and_evaluate_external_fix() |
                                                     +---------> +--------------------+-----------------------------------+
                                                                                      |
                                                                        +-------------+-------------+
                                                                        |                           | No
                                                                +-------v----------------+      +---v----------------+
                                                                | not external_solution? |      | solution = adapt_  |
                                                                | (Decision)             |      | external_solution()|
                                                                +-------+----------------+      +---------+----------+
                                                                        | Yes                         |
                                                                        v                             |
                                                                +-------+----------+                  |
                                                                | revert_vcs()     |                  |
                                                                +-------+----------+                  |
                                                                        |                             |
                                                                        v                             |
                                                                +-------+------------------------+    |
                                                                | return {"status": "failed",    |    |
                                                                | "reason": "No viable solution"}|    |
                                                                +-------+------------------------+    |
                                                                        |                             |
                                                                      [END]                           |
                                                                                                      |
                                      +---------------------------------------------------------------+
                                      |
                                      v
+-------------------------------------+-----------+
| apply_fix(solution)                             |
+--------------------+----------------------------+
                     |
                     v
+--------------------+----------------------------+
| verification_passed, _ = verify_fix(solution)   |
+--------------------+----------------------------+
                     |
        +------------+----------------+
        | Yes                         | No
+-------v-------------+   +-----------v------------------+
| verification_passed?|   | verification_passed is false |
| (Decision)          |   +----------+-------------------+
+-------+-------------+              |
        |                            v
        v                   +--------+-----------+
+-------+----------------+  | revert_vcs()       |
| document_fix()         |  +--------+-----------+
+------------------------+           |
        |                            v
        v                  +---------+--------------------------------+
+-------+----------------+ | attempt < max_internal_attempts?         |
| return {"status":      | | (Decision for internal retry)            |
| "resolved", ...}       | +---------+--------------------------------+
+------------------------+           | Yes (Internal Retry)
        |                            v
      [END]                +---------+----------------------------------+
                           | return handle_error(error_context,         |
                           |         attempt + 1, max_internal_attempts)|
                           +---------+----------------------------------+
                                     | (Recursion)
                                     |
                                   [END]
                                     |
                                     | No (Reached max internal or was external)
                                     v
                           +---------+--------------------------------+
                           | attempt == max_internal_attempts?        |
                           | (Decision for triggering external path)  |
                           +---------+--------------------------------+
                                     |
                                     | Yes (Next attempt will be external)
                                     v
                           +---------+----------------------------------+
                           | return handle_error(error_context,         |
                           |         attempt + 1, max_internal_attempts)|
                           +--------------------------------------------+
                                     |
                                     | (Recursion to external path)
                                     |
                                   [END]
                                     |
                                     |
                                     | No (This means attempt > max_internal_attempts, so external attempt failed)
                                     v
                           +---------+--------------------------------+
                           | return {"status": "failed",              |
                           | "reason": "External solution failed..."} |
                           +------------------------------------------+
                                     |
                                   [END]
```

#### **Import Error Resolution Algorithm**
**Purpose:** To resolve ***ModuleNotFoundError***, ***ImportError***, or ***incorrect path issues***, often occurring after directory restructuring or due to incorrect initial setup. This combines directory validation with error handling.
```ascii
+--------------------------------------------+
| START: Detect & Contextualize Import Error |
+--------------------------------------------+
                    |
                    v
+--------------------------------------------+
| Recent Directory Changes Caused Error?     |
| (Decision)                                 |
+--------------------+-----------------------+
                     | Yes
                     v
+--------------------------------------------+
| Invoke @DirectoryManagementProtocol        |
| (Correct Structural Issues)                |
+--------------------+-----------------------+
                     | No / After Dir Mgmt
                     v
+--------------------------------------------+
| Isolate Root Cause                         |
| (Verify Path, File Exists, Conflicts)      |
+--------------------------------------------+
                     |
                     v
+--------------------------------------------+
| Checkpoint (VCS)                           |
+--------------------------------------------+
                     |
                     v
+--------------------------------------------+
| Implement Minimal Fix (Attempt 1)          |
+--------------------------------------------+
                     |
                     v
+--------------------------------------------+
| Verify Fix (Attempt 1)                     |
| (Tests, Lint, Import Check, Integrity)     |
+--------------------+-----------------------+
                     |
       +-------------+-------------+
       | Yes                       | No
+------v-------------+     +-------v--------+
| Go to Final        |     | Revert Changes |
| Verification & Doc |     | (VCS)          |
+--------------------+     +----------------+
       |                           |
       |                           v
       |                 +---------+----------+
       |                 | Re-evaluate Root   |
       |                 | Cause              |
       |                 +--------------------+
       |                           |
       |                           v
       |                 +---------+----------+
       |                 | Apply Refined Fix  |
       |                 | (Attempt 2)        |
       |                 +--------------------+
       |                           |
       |                           v
       |                 +---------+-------------+
       |                 | Verify Fix (Attempt 2)|
       |                 +---------+-------------+
       |                           |
       |             +-------------+-------------+
       |             | Yes                       | No
       |      +------v-------------+     +-------v--------+
       |      | Go to Final        |     | Revert Changes |
       |      | Verification & Doc |     | (VCS)          |
       |      +--------------------+     +----------------+
       |             |                           |
       +-------------+                           v
                     |                 +---------+--------------------------+
                     |                 | Escalate: Invoke Main Error        |
                     |                 | Resolution Algorithm (Steps 5-7)   |
                     |                 | (Focus: External/Env Solutions)    |
                     |                 +------------------------------------+
                     |                                  |
                     v                                  v
+--------------------+-----------------------+   (Outcome handled by Main Algorithm)
| Final Verification & Testing               |
+--------------------------------------------+
                     |
                     v
+--------------------------------------------+
| Document Fix (Comments / Commit Msg)       |
+--------------------------------------------+
                     |
                     v
+--------------------------------------------+
| END: Import Error Resolved                 |
+--------------------------------------------+
```

> **Critical Constraints (Mandatory Adherence)**
>   - **Atomicity:** Each fix attempt must be the smallest possible change to resolve the identified root cause or implement the chosen solution. Adhere to the Single Responsibility Principle (SRP).
>   - **Targeted Changes:** No functionality or code must be lost, added, or removed beyond the specific, necessary change required by the fix. Do not refactor unrelated code.
>   - **No Placeholders:** Strictly prohibited: Never insert placeholder text like # ... [rest of the existing methods remain unchanged], # TODO: Implement later, or similar markers instead of the actual code. The AI must generate the complete, correct code for the change.
>   - **Attempt Limit:** Maximum of 2 direct internal fix attempts per error before reverting and leveraging external/alternative solutions (as per the algorithm).
>   - **Verification:** Every fix attempt must be followed by verification (testing, linting, integrity check).
>   - **No Regressions:** The fix must not introduce new errors or break existing, unrelated functionality. Verification steps should aim to catch this.
>   - **Idempotency (where applicable):** Ensure that re-applying the protocol doesn't lead to further errors if the state is already correct.
>   - **Focus:** Avoid unnecessary code alterations—focus solely on the precise change required for the fix.
