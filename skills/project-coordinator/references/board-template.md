# <Project> board

Goal: <one line, in the user's words>
Human: <name>, <role>. Coordinator session: <session title>.
Instructions: <path to project-instructions.md>. Library: <path to library/>.
Mode: <Codex Desktop | Claude Desktop | cmux>.
Models verified for threads: <e.g. default; openai/gpt-6-astra>

## Threads

### Ready for review
(PRs that finished the workflow and wait on the human)

### Waiting on you
- <ticket> (<priority>): <the exact question or decision, the options, and my recommendation>

### Suggested threads (waiting for the human's go)
- <ticket> (<priority>, confidence: bug real / fix right / impact checked): <one line>

### Working
| # | Thread | Kind | Started | Brief |
|---|---|---|---|---|
| 1 | <ticket>: <what it is doing now> | threadId (Codex), local_<id> (card), workspace:N (cmux) or subagent | <date> | <key context> |

### Landing
(approved PRs that are queued or merging)

### Idle (finished, nothing pending)
| # | Thread | Outcome |
|---|---|---|

### Resolved
| # | Thread | Outcome |
|---|---|---|

## Pull requests
- <ticket>: <PR URL> (<state>, tip <sha>). Reviews: <who and what they said>. Next: <step>.

## Routines
- Worker check: <Codex: heartbeat automation id | Claude Desktop/cmux: session-only cron, re-created each session>.
- <daily scout task, if any>

## Scout log
