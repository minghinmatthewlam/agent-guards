---
name: use-loop
description: "Run an autonomous, verifiable continuation loop for implementation, product, QA, cleanup, refactor, evaluation, performance, or research goals. Use when the user asks for /use-loop, loop mode, repeated attempts, retry-until-green work, or a non-trivial goal that can be measured and iterated."
---

# Use Loop

Turn the request into one measurable goal, start the host's real goal-continuation mechanism, and keep working until verified or genuinely blocked.

## Start

Before changing anything, establish:

- **Goal:** the specific outcome.
- **Target:** the observable success condition.
- **Verifier:** the exact command, test, metric, tool, or product surface.
- **Access:** tools, runtime, credentials, data, and continuation mechanism.
- **Baseline:** current state when measurable.
- **Stop conditions:** success, blocker, decision gate, stalled progress, or budget.

Use `self-test` to choose the highest-signal proof path. If the repo lacks a reasonable proof lane, add the smallest repeatable one as part of the work. If the target cannot be reached, report the exact blocker rather than silently weakening proof.

Start `/goal` or the available goal tool after these controls are clear. Create a goal only for an explicit loop request or when the surrounding system instructions authorize it.

Read `references/state-and-artifacts.md` when the loop will span many attempts, needs a durable ledger, or requires visual proof.

## Iterate

1. Establish or confirm the baseline.
2. Make one coherent attempt.
3. Measure it with the declared verifier.
4. Keep improvements; discard or revise regressions.
5. Record only the state needed to resume reliably.
6. Continue until a stop condition is met.

The target remains the source of truth. Do not weaken or replace it without human approval when that changes the requested outcome.

Surface only blockers, consequential decisions, surprising results, or useful progress changes while the loop runs. Do not narrate routine attempts.

## Decision Gates

Pause for product judgment, destructive actions, publishing, deployment, credential use, meaningful scope expansion, or ambiguous trade-offs. Ordinary implementation and verification steps continue autonomously.

## Gotchas

- Do not call a one-shot attempt a loop; use the host continuation mechanism.
- Do not rely on intention or chat history as proof.
- Do not keep a worse attempt merely because work was invested in it.
- Do not confuse a stopped loop with a successful loop.
- Do not replace real-surface verification with internal tests when the changed contract is user-visible.
- Do not create scheduled follow-up automation unless the task explicitly owns ongoing monitoring.

## Closeout

For implementation loops:

1. Run `self-test` on the declared surface.
2. Run `autoreview` and resolve accepted findings.

Use `concise-report` for the final response. Include the best result, verifier evidence, stop reason, durable artifacts when relevant, residual risk, and decisions still needed. Use `explain-report` only when important supporting understanding merits a retained artifact.
