# App Store Submission Health

Use this reference when preflight fails or App Review state is unclear.

## 1) Build processing state
```bash
asc builds info --build "<BUILD_ID>" --output json
```
Check:
- `processingState` is `VALID`
- encryption flags are resolved

## 2) Export compliance (encryption)
If build requires encryption declaration:
```bash
asc encryption declarations list --app "<APP_ID>" --output json
```

```bash
asc encryption declarations create \
  --app "<APP_ID>" \
  --app-description "Uses standard HTTPS/TLS" \
  --contains-proprietary-cryptography=false \
  --contains-third-party-cryptography=true \
  --available-on-french-store=true \
  --output json
```

```bash
asc encryption declarations assign-builds \
  --id "<DECLARATION_ID>" \
  --build "<BUILD_ID>" \
  --output json
```

Preferred long-term fix when valid: set `ITSAppUsesNonExemptEncryption = NO` in Info.plist and rebuild.

## 3) Content rights declaration
```bash
asc apps get --id "<APP_ID>" --output json
asc apps update --id "<APP_ID>" --content-rights "DOES_NOT_USE_THIRD_PARTY_CONTENT" --output json
```

Valid values:
- `DOES_NOT_USE_THIRD_PARTY_CONTENT`
- `USES_THIRD_PARTY_CONTENT`

## 4) Version metadata completeness
```bash
asc versions get --version-id "<VERSION_ID>" --include-build --output json
asc versions update --version-id "<VERSION_ID>" --copyright "2026 Your Company" --output json
```

## 5) Localizations and app-info checks
```bash
asc localizations list --version "<VERSION_ID>" --output json
asc app-infos list --app "<APP_ID>" --output json
asc localizations list --app "<APP_ID>" --type app-info --app-info "<APP_INFO_ID>" --output json
```

## 6) Submission operations
Recommended:
```bash
asc review submissions-create --app "<APP_ID>" --platform IOS --output json
asc review items-add --submission "<SUBMISSION_ID>" --item-type appStoreVersions --item-id "<VERSION_ID>" --output json
asc review submissions-submit --id "<SUBMISSION_ID>" --confirm --output json
```

Alternative:
```bash
asc submit create --app "<APP_ID>" --version "<VERSION_STRING>" --build "<BUILD_ID>" --confirm --output json
```

Monitor and cancel:
```bash
asc submit status --id "<SUBMISSION_ID>" --output json
asc submit status --version-id "<VERSION_ID>" --output json
asc submit cancel --id "<SUBMISSION_ID>" --confirm --output json
```

## Common failure triage
- "Version is not in valid state":
  - verify build attached and `VALID`
  - verify encryption declaration
  - verify content rights
  - verify localizations/screenshots
- "Export compliance must be approved":
  - resolve encryption declaration or rebuild with exemption flag
- "Multiple app infos found":
  - call `asc app-infos list --app "<APP_ID>"` and pass explicit `--app-info`
