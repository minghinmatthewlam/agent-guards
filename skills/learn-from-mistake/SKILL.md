---
name: learn-from-mistake
description: "Find why an agent produced a bad result, strengthen the code, repository, verification, tooling, or workflow that enabled it, then retry the original task. Use when the user asks to learn from a mistake, prevent recurrence, or postmortem an agent failure."
---

# Learn From Mistake

Fix both the immediate result and the system that made the mistake easy.

## Diagnose

Inspect the real source, output, and failure observation—treat the agent's explanation as a hypothesis, not proof. Identify the owning cause:

- **Repository** (misleading structure, weak types, missing checks) → `repo-setup`
- **Verification** (wrong surface, weak proof, missing coverage) → `create-verification-skill` or `maintain-verification-skill`
- **Task boundary** (missing context, access, or tools) → fix the boundary
- **Judgment** (one-off with adequate setup) → fix the result without adding machinery

## Prevent & Retry

Implement prevention in scope (prefer code/tooling over prose), prove it catches the failure class, then retry and verify the affected surface. Ask before changing global guidance or out-of-scope state.

## Report

Use `concisely`: what failed, verified cause, prevention + proof, corrected result, and residual risk.
