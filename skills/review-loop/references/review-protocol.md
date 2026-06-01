# Review Protocol

Shared reference for `plan-loop` and `review-loop`.

## Invocation

For actual code diffs, start with the `autoreview` skill. It builds a frozen diff bundle, runs the selected reviewer, validates structured findings, and exits nonzero when actionable findings exist.

Fresh-context reviewer agents are still useful for plan review, read-only audits, and focused follow-up on ambiguous findings. Do not use them as the default replacement for `autoreview` on code diffs.

## Host Rules

### Default Code-Diff Review

- Run `~/.agents/skills/autoreview/scripts/autoreview --mode auto --engine codex`.
- Keep web search enabled by default so review can check current API docs, dependency contracts, model names, platform behavior, and security guidance.
- Add `--no-web-search` only when the user explicitly requests offline/local-only review or network access would be inappropriate for the reviewed material.
- Retry a failed autoreview once with the same engine/model settings. If it still fails, note the review gap and lower confidence.

### Optional Panel

- Use `--reviewers codex,claude` only when the user asks for a second model, risk justifies extra spend, or Codex-only output needs arbitration.
- Do not use Droid or Copilot unless the user explicitly asks for those engines.

## Round Cap

Max 3 rounds. If not converged after R3, stop and escalate to the user with current findings and residual risks.

## Prompt Guidance

Tell any fresh-context reviewer:
- what phase they are reviewing (plan / execution / audit)
- what to focus on
- the relevant context inline
- for R2+, what changed since the previous round

Ask for this output format:

```text
## Verdict
READY or NOT_READY

## Findings
1. [blocker|high|medium|low] <title>
   Evidence: <specific passage, file path, or contradiction>
   Fix: <concrete change>

## Open Questions
- <question or "None">
```
