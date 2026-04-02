---
name: review-loop
description: "Post-implementation review/fix loop. Use host-appropriate review coverage on your implementation, fix issues, iterate until highly confident, then commit."
---

# Review Loop

After implementation, harden it with review coverage appropriate to the current host. Fix, iterate, commit.

Read-only analysis → use `audit-loop` instead.
Planning before implementation → use `plan-loop` instead.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before applying fixes — the safety, workflow, and code conventions that govern all agent work.

## How It Works

1. **Review** your implementation per `references/review-protocol.md`. Spin up all review agents in parallel using the host-specific coverage rules. Pass relevant context (what you built, why, what changed, how you verified). Pre-warm any deferred tools only when the selected host path actually needs them.
2. **Fix** issues found. Atomic commits (one logical fix per commit). After fixes that affect behavior, invoke `self-test` to re-verify on the real surface — don't trust code review alone.
3. **Repeat** until confident. Follow the host-specific coverage rules every round. Run autonomously — do not pause for user input between rounds.
4. **Commit and close** when confident.

## Gotchas

- **Self-test after behavioral fixes is mandatory.** When a review round finds a behavioral bug and you fix it, use the Skill tool to invoke `self-test` to re-verify — don't trust the code review alone to confirm the fix works on the real surface. Skipping this is how "reviewed and fixed" changes still ship broken.
- In Codex-hosted runs, do not invoke Oracle, Claude, or other cross-model tooling just to satisfy review coverage. Native Codex review is the expected path unless the human explicitly asks for an external second opinion.

## Round Sizing

- Claude host:
  - R1: 3-6 native + 1 Codex cross-model, scaled to the number of distinct risk surfaces in the changeset. Each native reviewer gets a different focus area.
  - R2+: 1+1 default. Focus on previous round's findings and what changed — not a fresh re-review. Escalate to 3+1 on verdict disagreement, confidence drop, or blocker without consensus.
- Codex host:
  - R1: 3-6 native reviewers only, scaled to the number of distinct risk surfaces in the changeset. Each native reviewer gets a different focus area.
  - R2+: 1-2 native reviewers focused only on unresolved findings and deltas.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what must be true to close:
- `<70`: another round, mandatory.
- `70-84`: one more focused round on residual risks. If still 70-84 after that, escalate to user with findings.
- `>=85`: eligible to close. Auto commit, push, and create PR.
