# Codex App Workers

Use native Codex App threads when the orchestrator is running in Codex App.

## Tools

Expose tools with `tool_search` when needed:

- `create_thread`: create a worker.
- `read_thread`: inspect current status and completed turns.
- `send_message_to_thread`: follow up or steer.
- `fork_thread`: branch completed context.
- `handoff_thread`: change local/worktree isolation.
- `list_threads`: locate an existing worker before creating another.
- `set_thread_title`, `set_thread_pinned`, `set_thread_archived`: keep threads navigable.
- `automation_update`: supervise asynchronously.

Use a project-local target for read-only work and safe single-worker edits. Use a worktree only when the shared checkout is unsafe or concurrent edits need isolation. Inherit model and reasoning defaults unless the task needs an override.

`read_thread` is the normal result path; workers do not push results into the orchestrator. Start with the newest turn and omit tool output, then broaden only when necessary.

## Heartbeat

Create a heartbeat immediately after the worker starts. Default to roughly three minutes unless the task suggests another cadence.

For a heartbeat that should wake the current orchestrator thread:

- set `destination="thread"`;
- omit `targetThreadId`;
- do not copy or guess a source or worker thread id.

Each tick should read the worker, report only meaningful progress, send a focused follow-up only after completion or a concrete blocker, and delete itself after the result is accepted.

If the heartbeat does not fire, view or delete it, read the worker manually once, and recreate it without an explicit `targetThreadId`.

Use direct polling only for an immediate spot check, final read, or when the user explicitly wants the current turn to remain open.

## Follow-up And Acceptance

Follow up on the same thread when its context remains useful. Fork only when a second path should share completed history. Before accepting, inspect the claimed files, proof, and real affected surface according to the shared acceptance rules.
