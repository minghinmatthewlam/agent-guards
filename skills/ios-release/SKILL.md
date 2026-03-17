---
name: ios-release
description: "Run a preflight-gated iOS release workflow with asc for TestFlight and App Store: auth check, ID resolution, validation, blocker triage, then controlled publish/submit commands. Use when: (1) shipping to TestFlight, (2) preparing App Store submission, (3) diagnosing release blockers, (4) creating repeatable release playbooks."
---

# iOS Release (ASC)

## Goal
Use one release skill for both TestFlight and App Store flows with a strict gate:
- Phase A: read-only preflight
- Phase B: mutating execution (only after explicit approval)

## Reference map (load only when needed)
- `references/id-resolution-and-cli.md`: auth, output formats, ID lookup, pagination, timeouts.
- `references/testflight-orchestration.md`: groups, testers, notes, distribution operations.
- `references/submission-health.md`: encryption/compliance, metadata checks, submission error recovery.
- `references/workflow-automation.md`: `.asc/workflow.json` validation and CI-safe automation.

## Required inputs
- `APP_ID`
- `VERSION_ID` (for App Store validation/submission)
- `BUILD_ID` (for TestFlight validation/submission)
- IPA path for upload/publish flows

## Phase A: Preflight (read-only, default)

### 0) Auth and environment health
```bash
asc auth status --verbose
asc doctor
```

### 1) Resolve and verify release identifiers
```bash
asc apps list --limit 20 --output json
asc versions list --app "<APP_ID>" --limit 20 --output json
asc builds list --app "<APP_ID>" --limit 20 --output json
asc testflight beta-groups list --app "<APP_ID>" --output json
```

### 2) Pipeline state snapshot
```bash
asc status --app "<APP_ID>" --output json
asc review submissions-list --app "<APP_ID>" --limit 10 --output json
```

### 3) Validation gates
TestFlight gate:
```bash
asc validate testflight --app "<APP_ID>" --build "<BUILD_ID>" --output json
```

App Store gate:
```bash
asc validate --app "<APP_ID>" --version-id "<VERSION_ID>" --output json
```

If any validation returns blocking errors:
- stop execution mode
- return a prioritized blocker checklist
- include the exact remediation command or ASC UI field for each blocker
- if blockers involve encryption/content-rights/localizations, load `references/submission-health.md`

## Phase B: Execute (mutating; explicit approval required)

### Route 1: TestFlight publish
One-shot path:
```bash
asc publish testflight \
  --app "<APP_ID>" \
  --ipa "<PATH_TO_IPA>" \
  --group "<GROUP_ID_OR_NAME>" \
  --wait \
  --output json
```

Optional notes and notifications:
```bash
asc publish testflight \
  --app "<APP_ID>" \
  --ipa "<PATH_TO_IPA>" \
  --group "<GROUP_ID_OR_NAME>" \
  --test-notes "<WHAT_TO_TEST>" \
  --locale "en-US" \
  --wait \
  --notify \
  --output json
```

If validation flags missing beta review fields, see `references/submission-health.md` for review detail recovery commands.

### Route 2: App Store publish and submission
One-shot publish:
```bash
asc publish appstore \
  --app "<APP_ID>" \
  --ipa "<PATH_TO_IPA>" \
  --version "<VERSION_STRING>" \
  --wait \
  --output json
```

Publish and submit:
```bash
asc publish appstore \
  --app "<APP_ID>" \
  --ipa "<PATH_TO_IPA>" \
  --version "<VERSION_STRING>" \
  --wait \
  --submit \
  --confirm \
  --output json
```

Manual submission path:
```bash
asc submit create \
  --app "<APP_ID>" \
  --version-id "<VERSION_ID>" \
  --build "<BUILD_ID>" \
  --confirm \
  --output json

asc submit status --version-id "<VERSION_ID>" --output json
```

If validation flags missing app review fields, see `references/submission-health.md` for review detail recovery commands.

## Release checklist output format
For each release run, return:
- route (`testflight` or `appstore`)
- identifiers used (`APP_ID`, `VERSION_ID`, `BUILD_ID`)
- preflight status (pass/fail + blocker count)
- executed mutating commands
- resulting submission/build IDs
- next manual step (if any)

## Guardrails
- Never run mutating commands in preflight mode.
- Never submit (`--confirm`) without explicit user approval in the current session.
- Prefer deterministic IDs over names when both are available.
- Keep JSON output for machine-readability; use table only for quick human scans.
- If `.asc/workflow.json` exists, validate before CI use:
```bash
asc workflow validate
```
- If a step needs details not in this file, load only the relevant reference file from this skill.
