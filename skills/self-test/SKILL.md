---
name: self-test
description: "Prove the requested goal works on the highest-signal affected surface before closing. Default closing behavior for every implementation task — not just when explicitly asked. Also triggers on: 'make sure it works', 'test it yourself', 'don't just tell me it's done', 'I don't want to test this'."
---

# Self-Test

You own verification of the delivered goal. If you can't prove the requested behavior works, it's not done.

Consider `$ARGUMENTS` if provided.

## Discover Verification Tools

Before planning, find what's available to prove the goal on the highest-signal affected surface. Search for test configs, test helpers, build scripts, app launch paths, browser/Electron harnesses, Computer Use skills, and existing specs. If you're missing a tool to reach the surface that matters, tell the user what you need and why — don't silently downgrade to lower-signal proof.

## Before You Code

- Define concrete, testable success criteria. If ambiguous or below 85% confidence, clarify first.
- **Name the exact goal surface you'll verify on.** The surface is where the requested behavior is consumed, not where the code runs internally. Examples: for desktop/web UI changes -> "the running app with real user interactions through browser automation or Computer Use." For API changes -> "the HTTP endpoint hit by a real client." For CLI changes -> "the command run in a real terminal." For library changes -> "a calling program that exercises the public API."
- **Name the exact proof path you'll use.** This may be commands, test files, browser/Electron automation, Computer Use steps, or a combination. If an existing repeatable test covers the goal surface, name it. If not, plan the smallest proof that can demonstrate the delivered behavior. If you can't reach the surface at all, surface that as a blocker.
- **Name the proof artifacts you'll create when the surface is visual or interactive.** Screenshots prove final visible state; short screen recordings prove multi-step flows, focus behavior, animation, scrolling, or timing. Store them under a durable path such as `/Users/matthewlam/.codex/proofs/<thread-or-task>/<slug>/`.
- For new user-facing features, bias toward a real-surface smoke test of the completed workflow using Computer Use, browser automation, or the most product-like harness available. Use command-line checks as supporting repeatable proof unless the command/API/library is itself the user-facing surface.
- Name exact verification blockers early: missing credentials, env vars, test data, local run path, preview/staging access, prod access, hardware, or anything else that prevents real verification.

## While You Code

- Use whatever fast tests and checks you need while coding. The skill does not need to prescribe the inner loop.
- If you discover you can't verify the final goal, surface the blocker immediately — what you tried, why it blocks, and the smallest user action that would unblock you.

## Before You Say Done

- Run verification that proves the requested goal works on the highest-signal affected surface. Mock-heavy or deterministic suites are not enough for new user-facing behavior unless they exercise that surface.
- **For user-visible changes, report proof as user action -> visible result.** Example: "user types @ in textarea -> popup appears with file list." If your proof doesn't simulate the relevant user action (click, type, keyboard shortcut, paste, HTTP request) and assert or observe the user-visible result (element appears, text changes, response body matches), it's testing plumbing, not product.
- Show the exact commands, tool steps, environment, and evidence you used as proof. For Computer Use/browser checks, include what you actually observed in the running product.
- Attach or link durable proof artifacts for visual and interaction checks. In Codex Desktop, reference local artifacts with absolute paths, for example `![final state](/Users/matthewlam/.codex/proofs/<task>/final.png)` or `[flow recording](/Users/matthewlam/.codex/proofs/<task>/flow.mov)`.
- Verify proof artifact metadata before reporting it. For macOS screenshots, `sips -g pixelWidth -g pixelHeight <file.png>` confirms the image exists and is readable. For videos, `ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1:nokey=0 <file.mov>` confirms duration and size.
- **If it fails, fix and re-verify. Repeat until all success criteria pass.** Don't report success with known failures. Don't stop after one attempt — the loop is: run → fail → diagnose → fix → re-run.
- Never tell the user to test or verify something you could have tested yourself. If you truly can't (requires credentials you don't have, physical hardware, third-party access), name the exact blocker and what you attempted.

## Gotchas

- Green tests do not prove product behavior if they never exercised the real app.
- One layer passing is not end-to-end proof if the real changed surface is elsewhere.
- **Testing internal layers (state stores, IPC handlers, API routes, service methods) is not the same as testing what the user sees.** Internal tests prove the backend works; they don't prove the component renders, the popup appears, the keyboard shortcut fires, or the HTTP response reaches the client. If the change is user-facing, your test must simulate what the user does and assert what the user sees. The bug is almost always in the layer between the internal API and the user — rendering, event handling, CSS, timing, serialization.
- **The most common self-test failure:** writing tests that call internal functions, seeing them pass, and declaring "verified on the real surface." The tests passed because the internal layer works. The bugs were in the layer the tests never touched.
- Mocked or seeded test paths can be useful, but they are weaker evidence for new product behavior than running against a real local/preview/prod surface.
- Command exit codes alone are not proof for user-visible behavior; verify the actual visible result. Command tests are primary proof when the command, API, or library call is the actual user-facing contract.
- Computer Use state output is useful for live reasoning, but it is not a durable artifact unless it writes a stable file. Pair Computer Use observations with saved screenshots, screen recordings, browser traces, or app logs when reporting proof.
- **Silently downgrading verification** — listing "manual E2E" or "the user should test" instead of using available product-surface tools. In Codex, Computer Use and browser tooling can prove many new feature workflows directly; use them when they are the highest-signal path.
- If only a deployed environment can prove the change, use the safest production-like path available and state the exact scope you verified.
