# agent-guards

Shared guardrails, skills, and bootstrap scripts for running serious agent workflows across Codex and Claude.

This repo is the source of truth for:
- one global `AGENTS.md` synced to both tools
- shared commands/prompts
- on-demand skills for repeated workflows
- repo bootstrap and sync scripts
- an opinionated agent operating model in [`docs/agent-philosophy.md`](docs/agent-philosophy.md)

## Why This Exists

Agent setups get bloated when the same rules appear in global prompts, skills, and repository documentation.

This repo keeps one simple operating model:
- read the code first;
- define and run a real verification path;
- make the correct repository path the easiest path;
- prevent important mistakes from recurring;
- report the important result and proof clearly.

If that framing resonates, start with [`AGENTS.md`](AGENTS.md) and [`docs/agent-philosophy.md`](docs/agent-philosophy.md).

## What You Get

- `AGENTS.md`: one global guardrail file, symlinked to both Codex and Claude
- `skills/`: reusable workflows for verification, repository setup, recurrence prevention, review, and specialized work
- `commands/`: shared prompt files that work in both ecosystems
- `scripts/sync.sh`: syncs guardrails, commands, and skills into the right user-level locations
- `scripts/new-repo.sh`: bootstraps a fresh repo with repo verification scaffolding and optional repo-local `AGENTS.md` / `CLAUDE.md`
- `templates/`: repo bootstrap files plus reusable loop contracts for recurring automations

## Notable Skills

Core workflow skills:

| Skill | What it does |
|---|---|
| `create-verification-skill` | Builds and proves a repo-local guide for running and checking the real product |
| `maintain-verification-skill` | Checks that guide against current code and live behavior, then repairs drift |
| `repo-setup` | Makes the intended architecture obvious and important violations fail mechanically |
| `learn-from-mistake` | Diagnoses an agent failure, strengthens the owning system, and retries the task |
| `concisely` | Keeps reports concise while surfacing important outcomes, evidence, and project learning |
| `autoreview` | Runs OpenClaw structured code review for local changes, branches, commits, and PRs |
| `explain-report` | Produces focused self-contained HTML reports for important project knowledge, research, code changes, learning, decisions, and accepted findings |

Task-specific skills:

| Skill | What it does |
|---|---|
| `skills-audit` | Audits a repo's skills against practical quality checks |

## Cross-Tool Sync Model

One source repo fans out to both ecosystems:

| Source | Codex destination | Claude destination |
|---|---|---|
| `AGENTS.md` | `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` |
| `commands/*.md` | `~/.codex/prompts/` | `~/.claude/commands/` |
| `skills/*/` | `~/.agents/skills/` | `~/.claude/skills/` |

`scripts/sync.sh` also:
- validates every `SKILL.md` before syncing
- skips command sync when a same-name skill exists
- prunes stale agent-guards-managed commands and skills by default
- skips `agent-only` skills for Claude
- installs external skills from [`external-skills.json`](external-skills.json) when `npx` and `jq` are available

## First-Time Setup

Prerequisites:
- `bash`
- `rsync`
- `ruby` for `./scripts/validate-skills.sh`
- `jq` and `npx` if you want external skills installed from `external-skills.json`
- `gh` if you want `new-repo.sh` to create a GitHub repo

```bash
git clone https://github.com/minghinmatthewlam/agent-guards.git
cd agent-guards
./scripts/sync.sh
```

Useful sync commands:

```bash
./scripts/sync.sh --dry-run
./scripts/sync.sh --no-prune
```

## Setting Up a New Repo

Use the setup wizard:

```bash
./scripts/new-repo.sh <repo-name>
```

It is interactive and will:
1. create the repo directory
2. run `git init`
3. create `.gitignore`
4. create `docs/VERIFY.md` and `scripts/self-test.sh`
5. create an initial commit
6. optionally create and push a GitHub repo with `gh`

If you want repo-local pointer files too:

```bash
./scripts/new-repo.sh --with-agents <repo-name>
```

`--with-agents` additionally creates:
- `AGENTS.md` from [`templates/repo-agents.md`](templates/repo-agents.md)
- `CLAUDE.md` as a symlink to `AGENTS.md` when possible, with a copy fallback otherwise

After the product has a working launch path, invoke `$repo-setup` and `$create-verification-skill`. They make the intended implementation path obvious and give agents a real way to prove the product works.

The template currently contains:

```markdown
Always read the global `AGENTS.md` (synced to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`) before any repo-specific instructions.

Before implementation, look for `.agents/skills/verify-*`. If none exists for the product surface, use the global `create-verification-skill`.
```

## Loop Templates

`templates/loops/` contains lightweight starting points for recurring agent work:

- `LOOP.md`: generic loop contract with concise reporting.
- `daily-priorities.md`: daily priority scan and top-three focus loop.
- `repo-verification.md`: improve a repo's verification skill and proof paths.
- `thread-introspection.md`: review recent agent usage for repeated struggles, verbose reports, missing proof, or skill/setup improvements. Treat this as propose-first by default; only edit the explicitly allowed subset of skills or templates.

## Editing This Repo

Source of truth:
- global guardrails: [`AGENTS.md`](AGENTS.md)
- skills: [`skills/`](skills/)
- commands: [`commands/`](commands/)
- philosophy: [`docs/agent-philosophy.md`](docs/agent-philosophy.md)

After changes:

```bash
./scripts/validate-skills.sh
python3 -m py_compile skills/autoreview/scripts/autoreview skills/autoreview/scripts/test-autoreview-unit.py skills/autoreview/scripts/test-review-harness.py
bash -n skills/autoreview/scripts/test-review-harness
./scripts/sync.sh --dry-run
./scripts/sync.sh
git status
```

## Repo Structure

```text
agent-guards/
├── AGENTS.md
├── commands/
├── docs/
├── external-skills.json
├── scripts/
├── skills/
└── templates/
```
