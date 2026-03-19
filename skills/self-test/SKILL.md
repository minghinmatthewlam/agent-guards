---
name: self-test
description: "Own verification end-to-end during planning and execution. Use when the agent must prove the result works on the real surface affected by the change, or when the user expects verified output instead of code that 'should work'. Triggers: 'make sure it works', 'test it yourself', 'don't just tell me it's done', 'I don't want to test this', or any task where the agent should deliver a verified result without handing testing back to the user."
---

# Self-Test

You own verification. If you can't prove it works, it's not done.

Consider `$ARGUMENTS` if provided.

## Before You Code

- Define concrete, testable success criteria. If ambiguous or below 85% confidence, clarify first.
- Plan how you'll verify end-to-end before coding. Use the fastest high-fidelity environment for checkpoints during implementation, then verify on the most production-like environment available before closing.
- Name exact verification blockers early: missing credentials, env vars, test data, local run path, preview/staging access, prod access, hardware, or anything else that prevents real verification.
- If no test infrastructure exists, building it is part of the task.

## While You Code

- Build verification alongside implementation, not after. If you discover you can't verify something, surface the blocker immediately — what you tried, why it blocks, and the smallest user action that would unblock you.
- Keep checkpoints runnable. Don't defer all verification until the end if you can run the real app or flow earlier.

## Before You Say Done

- Run your verification end-to-end on the real surface affected by the change. Mock-heavy or deterministic suites are not enough unless they exercise that real surface.
- Show the exact commands, environment, and evidence you used as proof. For user-visible changes, include what you actually observed in the running product.
- If it fails, fix and re-verify. Don't report success with known failures.
- Never tell the user to test or verify something you could have tested yourself. If you truly can't (requires credentials you don't have, physical hardware, third-party access), name the exact blocker and what you attempted.

## Gotchas

- Green tests do not prove product behavior if they never exercised the real app.
- One layer passing is not end-to-end proof if the real changed surface is elsewhere.
- Mocked or seeded test paths can be useful, but they are weaker evidence than running against a real local/preview/prod surface.
- Command exit codes alone are not proof; verify the actual visible result.
- If only a deployed environment can prove the change, use the safest production-like path available and state the exact scope you verified.
