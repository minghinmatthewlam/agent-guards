---
name: orchestrator
description: "Coordinate complex work across worker threads (Codex) or background subagents (Claude). Keep the main thread as orchestrator: clarify, delegate, supervise to completion, review outputs, iterate, verify, and ship without doing substantial implementation directly."
---

# Orchestrator

Use this skill when the user wants the main thread — a Codex App thread or a Claude Code session — to coordinate work across worker threads or subagents. The orchestrator owns context, decisions, integration, and final judgment. Workers do research, implementation slices, verification, or review. A Codex App orchestrator drives Codex App threads (see Codex App Tools); a Claude Code orchestrator drives `Agent`-tool subagents or headless pi workers (see Claude Backend).

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

For Codex App heartbeats that should wake the current orchestrator thread, set `destination="thread"` and omit `targetThreadId`. Do not copy a source thread id, worker thread id, guessed current thread id, or stale id into `targetThreadId`; that can attach the heartbeat somewhere else or prevent the visible orchestrator loop from resuming. Only set `targetThreadId` when intentionally attaching to a specific known thread, and first verify that id with `list_threads` or an existing tool result.

After creating a heartbeat, keep the returned `automationId` in the status/report. If the heartbeat appears not to fire, immediately `view` or `delete` that automation, manually read the workers once, and recreate the heartbeat with `destination="thread"` and no explicit `targetThreadId`.

Keep heartbeat messages compact. Do not paste full worker histories, full logs, or large status inventories into every wakeup. The orchestrator thread already has context; the heartbeat only needs to wake it and point at the current supervision goal. Store detail in worker threads, PR/check links, patch artifacts, or a ledger.

```text
Wake message: Continue supervising <goal>. Read the active worker thread(s), send focused follow-up if blocked or incomplete, report only meaningful changes or final completion, and stop when <condition>.
```

## Claude Backend

Same orchestrator role; different plumbing. A Claude Code orchestrator cannot use the Codex App tools (`create_thread` etc. exist only when the orchestrator IS the Codex App). It drives workers two ways — the `Agent` tool or shelling out to headless `pi`. Do NOT assume the Codex App poll model; supervision is covered below.

### Choosing the worker engine

- **Claude workers (`Agent` tool)** — use when the task turns on **design, frontend, or visual/UX taste**: UI, layout, styling, animation, "make it look good / on-brand", copy tone, any aesthetic judgment call.
- **pi workers (`pi -p`)** — the DEFAULT for everything else: implementation, refactors, bug fixes, tests, backend/CLI/data work, research, analysis, review.

Heuristic: if the deliverable is judged by how it *looks or feels*, use a Claude worker; if it's judged by whether it *works*, use a pi worker.

### Claude workers (Agent tool)

- **Spawn:** `Agent` tool with `run_in_background: true` (Explore for read-only; general-purpose or a custom type for edits). Each gets its own context. Name it so you can steer it.
- **Completion is PUSH:** finished workers notify the orchestrator automatically with their full result — but push is reliable only while a worker's turn is live (see Supervision).
- **Steer:** `SendMessage` to the worker's name.
- **Worker loop:** the worker runs `/use-loop` then `/goal`.

### pi workers (pi -p)

Shell out via `Bash` with `run_in_background: true`. Requires pi >= 0.80, pi-goal >= 0.3.0 (headless goal loop + exit codes), and the pi-worker extension (`pi install npm:@matthewlam/pi-goal`, `pi install npm:@matthewlam/pi-worker`). Verified end-to-end: goal-driven multi-turn completion, parallel fan-out, heartbeat supervision, schema results, session-resume follow-ups.

**Preflight check** (do NOT inspect `~/.pi/agent/extensions/` — packages are registered in `~/.pi/agent/settings.json`, not that folder): `pi --help | grep -c 'last-message-file'` — nonzero means the extensions are loaded. If zero, run the two `pi install` commands above rather than falling back to Claude workers.

