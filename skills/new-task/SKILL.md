---
name: new-task
description: "Iteratively clarify requirements for a new task until reaching 95%+ confidence, then auto-invoke plan-loop."
---

# New Task

Iterative clarification loop: refine understanding of a new task until it is precise, testable, and ready for planning.

Consider `$ARGUMENTS` if provided.

## Loop

Each round:

1. **Present** current understanding: problem statement, requirements, assumptions. Show confidence as a single percentage.
2. **Ask** 3-7 targeted questions, prioritized by what will increase confidence most. Focus on: edge cases, product decisions, integration points, success criteria.
3. **Wait** for user answers — update understanding and recalculate confidence.

Keep iterating until confidence reaches 95%+.

## Question Strategy

- Start broad (problem space, users, goals), narrow each round (edge cases, constraints, acceptance criteria).
- Make questions concrete with examples when ambiguity is high.
- Group related questions; don't repeat answered ones.
- Always clarify how the agent will verify the result (`self-test`). Success criteria must be testable by the agent, not just by the human. If verification requires access or tools the agent doesn't have, surface that as a blocker early.

## Transition to Planning

Once confidence reaches 95%+, invoke the `plan-loop` skill with the finalized requirements as context.
