---
name: new-task
description: "Iteratively clarify requirements for a new task until reaching 90%+ confidence, then auto-invoke plan-loop."
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

## Transition to Planning

Once confidence reaches 90%+:

1. Explicitly call out the specific use cases and features you'll test end-to-end (`self-test`).
2. **Use the Skill tool to invoke `plan-loop`** with the finalized requirements and e2e test targets as context. Do NOT plan on your own — `plan-loop` uses multi-agent research, dual-model review, structured verification design, and `self-test` integration that ad-hoc planning skips.

If `plan-loop` is unavailable, tell the user and stop — do not substitute your own planning.

## Gotchas

- **The #1 failure mode:** agent reaches 90% confidence and starts planning/implementing directly instead of invoking `plan-loop` via the Skill tool. This defeats the entire purpose of `new-task` — the value is the structured handoff, not just the clarification.
- Don't inflate confidence to reach 90% faster. If key questions remain, stay in the loop.
- Don't ask questions the user already answered in earlier rounds.
