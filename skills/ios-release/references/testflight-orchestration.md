# TestFlight Orchestration

Use this reference for tester/group operations and post-upload distribution details.

## Export current TestFlight config
```bash
asc testflight sync pull --app "<APP_ID>" --output "./testflight.yaml"
asc testflight sync pull --app "<APP_ID>" --output "./testflight.yaml" --include-builds --include-testers
```

## Group and tester management

### Groups
```bash
asc testflight beta-groups list --app "<APP_ID>" --paginate --output json
asc testflight beta-groups create --app "<APP_ID>" --name "Beta Testers" --output json
```

### Testers
```bash
asc testflight beta-testers list --app "<APP_ID>" --paginate --output json
asc testflight beta-testers add --app "<APP_ID>" --email "tester@example.com" --group "<GROUP_ID_OR_NAME>" --output json
asc testflight beta-testers invite --app "<APP_ID>" --email "tester@example.com" --output json
```

## Build distribution
```bash
asc builds add-groups --build "<BUILD_ID>" --group "<GROUP_ID>" --output json
asc builds remove-groups --build "<BUILD_ID>" --group "<GROUP_ID>" --output json
```

## What to Test notes
```bash
asc builds test-notes create \
  --build "<BUILD_ID>" \
  --locale "en-US" \
  --whats-new "Test instructions" \
  --output json
```

```bash
asc builds test-notes update \
  --id "<LOCALIZATION_ID>" \
  --whats-new "Updated notes" \
  --output json
```

## Beta app review details
If validation flags missing Beta Review metadata:
```bash
asc testflight review get --app "<APP_ID>" --output json
asc testflight review update \
  --id "<BETA_REVIEW_DETAIL_ID>" \
  --contact-first-name "<FIRST>" \
  --contact-last-name "<LAST>" \
  --contact-email "<EMAIL>" \
  --contact-phone "<PHONE>" \
  --notes "<BETA_NOTES>" \
  --output json
```

## Guardrails
- Use IDs for deterministic operations.
- Use `--paginate` for large tester/group sets.
- Keep `--wait` on publish paths when you need a complete terminal status in one run.
