# ASC Workflow Automation

Use this reference to encode repeatable release flows in repo-local workflow files.

## Core commands
```bash
asc workflow validate
asc workflow list
asc workflow run --dry-run beta
asc workflow run beta BUILD_ID:123 GROUP_ID:grp_abc
```

## File location
- Default: `.asc/workflow.json`
- Override: `asc workflow run --file ./path/workflow.json <name>`

## CI-safe contract
- `asc workflow validate` returns non-zero on invalid workflows.
- `asc workflow run` emits JSON on `stdout`.

Examples:
```bash
asc workflow validate | jq -e '.valid == true'
asc workflow run beta BUILD_ID:123 GROUP_ID:grp_abc | jq -e '.status == "ok"'
```

## Recommended rollout
1. Write/adjust `.asc/workflow.json`.
2. Validate syntax and references.
3. Dry-run target workflow.
4. Execute real run with explicit runtime params.

## Practical rules
- Keep IDs deterministic (`APP_ID`, `BUILD_ID`, `VERSION_ID`).
- Keep destructive operations explicit (`--confirm`).
- Avoid secrets in workflow file; pass via CI env vars.
- Keep hook steps (`before_all`, `after_all`, `error`) short and deterministic.
