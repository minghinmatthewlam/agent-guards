---
name: new-task
description: "Clarify a new task by stating the goal the agent believes the user wants, showing its current understanding, and asking only product-related or high-priority questions that could materially change the outcome. Use before planning or implementation when the task needs alignment."
---

# New Task

Consider `$ARGUMENTS` if provided.

Before planning or implementation:

1. Present a concise **Current understanding**, beginning with the **Goal** you believe the user wants to achieve, followed by the important product behavior, constraints, assumptions, and intended deliverable.
2. Ask only product-related or high-priority questions whose answers could materially change scope, behavior, architecture, or success.
3. Update the understanding after the user answers and repeat only when a material ambiguity remains.

When aligned, return a compact confirmed brief with success criteria and any
remaining assumptions, then continue only as authorized.
