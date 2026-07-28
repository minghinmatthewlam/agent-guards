# iOS Publish Commands

Load this reference only after selecting a release route. Mutating commands require explicit approval in the current session.

## Health And State

```bash
asc auth status --verbose
asc doctor
asc apps list --limit 20 --output json
asc versions list --app "<APP_ID>" --limit 20 --output json
asc builds list --app "<APP_ID>" --limit 20 --output json
asc status --app "<APP_ID>" --output json
asc review submissions-list --app "<APP_ID>" --limit 10 --output json
```

## Validation

TestFlight:

```bash
asc validate testflight --app "<APP_ID>" --build "<BUILD_ID>" --output json
```

App Store:

```bash
asc validate --app "<APP_ID>" --version-id "<VERSION_ID>" --output json
```

## TestFlight Publish

```bash
asc publish testflight \
  --app "<APP_ID>" \
  --ipa "<PATH_TO_IPA>" \
  --group "<GROUP_ID_OR_NAME>" \
  --wait \
  --output json
```

Optional approved notes and notification:

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

## App Store Publish

Upload and process:

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

Manual submission:

```bash
asc submit create \
  --app "<APP_ID>" \
  --version-id "<VERSION_ID>" \
  --build "<BUILD_ID>" \
  --confirm \
  --output json
asc submit status --version-id "<VERSION_ID>" --output json
```

## Workflow Validation

```bash
asc workflow validate
```
