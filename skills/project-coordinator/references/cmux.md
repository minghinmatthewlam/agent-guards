# cmux mode

Use this when `$CMUX_WORKSPACE_ID` is set and `cmux ping` prints `PONG`. Each worker is a Claude CLI session in its own cmux workspace. It starts immediately; there is no card to click.

## Start a worker

Save the brief to `<project home>/briefs/<ticket>.md`, then:

```bash
cmux workspace create --name "<ticket>" --cwd <repo> --focus false \
  --command 'claude -n "<ticket>" -w "<branch>" --model <model> "$(cat <project home>/briefs/<ticket>.md)"'
```

- `-w` puts the worker in its own worktree, so the shared checkout is never switched.
- The model is fixed at launch with `--model`. To change it, start a new worker.
- Record the workspace ref from the output (`workspace:N`) on the board.
- End every brief with: "When you finish, get blocked, or open a PR, report to the coordinator with `cmux agent message <coordinator workspace ref> "<one-line status>"`." Get your own ref with `cmux identify --json`. Reports then arrive without polling.

## Message a worker

```bash
cmux agent message <workspace ref or title> --from coordinator "text"
cmux agent message --reply-to <message-id> "text"
cmux agent inbox
```

cmux delivers through the worker's hooks: an idle worker wakes up, a busy one reads it at its next step. Never use `cmux send` to talk to an agent; it types into the terminal. ListAgents and SendMessage also reach cmux sessions, but `cmux agent message` is the default.

## Track workers

- `cmux workspace status --workspace <ref>`: `working` or `needs-attention`.
- `cmux list-notifications`: why a worker needs attention, for example "Bash needs approval".
- `cmux read-screen --workspace <ref> --lines 60`: the worker's screen, including a pending question and its options, word for word.
- `cmux sidebar-state`: each workspace's git branch, PR and status line.
- `cmux sessions list --agent claude --json`: each session's transcript path, for a full read.

## CI and review comments

Step 6 of the workflow: after opening the PR, the worker runs `/loop` in its own session. Bare `/loop` handles failed CI, review comments and merge conflicts, paces itself, and expires after 7 days. The coordinator does not poll CI.

## Close a worker

After its PR merges or the human drops it: `cmux workspace close <ref> --force`. Ask the human first if the worker still has unreported work.
