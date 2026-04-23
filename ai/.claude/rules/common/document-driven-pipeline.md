# Document-Driven Pipeline

When a project contains `.docs/pipeline/` artifacts, respect them as the source of truth:

1. **SPEC.md** defines requirements. Do not implement features not in the spec without explicit approval.
2. **ARCHITECTURE.md** defines system design. Follow its component structure, patterns, and technology decisions.
3. **TASKS.md** defines implementation order. Work through tasks in phase order, not ad hoc.
4. **PIPELINE-STATUS.md** tracks progress. Check it when resuming work to understand current state.

## When Modifying a Project With Pipeline Artifacts

- Check if the requested change aligns with the spec
- Follow the architecture's component boundaries
- Update TASKS.md checkboxes when completing tasks
- Run verification after completing a phase
- Update PIPELINE-STATUS.md when transitioning between phases

## When Artifacts Seem Stale

If the code has diverged from the pipeline artifacts (e.g., files mentioned in TASKS.md no longer exist, or architecture has changed):
- Flag the discrepancy to the user
- Ask whether to update the artifacts or follow the current code state
- Do not silently ignore stale artifacts
