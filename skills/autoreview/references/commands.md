# Autoreview Commands

Load this reference when selecting a target, helper path, reviewer panel, or parallel test command.

## Targets

Dirty local work:

```bash
~/.agents/skills/autoreview/scripts/autoreview --mode local --engine codex
```

Branch or PR work:

```bash
~/.agents/skills/autoreview/scripts/autoreview --mode branch --base origin/main --engine codex
```

Use the PR's actual base when one exists:

```bash
base=$(gh pr view --json baseRefName --jq .baseRefName)
~/.agents/skills/autoreview/scripts/autoreview --mode branch --base "origin/$base" --engine codex
```

Committed change:

```bash
~/.agents/skills/autoreview/scripts/autoreview --mode commit --commit HEAD --engine codex
```

Optional context:

```bash
~/.agents/skills/autoreview/scripts/autoreview --mode branch --base origin/main \
  --prompt-file /tmp/review-notes.md --dataset /tmp/evidence.json
```

## Panels And Models

Codex plus Claude:

```bash
~/.agents/skills/autoreview/scripts/autoreview --reviewers codex,claude
```

`--panel` is shorthand for a two-engine panel. Use `--model` and `--thinking` only for explicit reproducibility or when requested. Inline reviewer syntax is also supported:

```bash
~/.agents/skills/autoreview/scripts/autoreview \
  --reviewers codex:gpt-5.1:high,claude:sonnet:max
```

## Parallel Tests

Formatting should run first when it can change line locations. Then tests may run alongside review:

```bash
~/.agents/skills/autoreview/scripts/autoreview \
  --parallel-tests "<focused test command>"
```

If either path causes edits, rerun the affected proof and review. On Windows, select `powershell` or `pwsh` with `--parallel-tests-shell` when needed.

## Other Useful Flags

- `--fail-on P0|P1|P2|P3` (default `P1`; the selected priority and anything higher exits nonzero)
- `--dry-run`
- `--no-web-search`
- `--no-tools`
- `--stream-engine-output`
- `--output` or `--json-output`
- `--prompt`, `--prompt-file`, or `--dataset`

Run `~/.agents/skills/autoreview/scripts/autoreview --help` for the authoritative current flag set.
