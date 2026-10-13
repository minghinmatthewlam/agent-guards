# Claude Desktop mode

Use this in the Claude desktop app, when the `spawn_task` tool is available.

## Start a worker

- Post a task card with `spawn_task`. The human clicks it to start it.
- For a non-default model, write the brief so the card waits for a "go" message. Once it starts, call `set_session_model` with the model picker's id, then send "go".
- Threads never post their own task cards. Neither you nor the human reliably sees cards posted from another session.

## Message a worker

SendMessage to its `local_…` id. Record that id on the board.

## Track workers

- `list_sessions` shows which sessions are idle or running.
- `list_events` (limit 4) shows a session's final report. A blocked session shows only "(called AskUserQuestion)" or a pending tool call; read the real question from its transcript jsonl (see [worker-check-prompt.md](worker-check-prompt.md)).

## CI and review comments

Step 6 of the workflow: turn on the app's CI auto-fix monitor from the PR's own session. Never poll CI yourself. The monitor only binds a PR to a session whose checkout is that PR's repo; for a PR in another repo, say so and ask how to watch it.

## Approvals

When a thread needs the human's approval, relay their exact words and let the app show them the card.
