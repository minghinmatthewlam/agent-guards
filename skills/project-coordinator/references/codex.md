# Codex Desktop mode

Use this when the `create_thread` and `wait_threads` tools are available (the Codex app tools). Each worker is a Codex thread in the sidebar. It starts immediately; there is no card to click. The human can open any worker and steer it.

Invoking this skill is the human's request to coordinate, so it authorizes you to create worker threads, spawn subagents, and message the threads you started. It does not authorize messaging threads you didn't start; ask first.

## Start a worker

1. Call `list_projects` once and record the repo's `projectId` on the board.
2. Save the brief to `<project home>/briefs/<ticket>.md`.
3. `create_thread` with:
   - `target`: the project, in a **worktree** environment, so the shared checkout is never switched. Pass `ref` only when the work continues an existing branch.
   - `prompt`: the full brief text.
   - `title`: `<ticket>: <short goal>`.
   - `model` / `thinking`: only for a non-default model. The model is set at creation; there is no "go" step.
4. Emit `::created-thread{...}` in your reply and record the returned `threadId` and `hostId` on the board. A worktree thread may first return a `clientThreadId`; look up the real `threadId` with `list_threads` before messaging it.

Research and audits stay in subagents (`spawn_agent`, read-only brief, `fork_context: false`). Their result arrives as a notification; close them with `close_agent` once the report is saved to `library/`.

## Message a worker

`send_message_to_thread` with its `threadId` (and `hostId`). Never message a thread you didn't start without the human's go.

## Track workers

- `wait_threads` with every working `threadId` and its last `afterCursor`, `timeoutMs: 0`, for a compact snapshot. Store each returned cursor on the board so the next check only sees new output.
- `read_thread` (`turnLimit: 1`, `includeOutputs: true`) to read a finished worker's final report.
- A worker that "needs attention" is waiting on an approval or a question. Show the human the exact request from `read_thread`, word for word, with the options, and tell them to answer it in that thread. Don't approve it yourself.
- Full transcripts live under `~/.codex/sessions/YYYY/MM/DD/*.jsonl` if `read_thread` truncates.

## CI and review comments

After opening the PR (tell the worker this in its brief's environment line), the worker calls `attach_artifact` with the PR URL, then creates a heartbeat automation on its own thread (`automation_update`) that reads CI with the Code Review plugin's `pull_requests_checks`, fixes failures and answers bot reviews, stays quiet when nothing changed, and deletes itself once the PR merges. The coordinator does not poll CI.

## Memory

Codex Memories (`[features] memories = true`, or Settings > Personalization) are off by default. When on, Codex extracts memories in the background from past threads once they've been idle (6 hours by default) into `~/.codex/memories/` (`memory_summary.md`, `MEMORY.md`), and `/memories` controls it per thread. Nothing is written the moment you learn a rule.

- To queue a standing rule for memory, write a short dated file to `~/.codex/memories/extensions/ad_hoc/notes/` (for example `2026-10-09-<project>-rules.md`). Codex folds these notes into memory at its next consolidation, following `extensions/ad_hoc/instructions.md`. Never edit `MEMORY.md` or the summaries by hand, and never delete a note.
- Also write every standing rule to `project-instructions.md` and the top of `board.md`. That is the copy a new coordinator thread reads at start, and it works even before consolidation runs.
- If Memories are off (no `~/.codex/memories/`), tell the human once and suggest turning them on; don't change their config yourself.
- Pin the coordinator thread (`set_thread_pinned`).

## Files

The project home usually sits outside the sandbox's writable roots. Edit board and library files with `apply_patch` or a shell write, and request escalation when the sandbox blocks it. Keep the existing project home when one exists, so Claude and Codex coordinators share one board.

## Close a worker

After its PR merges or the human drops it: `set_thread_archived` on the thread, and `archive_worktree` for its worktree. Ask the human first if the worker still has unreported work.