- **Spawn (default):**

  ```bash
  pi -p --session-id <uuid> -t read,write,bash,create_goal,update_goal,get_goal \
    --last-message-file <dir>/last.txt "<worker prompt>"
  ```

  The worker prompt is the SAME template as the other backends (see Worker Prompt): "Use /use-loop... use create_goal for this delegated task..." — pi discovers /use-loop from ~/.agents/skills, and pi-goal keeps driving continuation turns until the goal is terminal.
  - CRITICAL: the `-t` allowlist covers extension tools — it must include `create_goal,update_goal,get_goal` (and `report_result` if using --result-schema) or the worker silently cannot run the goal loop. Omit `-t` entirely for trusted workers.
  - Model/thinking default from `~/.pi/agent/settings.json`; override per worker with `--model <provider/model[:thinking]>` / `--thinking low|medium|high|xhigh`.
  - Give each parallel worker its own working dir; use `--session-id <uuid>` (not `--no-session`) so follow-ups are possible.
  - **Prepare the worker's directory BEFORE spawning** and launch with cwd already inside it (create the git worktree first, then spawn there). Never spawn in a protected checkout and tell the worker to "create and move into" a worktree — its early commands run in the wrong directory (observed: a worker mutated the main checkout's lockfile this way).
- **Exit codes:** 0 = goal complete (or no goal); 4 = loop ended incomplete (blocked / budget_limited / usage_limited / --goal-max-turns cap). The orchestrator can triage from the exit code alone.
- **Opt-in flags by task shape:** `--worker-heartbeat-file <hb.json>` for long tasks (stall detection: stale timestamp = hung); `--goal-state-file <gs.json>` for goal status + progress ledger on every change (tells you WHERE it is, not just that it's alive); `--result-schema/--result-file` when downstream code consumes the output; `--goal-max-turns <n>` (default 50) to bound the loop; `token_budget` in create_goal for checkpoint-style review.
- **Live progress for long workers:** spawn with `pi --mode json -p ...` — stdout becomes a live JSONL event stream (every tool call, turn, message) you can tail mid-run. Plain `-p` text output buffers per turn, so a working worker looks silent; do not mistake that for a hang.
- **Result:** `last.txt` = final message of the FINAL turn; `result.json` when schema is set.
- **Follow-up / steer:** re-run `pi -p --session-id <same-uuid> "<clarification>"` — resumes with full context and re-enters the goal loop. Mid-run emergency: kill the process (sessions persist every turn), then resume the same way. Prompt workers to `update_goal blocked` with a question when ambiguous instead of guessing — blocked (exit 4) is the worker asking for steering.
- **Parallel fan-out:** N background `pi -p` processes — independent sessions, truly concurrent.
- **No sandbox:** pi workers CAN git commit, npm install, and reach the network. The flip side: no OS-level containment — scope with `-t` allowlists and explicit Do-NOT lines in the prompt, and treat untrusted-content tasks with care.

### Supervision — arm a fallback heartbeat by default, both engines

Cadence is adaptive: 5-10 min while workers are actively implementing or a run is fragile; relax to ~20 min for long stable batch grinds (a multi-hour eval matrix doesn't need 8 checks an hour). Context overflow is survivable — pi auto-compacts on overflow and continues (probe-verified: 388k tokens summarized to ~450, task completed) — but compaction is lossy summarization at the moment the worker most needs its own details, so a worker deep in polish loops at high context is better nudged to converge (stop + resume the session with "commit as-is, report, no new work") than left to compact mid-implementation. That is a quality call, not a rescue.

Arm this right after spawning workers; do not wait for a stall. The cost is asymmetric — an unneeded heartbeat is one cheap tick then `CronDelete`, but a missing one lets a finished job sit silently unreported (observed: a background run sat ~6h until the user pinged).

- **Schedule** with `/loop <5-10m> <check prompt>` (CronCreate underneath); pick an off-minute cadence so fleet load spreads.
- **Keep each tick CHEAP:** `TaskList` for board status, plus each pi worker's `hb.json` (timestamp, last event, token totals — one tiny read tells you alive vs stalled). NEVER dump a worker transcript (`TaskOutput`) on a routine tick.
- **Why both engines need it:** a Claude worker's push breaks when it offloads to a detached process (a `run_in_background` command, a matrix/eval run, a deploy) then ends its turn; a pi worker has no live turn to push from at all — only the process-exit notification, and a stale `hb.json` timestamp is the only stall signal.
- **On a tick,** if a deliverable is complete but unreported: nudge the worker (`SendMessage` for Claude, `pi -p --session-id <uuid> "<nudge>"` for pi), or verify and commit it yourself when the worker is stale.
- **Shared state:** a `TaskCreate`/`TaskUpdate` board, one task per worker.
- **END the heartbeat** (`CronDelete`) once every tracked deliverable is accepted and committed. Also heartbeat a standing orchestrator that must keep finding NEW work.

A live worker's push still lands first and is handled immediately; the heartbeat only catches what push misses.

Gotchas:

- A worker that launches a background job and then ends its turn will NOT push when that job finishes. Detached work needs the fallback heartbeat, not push.
- A pi `-t` allowlist applies to EXTENSION tools too: forgetting the goal tools silently disables the goal loop, and forgetting `report_result` silently disables structured results (exit 0, empty result file, no error).
- pi has no read-only sandbox mode: for research workers use `-t read,bash` (or `-t read,grep,find,ls`) plus explicit no-write instructions — soft policy, not enforcement.
- A pi worker that exits suspiciously fast with exit 0 and an empty last.txt likely died on a provider/billing error, not "finished trivially" — check the tail of the `--mode json` stream for `stopReason: "error"` (observed: an exhausted provider quota killed spawns instantly with exit 0).
- pi sessions PIN the model they were created with; resuming a session ignores later settings changes. When the default model or its billing is in flux, pass `--provider`/`--model` explicitly on every spawn — including resumes.
- `--no-extensions` also unloads pi-worker/pi-goal, so `--last-message-file`, `--worker-heartbeat-file`, and the goal tools disappear with it.
- Multi-hour batch processes (eval matrices, deploys) should not run as harness-tracked background tasks — they can be reaped mid-run (observed twice in one evening). Launch them detached (`nohup`, pidfiles + logs to a known dir) and supervise via the cron heartbeat by output-count/pidfile, accepting that completion-push is lost. Better still, run them on an always-on box (laptop sleep kills detached processes too).
- Same-repo Claude workers share persistent memory and CLAUDE.md. Good for shared context; use a git worktree per worker for true isolation on parallel edits. pi workers isolate by per-worker working dirs or a worktree.
- Agent Teams is NOT the backend: teammates cannot spawn teammates, which breaks orchestrator to worker delegation.

## Worker Scope

One primary deliverable per worker. Before spawning, count the distinct deliverables in the task; more than 2-3 means split it into multiple workers. Oversized scopes hurt two ways at once: the worker outgrows its context window mid-task (pi survives this by auto-compacting, but compaction is lossy summarization exactly when the worker most needs its own details — observed: a 5-deliverable worker hit 90% context in its polish phase), and work that could have run in parallel serializes inside one thread. Splitting is almost free — workers are cheap, and each split adds parallelism plus an independent report to review. Remember the worker also spends context on standing overhead (self-review passes, proof artifacts, explain-diff), so size the task for ~60% of the window, not 100%.

Include a context budget line in every worker prompt ("wrap up with commits + report before ~70% context usage") and require granular commits as the worker goes — then even a worst-case failure loses only the final report, never the work.

## Worker Prompt

Give every worker a concrete, bounded task.

```text
You are working in this thread on one delegated task.
Use /use-loop. After you identify the verifiable goal, tool access, and self-test path, set /goal or use the harness goal tool for this delegated task.
Goal: <specific outcome>.
Permissions: <read-only or allowed edits>.
Do not: <forbidden actions such as publish, push, destructive commands>.
Success criteria: <evidence required before done>.
Self-test: <expected proof lane; worker may add minimal tests/scripts/fixtures/browser or Computer Use checks needed to prove the goal unless forbidden>.
Proof artifacts: <required screenshots/videos/traces/logs and where to save them; use "not needed" only with reason>.
Explain diff: <for substantial code changes, invoke and use /explain-diff; return the HTML path, or "not needed" with reason>.
Return in this thread: use /concise-report. Include status, result, evidence/proof paths, files changed, explain-diff path, blockers or decisions, next action, and residual risk. Use P0/P1/P2 only for the highest-signal findings, blockers, risks, or options.
```

Use `/use-loop` by default in worker prompts. The worker identifies the verifiable target, checks tool/self-test access, starts `/goal` or the harness goal tool for its assigned task, iterates until the target is met or blocked, and writes `/concise-report` status/blocker/final reports in its own thread. The orchestrator supervises by reading that thread and by maintaining heartbeat automation in the orchestrator thread.

For UI, desktop, browser, animation, focus, scrolling, or multi-step interaction work, require durable proof artifacts from the worker. Ask for saved screenshots for final visible state and short recordings for flows that require motion or timing. Prefer a stable directory such as `/Users/matthewlam/.codex/proofs/<worker-thread-id>/<task-slug>/`, and ask the worker to report artifact metadata with the final result.

For new features or fixes without a useful existing proof lane, explicitly allow the worker to add minimal verification structure while implementing: focused tests, fixtures, scripts, browser automation, Computer Use smoke checks, or artifact capture. The worker should not stop at "no test exists" when it can create the self-test path itself.

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

Use independent verification proportional to the risk:

- **Low risk:** accept worker self-test after checking the reported proof is specific, rerunnable, and tied to the requested surface.
- **Medium or high risk:** spot-check the changed files, rerun the key verifier, inspect proof artifacts, or spawn a verifier worker with a different prompt.
- **Methodology-critical:** use the stricter re-derivation rule below.

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
- **Methodology-critical work gets orchestrator re-derivation, not spot-checks.** For measurement, metering, data schemas, accounting, comparability, or security — anything whose errors silently corrupt everything downstream — do not verify against the worker's own test artifacts: they share the worker's blind spot. Re-derive the claim from raw evidence yourself and run one independent probe the worker didn't design, chosen so the wrong interpretation and the right one produce different answers (observed: a worker's single-turn token probe passed its own tests while the parser undercounted multi-turn runs 16x; a orchestrator-designed multi-turn probe exposed it in minutes). The orchestrator usually runs a stronger model with fuller context than workers — verification is where that advantage pays, not implementation.
- Before merging a worker branch, confirm nothing live is executing from the target checkout (a running eval/deploy mounts code from it; merging mid-run changes the thing being measured). Base successor workers' worktrees on the predecessor's branch so sequential merges don't conflict.

When reporting worker output to the user, label the confidence level clearly:

- **Orchestrator-accepted:** spot-checked or otherwise verified enough to drive decisions.
- **Worker-reported:** plausible worker result that has not been independently checked.
- **Unverified / needs proof:** useful lead that requires follow-up, live surface proof, or implementation-specific verification.

Use `/concise-report` for user-facing orchestration summaries. Summarize only meaningful changes, accepted results, blockers, decisions, and next actions. Use P0/P1/P2 priority tags for the few items that most affect what the user should do or believe. Keep worker detail in the worker thread, proof artifacts, explain-diff HTML, PRs, or ledgers.

## Gotchas

- Do not convert orchestration into main-thread implementation.
- Do not stop at "worker created." Supervision is the orchestrator's job.
- Do not over-steer active workers; wait for completion first.
- Broad initial discovery tasks are fine; broad follow-ups are the problem. After a worker responds, ask for the exact missing evidence, decision, or fix.
- Do not let worker confidence replace verification on the real affected surface.
- Do not ignore material overlap, conflicts, or duplicated work between workers; resolve those centrally when they appear.
