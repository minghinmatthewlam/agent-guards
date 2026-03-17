# ASC CLI and ID Resolution

Use this reference when the release flow needs deterministic IDs or CLI behavior details.

## Command discovery
- `asc --help`
- `asc apps --help`
- `asc builds --help`

Always check `--help` for exact flags before execution.

## Output and pagination
- Default output is JSON.
- Use `--output table` only for quick human scanning.
- Use `--paginate` for full result sets when resolving IDs.
- Use `--pretty` only with JSON output.

## Auth and environment
- Keychain login:
```bash
asc auth login
asc auth status --verbose
```
- Common env vars:
  - `ASC_APP_ID`
  - `ASC_KEY_ID`
  - `ASC_ISSUER_ID`
  - `ASC_PRIVATE_KEY_PATH`
  - `ASC_PRIVATE_KEY` / `ASC_PRIVATE_KEY_B64`

## ID resolution playbook

### App ID
```bash
asc apps list --bundle-id "com.example.app" --output json
asc apps list --name "My App" --output json
```

### Version ID
```bash
asc versions list --app "<APP_ID>" --paginate --output json
```

### Build ID
```bash
asc builds latest --app "<APP_ID>" --version "1.2.3" --platform IOS --output json
asc builds list --app "<APP_ID>" --sort -uploadedDate --limit 10 --output json
```

### TestFlight Group/Tester IDs
```bash
asc testflight beta-groups list --app "<APP_ID>" --paginate --output json
asc testflight beta-testers list --app "<APP_ID>" --paginate --output json
```

### Submission IDs
```bash
asc review submissions-list --app "<APP_ID>" --paginate --output json
```

## Timeouts (long upload/processing flows)
- `ASC_TIMEOUT` or `ASC_TIMEOUT_SECONDS`
- `ASC_UPLOAD_TIMEOUT` or `ASC_UPLOAD_TIMEOUT_SECONDS`

## Guardrails
- Prefer IDs over names once resolved.
- Prefer bounded list commands (`--limit`) for quick checks, then `--paginate` if needed.
- Keep machine-facing steps in JSON for reproducibility.
