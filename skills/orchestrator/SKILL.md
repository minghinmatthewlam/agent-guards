---
name: orchestrator
description: "Coordinate complex work with Codex App worker threads. Keep the main thread as orchestrator: clarify, delegate, wait for worker completion, review outputs, iterate, verify, and ship without doing substantial implementation directly."
---

# Orchestrator

Use this skill when the user wants the main Codex App thread to coordinate work across other Codex threads. The orchestrator owns context, decisions, integration, and final judgment. Worker threads do research, implementation slices, verification, or review.

For simple one-thread tasks, skip this skill and do the work directly.

Read `~/dev/agent-guards/AGENTS.md` before starting.

## Core Rule

The orchestrator orchestrates; it does not implement substantial work itself.

Keep the main thread focused on:

- Clarifying the goal and success criteria.
- Choosing worker tasks and file ownership.
- Creating worker threads.
- Waiting for workers to finish.
- Reviewing worker outputs and evidence.
- Sending follow-ups after completion when needed.
- Integrating results, deciding next steps, and reporting to the user.

Implement directly only when the task is tiny, urgent, or the user explicitly asks this thread to do it.

## Codex App Tools

Use `tool_search` to expose these tools when they are not already available:

- `create_thread`: start a user-owned Codex App worker thread.
- `read_thread`: inspect worker status and read completed turns.
- `send_message_to_thread`: send follow-up work, missing context, or changed decisions.
- `fork_thread`: branch completed context into a new thread when a second path should share history.
- `handoff_thread`: move a thread between local checkout and Codex worktree when isolation needs change.
- `list_threads`: find an existing worker thread before continuing it.
- `set_thread_title`, `set_thread_pinned`, `set_thread_archived`: keep orchestration threads tidy.
- `automation_update`: create a heartbeat when worker completion should be checked later without keeping the current turn open.

`create_thread` basics:

- Use a project local target by default, especially for read-only investigation, planning, review, explanation, and normal same-branch app work.
- Use a project worktree target only when isolation is useful: parallel edit-heavy workers, risky experiments, or tasks that should not touch the shared checkout.
- Include model/thinking only when the task needs an override; otherwise inherit defaults.
- After a successful creation, report the created thread id using the Codex App thread directive required by the host.
- After starting a worker, immediately establish supervision. Default to a heartbeat automation, including for short tasks, unless the user explicitly wants the current turn to stay open.

`read_thread` is the normal inspection mechanism. Worker threads do not return results directly to the caller and should not normally message the orchestrator thread. Use it for immediate spot checks, heartbeat wakeups, final result reads, and focused follow-up review.

Use `automation_update` for heartbeat supervision by default after worker creation. The heartbeat should wake the orchestrator thread, read the worker, summarize progress if still active, send a focused follow-up if the result is incomplete, and disable itself after the worker completes and the result is summarized.

## Worker Prompt

Give every worker a concrete, bounded task.

```text
You are a worker thread for the orchestrator.
Goal: <specific outcome>.
Scope: <repo/files/surfaces>.
Permissions: <read-only or allowed edits>.
File ownership: <exclusive paths, if editing>.
Do not: <forbidden actions such as publish, push, destructive commands>.
Success criteria: <evidence required before done>.
Return: <concise report format: findings, files changed, tests run, blockers, residual risk>.
```

For implementation workers, give exclusive file ownership whenever possible. Treat files outside that ownership as read-only unless the orchestrator explicitly expands scope.

Broad discovery tasks are allowed when the desired output is broad. Examples:

- "Read how X works in this repo and explain it."
- "Find the top-priority improvements for this app."
- "Map the release pipeline and identify weak spots."

For broad tasks, bound the return format instead of pretending the investigation is narrow: ask for a ranked list, evidence, confidence, open questions, and recommended next actions. After that worker returns, follow-ups should be specific to the missing evidence or chosen next step.

## Main Loop

