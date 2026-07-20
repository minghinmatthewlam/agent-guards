# Claude Orchestrator With Pi Workers

Claude Code uses headless Pi workers for delegated work. Pi workers are external processes with separate model context; they do not push their full transcript into Claude.

Requires Pi 0.80+, `@matthewlam/pi-goal` 0.3.0+, and `@matthewlam/pi-worker`. Confirm `pi --help` exposes `--result-schema`, `--result-file`, and `--worker-heartbeat-file`. Pi packages are registered in `~/.pi/agent/settings.json`.

## Spawn

Prepare the selected checkout and a separate run directory before spawning:

```bash
pi -p --session-id <uuid> -t read,write,bash,create_goal,update_goal,get_goal,report_result \
  --result-schema ~/.agents/skills/orchestrator/result.schema.json \
  --result-file <run-dir>/result.json \
  --worker-heartbeat-file <run-dir>/hb.json "<worker prompt>"
```

Use `~/.agents/runs/<repo>/<task-id>/` for result, heartbeat, optional goal-state, and debug files so the checkout stays clean. Require a fresh `result.json` for every invocation.

The tool allowlist must include `create_goal`, `update_goal`, `get_goal`, and `report_result`; omit `-t` for a trusted worker rather than accidentally disabling extension tools. Pi has no OS-level sandbox, so use explicit permissions and avoid untrusted work.

Use a persistent session id. Let the worker run `/use-loop`, drive its goal terminal, formulate a concise structured result, and call `report_result` once as its final action.

## Supervise

Arm `/loop` immediately:

- check process state and `hb.json`;
- use 5–10 minute checks for active or fragile work and relax toward 20 minutes for stable long runs;
- do not read the transcript or JSON stream during routine checks;
- inspect a short stream tail only to diagnose a concrete error or stall;
- delete the loop after acceptance.

Multi-hour evals or deploys should run as explicitly detached jobs with pidfiles and logs, ideally on an always-on machine. They need separate completion monitoring because worker push is unavailable.

## Result And Follow-up

Exit `0` means the process completed; exit `4` means the goal remained incomplete or blocked. Neither replaces result validation.

After exit:

1. Confirm the fresh `result.json` was created by this invocation.
2. Read it once.
3. Parse and revalidate it against the shared schema.
4. Independently verify the claimed work.

For follow-up, archive the prior result, make the result path absent again, and rerun the full command with the same session id and a focused clarification.

`last.txt` is optional legacy/debug output and is never authoritative.

## Important Failure Modes

- `--no-extensions` removes the goal, result, and heartbeat extensions.
- Sessions pin their original model; pass provider/model explicitly on spawn and resume when defaults or billing may change.
- Exit `0` without a valid result can indicate a provider or quota failure.
- A stale heartbeat plus a live process is a stall signal; a quiet fresh heartbeat is not.
- Prepare the checkout before spawning. Never ask a worker already running in a protected checkout to create and move itself into a worktree.
