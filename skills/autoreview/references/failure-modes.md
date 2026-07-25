# Autoreview Failure Modes

Load this reference only when a review stalls, fails, or needs deeper evidence handling.

## Long Runs

- Structured review can take up to 30 minutes for large bundles or web-enabled calls.
- Advancing `review still running` heartbeats indicate healthy progress.
- Do not kill a run for a few quiet minutes. Investigate after multiple expected heartbeats are missing, the run exceeds its normal window, or a subprocess clearly failed.
- `--stream-engine-output` exposes useful live progress while preserving structured validation.

## Engine Failures

- Preserve the requested engine/model. Retry the same command a few times for transient capacity failures.
- Do not silently switch models or engines.
- The helper's successful exit with no actionable findings is sufficient even if engine prose is terse.

## Gitcrawl And GitHub

- For `database disk image is malformed`, portable manifest mismatch, unhealthy source/runtime databases, or stale portable-store state, run `gitcrawl doctor --json` once and inspect its health fields before bypassing the cache.
- Fall back to live GitHub only when repair fails and freshness requires it.

## Provenance

Keep blamed code author, blamed PR author, merger/committer, current PR author, and dates distinct. If no PR is traceable, report the blamed commit instead of inventing PR metadata.

For automation merges, identify the human trigger when practical from timeline comments, labels, or merge commands. Otherwise state that the trigger is unknown.

## Security Findings

Report only concrete, actionable security risk. When changing suppression behavior, ensure suppressed findings remain auditable, active output retains an unsuppressible suppression notice, and aggregate findings cannot hide unrelated active risk.
