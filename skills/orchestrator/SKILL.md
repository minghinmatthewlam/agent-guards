---
name: orchestrator
description: "Coordinate complex work across workers while keeping product context and final judgment in the main session. Use when the user asks to orchestrate, delegate, parallelize, supervise workers, or coordinate multi-agent implementation, research, review, or verification from Codex App, Claude Code, or Cursor."
---

# Orchestrator

Read `~/dev/agent-guards/AGENTS.md`.

The main session owns product context, task decomposition, supervision, integration, verification, and final reporting. Workers own bounded research, implementation, cleanup, or review. Do not turn the orchestrator into another implementation worker.

## Select The Host Path

Keep host mechanisms separate:

- **Codex App:** use native Codex App worker threads. Read [references/codex-app.md](references/codex-app.md) before spawning.
- **Claude Code:** use headless Pi workers. Read [references/claude-pi.md](references/claude-pi.md) before spawning.
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
7. Independently verify in proportion to risk, integrate centrally, and report with `/concise-report`.

Continue until the requested outcome is accepted or a real blocker requires the user. Creating workers is not completion.

## Worker Task Contract

Tell the worker:

- the specific goal and why it matters;
- allowed edits and forbidden actions;
- success criteria and the highest-signal self-test surface;
- required proof artifacts and where they should live;
- the expected result: outcome, important evidence, changed files, blockers, decisions, and residual risk;
- to use `/use-loop` and wrap up before context exhaustion.

Trust workers to choose implementation details. Split work when outcomes can run independently or one worker would accumulate unrelated deliverables. Use one integrated `/explain-report` or `/explain-diff` owner only when its trigger policy applies; other workers return evidence.

## Supervision Contract

Every worker must have a supervision path established immediately after spawn:

- **Codex App:** heartbeat automation wakes the orchestrator and checks the worker with `read_thread`.
- **Claude/Pi:** `/loop` checks process state and `hb.json`, not the transcript.
- **Cursor:** use native agent-window status and completion signals. Add fallback monitoring only for detached shell work.

Keep checks cheap and adaptive. Report only meaningful changes, blockers, or final completion. Do not repeatedly ingest worker histories or streams. Stop and delete fallback supervision after every tracked result is accepted.

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

Use `/concise-report` to keep the human oriented to meaningful outcomes, evidence, project learning, decisions, blockers, next actions, and residual risk. Keep raw detail in worker threads, proof artifacts, PRs, or ledgers.

## Gotchas

- Do not stop after spawning or silently leave completed workers unreviewed.
- Do not over-steer active workers.
- Do not let worker confidence replace real-surface proof.
- Do not reuse unknown, active, or user-owned worktrees.
- Detached background jobs need their own liveness and completion monitoring.
