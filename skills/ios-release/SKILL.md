---
name: ios-release
description: "Run a preflight-gated iOS release with asc for TestFlight or App Store delivery. Use when preparing, validating, publishing, submitting, diagnosing blockers, or creating a repeatable iOS release workflow."
---

# iOS Release

Separate every release into read-only preflight and explicitly approved mutation.

## Load Relevant References

- `references/id-resolution-and-cli.md`: authentication, IDs, output formats, pagination, and timeouts.
- `references/testflight-orchestration.md`: groups, testers, notes, and distribution.
- `references/submission-health.md`: compliance, metadata, validation, and submission recovery.
- `references/workflow-automation.md`: `.asc/workflow.json` and CI-safe automation.
- `references/publish-commands.md`: concrete TestFlight and App Store publish/submit commands.

Load only the references required for the selected route or blocker.

## Required State

Resolve and verify the app, version, build, intended route, artifact path, target groups, and current pipeline state. Prefer immutable IDs over names.

## Phase A: Preflight

1. Verify `asc` authentication and environment health.
2. Resolve the exact app, version, build, and TestFlight groups.
3. Inspect current version, build, review, and submission state.
4. Run the route-specific validation.
5. Stop on blockers and return exact remediation evidence.

Preflight is read-only. Do not upload, distribute, publish, submit, or confirm.

## Phase B: Execute

Proceed only after explicit approval for the concrete release route and scope in the current session.

1. Reconfirm identifiers and artifact immediately before mutation.
2. Run the narrowest approved publish or submit operation from `references/publish-commands.md`.
3. Wait for processing when supported.
4. Inspect resulting build, distribution, or submission state.
5. Stop if validation changes or the command would broaden distribution.

## Gotchas

- Authentication success does not prove release metadata is complete.
- Names can be ambiguous or stale; resolve deterministic IDs.
- Build processing, TestFlight validation, and App Store validation are different gates.
- `--confirm` is a real submission boundary and always requires explicit approval.
- Never hide blocker details behind a generic validation failure.
- Validate `.asc/workflow.json` before relying on it in CI.
- Verify current `asc` help when command syntax drifts.

## Closeout

Report the route, identifiers, artifact, preflight result, exact mutation performed, resulting state or IDs, blockers, and next manual action. Keep machine-readable JSON as evidence when available.
