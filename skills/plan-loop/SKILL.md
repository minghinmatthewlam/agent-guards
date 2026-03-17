---
name: plan-loop
description: "Plan-first dual-model hardening loop. Draft a plan, get it reviewed by both model families, iterate until confident, get user sign-off, then execute continuously."
---

# Plan Loop

Draft a plan, harden it with both model families, then execute after user approval.

Read-only analysis → use `audit-loop` instead.
Post-implementation review → use `review-loop` instead.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before starting — the safety, workflow, and code conventions that govern all agent work. Your plan and implementation must follow these guidelines.

## How It Works

1. **Research** — spin up many agents in parallel to explore the codebase and inform the plan. Don't skimp — missing context during planning costs tenfold during implementation. If the conversation already contains investigation findings (e.g., the user explored before invoking this skill), build on those rather than re-discovering them.
2. **Draft** a plan in `plans/<task>/plan.md` (e.g. `plans/auth-refactor/plan.md`) informed by research findings. Gitignore `plans/`.
3. **Review** with both model families per `references/review-protocol.md`. Spin up all review agents in parallel — native via subagent, cross-model via the other family's tool. Pre-warm any deferred tools (e.g. `ToolSearch` in Claude Code) before the first review round so cross-model calls don't fail.
4. **Fix** the plan based on feedback.
5. **Repeat** until confident. Both families must be represented every round (coverage invariant).
6. **User sign-off** before execution.

## Round Sizing

- R1: 2-4 native + 1 cross-model, all launched in parallel. Each native reviewer gets a distinct focus area.
- R2+: 1+1 default. Focus on previous round's findings and what changed — not a fresh re-review. Escalate to 3+1 on verdict disagreement, confidence drop, or blocker without consensus.
- Cross-model cap: always 1 per round. Cross-model tools serialize, so a 2nd would wait for the 1st — add native reviewers instead for more coverage.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what must be true to proceed:
- `<70`: another round.
- `70-84`: user must accept listed risks to proceed.
- `>=85`: eligible for sign-off.

## Execution

After plan approval:
- Execute continuously — no mandatory stop gates.
- If new facts appear, update the plan file (what changed, why, impact).
- If the plan breaks mid-execution, stop and re-plan — don't brute-force a failing approach.
- Atomic commits throughout.
- After implementation, invoke the `review-loop` skill.
