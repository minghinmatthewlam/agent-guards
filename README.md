# agent-guards

Shared guardrails, skills, and bootstrap scripts for running serious agent workflows across Codex and Claude.

This repo is the source of truth for:
- one global `AGENTS.md` synced to both tools
- shared commands/prompts
- on-demand skills for repeated workflows
- repo bootstrap and sync scripts
- an opinionated agent operating model in [`docs/agent-philosophy.md`](docs/agent-philosophy.md)

## Why This Exists

Most agent setups get bloated fast: long global prompts, duplicated config across tools, and too much workflow guidance inline.

This repo takes the opposite approach:
- keep global instruction files lean
- move repeated workflows into skills
- keep product context in the main session
- use parallel agents for research, implementation, cleanup, and review
- optimize for tools + success criteria, not micromanaged step-by-step prompts

If that framing resonates, start with [`AGENTS.md`](AGENTS.md) and [`docs/agent-philosophy.md`](docs/agent-philosophy.md).

## What You Get

- `AGENTS.md`: one global guardrail file, symlinked to both Codex and Claude
- `skills/`: reusable workflows like planning, self-test, review loops, CI repair, and iOS release work
- `commands/`: shared prompt files that work in both ecosystems
- `scripts/sync.sh`: syncs guardrails, commands, and skills into the right user-level locations
- `scripts/new-repo.sh`: bootstraps a fresh repo with optional repo-local `AGENTS.md` / `CLAUDE.md`
- `templates/repo-agents.md`: lightweight pointer template for repo-local instruction files

## Notable Skills

Core workflow skills:

| Skill | What it does |
|---|---|
| `orchestrator` | Runs the full clarify -> plan -> implement -> simplify -> review flow with agent teams |
| `plan-loop` | Hardens plans with parallel review before execution |
| `review-loop` | Reviews completed changes with multiple agents before shipping |
| `self-test` | Forces the agent to prove the real surface works before closing |
| `simplify` | Cleanup pass after implementation to remove unnecessary complexity |
| `audit-loop` | Read-only investigation with cross-checking and confidence gates |

Task-specific skills:

| Skill | What it does |
|---|---|
| `fix-ci` | Waits for checks, inspects failures, fixes issues, and loops until CI is green |
| `ios-dev` | Simulator-first iOS development and debugging workflow |
| `ios-release` | Preflight-gated TestFlight / App Store release workflow |
| `mcporter` | Calls MCP tools via CLI without loading server schemas into context |
| `oracle` | Bundles repo context for second-model consultation |
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
3. create `.gitignore` and `docs/.gitkeep`
4. create an initial commit
5. optionally create and push a GitHub repo with `gh`

If you want repo-local pointer files too:

```bash
./scripts/new-repo.sh --with-agents <repo-name>
```

`--with-agents` additionally creates:
- `AGENTS.md` from [`templates/repo-agents.md`](templates/repo-agents.md)
- `CLAUDE.md` as a symlink to `AGENTS.md` when possible, with a copy fallback otherwise

The template currently contains:

```markdown
Always read the global `AGENTS.md` (synced to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`) before any repo-specific instructions.
```

## Editing This Repo

Source of truth:
- global guardrails: [`AGENTS.md`](AGENTS.md)
- skills: [`skills/`](skills/)
- commands: [`commands/`](commands/)
- philosophy: [`docs/agent-philosophy.md`](docs/agent-philosophy.md)

After changes:

```bash
./scripts/validate-skills.sh
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
