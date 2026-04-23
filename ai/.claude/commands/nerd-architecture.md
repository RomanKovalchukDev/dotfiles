---
description: "Generate ARCHITECTURE.md from an approved SPEC.md. Creates system design, component diagram, data model, technology decisions, and testing strategy in .docs/pipeline/."
---

# Generate Architecture

You are generating an architecture document based on the approved specification. Follow the nerd-dev-pipeline skill.

## Steps

1. **Read spec**
   - Read `.docs/pipeline/SPEC.md` from the project root
   - If it does not exist, tell the user: "No SPEC.md found. Run `/nerd-spec` first."
   - If it exists, confirm its version and date

2. **Explore codebase**
   - Use a subagent (architect, model: opus) with read-only tools (Read, Grep, Glob) to:
     - Understand existing architecture, patterns, and conventions
     - Identify existing components that can be reused or extended
     - Note technology stack already in use
     - Review existing tests and testing patterns

3. **Generate ARCHITECTURE.md**
   - Read the template from the nerd-dev-pipeline skill: `references/templates/ARCHITECTURE.template.md`
   - Fill in all sections based on the spec and codebase exploration:
     - System overview aligned with spec's problem statement
     - Architecture diagram (ASCII) showing all components and data flow
     - Component design with responsibility, interface, dependencies
     - Data model with entities and relationships
     - API design or interface contracts
     - Technology decisions with rationale AND alternatives considered
     - Security considerations addressing NFRs from spec
     - Testing strategy with coverage targets
   - Replace {DATE} with today's date, reference SPEC.md version
   - Write to `.docs/pipeline/ARCHITECTURE.md`

4. **Present summary**
   - Show a concise summary:
     - Number of components
     - Key technology decisions with tradeoffs
     - Testing approach
   - Ask: "Architecture generated. Review `.docs/pipeline/ARCHITECTURE.md` and tell me: **proceed** (to tasks), **modify** (with feedback), or **stop**."

5. **Handle response**
   - "proceed": Tell the user to run `/nerd-tasks`
   - "modify": Re-enter step 3 with user feedback
   - "stop": Save state and exit
