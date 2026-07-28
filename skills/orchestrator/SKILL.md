---
name: orchestrator
description: "Coordinate complex work across workers while keeping product context and final judgment in the main session. Use when the user asks to orchestrate, delegate, parallelize, supervise workers, or coordinate multi-agent implementation, research, review, or verification from Codex App, Claude Code, or Cursor."
---

# Orchestrator

Read `~/dev/agent-guards/AGENTS.md`.

The main session owns product context, task decomposition, supervision, integration, verification, and final reporting. Workers own bounded research, implementation, cleanup, or review. Do not turn the orchestrator into another implementation worker.

## Select The Host Path

Keep host mechanisms separate:

- **Codex:** use native subagents for bounded work. When the user approves and work needs durable context isolation, an independent lifecycle, or follow-up across turns, use a separate Codex task managed through the pinned project orchestrator. The orchestrator remains the user's interface: send messages, surface questions and meaningful progress, integrate results, and archive completed tasks.
- **Claude Code:** use native subagents, with [headless Pi workers](references/claude-pi.md) as the fallback when native subagents are unavailable or unsuitable.
- **Cursor:** use Cursor's native worker/subagent capabilities from the IDE or agent window, with **Grok 4.5 High** as the default worker model. Trust Cursor's built-in orchestration rather than adding CLI wrappers.

Do not mix host mechanisms unless the user explicitly wants cross-host work.

If edit isolation is needed, read [references/worktrees.md](references/worktrees.md) before creating or reusing a worktree.

## Shared Workflow

1. Define the goal and evidence required for acceptance.
2. Split separable outcomes into bounded worker tasks; keep dependent decisions in the main session.
3. Choose the host-native worker mechanism and the least-isolated safe checkout.
4. Give each worker the task contract below.
5. Arm supervision immediately after spawning.
6. Review the result and claimed evidence; follow up on the same worker when context should be preserved.
7. Independently verify in proportion to risk, integrate centrally, and report with `/concisely`.

Continue until the requested outcome is accepted or a real blocker requires the user. Creating workers is not completion.

## Worker Task Contract

Tell the worker:

- the specific goal and why it matters;
- the relevant starting commit or ref and working-tree state when conclusions depend on repository state;
- allowed edits and forbidden actions;
- success criteria and the highest-signal self-test surface;
- required proof artifacts and where they should live;
- the expected result: outcome, important evidence, changed files, blockers, decisions, and residual risk;
- to use `/use-loop` and wrap up before context exhaustion.

Trust workers to choose implementation details. Split work when outcomes can run independently or one worker would accumulate unrelated deliverables. Give concurrent implementation workers disjoint write scopes and integrate shared files centrally. Use one integrated `/explain-report` owner only when its trigger policy applies; other workers return evidence.

Give bounded workers a self-contained task contract and the minimum inherited conversation context. For Codex subagents, use `fork_turns: "none"` for independent research or review, the smallest useful recent-turn count when task history matters, and full history only when genuinely necessary. Reuse the same worker when implementation directly follows its audit or prior reasoning remains important.

## Supervision Contract

Use host-native status and completion signals. Keep checks cheap and adaptive; report only meaningful changes, blockers, or final completion. Detached external workers require separate monitoring, removed after acceptance.

Treat a quiet active worker as working unless status, heartbeat age, process state, or a task-specific timeout shows otherwise. Steer only for new user context, an explicit blocker, incorrect scope, or concrete stall evidence.

## Acceptance

Worker output is evidence, not an automatic final answer.

- Check every success criterion and distinguish verified facts from inference.
- Inspect or rerun the highest-signal proof before using a result to drive consequential work.
- Require durable screenshots or recordings when visual state, focus, timing, or interaction matters.
- Re-derive methodology-critical claims from raw evidence with an independent probe; do not validate measurement, accounting, schema, comparability, or security claims only against worker-authored tests.
- Resolve overlap and conflicts centrally.
- Preserve contributor credit and verify no live process is using a checkout before merging into it.

Label results when the distinction matters:

- **Orchestrator-accepted:** independently checked enough to drive decisions.
- **Worker-reported:** plausible but not independently checked.
- **Unverified:** requires another proof surface.

## Reporting

Use `/concisely` to keep the human oriented to meaningful outcomes, evidence, project learning, decisions, blockers, next actions, and residual risk. Keep raw detail in worker threads, proof artifacts, PRs, or ledgers.

## Gotchas

- Do not stop after spawning or silently leave completed workers unreviewed.
- Do not over-steer active workers.
- Do not let worker confidence replace real-surface proof.
- Do not reuse unknown, active, or user-owned worktrees.
- Do not create separate Codex tasks when a bounded native subagent is sufficient.
- Detached background jobs need their own liveness and completion monitoring.
