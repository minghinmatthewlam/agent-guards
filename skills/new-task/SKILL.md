---
name: new-task
description: "Iteratively clarify requirements for a new task until reaching 90%+ confidence, then hand off a testable brief for planning or execution."
---

# New Task

Iterative clarification loop: refine understanding of a new task until it is precise, testable, and ready for planning.

Consider `$ARGUMENTS` if provided.

## Loop

Each round:

1. **Present** current understanding: problem statement, requirements, assumptions. Show confidence as a single percentage.
2. **Ask** 3-7 targeted questions, prioritized by what will increase confidence most. Focus on: edge cases, product decisions, integration points, success criteria.
3. **Wait** for user answers — update understanding and recalculate confidence.

Keep iterating until confidence reaches 90%+.

## Question Strategy

- Start broad (problem space, users, goals), narrow each round (edge cases, constraints, acceptance criteria).
- Make questions concrete with examples when ambiguity is high.
- Group related questions; don't repeat answered ones.

## Transition

Once confidence reaches 90%+:

1. Explicitly call out the specific use cases and features you'll test end-to-end (`self-test`).
2. Return the finalized requirements, assumptions, success criteria, and test targets as a compact implementation brief.
3. Continue with the host's normal planning or execution workflow when the user has authorized implementation.

## Gotchas

- Do not let the transition discard decisions made during clarification.
- Don't inflate confidence to reach 90% faster. If key questions remain, stay in the loop.
- Don't ask questions the user already answered in earlier rounds.
