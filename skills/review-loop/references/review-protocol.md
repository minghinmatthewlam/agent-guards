# Review Protocol

Shared reference for plan-loop, review-loop, and audit-loop skills.

## Invocation

Spin up a fresh-context agent for each review — never review inline. Run all agents in parallel.

- **Native**: spin up an agent in your own model family
- **Cross-model**: call the other family (Claude host calls `codex` MCP tool, Codex host calls `claude` CLI below)

### Codex (from Claude host)

Call the `codex` MCP tool. Use `codex-reply` with the returned `threadId` for follow-ups.

### Claude (from Codex host)

```bash
timeout 300 env -u CLAUDECODE claude -p "<prompt>"
```

Do NOT pass `--permission-mode plan`. It causes hangs in non-interactive mode.

## Retry Policy

- Empty response or timeout: retry once.
- Still failing: note the gap and continue.

## Coverage Invariant

Every round must have at least 1 codex review + 1 claude review (native or cross-model).

## Round Cap

Max 3 rounds. If not converged after R3, stop and escalate to user with current findings and residual risks.

## Prompt Guidance

Tell each reviewer:
- What phase (plan / execution / audit) and what to focus on
- Provide the relevant context inline (plan text, code changes, findings, etc.)
- For R2+: what was found last round and what changed since — reviewers should focus on the delta, not re-review from scratch

Ask for this output format:
```
## Verdict
READY or NOT_READY

## Findings
1. [blocker|high|medium|low] <title>
   Evidence: <specific passage, file path, or contradiction>
   Fix: <concrete change>

## Open Questions
- <question or "None">
```
