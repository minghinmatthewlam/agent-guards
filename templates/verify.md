# Verification

Use the highest-signal affected surface before closing work. The goal is to make changes shippable without requiring line-by-line human review.

## Default Commands

- `scripts/self-test.sh default`: normal confidence check for code changes.
- `scripts/self-test.sh build`: build/package check.
- `scripts/self-test.sh ui`: user-facing workflow check.

Update these commands as the repo gets real test lanes. This file is a map, not a frozen policy.

## Add The Missing Test Lane

When a feature cannot be proven with the current test setup, the agent should add the smallest useful verification structure while implementing:

- unit or contract tests for deterministic behavior,
- integration tests for API, CLI, worker, or persistence flows,
- browser/E2E tests for web UI,
- Computer Use or desktop automation for native app behavior,
- screenshots/videos/logs/traces for proof artifacts.

Do not stop at "no test exists" when the repo can reasonably grow one.

## Real-Surface Proof

For UI, browser, desktop, animation, focus, scrolling, timing, or multi-step interaction changes, prove the behavior where a user would experience it. Browser automation and Computer Use should be treated as normal verification tools: if a human could manually test the workflow on this machine, the agent should usually be able to test it too.

Save durable proof artifacts outside the repo:

```text
/Users/matthewlam/.codex/proofs/<repo>/<task>/
```

Report proof as:

```text
User action -> visible result
Artifact: <absolute screenshot/video/log path>
Metadata: <sips/ffprobe/check output when relevant>
```

## Verification Blockers

If proof is blocked, report:

- the exact surface that could not be reached,
- what was attempted,
- the smallest missing access/tool/data/setup,
- the best weaker evidence collected,
- what should be added to make the proof repeatable next time.
