# Review Protocol

Shared reference for `plan-loop`.

## Invocation

Spin up a fresh-context reviewer for each review. Run all reviewers for a round in parallel.

- **Native**: use reviewers from the current host model family
- **Cross-model**:
  - **Claude host**: call Codex through the MCP tool
  - **Codex host**: do not require Claude review as part of this skill

## Host Rules

### Claude Host

- Every round should include at least 1 native Claude review and 1 Codex review.
- Retry a failed Codex review once. If it still fails, note the gap and lower confidence before asking the user to proceed.

### Codex Host

- Use native Codex reviewers only.
- Do not block or fake coverage by calling unreliable Claude CLI review paths.

## Round Cap

Max 3 rounds. If not converged after R3, stop and escalate to the user with current findings and residual risks.

## Prompt Guidance

Tell each reviewer:
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
