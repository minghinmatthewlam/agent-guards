# Thread Introspection Loop

Goal: Review actual agent usage and propose small improvements to skills, prompts, automations, or repo setup.

Trigger: daily or weekly heartbeat in a dedicated repo-scoped improvement thread. Prefer a dedicated worker thread for this loop; only combine it with another heartbeat as a temporary fallback.

Inputs:

- recent Codex/Claude threads,
- worker outputs,
- repeated user corrections,
- repeated blockers,
- verbose or low-signal reports,
- failed proof attempts,
- skills and templates in `~/dev/agent-guards`.

Guardrails:

- default to proposing changes, not auto-editing all skills,
- only edit an explicitly allowed subset,
- keep diffs small,
- prefer one high-confidence improvement over broad rewrites,
- preserve the user's latest preferences over stale patterns.

Verifier:

- every proposed change cites the thread behavior or repeated failure it addresses,
- updates preserve concise reporting and verification discipline,
- `./scripts/sync.sh --dry-run` passes before sync.

Report:

- P0/P1 repeated pattern found,
- proposed skill/setup change,
- evidence from actual usage,
- change made or pending decision,
- residual risk.
