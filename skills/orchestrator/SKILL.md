---
name: orchestrator
description: "Orchestrate complex tasks with agent teams. Clarify requirements, plan with dual-model review, implement with TeamCreate, simplify, review, and ship."
---

# Orchestrator

End-to-end flow for complex tasks: clarify → plan → implement with teams → simplify → review → ship.

For simple tasks (1-3 files), skip this — just implement directly, then `review-loop`.

Consider `$ARGUMENTS` if provided. Read `~/dev/agent-guards/AGENTS.md` before starting.

## Control Flow

You drive each phase and control all transitions. When a sub-skill finishes, return here for the next phase.

## Phase 1: Clarify

Use the Skill tool to invoke `new-task`. When 95%+ confident, proceed to Phase 2 yourself.

## Phase 2: Plan

Use the Skill tool to invoke `plan-loop`. When user approves the plan, proceed to Phase 3 yourself.

## Phase 3: Implement with Agent Teams

Use **TeamCreate** for coordinated parallel work (shared task list, peer messaging). Split agents by module/feature, not by role — each agent owns a vertical slice with exclusive file ownership. Size the team to the task (2-4 agents typical).

Use the **Agent tool** only for isolated read-only research/exploration, not implementation.

If new facts invalidate the plan, update the plan file before continuing.

## Phase 4: Simplify

Use the Skill tool to invoke `simplify` on the full changeset. Fix reuse, quality, and efficiency findings. This catches duplication and code smell that implementation agents introduce.

## Phase 5: Verify

Use the Skill tool to invoke `self-test`. Run the verification plan defined during Phase 2 against the real surfaces affected by the change. If verification fails, fix and re-verify before proceeding. Do not skip this phase — code review is not a substitute for proving it works.

## Phase 6: Review and Ship

Use the Skill tool to invoke `review-loop` on the full changeset (including simplify and verify changes). At >=85 confidence: commit, push, and create PR. Include in the PR summary: what was built, key decisions, and residual risks.

## Gotchas

- **Phase skipping is the #1 failure mode.** Agents skip Simplify and Self-Test because they feel "done" after implementation. Every phase exists for a reason — don't skip any.
- **Always return to the orchestrator after a sub-skill completes.** Don't let a sub-skill's closing state bleed into the next phase — come back here, confirm which phase just finished, then proceed to the next.
- **Don't do everything in the main context.** Phase 3 exists to delegate to teams. If you're implementing everything yourself in one thread, you're not using the orchestrator correctly.
