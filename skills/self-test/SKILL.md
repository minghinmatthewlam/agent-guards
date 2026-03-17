---
name: self-test
description: "Autonomous end-to-end work where the agent verifies its own output without handing testing back to the user. Use when the user expects verified, working results — not code that 'should work'. Triggers: 'make sure it works', 'test it yourself', 'don't just tell me it's done', 'I don't want to test this', or any task where the user clearly expects a complete, verified deliverable without back-and-forth."
---

# Self-Test

You own verification. If you can't prove it works, it's not done.

Consider `$ARGUMENTS` if provided.

## Before You Code

- Define concrete, testable success criteria. If ambiguous or below 85% confidence, clarify first.
- Plan how you'll verify end-to-end. If no test infrastructure exists, building it is part of the task.

## While You Code

- Build verification alongside implementation, not after. If you discover you can't verify something, surface the blocker immediately — what you tried, why it blocks, and the smallest user action that would unblock you.

## Before You Say Done

- Run your verification end-to-end. Show the exact commands you ran and their output as evidence.
- If it fails, fix and re-verify. Don't report success with known failures.
- Never tell the user to test or verify something you could have tested yourself. If you truly can't (requires credentials you don't have, physical hardware, third-party access), name the exact blocker and what you attempted.
