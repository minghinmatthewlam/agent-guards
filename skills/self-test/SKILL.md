---
name: self-test
description: "Own verification end-to-end during planning and execution. Default closing behavior for every implementation task — not just when explicitly asked. Also triggers on: 'make sure it works', 'test it yourself', 'don't just tell me it's done', 'I don't want to test this'. Use whenever the agent must prove the result works on the real surface affected by the change."
---

# Self-Test

You own verification. If you can't prove it works, it's not done.

Consider `$ARGUMENTS` if provided.

## Before You Code

- Define concrete, testable success criteria. If ambiguous or below 85% confidence, clarify first.
- **Name the exact surface you'll verify on.** The surface is where the USER interacts, not where the code runs internally. Examples: for UI changes → "the rendered DOM in the running app with real user interactions (typing, clicking, keyboard shortcuts)." For API changes → "the HTTP endpoint hit by a real client." For CLI changes → "the command run in a real terminal." For library changes → "a calling program that exercises the public API."
- Plan how you'll verify end-to-end before coding. Use the fastest high-fidelity environment for checkpoints during implementation, then verify on the most production-like environment available before closing.
- Name exact verification blockers early: missing credentials, env vars, test data, local run path, preview/staging access, prod access, hardware, or anything else that prevents real verification.
- If no test infrastructure exists, building it is part of the task.

## While You Code

- Build verification alongside implementation, not after. If you discover you can't verify something, surface the blocker immediately — what you tried, why it blocks, and the smallest user action that would unblock you.
- Keep checkpoints runnable. Don't defer all verification until the end if you can run the real app or flow earlier.

## Before You Say Done

- Run your verification end-to-end on the real surface affected by the change. Mock-heavy or deterministic suites are not enough unless they exercise that real surface.
- **For user-visible changes, write each verification step as a user action → visible result.** Example: "user types @ in textarea → popup appears with file list." If your test doesn't simulate the user action (click, type, keyboard shortcut, paste, HTTP request) and assert the user-visible result (element appears, text changes, response body matches), it's testing plumbing, not product.
- Show the exact commands, environment, and evidence you used as proof. For user-visible changes, include what you actually observed in the running product.
- If it fails, fix and re-verify. Don't report success with known failures.
- Never tell the user to test or verify something you could have tested yourself. If you truly can't (requires credentials you don't have, physical hardware, third-party access), name the exact blocker and what you attempted.

## Gotchas

- Green tests do not prove product behavior if they never exercised the real app.
- One layer passing is not end-to-end proof if the real changed surface is elsewhere.
- **Testing internal layers (state stores, IPC handlers, API routes, service methods) is not the same as testing what the user sees.** Internal tests prove the backend works; they don't prove the component renders, the popup appears, the keyboard shortcut fires, or the HTTP response reaches the client. If the change is user-facing, your test must simulate what the user does and assert what the user sees. The bug is almost always in the layer between the internal API and the user — rendering, event handling, CSS, timing, serialization.
- **The most common self-test failure:** writing tests that call internal functions, seeing them pass, and declaring "verified on the real surface." The tests passed because the internal layer works. The bugs were in the layer the tests never touched.
- Mocked or seeded test paths can be useful, but they are weaker evidence than running against a real local/preview/prod surface.
- Command exit codes alone are not proof; verify the actual visible result.
- If only a deployed environment can prove the change, use the safest production-like path available and state the exact scope you verified.
