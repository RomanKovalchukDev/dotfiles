---
description: "Generate a structured SPEC.md from requirements. Creates functional/non-functional requirements, constraints, acceptance criteria, and user flows in .docs/pipeline/."
---

# Generate Specification

You are generating a structured specification document for a project. Follow the nerd-dev-pipeline skill.

## Input

User requirement: $ARGUMENTS

## Steps

1. **Check for existing spec**
   - Look for `.docs/pipeline/SPEC.md` in the project root
   - If it exists, ask: "A spec already exists. Do you want to overwrite it or create a new version?"

2. **Gather requirements** (if $ARGUMENTS is empty or vague)
   - Ask clarifying questions:
     - What is the core problem being solved?
     - Who are the users?
     - What are the hard constraints (platform, language, timeline)?
     - What existing code or systems does this integrate with?
     - What is explicitly out of scope?
   - Do NOT proceed until requirements are clear

3. **Explore codebase**
   - Use a subagent (planner, model: opus) with read-only tools (Read, Grep, Glob) to:
     - Understand existing project structure and conventions
     - Identify related code, dependencies, and patterns
     - Note any existing tests or documentation

4. **Generate SPEC.md**
   - Create `.docs/pipeline/` directory if it does not exist
   - Read the template from the nerd-dev-pipeline skill: `references/templates/SPEC.template.md`
   - Fill in all sections based on gathered requirements and codebase exploration
   - Replace {DATE} with today's date, {VERSION} with v1
   - Every functional requirement must have a priority (Must/Should/Could)
   - Acceptance criteria must be measurable and testable
   - Out of scope section must be explicit
   - Write to `.docs/pipeline/SPEC.md`

5. **Present summary**
   - Show a concise summary of what was generated:
     - Number of functional requirements
     - Key constraints
     - Top acceptance criteria
   - Ask: "Spec generated. Review `.docs/pipeline/SPEC.md` and tell me: **proceed** (to architecture), **modify** (with feedback), or **stop**."

6. **Handle response**
   - "proceed": Tell the user to run `/nerd-architecture`
   - "modify": Re-enter step 4 with user feedback
   - "stop": Save state and exit
