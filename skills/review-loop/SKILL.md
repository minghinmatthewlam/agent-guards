---
name: review-loop
description: "Post-implementation dual-model review/fix loop. Spin up reviews from both model families on your implementation, fix issues, iterate until highly confident, then commit."
---

# Review Loop

After implementation, harden it with both model families. Fix, iterate, commit.

Read-only analysis → use `audit-loop` instead.
Planning before implementation → use `plan-loop` instead.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before applying fixes — the safety, workflow, and code conventions that govern all agent work.

## How It Works

1. **Review** your implementation with both model families per `references/review-protocol.md`. Spin up all review agents in parallel. Pass relevant context (what you built, why, what changed, how you verified). Pre-warm any deferred tools (e.g. `ToolSearch` in Claude Code) before the first review round so cross-model calls don't fail.
2. **Fix** issues found. Atomic commits (one logical fix per commit). After fixes that affect behavior, invoke `self-test` to re-verify on the real surface — don't trust code review alone.
3. **Repeat** until confident. Both families must be represented every round (coverage invariant). Run autonomously — do not pause for user input between rounds.
4. **Commit and close** when confident.

## Gotchas

- **Self-test after behavioral fixes is mandatory.** When a review round finds a behavioral bug and you fix it, use the Skill tool to invoke `self-test` to re-verify — don't trust the code review alone to confirm the fix works on the real surface. Skipping this is how "reviewed and fixed" changes still ship broken.

## Round Sizing

- R1: 3-6 native + 1 cross-model, scaled to the number of distinct risk surfaces in the changeset. Each native reviewer gets a different focus area.
- R2+: 1+1 default. Focus on previous round's findings and what changed — not a fresh re-review. Escalate to 3+1 on verdict disagreement, confidence drop, or blocker without consensus.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what must be true to close:
- `<70`: another round, mandatory.
- `70-84`: one more focused round on residual risks. If still 70-84 after that, escalate to user with findings.
- `>=85`: eligible to close. Auto commit, push, and create PR.
