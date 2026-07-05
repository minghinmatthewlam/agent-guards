---
name: orchestrator
description: "Coordinate complex work across worker threads (Codex) or background subagents (Claude). Keep the main thread as orchestrator: clarify, delegate, supervise to completion, review outputs, iterate, verify, and ship without doing substantial implementation directly."
---

# Orchestrator

Use this skill when the user wants the main thread — a Codex App thread or a Claude Code session — to coordinate work across worker threads or subagents. The orchestrator owns context, decisions, integration, and final judgment. Workers do research, implementation slices, verification, or review. A Codex App orchestrator drives Codex App threads (see Codex App Tools); a Claude Code orchestrator drives `Agent`-tool subagents or `codex exec` workers (see Claude Backend).

Read `~/dev/agent-guards/AGENTS.md` before starting.

## Core Rule

The orchestrator orchestrates; it does not implement substantial work itself.

Keep the main thread focused on:

- Clarifying the goal and success criteria.
- Choosing worker tasks.
- Creating worker threads.
- Waiting for workers to finish.
- Reviewing worker outputs and evidence.
- Sending follow-ups after completion when needed.
- Integrating results, deciding next steps, and reporting to the user.

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
- After starting a worker, immediately establish heartbeat supervision, including for short tasks, unless the user explicitly wants the current turn to stay open.

`read_thread` is the normal inspection mechanism. Worker threads do not return results directly to the caller and should not normally message the orchestrator thread. Use it for immediate spot checks, heartbeat wakeups, final result reads, and focused follow-up review.

Use `automation_update` after worker creation. Default to a 3-minute heartbeat unless the user specifies a cadence. The heartbeat should wake the orchestrator thread, read the worker, summarize progress if still active, send a focused follow-up if the result is incomplete, and disable itself after the worker completes and the result is summarized.

Keep heartbeat messages compact. Do not paste full worker histories, full logs, or large status inventories into every wakeup. The orchestrator thread already has context; the heartbeat only needs to wake it and point at the current supervision goal. Store detail in worker threads, PR/check links, patch artifacts, or a ledger.

```text
Wake message: Continue supervising <goal>. Read the active worker thread(s), send focused follow-up if blocked or incomplete, report only meaningful changes or final completion, and stop when <condition>.
```

## Claude Backend

Same orchestrator role; different plumbing. A Claude Code orchestrator cannot use the Codex App tools (`create_thread` etc. exist only when the orchestrator IS the Codex App). It drives workers two ways — the `Agent` tool or shelling out to `codex exec`. Do NOT assume the Codex App poll model; supervision is covered below.

### Choosing the worker engine

- **Claude workers (`Agent` tool)** — use when the task turns on **design, frontend, or visual/UX taste**: UI, layout, styling, animation, "make it look good / on-brand", copy tone, any aesthetic judgment call.
- **Codex workers (`codex exec`)** — the DEFAULT for everything else: implementation, refactors, bug fixes, tests, backend/CLI/data work, research, analysis, review.

Heuristic: if the deliverable is judged by how it *looks or feels*, use a Claude worker; if it's judged by whether it *works*, use `codex exec`.

### Claude workers (Agent tool)

- **Spawn:** `Agent` tool with `run_in_background: true` (Explore for read-only; general-purpose or a custom type for edits). Each gets its own context. Name it so you can steer it.
- **Completion is PUSH:** finished workers notify the orchestrator automatically with their full result — but push is reliable only while a worker's turn is live (see Supervision).
- **Steer:** `SendMessage` to the worker's name.
- **Worker loop:** the worker runs `/use-loop` then `/goal`.

### Codex workers (codex exec)

Shell out via `Bash` with `run_in_background: true`. Reliable exit codes and clean result capture make this the better programmatic worker.

- **Spawn:** `codex exec --skip-git-repo-check -s <sandbox> -C <dir> --json -o <last.txt> "<prompt>"`
  - `-s read-only|workspace-write|danger-full-access` scopes permissions.
  - `-C <dir>` = worker root; give each parallel worker its own dir/worktree so edits don't collide.
  - `-o <file>` captures only the final message; `--json` streams JSONL events (`thread.started` carries `thread_id`; `turn.completed`, `command_execution`, `file_change`).
  - `-m <model>` overrides the model per worker.
- **Result:** read the `-o` file for the final message; process exit 0 = success.
- **Steer / follow-up:** `codex exec resume <thread_id> "<msg>"`. Gotcha: `resume` inherits the original session's sandbox/cwd and REJECTS `-s`/`-C`; still pass `--skip-git-repo-check` if the original cwd wasn't a git repo.
- **Parallel fan-out:** launch N `codex exec` processes in the background, each with its own `-C` dir — truly concurrent (independent processes and threads).
- **Worker loop:** the bounded prompt is the `exec` argument; the worker self-loops to the goal and exits with the result in `-o <file>` (it cannot run `/use-loop` interactively).

### Supervision — arm a fallback heartbeat (5-10 min) by default, both engines

Arm this right after spawning workers; do not wait for a stall. The cost is asymmetric — an unneeded heartbeat is one cheap tick then `CronDelete`, but a missing one lets a finished job sit silently unreported (observed: a background run sat ~6h until the user pinged).

