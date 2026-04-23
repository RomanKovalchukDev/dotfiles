---
description: "Execute TASKS.md phase by phase with TDD verification. Reads task list, implements each phase, checks off completed tasks, generates phase reports, and pauses for approval between phases."
---

# Implement Tasks

You are implementing the task list phase by phase. Follow the nerd-dev-pipeline skill.

## Input

Phase argument: $ARGUMENTS
- Empty: run all phases sequentially
- Number (e.g., "2"): run only that phase
- Range (e.g., "2-4"): run phases 2 through 4

## Steps

1. **Read task list**
   - Read `.docs/pipeline/TASKS.md` from the project root
   - If it does not exist, tell the user: "No TASKS.md found. Run `/nerd-tasks` first."
   - Parse phases and tasks, identify which are already checked off
   - Determine which phases to run based on $ARGUMENTS

2. **Context management**
   - If this is the first implementation phase in the session, suggest: "Consider running `/compact` to free up context before implementation."
   - Read `.docs/pipeline/ARCHITECTURE.md` for reference during implementation

3. **For each phase to implement:**

   a. **Display phase header**
      - Show phase number, name, goal, and task list

   b. **For each unchecked task in the phase:**
      - Read the task description, target files, and verification method
      - **If writing new code**: Follow TDD methodology
        1. Write test first (RED)
        2. Run test to confirm it fails
        3. Write minimal implementation (GREEN)
        4. Run test to confirm it passes
        5. Refactor if needed (IMPROVE)
      - **If modifying existing code**: Make changes, run existing tests
      - **If configuration/setup**: Apply changes, verify they work
      - After completing the task, check it off in TASKS.md (change `- [ ]` to `- [x]`)

   c. **Run verification after all tasks in the phase**
      - Build the project
      - Run relevant tests
      - Check types/lint if applicable

   d. **Generate phase report**
      - Read template from nerd-dev-pipeline skill: `references/templates/PHASE-REPORT.template.md`
      - Fill in: tasks completed, files changed, verification results, decisions made
      - Write to `.docs/pipeline/PHASE-REPORT-{N}.md`

   e. **Update progress log**
      - Update the Progress Log table in TASKS.md with phase status, dates

   f. **Gate: ask for approval**
      - Present the phase report summary
      - Ask: "Phase {N} complete ({X}/{Y} tasks). **Proceed** to Phase {N+1}, **modify** (with feedback), or **stop**?"

   g. **Handle response**
      - "proceed": Continue to next phase
      - "modify": Fix issues based on feedback, re-run verification
      - "stop": Save state and exit

4. **After all phases complete:**
   - Run code review using the **code-reviewer** agent on all changed files
   - Run security review using the **security-reviewer** agent
   - Present combined review findings
   - If CRITICAL/HIGH issues found, fix them before proceeding
   - Ask: "All phases complete and reviewed. Ready to **ship** (commit), **modify** (fix issues), or **stop**?"

5. **Context management during long implementations**
   - After every 2 phases, suggest `/compact` if context feels heavy
   - Keep implementation focused: pass only the current phase tasks to subagents
