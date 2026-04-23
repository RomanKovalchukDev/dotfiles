---
description: "Full document-driven development pipeline. Chains spec -> architecture -> tasks -> implement -> review -> ship with human gates between phases. Supports resume from saved state."
---

# Development Pipeline

You are orchestrating the full document-driven development pipeline. Follow the nerd-dev-pipeline skill.

## Input

$ARGUMENTS usage:
- Description (e.g., "Build a REST API for bookmarks"): Start fresh pipeline
- "resume": Resume from PIPELINE-STATUS.md
- "status": Show current pipeline status
- Empty: Ask what the user wants to build

## Fresh Pipeline Flow

### 1. Initialize

- Create `.docs/pipeline/` directory if it does not exist
- Read the PIPELINE-STATUS template from the nerd-dev-pipeline skill: `references/templates/PIPELINE-STATUS.template.md`
- Create `.docs/pipeline/PIPELINE-STATUS.md` with all phases set to "Pending"
- Replace {DATE} with today's date

### 2. Phase 0: Requirements Gathering

- If $ARGUMENTS contains a description, use it as the starting point
- Ask clarifying questions:
  - What is the core problem being solved?
  - Who are the users?
  - What are the hard constraints (platform, language, timeline)?
  - What existing code or systems does this integrate with?
  - What is explicitly out of scope?
- Update PIPELINE-STATUS.md: Phase 0 = Complete

### 3. Phase 1: Spec

- Execute the logic from `/nerd-spec` with the gathered requirements
- Update PIPELINE-STATUS.md: Phase 1 status and gate
- **GATE: Wait for human approval before proceeding**

### 4. Phase 2: Architecture

- Execute the logic from `/nerd-architecture`
- Update PIPELINE-STATUS.md: Phase 2 status and gate
- **GATE: Wait for human approval before proceeding**

### 5. Phase 3: Tasks

- Execute the logic from `/nerd-tasks`
- Update PIPELINE-STATUS.md: Phase 3 status and gate
- **GATE: Wait for human approval before proceeding**
- Suggest: "Consider running `/compact` before implementation to free context."

### 6. Phase 4: Implementation

- Execute the logic from `/nerd-implement` (all phases)
- Update PIPELINE-STATUS.md after each sub-phase
- **GATE: Human approval after each sub-phase**

### 7. Phase 5: Review

- Run **code-reviewer** agent on full diff (all changes since pipeline start)
- Run **security-reviewer** agent on full diff
- Present combined findings by severity (CRITICAL > HIGH > MEDIUM > LOW)
- Update PIPELINE-STATUS.md: Phase 5 status
- **GATE: Must resolve all CRITICAL and HIGH issues before proceeding**
- If issues found, fix them and re-run review

### 8. Phase 6: Ship

- Run full verification (build + tests + lint + types)
- Show summary: files changed, lines added/removed, test coverage
- Propose commit message using conventional commits format
- Update PIPELINE-STATUS.md: Phase 6 status
- **GATE: Human confirmation before creating commit**
- Create commit
- Ask if user wants to create a PR
- If yes, create PR with summary derived from SPEC.md
- Update PIPELINE-STATUS.md: Complete

## Resume Flow

When $ARGUMENTS is "resume":

1. Read `.docs/pipeline/PIPELINE-STATUS.md`
2. If it does not exist, tell user: "No pipeline in progress. Start with `/nerd-pipeline <description>`."
3. Display current status table
4. Read the Resumption Context section
5. Identify the next incomplete phase
6. Ask: "Pipeline is at Phase {N} ({name}). Resume from here?"
7. On confirmation, continue from that phase

## Status Flow

When $ARGUMENTS is "status":

1. Read `.docs/pipeline/PIPELINE-STATUS.md`
2. If it does not exist, say "No active pipeline."
3. Display the phase tracker table and artifact inventory
4. Show what the next action would be