- **Schedule** with `/loop <5-10m> <check prompt>` (CronCreate underneath); pick an off-minute cadence so fleet load spreads.
- **Keep each tick CHEAP:** `TaskList` for board status, plus `git status` / file mtimes / the worker's `-o`/`--json` tail for finished-but-unreported surfaces. NEVER dump a worker transcript (`TaskOutput`) on a routine tick.
- **Why both engines need it:** a Claude worker's push breaks when it offloads to a detached process (a `run_in_background` command, a matrix/eval run, a deploy) then ends its turn; a `codex exec` worker has no live turn to push from at all — only a weak process-exit notification and no steering channel if it stalls.
- **On a tick,** if a deliverable is complete but unreported: nudge the worker (`SendMessage` for Claude, `codex exec resume <thread_id>` for codex), or verify and commit it yourself when the worker is stale.
- **Shared state:** a `TaskCreate`/`TaskUpdate` board, one task per worker.
- **END the heartbeat** (`CronDelete`) once every tracked deliverable is accepted and committed. Also heartbeat a standing orchestrator that must keep finding NEW work.

A live worker's push still lands first and is handled immediately; the heartbeat only catches what push misses.

Gotchas:

- A worker that launches a background job and then ends its turn will NOT push when that job finishes. Detached work needs the fallback heartbeat, not push.
- `codex exec resume` flag-parsing differs from the initial `exec` (no `-s`/`-C`) — don't reuse the spawn command verbatim for follow-ups.
- Same-repo Claude workers share persistent memory and CLAUDE.md. Good for shared context; use a git worktree per worker for true isolation on parallel edits. `codex exec` isolates via `-C`/`--add-dir` or a worktree.
- Agent Teams is NOT the backend: teammates cannot spawn teammates, which breaks orchestrator to worker delegation.

## Worker Prompt

Give every worker a concrete, bounded task.

```text
You are working in this thread on one delegated task.
Use /use-loop. After you identify the verifiable goal, tool access, and self-test path, set /goal or use the harness goal tool for this delegated task.
Goal: <specific outcome>.
Permissions: <read-only or allowed edits>.
Do not: <forbidden actions such as publish, push, destructive commands>.
Success criteria: <evidence required before done>.
Proof artifacts: <required screenshots/videos/traces/logs and where to save them; use "not needed" only with reason>.
Explain diff: <for substantial code changes, invoke and use /explain-diff; return the HTML path, or "not needed" with reason>.
Return in this thread: <concise report format: findings, files changed, tests run, proof artifact paths, explain-diff path, blockers, residual risk>.
```

Use `/use-loop` by default in worker prompts. The worker identifies the verifiable target, checks tool/self-test access, starts `/goal` or the harness goal tool for its assigned task, iterates until the target is met or blocked, and writes status/blocker/final reports in its own thread. The orchestrator supervises by reading that thread and by maintaining heartbeat automation in the orchestrator thread.

For UI, desktop, browser, animation, focus, scrolling, or multi-step interaction work, require durable proof artifacts from the worker. Ask for saved screenshots for final visible state and short recordings for flows that require motion or timing. Prefer a stable directory such as `/Users/matthewlam/.codex/proofs/<worker-thread-id>/<task-slug>/`, and ask the worker to report artifact metadata with the final result.

For substantial code changes that the caller needs to understand, tell the worker to invoke and use `/explain-diff` before final reporting. The worker should return the generated HTML path. Do not inline explain-diff instructions into the worker prompt.

Broad discovery tasks are allowed when the desired output is broad. Examples:

- "Read how X works in this repo and explain it."
- "Find the top-priority improvements for this app."
- "Map the release pipeline and identify weak spots."

For broad tasks, bound the return format instead of pretending the investigation is narrow: ask for a ranked list, evidence, confidence, open questions, and recommended next actions. After that worker returns, follow-ups should be specific to the missing evidence or chosen next step.

## Main Loop

1. Clarify success criteria before creating workers.
2. Split work by separable outcome, module, or evidence source.
3. Spawn workers with explicit prompts and permissions.
4. Set up heartbeat automation immediately after worker creation so the orchestrator is guaranteed to check the worker. Use direct `read_thread` polling only for immediate spot checks, final reads, or when the user explicitly wants this turn to stay open.
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

(Codex poll model. On Claude, completion is push; see the Claude Backend section.)

Default to passive supervision. A worker that is `inProgress` may be thinking, running tools, or waiting on a command.

Use heartbeat supervision instead of keeping the current turn open for manual polling. The heartbeat is still polling with `read_thread`; it just moves the wait out of the current turn and into scheduled follow-ups.

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
- For visual or interaction work, confirm the worker provided durable proof artifact paths and enough metadata to reopen them.
- For substantial code changes, confirm the worker either returned an `/explain-diff` HTML path or gave a clear reason it was not needed.
- For broad audits or discovery, check the response shape for every finding, then spot-check the highest-impact P0/P1 claims against the cited source before presenting them as accepted.
- Fully verify any finding that will drive implementation delegation; otherwise label it as worker-reported or source-inferred.
- Resolve conflicts between workers in the orchestrator thread.
- Ask follow-ups for missing evidence instead of filling gaps silently.

When reporting worker output to the user, label the confidence level clearly:

- **Orchestrator-accepted:** spot-checked or otherwise verified enough to drive decisions.
- **Worker-reported:** plausible worker result that has not been independently checked.
- **Unverified / needs proof:** useful lead that requires follow-up, live surface proof, or implementation-specific verification.

## Gotchas

- Do not convert orchestration into main-thread implementation.
- Do not stop at "worker created." Supervision is the orchestrator's job.
- Do not over-steer active workers; wait for completion first.
- Broad initial discovery tasks are fine; broad follow-ups are the problem. After a worker responds, ask for the exact missing evidence, decision, or fix.
- Do not let worker confidence replace verification on the real affected surface.
- Do not ignore material overlap, conflicts, or duplicated work between workers; resolve those centrally when they appear.
