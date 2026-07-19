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

- Choose local versus worktree using Worktree lifecycle below; local is the default unless isolation is required.
- Include model/thinking only when the task needs an override; otherwise inherit defaults.
- After a successful creation, report the created thread id using the Codex App thread directive required by the host.
- After starting a worker, immediately establish heartbeat supervision, including for short tasks, unless the user explicitly wants the current turn to stay open.

### Worktree lifecycle

Worktrees are isolation resources, not the default worker target.

- Use the shared local checkout for read-only work and for one edit worker only when no other worker or live process owns it, its status is understood, and it is safe to mutate. Use one worktree per concurrent edit worker, risky experiment, conflicting branch, or task that needs an independently reviewable branch.
- Before creating one, inspect `git worktree list --porcelain`. Reuse only a registered worktree owned by the same task, worker, and branch, with no active worker or process using it. Resume and follow-up work should normally reuse that worktree. Never reuse another active, unknown, or user-created worktree.
- Let Codex App manage its own worktree location. Record and inspect the returned registered path immediately after creation; pause or steer the worker if the result is wrong.
- For manually created Claude or pi worktrees, preallocate a short unique task id before creation, then use `<repo>/.worktrees/<task-slug>-<task-id>/` and a branch named `agent/<task-slug>-<task-id>`. Record the eventual worker thread or session id as its owner after spawn.
- Before creating the first repo-local worktree, ensure `/.worktrees/` is present in the local exclude file resolved from the main checkout by `git rev-parse --git-path info/exclude`; do not modify the repository's committed `.gitignore` solely for agent worktrees. Preserve existing exclude entries and verify the main checkout stays clean.
- Treat `.worktrees/` as infrastructure: exclude it from recursive searches, file watchers, formatters, test discovery, and bulk repository operations. Never run `git clean` with `-x` or an equivalent bulk cleaner against the parent checkout while registered nested worktrees exist. Remove registered nested worktrees before moving or deleting the main repository.
- Record each worktree in orchestration status with its owner thread or session id, path, and purpose. Record the exact base commit for manually created or dependency-based worktrees, and report a retained reason at closeout.
- Resolve the integration base explicitly and record its commit before manual creation. Use the current task branch, the verified default branch, or a predecessor worker branch according to the task dependency; never branch from ambiguous `HEAD` or silently change the base.
- For manual Claude or pi worktrees, create and validate the worktree before spawning: verify its registered path, checked-out branch, and clean status, then launch the worker with cwd already set there.
- Worker completion does not authorize cleanup. Remove an orchestrator-owned worktree only after its result is accepted, proof is stored outside it, no process or thread uses it, and all wanted changes are committed and integrated or otherwise preserved. Never discard uncommitted or unreachable work without explicit approval.
- Remove with `git worktree remove <path>` without `--force`; never use `rm -rf`. When stale administrative records are suspected, inspect `git worktree prune --dry-run --verbose` before pruning them. Never remove or prune active or user-owned work based only on age.
- At orchestration closeout, report retained and removed worktrees and why each retained worktree still exists.

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

**Preflight check** (do NOT inspect `~/.pi/agent/extensions/` — packages are registered in `~/.pi/agent/settings.json`, not that folder): confirm `pi --help` lists `--result-schema`, `--result-file`, and `--worker-heartbeat-file`. If any are missing, run the two `pi install` commands above rather than falling back to Claude workers.

