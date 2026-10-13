# T3 Code mode

Use this when the `t3-code` MCP tools `t3_thread_launch` and `delegate_task` are available. T3 Code hosts several providers (Claude via OpenRouter, Codex, and others) behind one app. Each worker is a top-level T3 thread bound to its own worktree. It starts immediately; there is no card to click. The human can open any worker and steer it.

T3 launches a top-level thread only when the human asked for separate threads. A request to coordinate a project with worker threads is that request. If the human only invoked this skill, ask once before the first launch, and record their answer as a standing rule. Delegating subagent tasks and messaging the threads you started need no further ask. Messaging threads you didn't start does; ask first.

## Pick a model

Call `orchestrator_capabilities` once per session. Its output is large; save it and query it with `jq` instead of reading it whole. Use only a provider whose `canRunChildTask` is true, and a model id from that provider's `models` list. Record the verified pairs on the board.

- Claude models: the Claude provider whose `canRunChildTask` is true (now `claude_openrouter_shared`; instance ids change with T3 settings), ids like `claude-opus-5-5`.
- OpenAI, Google, xAI and other models: provider `codex`, ids like `openai/gpt-6.1-sol`.
- Reasoning goes in `options`: `{"reasoningEffort": "xhigh"}` on `codex`, `{"effort": "xhigh"}` on the Claude provider. Check the option ids in the catalog.
- The two tools name the provider differently. `t3_thread_launch` takes `modelSelection: {"instanceId", "model", "options"}`. `delegate_task` takes `target: {"providerInstanceId", "model", "options"}`. Omit either to inherit your own model.

## Start a worker

1. Call `t3_project_list` and record the target repo's `projectId` on the board. If the repo isn't a T3 project yet, register it with `t3_project_create` (`workspaceRoot` = the checkout).
2. Save the brief to `<project home>/briefs/<ticket>.md`.
3. `t3_thread_launch` with:
   - `projectId`, `title`: `<ticket>: <short goal>`.
   - `workspaceStrategy`: `{"type": "worktree", "baseRef": "<default branch>", "branch": "<branch>", "startFromOrigin": true}`. Continuing an existing branch uses `{"type": "existing_worktree", ...}` (paths from `t3_worktree_list` with the project's thread). Never omit it: an omitted strategy runs in the shared checkout.
   - `message`: the full brief text. A `/skill` at the start of the message is not run as a command; it reaches the model as plain text. Name skills in the brief the way [poteto-mode.md](poteto-mode.md) shows.
   - `modelSelection`: only for a non-default model, for example `{"instanceId": "codex", "model": "openai/gpt-6.1-sol", "options": {"reasoningEffort": "xhigh"}}`.
4. Record the returned `threadId` on the board at once. The launch has no retry key: if it errors or the response is lost, check `t3_thread_list` before launching again.
5. Link the worker for the human as `[<title>](t3-thread://v1/<threadId>)`.

Research, audits and cross-model reviews stay in subagents:
- A model your native subagent tool can select (Claude's Agent tool, Codex's `spawn_agent`): that tool.
- Any other model, including a same-family model the native tool doesn't offer: `delegate_task` with `mode: "async"`, a `role` (`research` or `review`), the target provider and model, and a `clientRequestId` unique to that round. Its completion wakes this thread by itself; don't poll it. Track it by `taskId`; stop it with `task_cancel`.
- A delegated child runs in **your** checkout, not a worktree. Keep delegated tasks read-only. Point reviewers at the worker's worktree path (`t3_worktree_list` with the worker's `threadId`). Have the worker commit before a review, so `git -C <worktree> diff origin/<default branch>...HEAD` holds the whole change; a reviewer also runs `git -C <worktree> status --short` and reports anything uncommitted.
- Each review round is a fresh `delegate_task` whose prompt carries the original brief, prior findings, the worker's responses and open objections. Never continue a review through `t3_thread_send` to its `childThreadId`.

## Message a worker

`t3_thread_send` with its `threadId` and `mode: "auto"` (starts an idle thread, steers a running one). Use `queue` for a separate follow-up turn and `steer` for a correction to the current turn. Pass a `clientRequestId` so a retry doesn't double-send.

## Track workers

- `t3_thread_list` with the project's `projectId` gives each thread's status. It pages; follow `cursor` until every board thread is found. `running` and `starting` are working. `waiting` needs attention. `completed`, `failed` and `interrupted` mean the turn ended, not that the work did. A worker ends its turn after every checkpoint, and after it starts watching its PR. Read its last report to place it: a design waiting on approval goes to "Waiting on you", a PR being watched stays in "Working", and only a merge-ready handoff goes to "Ready for review".
- `t3_thread_read` (view `messages`) reads a finished worker's final report. Store its `nextPosition` on the board as the worker's cursor and pass it as `afterPosition` next time, so a check reads only new output. Keep reading until no newer page is left, and recover a truncated item with `itemId` and `textOffset`, before you call a worker finished.
- A `waiting` worker is blocked on a question or an approval. `t3_pending_request_list` with its `threadId` shows questions, and `t3_pending_request_read` gives the exact text and options. Approval requests are not in that list. If it is empty, read the thread with view `activity` to find the pending command. Show the human the request word for word, with the options, and tell them to answer it in that thread. Never answer it with `t3_pending_request_respond` on the human's behalf.
- `list_thread_pull_requests` with a worker's `threadId` shows its PRs and their last known state, for the board's "Pull requests" section.

## CI and review comments

Step 6 of the workflow: after opening the PR, the worker calls `link_pull_request`, handles the review comments and checks already there, then calls `watch_pull_request` on its own thread and ends its turn. The watch only reports comments posted after it starts. T3 wakes that thread when a check fails, required checks pass, someone comments or reviews, or the branch conflicts. Each wake is one babysit pass. No `/loop`, no sleep loop, no polling. When the PR reaches merge-ready and the worker hands it back, it calls `unwatch_pull_request`. The coordinator does not poll CI. A delegated subagent cannot watch a PR, which is one reason implementation runs in launched threads.

## Check loop

Top-level worker threads don't notify the coordinator when they finish, so the check loop is required. Use `schedule_task` with `{"type": "interval", "everyMs": 1200000}`, `bindToCurrentThread: true`, and the T3 Code prompt in [worker-check-prompt.md](worker-check-prompt.md). It persists across app restarts. Call `list_scheduled_tasks` first and update the existing check with `update_scheduled_task` rather than adding a duplicate. Report its next run time. Pause it with `enabled: false` only when the board has no rows in "Working" or "Waiting on you", and re-enable it with `update_scheduled_task` on every launch.

A daily scout uses `schedule_task` with `{"type": "fixed_time", "timeOfDay": "08:57"}`.

## Memory

Use the memory of the provider you run as. Claude: its file memory. Codex: see the Memory section of [codex.md](codex.md). Also write every standing rule to `project-instructions.md` and the top of `board.md`, the copy a later coordinator reads first, whichever provider it runs on.

Pin the coordinator thread with `t3_thread_organize` (`action: "pin"`).

## Close a worker

After its PR merges or the human drops it: `t3_thread_organize` with `action: "settle"` (or `archive`). T3 does not remove the worktree; ask the human, then `git worktree remove <path>` from the main checkout. Ask the human first if the worker still has unreported work.
