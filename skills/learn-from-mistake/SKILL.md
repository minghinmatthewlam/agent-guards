---
name: learn-from-mistake
description: "Find why an agent produced a bad result, strengthen the code, repository, verification, tooling, or workflow that enabled it, then retry the original task. Use when the user asks to learn from a mistake, prevent recurrence, or postmortem an agent failure."
---

# Learn From Mistake

Fix the immediate result and the system that made the mistake easy.

## Diagnose

Preserve the original request, wrong result, available context and tools, and the observation that exposed the failure. Inspect the real source and output. Treat the agent's explanation as a hypothesis, not proof.

Find the owning cause:

- **Repository:** Misleading structure, duplicate paths, weak types, or missing deterministic checks. Use `repo-setup` to choose and prove the strongest proportional prevention.
- **Verification:** The wrong surface was checked, proof was weak, or the feature was not covered. Use `create-verification-skill` or `maintain-verification-skill`.
- **Task boundary:** Required context, access, ownership, or tools were missing or unclear. Fix that boundary.
- **Judgment:** The setup was adequate and recurrence is unlikely. Correct the result without adding machinery.

## Prevent And Retry

Implement the prevention within the authorized scope. Prove it catches the same class of failure, then retry the original task and verify the affected surface.

Ask before changing global guidance, external state, or anything outside the task's write scope.

## Report

Use `concisely`. State what failed, the verified cause, what changed to prevent recurrence, the corrected result, and remaining risk.

## Gotchas

- Do not turn every ordinary bug into an agent rule.
- Do not add prose when code or tooling can enforce the behavior.
- Do not fix the visible symptom while leaving the demonstrated failure path open.
- Do not claim prevention worked without reproducing the relevant failure safely.
