# Loop State And Artifacts

Load this reference for long-running loops, repeated experiments, or visual and interaction work.

## Compact State

Keep current control state short:

```text
Goal: <one-line outcome>
Verifier: <exact command or surface and latest result>
Best state: <baseline or kept attempt>
Attempts: <kept/reverted count>
Blocker: <none or exact blocker>
Next: <single next action>
Stop when: <target, stall, blocker, decision, or budget>
Artifacts: <ledger, proof, patch, run, or PR paths>
```

## Durable Ledger

Use an existing issue, plan, checklist, task artifact, or workspace file. For each meaningful attempt record:

- change made;
- verifier result;
- keep, revise, or discard decision;
- evidence path or result summary;
- next idea or blocker.

Do not duplicate raw logs in chat.

## Visual Proof

Plan durable proof before implementing visual, UI, browser, desktop, animation, focus, timing, or multi-step interaction work:

- screenshots for final visible state;
- short recordings for flows or timing;
- traces or logs when they materially explain behavior.

Store retained artifacts under `/Users/matthewlam/.codex/proofs/<task>/<slug>/` and verify that the files can be reopened before citing them.
