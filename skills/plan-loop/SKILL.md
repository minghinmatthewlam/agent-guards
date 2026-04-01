---
name: plan-loop
description: "Use for complex or high-risk implementation work that needs plan-first execution, explicit verification design, and review before coding. When hosted in Claude, include Codex cross-review. When hosted in Codex, do not rely on Claude review."
---

# Plan Loop

Draft a plan, harden it with review coverage appropriate to the current host, then execute after user approval.

Read-only analysis -> use `audit-loop` instead.
Post-implementation review -> use `review-loop` instead.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before starting, plus any repo-local `AGENTS.md` / `CLAUDE.md` instructions that apply. Your plan and implementation must follow those guidelines.

## How It Works

1. **Research** — spin up many agents in parallel to explore the codebase and inform the plan. Don't skimp — missing context during planning costs tenfold during implementation. If the conversation already contains investigation findings, build on those rather than re-discovering them.
2. **Draft** a plan in `plans/<task>/plan.md` (for example `plans/auth-refactor/plan.md`) informed by research findings. Gitignore `plans/`. Default to clean reimplementation over patching around existing complexity — agents implement fast, so the cost of rewriting cleanly is almost always lower than the cost of maintaining a patch on bad code.
3. **Plan verification up front** using the `self-test` skill. The plan's self-test section must name the exact proof command the agent will run (e.g., `pnpm exec playwright test tests/core/foo.spec.ts`). If no existing test covers the surface, the plan must commit to writing one. "Manual E2E" or "the user should verify" is not acceptable when the agent can build and run the test itself.
4. **Review** per `references/review-protocol.md`. Spin up all review agents in parallel.
5. **Fix** the plan based on feedback.
6. **Repeat** until confident.
7. **User sign-off** before execution.
8. **Execute** continuously — no mandatory stop gates. Atomic commits throughout. If new facts appear, update the plan file. If the plan breaks, stop and re-plan.
9. **Self-test** — invoke `self-test` skill. Build and run verification on the real product surface. If it fails, fix and re-run.
10. **Simplify** — invoke `simplify` skill, coding agents tend to overcomplicate code.
11. **Review** — invoke `review-loop`. It handles its own fix/re-verify cycle internally.

Steps 8-11 run autonomously — do not pause for user input between them.

## Round Sizing

- Claude host:
  - R1: 2-4 native + 1 Codex cross-model, all launched in parallel. Each native reviewer gets a distinct focus area.
  - R2+: 1+1 default. Focus on previous round's findings and what changed — not a fresh re-review. Escalate to 3+1 on verdict disagreement, confidence drop, or blocker without consensus.
- Codex host:
  - R1: 2-4 native reviewers in parallel.
  - R2+: 1-2 native reviewers focused only on unresolved findings and plan deltas.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what must be true to proceed:
- `<70`: another round.
- `70-84`: user must accept listed risks to proceed.
- `>=85`: eligible for sign-off.

## Gotchas

- Do not claim `self-test` coverage unless the written plan names the exact proof commands, environments, and blockers.
- Do not plan patches on top of bad code. Ask "would a clean rewrite be simpler?" — for agents, it usually is.
- Do not list "manual verification" or "the user should test" in the self-test section. Verification is always automatable — use Playwright, browser MCPs, or CLI tools to prove it works.
- Do not defer all verification to post-implementation. Build the test alongside the code and run it on the real surface.
- Do not re-research the codebase if the conversation already contains current findings you can build on.
- Do not mark the plan as dual-model reviewed in Codex-hosted runs unless Claude coverage actually happened through a separate reliable path.