- **Spawn (default):**

  ```bash
  pi -p --session-id <uuid> -t read,write,bash,create_goal,update_goal,get_goal,report_result \
    --result-schema ~/.agents/skills/orchestrator/result.schema.json \
    --result-file <run-dir>/result.json \
    --worker-heartbeat-file <run-dir>/hb.json "<worker prompt>"
  ```

  The worker prompt is the SAME template as the other backends (see Worker Prompt): "Use /use-loop... use create_goal for this delegated task..." — pi discovers /use-loop from ~/.agents/skills, and pi-goal keeps driving continuation turns until the goal is terminal. Before finishing, the worker uses `/concise-report` to formulate the structured result, then calls `report_result` exactly once as its final action.
  - CRITICAL: the `-t` allowlist covers extension tools — it must include `create_goal,update_goal,get_goal,report_result` or the worker silently cannot run the goal loop or save its structured result. Omit `-t` entirely for trusted workers.
  - Model/thinking default from `~/.pi/agent/settings.json`; override per worker with `--model <provider/model[:thinking]>` / `--thinking low|medium|high|xhigh`.
  - Give each parallel worker its own working dir; use `--session-id <uuid>` (not `--no-session`) so follow-ups are possible.
  - Keep orchestration files outside the checkout. Prepare a unique `<run-dir>` such as `~/.agents/runs/<repo-slug>/<task-id>/` for `result.json`, `hb.json`, optional goal state, and debug output; do not dirty the worktree with worker-control files.
  - **Follow Worktree lifecycle above. Prepare and validate the selected worker directory BEFORE spawning** and launch with cwd already inside it. Create a worktree first only when the lifecycle rules require isolation. Never spawn in a protected checkout and tell the worker to "create and move into" a worktree — its early commands run in the wrong directory (observed: a worker mutated the main checkout's lockfile this way).
  - **Require a fresh result path for every invocation.** Before spawning, require that `<run-dir>/result.json` does not exist. Archive an accepted prior result elsewhere before a resume; never let a new invocation inherit an existing result file.
- **Exit codes:** 0 = goal complete (or no goal); 4 = loop ended incomplete (blocked / budget_limited / usage_limited / --goal-max-turns cap). Use the exit code for initial triage, but never accept a worker without the validated structured result.
- **Opt-in flags by task shape:** `--worker-heartbeat-file <hb.json>` for long tasks (stall detection: stale timestamp = hung); `--goal-state-file <gs.json>` for goal status + progress ledger on every change (tells you WHERE it is, not just that it's alive); `--goal-max-turns <n>` (default 50) to bound the loop; `token_budget` in create_goal for checkpoint-style review. The default structured-result flow uses the orchestrator skill's reusable `result.schema.json` with explicit `--result-schema` and `--result-file` paths.
- **Execution monitoring:** monitor only the process and `--worker-heartbeat-file` during normal execution. Do not tail or ingest the worker's JSONL event stream or transcript. `--mode json` remains an exceptional debug aid for diagnosing a concrete stall, not part of the default result flow.
- **Result:** `result.json` is the authoritative worker result. After the process completes, confirm the previously absent file was created by that invocation, then read it once, parse it, and revalidate it against the same schema before accepting it. Then invoke `/concise-report` independently when integrating the worker's findings; do not forward the worker report verbatim. `--last-message-file <dir>/last.txt` remains available only as an optional legacy/debug fallback and is neither the default nor authoritative.
- **Follow-up / steer:** archive the prior result so `<run-dir>/result.json` is absent, then re-run the full default command with `--session-id <same-uuid>`, the same `-t` allowlist including `report_result`, the same `--result-schema`, and the same `--result-file`, replacing the prompt with the clarification. This resumes with full context, re-enters the goal loop, and can emit a fresh authoritative result. Mid-run emergency: kill the process (sessions persist every turn), then resume with that same full command. Prompt workers to `update_goal blocked` with a question when ambiguous instead of guessing — blocked (exit 4) is the worker asking for steering.
- **Parallel fan-out:** N background `pi -p` processes — independent sessions, truly concurrent.
- **No sandbox:** pi workers CAN git commit, npm install, and reach the network. The flip side: no OS-level containment — scope with `-t` allowlists and explicit Do-NOT lines in the prompt, and treat untrusted-content tasks with care.

### Supervision — arm a fallback heartbeat by default, both engines

Cadence is adaptive: 5-10 min while workers are actively implementing or a run is fragile; relax to ~20 min for long stable batch grinds (a multi-hour eval matrix doesn't need 8 checks an hour). Context overflow is survivable — pi auto-compacts on overflow and continues (probe-verified: 388k tokens summarized to ~450, task completed) — but compaction is lossy summarization at the moment the worker most needs its own details, so a worker deep in polish loops at high context is better nudged to converge (stop + resume the session with "commit as-is, report, no new work") than left to compact mid-implementation. That is a quality call, not a rescue.

Arm this right after spawning workers; do not wait for a stall. The cost is asymmetric — an unneeded heartbeat is one cheap tick then `CronDelete`, but a missing one lets a finished job sit silently unreported (observed: a background run sat ~6h until the user pinged).

- **Schedule** with `/loop <5-10m> <check prompt>` (CronCreate underneath); pick an off-minute cadence so fleet load spreads.
- **Keep each tick CHEAP:** while a pi worker is running, use `TaskList` for board status plus its process state and `hb.json` (timestamp, last event, token totals). NEVER dump a worker transcript (`TaskOutput`) on a routine tick. Once the process exits, stop polling and follow the Result lifecycle above.
- **Why both engines need it:** a Claude worker's push breaks when it offloads to a detached process (a `run_in_background` command, a matrix/eval run, a deploy) then ends its turn; a pi worker has no live turn to push from at all — only the process-exit notification, and a stale `hb.json` timestamp is the only stall signal.
- **On a tick,** if a deliverable is complete but unreported: nudge the worker (`SendMessage` for Claude; for pi, use the full Follow-up / steer command and fresh-result lifecycle above), or verify and commit it yourself when the worker is stale.
- **Shared state:** a `TaskCreate`/`TaskUpdate` board, one task per worker.
- **END the heartbeat** (`CronDelete`) once every tracked deliverable is accepted and committed. Also heartbeat a standing orchestrator that must keep finding NEW work.

A live worker's push still lands first and is handled immediately; the heartbeat only catches what push misses.

Gotchas:

- A worker that launches a background job and then ends its turn will NOT push when that job finishes. Detached work needs the fallback heartbeat, not push.
- A pi `-t` allowlist applies to EXTENSION tools too: forgetting the goal tools silently disables the goal loop, and forgetting `report_result` silently disables structured results (exit 0, empty result file, no error).
- pi has no read-only sandbox mode: for research workers use `-t read,bash` (or `-t read,grep,find,ls`) plus explicit no-write instructions — soft policy, not enforcement.
- A pi worker that exits suspiciously fast with exit 0 and no valid `result.json` likely died on a provider/billing error, not "finished trivially" — check the tail of the `--mode json` stream for `stopReason: "error"` (observed: an exhausted provider quota killed spawns instantly with exit 0).
- pi sessions PIN the model they were created with; resuming a session ignores later settings changes. When the default model or its billing is in flux, pass `--provider`/`--model` explicitly on every spawn — including resumes.
- `--no-extensions` also unloads pi-worker/pi-goal, so `--result-schema`, `--result-file`, `--last-message-file`, `--worker-heartbeat-file`, `report_result`, and the goal tools disappear with it.
- Multi-hour batch processes (eval matrices, deploys) should not run as harness-tracked background tasks — they can be reaped mid-run (observed twice in one evening). Launch them detached (`nohup`, pidfiles + logs to a known dir) and supervise via the cron heartbeat by output-count/pidfile, accepting that completion-push is lost. Better still, run them on an always-on box (laptop sleep kills detached processes too).
- Same-repo Claude workers share persistent memory and CLAUDE.md. Good for shared context; follow Worktree lifecycle for parallel edits. pi workers isolate by per-worker working dirs or a worktree.
- Agent Teams is NOT the backend: teammates cannot spawn teammates, which breaks orchestrator to worker delegation.

## Worker Scope

One primary deliverable per worker. Before spawning, count the distinct deliverables in the task; more than 2-3 means split it into multiple workers. Oversized scopes hurt two ways at once: the worker outgrows its context window mid-task (pi survives this by auto-compacting, but compaction is lossy summarization exactly when the worker most needs its own details — observed: a 5-deliverable worker hit 90% context in its polish phase), and work that could have run in parallel serializes inside one thread. Splitting is almost free — workers are cheap, and each split adds parallelism plus an independent report to review. Remember the worker also spends context on standing overhead (self-review passes, proof artifacts, explain-report or explain-diff), so size the task for ~60% of the window, not 100%.

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
Explain report: <needed or not needed under /explain-report's trigger policy; if needed, name the single report owner, mode, audience, questions, accepted evidence, and artifact path. Use /explain-diff for code changes>.
Return in this thread: use /concise-report. Include status, result, evidence/proof paths, files changed, explain-report or explain-diff path, blockers or decisions, next action, and residual risk. Use P0/P1/P2 for every finding, blocker, risk, or option that materially affects what the user should do or believe; omit redundant or immaterial detail without imposing a fixed count.
```

Use `/use-loop` by default in worker prompts. The worker identifies the verifiable target, checks tool/self-test access, starts `/goal` or the harness goal tool for its assigned task, iterates until the target is met or blocked, and writes `/concise-report` status/blocker/final reports in its own thread. The orchestrator supervises by reading that thread and by maintaining heartbeat automation in the orchestrator thread.

For pi workers using the default structured-result flow, make the final instruction explicit: formulate the result with `/concise-report`, map it into the shared schema, then call `report_result` exactly once as the final action. The orchestrator accepts only the completed, parsed, independently revalidated `result.json`; it does not treat a worker's prose or legacy `last.txt` as authoritative.

For UI, desktop, browser, animation, focus, scrolling, or multi-step interaction work, require durable proof artifacts from the worker. Ask for saved screenshots for final visible state and short recordings for flows that require motion or timing. Prefer a stable directory such as `/Users/matthewlam/.codex/proofs/<worker-thread-id>/<task-slug>/`, and ask the worker to report artifact metadata with the final result.

For new features or fixes without a useful existing proof lane, explicitly allow the worker to add minimal verification structure while implementing: focused tests, fixtures, scripts, browser automation, Computer Use smoke checks, or artifact capture. The worker should not stop at "no test exists" when it can create the self-test path itself.

Use `/explain-report` as the sole owner of report trigger policy. The orchestrator decides whether that policy applies after considering the accepted material and the user's need to stay oriented or learn the project.

Designate exactly one report owner. Normally integrate and verify worker results first, then have the orchestrator or one report worker create one artifact from accepted findings. A single implementation, research, or learning worker may own `/explain-diff` or `/explain-report` when its prompt explicitly names HTML as a primary deliverable. All other workers return evidence only. Do not inline either skill's instructions into the worker prompt.

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
- When the worker prompt designated that worker as report owner, confirm the artifact was built from accepted evidence and returned a valid path. Otherwise, accept evidence without requiring per-worker HTML and create the integrated report after verification when `/explain-report` policy calls for it.
- For broad audits or discovery, check the response shape for every finding, then spot-check the highest-impact P0/P1 claims against the cited source before presenting them as accepted.
- Fully verify any finding that will drive implementation delegation; otherwise label it as worker-reported or source-inferred.
- Resolve conflicts between workers in the orchestrator thread.
- Ask follow-ups for missing evidence instead of filling gaps silently.
- **Methodology-critical work gets orchestrator re-derivation, not spot-checks.** For measurement, metering, data schemas, accounting, comparability, or security — anything whose errors silently corrupt everything downstream — do not verify against the worker's own test artifacts: they share the worker's blind spot. Re-derive the claim from raw evidence yourself and run one independent probe the worker didn't design, chosen so the wrong interpretation and the right one produce different answers (observed: a worker's single-turn token probe passed its own tests while the parser undercounted multi-turn runs 16x; a orchestrator-designed multi-turn probe exposed it in minutes). The orchestrator usually runs a stronger model with fuller context than workers — verification is where that advantage pays, not implementation.
- Before merging a worker branch, confirm nothing live is executing from the target checkout (a running eval/deploy mounts code from it; merging mid-run changes the thing being measured). Follow Worktree lifecycle when basing successor work on a predecessor branch.

When reporting worker output to the user, label the confidence level clearly:

- **Orchestrator-accepted:** spot-checked or otherwise verified enough to drive decisions.
- **Worker-reported:** plausible worker result that has not been independently checked.
- **Unverified / needs proof:** useful lead that requires follow-up, live surface proof, or implementation-specific verification.

Use `/concise-report` for user-facing orchestration summaries. Summarize meaningful changes, accepted results, blockers, decisions, and next actions. Use P0/P1/P2 priority tags for every item that materially affects what the user should do or believe; omit redundant or immaterial detail without imposing a fixed count. Link one integrated `/explain-report` or `/explain-diff` artifact when important supporting understanding should remain available; keep raw worker detail in worker threads, proof artifacts, PRs, or ledgers.

## Gotchas

- Do not convert orchestration into main-thread implementation.
- Do not stop at "worker created." Supervision is the orchestrator's job.
- Do not over-steer active workers; wait for completion first.
- Broad initial discovery tasks are fine; broad follow-ups are the problem. After a worker responds, ask for the exact missing evidence, decision, or fix.
- Do not let worker confidence replace verification on the real affected surface.
- Do not ignore material overlap, conflicts, or duplicated work between workers; resolve those centrally when they appear.
