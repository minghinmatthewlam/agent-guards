# Worker check prompt

Replace `<board>` with the board's path, then schedule the prompt for your mode:

- **Claude Desktop and cmux:** CronCreate, recurring, every 30 minutes at an off-minute (for example `7,37 * * * *`). It is session-only: it dies with the session and expires after 7 days, so re-create it in every coordinator session.
- **T3 Code:** `schedule_task` with an interval of 30 minutes (`everyMs: 1800000`), bound to the coordinator thread. It persists across app restarts; call `list_scheduled_tasks` first and update the existing check rather than adding a duplicate.
- **Codex Desktop:** a heartbeat automation on the coordinator thread (`automation_update`), every 30 minutes. It persists across app restarts; check `$CODEX_HOME/automations/` and update the existing one rather than adding a duplicate.

## T3 Code

```
Coordinator worker check (automated, not from the human). Read <board>, sections "### Working" and "### Waiting on you".
- Delegated tasks (taskId on the board) and native subagents: skip them; their completion notification arrives on its own.
- T3 worker threads (threadId on the board): call t3_thread_list with the board's projectId, following its cursor until every board thread is found. For a thread whose turn ended (completed, failed or interrupted), read all its new output with t3_thread_read (view messages, afterPosition = its stored cursor, then each nextPosition; recover truncated items with itemId and textOffset) and store the new cursor. A "Waiting on you" thread that is running again goes back to "Working". An ended turn is not a finished worker: place it by its last report. A question waiting on the human goes to "Waiting on you". A worker that reports an open PR moves to "Ready for review" and starts the PR phase (SKILL.md): ready it, request the bot review once CI is green, and record the request on the board. For each PR in the PR phase, read its review thread for a verdict and its new review comments; relay blocking comments to the worker with the poteto-mode follow-up line, re-request after the fix, and merge only under the project's merge rule (otherwise bring the merge decision to the human). For a thread that is waiting, get the exact question with t3_pending_request_list and t3_pending_request_read, or, if that list is empty, the pending approval from t3_thread_read with view activity, and show it to the human here word for word, with the options; don't answer it.
Don't poll CI here; each PR's own thread watches it with watch_pull_request. For PR state on the board, use list_thread_pull_requests with the worker's threadId.
Finished: move the row to "Idle" (or to "Ready for review" if it opened a PR, which also goes under "## Pull requests") with a 1–2 line outcome. Blocked (asks a question or needs approval): move it to "Waiting on you". Edit the board with your file-edit tool (Edit on Claude, apply_patch on Codex), not a shell write.
If nothing changed, update nothing and reply with one short line ("no worker changes"). Otherwise give a 3–5 line summary leading with what the human should act on, with each ticket's priority, linking each thread as [title](t3-thread://v1/<threadId>). Toward workers, only relay review comments and the human's own words; never approve on the human's behalf.
```

## Codex Desktop

```
Coordinator worker check (automated, not from the human). Read <board>, section "### Working".
- Subagent threads: skip them; their completion notification arrives on its own.
- Codex worker threads (threadId on the board): call wait_threads once with every working threadId, its hostId and its stored afterCursor, timeoutMs 0. Store the new cursors on the board. For a thread that completed, read its final report with read_thread (turnLimit 1, includeOutputs true). For a thread that needs attention, read_thread to get the exact pending approval or question and show it to the human here word for word, with the options; don't answer it.
Don't poll CI here; each PR's own thread watches it with its own heartbeat.
Finished: move the row to "Idle" (or to "Ready for review" if it opened a PR, which also goes under "## Pull requests") with a 1–2 line outcome. Blocked (asks a question or needs approval): move it to "Waiting on you".
If nothing changed, update nothing and stay quiet. Otherwise give a 3–5 line summary leading with what the human should act on, with each ticket's priority. Toward workers, only relay review comments and the human's own words; never approve on the human's behalf.
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
