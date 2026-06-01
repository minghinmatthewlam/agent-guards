---
name: plan-loop
description: "Use for complex or high-risk implementation work that needs plan-first execution, explicit verification design, pre-code review, and autonomous post-implementation hardening through self-test, simplify, and review-loop."
---

# Plan Loop

Draft a plan, harden it with review coverage appropriate to the current host, then execute after user approval.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before starting, plus any repo-local `AGENTS.md` / `CLAUDE.md` instructions that apply. Your plan and implementation must follow those guidelines.

## How It Works

1. **Research** — spin up many agents in parallel to explore the codebase and inform the plan. Don't skimp — missing context during planning costs tenfold during implementation. If the conversation already contains investigation findings, build on those rather than re-discovering them.
2. **Draft** a plan in `plans/<task>/plan.md` (for example `plans/auth-refactor/plan.md`) informed by research findings. Gitignore `plans/`. Default to clean reimplementation over patching around existing complexity — agents implement fast, so the cost of rewriting cleanly is almost always lower than the cost of maintaining a patch on bad code.
3. **Plan verification up front** using the `self-test` skill. The plan's self-test section must name the exact proof path the agent will use: commands, test files, browser/Electron automation, Computer Use steps, or a combination. For new user-facing features, prefer a real-surface smoke of the completed workflow, then use fast command checks for repeatable confidence. "Manual E2E" or "the user should verify" is not acceptable when the agent can prove the behavior itself.
4. **Review** the plan with fresh-context reviewers per `references/review-protocol.md`. `autoreview` is for actual code diffs; use reviewer agents for pure plan files unless the plan itself is the change being shipped.
5. **Fix** the plan based on feedback.
6. **Repeat** until confident.
7. **User sign-off** before execution.
8. **Execute** continuously — no mandatory stop gates. Atomic commits throughout. If new facts appear, update the plan file. If the plan breaks, stop and re-plan.
9. **Self-test** — invoke `self-test` skill. Run the planned proof path on the highest-signal affected surface. If it fails, fix and re-run.
10. **Simplify** — invoke `simplify` skill, coding agents tend to overcomplicate code.
11. **Review** — invoke `review-loop`. It uses `autoreview` for the implemented diff and handles its own fix/re-verify cycle internally.

Steps 8-11 run autonomously — do not pause for user input between them.

## Round Sizing

- Plan review:
  - R1: 2-4 fresh-context reviewers in parallel, each with a distinct focus area.
  - R2+: 1-2 reviewers focused only on unresolved findings and plan deltas.
- Code-diff review after implementation:
  - Defer to `review-loop`, which uses `autoreview` by default.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what must be true to proceed:
- `<70`: another round.
- `70-84`: user must accept listed risks to proceed.
- `>=85`: eligible for sign-off.

## Gotchas

- Do not claim `self-test` coverage unless the written plan names the exact proof path, environment, and blockers.
- Do not stop after `self-test`. `plan-loop` is not complete until `simplify` and `review-loop` have also run.
- Do not plan patches on top of bad code. Ask "would a clean rewrite be simpler?" — for agents, it usually is.
- Do not list "manual verification" or "the user should test" in the self-test section when product-surface tools, browser automation, Computer Use, or command tests can prove the behavior.
- Do not confuse implementation checkpoints with final proof. Agents may use fast tests while coding, but the plan must still prove the delivered goal on the highest-signal affected surface.
- Do not re-research the codebase if the conversation already contains current findings you can build on.
- Do not mark the plan as dual-model reviewed in Codex-hosted runs unless Claude coverage actually happened through a separate reliable path.
