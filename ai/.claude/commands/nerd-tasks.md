---
description: "Generate TASKS.md from approved SPEC.md and ARCHITECTURE.md. Creates a phased, checkable task list grouped by milestone with dependencies and verification methods."
---

# Generate Task Breakdown

You are generating a phased task list based on the approved specification and architecture. Follow the nerd-dev-pipeline skill.

## Steps

1. **Read artifacts**
   - Read `.docs/pipeline/SPEC.md` from the project root
   - Read `.docs/pipeline/ARCHITECTURE.md` from the project root
   - If either is missing, tell the user which command to run first (`/nerd-spec` or `/nerd-architecture`)

2. **Analyze scope**
   - Use a subagent (planner, model: opus) with read-only tools (Read, Grep, Glob) to:
     - Map spec requirements to architecture components
     - Identify which files need to be created or modified for each requirement
     - Determine natural phase boundaries (setup -> core -> integration -> polish)
     - Estimate complexity per phase

3. **Generate TASKS.md**
   - Read the template from the nerd-dev-pipeline skill: `references/templates/TASKS.template.md`
   - Group tasks into phases following this pattern:
     - **Phase 1**: Project setup, configuration, scaffolding
     - **Phase 2-N**: Core feature phases (one per major component or flow)
     - **Final Phase**: Verification, review, documentation
   - For each task:
     - Assign a sequential ID (T-01, T-02, ...)
     - Write a clear, actionable description
     - List specific file paths that will be created or modified
     - Define a verification method (test passes, build succeeds, behavior check)
   - Each phase must have:
     - A clear goal statement
     - Dependency declaration (which phase it depends on)
     - Complexity estimate (Low/Medium/High)
   - Replace {DATE} with today's date, reference spec and architecture versions
   - Write to `.docs/pipeline/TASKS.md`

4. **Present summary**
   - Show:
     - Number of phases and total task count
     - Phase names and their goals
     - Estimated overall complexity
   - Ask: "Tasks generated. Review `.docs/pipeline/TASKS.md` and tell me: **proceed** (to implementation), **modify** (with feedback), or **stop**."

5. **Handle response**
   - "proceed": Tell the user to run `/nerd-implement` or `/nerd-implement 1` to start with Phase 1
   - "modify": Re-enter step 3 with user feedback
   - "stop": Save state and exit
