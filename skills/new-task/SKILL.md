---
name: new-task
description: "Clarify a new task by stating the goal the agent believes the user wants, showing its current understanding, and asking only product-related or high-priority questions that could materially change the outcome. Use before planning or implementation when the task needs alignment."
---

# New Task

Consider `$ARGUMENTS` if provided.

Before planning or implementation:

1. State a concise **Current understanding** (goal, key product behavior, constraints, assumptions, deliverable).
2. Ask only high-priority product or scope questions whose answers would materially change the outcome.
3. Iterate only if material ambiguity remains, then confirm a compact brief with success criteria and proceed only as authorized.