1. Clarify success criteria before creating workers.
2. Split work by separable outcome, module, or evidence source.
3. Spawn workers with explicit prompts and permissions.
4. Supervise completion. Default to a heartbeat automation immediately after worker creation. Use direct `read_thread` polling only for immediate spot checks, final reads, or when the user explicitly wants this turn to stay open.
5. When a worker completes, read its final response and inspect claimed evidence.
6. Decide centrally:
   - accept the result,
   - send a focused follow-up to the same worker,
   - spawn another worker for an independent pass,
   - revise the plan,
   - or integrate and move to verification.
7. Repeat until the success criteria are met or a real blocker is surfaced.

Do not end after merely creating a worker unless you have also established how the orchestrator will continue supervision. The user should not need to manually check worker threads.

## Waiting Policy

Default to passive supervision. A worker that is `inProgress` may be thinking, running tools, or waiting on a command.

Default to heartbeat supervision instead of keeping the current turn open for manual polling. For short tasks, use a short heartbeat interval; for longer tasks, use a longer interval. The heartbeat is still polling with `read_thread`; it just moves the wait out of the current turn and into scheduled follow-ups.

Use direct `read_thread` polling only when you need an immediate spot check, a final result read, or the user explicitly wants live coordination in the current turn. For low-noise reads, start with the newest turn only and omit tool outputs where possible, such as `turnLimit=1` and `includeOutputs=false`. Broaden the read only when the latest turn does not contain enough context.

Do not send mid-turn status checks or steering messages by default. Steer only when:

- New user context, product decisions, or constraints arrive.
- The original prompt was wrong or missing critical context.
- The worker asks a blocking question.
- The worker explicitly reports a blocker.
- A task-specific timeout is exceeded with no new visible progress.

If the worker finishes with an incomplete answer, send a follow-up after completion. Do not interrupt an active turn just because it is quiet.

Important limitation: `read_thread` shows status, visible messages, and final outputs. It does not expose private reasoning. Treat `inProgress` as active unless there is concrete evidence otherwise.

## Review And Integration

Worker output is evidence, not an automatic final answer.

Before accepting a worker result:

- Check that every success criterion was answered.
- Separate verified facts from inference.
- Confirm claimed file edits, tests, links, or timestamps where practical.
- For broad audits or discovery, check the response shape for every finding, then spot-check the highest-impact P0/P1 claims against the cited source before presenting them as accepted.
- Fully verify any finding that will drive implementation delegation; otherwise label it as worker-reported or source-inferred.
- Resolve conflicts between workers in the orchestrator thread.
- Ask follow-ups for missing evidence instead of filling gaps silently.

When reporting worker output to the user, label the confidence level clearly:

- **Orchestrator-accepted:** spot-checked or otherwise verified enough to drive decisions.
- **Worker-reported:** plausible worker result that has not been independently checked.
- **Unverified / needs proof:** useful lead that requires follow-up, live surface proof, or implementation-specific verification.

For code changes, run the normal closeout sequence after workers finish:

1. `simplify` on the integrated changeset.
2. `self-test` against the real affected surface.
3. `review-loop` on the final diff.
4. Commit, push, and open a PR only after verification is sufficient.

## Patterns

Read-only incident investigation:

- Worker A: gather local repo evidence.
- Worker B: verify live external state, if credentials/tools are available.
- Orchestrator: merge timelines, distinguish direct evidence from inference, ask one follow-up for gaps.

Implementation:

- Worker A: implement owned module or narrow fix in a worktree.
- Worker B: independently review the intended fix or write verification plan.
- Orchestrator: inspect diffs, resolve tradeoffs, run simplify/self-test/review-loop, then ship.

Review:

- Worker A: code review for correctness and regressions.
- Worker B: test/verification audit.
- Orchestrator: prioritize findings, decide fixes, delegate follow-up work.

## Gotchas

- Do not convert orchestration into main-thread implementation.
- Do not stop at "worker created." Supervision is the orchestrator's job.
- Do not over-steer active workers; wait for completion first.
- Broad initial discovery tasks are fine; broad follow-ups are the problem. After a worker responds, ask for the exact missing evidence, decision, or fix.
- Do not let worker confidence replace verification on the real affected surface.
- Do not let one worker edit files another worker owns.
- Do not skip simplify, self-test, or review-loop after implementation work.
