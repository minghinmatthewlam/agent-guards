# Worker check prompt

Replace `<board>` with the board's path, then schedule the prompt for your mode:

- **Claude Desktop and cmux:** CronCreate, recurring, at an off-minute (for example `7,27,47 * * * *`). It is session-only: it dies with the session and expires after 7 days, so re-create it in every coordinator session.
- **Codex Desktop:** a heartbeat automation on the coordinator thread (`automation_update`), every 20 minutes. It persists across app restarts; check `$CODEX_HOME/automations/` and update the existing one rather than adding a duplicate.

## Codex Desktop

```
Coordinator worker check (automated, not from the human). Read <board>, section "### Working".
- Subagent threads: skip them; their completion notification arrives on its own.
- Codex worker threads (threadId on the board): call wait_threads once with every working threadId, its hostId and its stored afterCursor, timeoutMs 0. Store the new cursors on the board. For a thread that completed, read its final report with read_thread (turnLimit 1, includeOutputs true). For a thread that needs attention, read_thread to get the exact pending approval or question and show it to the human here word for word, with the options; don't answer it.
Don't poll CI here; each PR's own thread watches it with its own heartbeat.
Finished: move the row to "Idle" (or to "Ready for review" if it opened a PR, which also goes under "## Pull requests") with a 1–2 line outcome. Blocked (asks a question or needs approval): move it to "Waiting on you".
If nothing changed, update nothing and stay quiet. Otherwise give a 3–5 line summary leading with what the human should act on, with each ticket's priority. Read-only toward workers: never message or approve on a worker's behalf.
```

## Claude Desktop

```
Coordinator worker check (automated, not from the human). Read <board>, section "### Working".
- Subagent threads: skip them; their completion notification arrives on its own.
- Task-card threads (local_… ids): call list_sessions. If the session is idle with newer activity, read its final report with list_events (limit 4). If list_events shows only "(called AskUserQuestion)" or a pending tool call, read the session's transcript jsonl under ~/.claude/projects/<cwd-slug>/ to get the exact pending question or command, and show it to the human here word for word.
Don't poll CI here; CI waiting goes through the app's auto-fix monitor.
Finished: move the row to "Idle" (or to "Ready for review" if it opened a PR, which also goes under "## Pull requests") with a 1–2 line outcome. Blocked (asks a question or needs approval): move it to "Waiting on you". Use the Edit tool, not Bash.
If nothing changed, update nothing and reply with one short line ("no worker changes"). Otherwise give a 3–5 line summary leading with what the human should act on, with each ticket's priority. Read-only toward threads.
```

## cmux

```
Coordinator worker check (automated, not from the human). Read <board>, section "### Working".
- Subagent threads: skip them; their completion notification arrives on its own.
- cmux workers (workspace:N refs): run `cmux agent inbox` for reports since the last check, then `cmux workspace status --workspace <ref>` for each. For any that is needs-attention, run `cmux list-notifications` and `cmux read-screen --workspace <ref> --lines 60`, and show the pending question or command to the human here word for word, with the options. For any that went quiet with no report, read its screen for the final message.
Don't poll CI here; each PR's own session watches it with /loop.
Finished: move the row to "Idle" (or to "Ready for review" if it opened a PR, which also goes under "## Pull requests") with a 1–2 line outcome. Blocked (asks a question or needs approval): move it to "Waiting on you". Use the Edit tool, not Bash.
If nothing changed, update nothing and reply with one short line ("no worker changes"). Otherwise give a 3–5 line summary leading with what the human should act on, with each ticket's priority. Read-only toward workers.
```

## Reading a desktop session's pending question

To read a session's pending question from its transcript:

```bash
f=$(ls -t ~/.claude/projects/<cwd-slug>/*.jsonl | head -1)
tail -n 12 "$f" | python3 -c '
import sys, json
for l in sys.stdin:
    try: o = json.loads(l)
    except: continue
    c = o.get("message", {}).get("content")
    for b in c if isinstance(c, list) else []:
        if b.get("type") == "tool_use": print(b["name"], json.dumps(b["input"])[:3000])
        if b.get("type") == "text": print(b["text"][:1500])
'
```
