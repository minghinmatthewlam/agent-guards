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
- `scripts/new-repo.sh`: bootstraps a fresh git repo with optional repo-local `AGENTS.md` / `CLAUDE.md`
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
| `teach` | Builds a code-grounded mental model through components, interfaces, and end-to-end steps |
| `architect` | Designs changes through explicit code ownership, dependency boundaries, data models, and caller interfaces |
| `autoreview` | Uses independent native subagents to review changes for concrete defects and unnecessary complexity |
| `explain-report` | Produces focused self-contained HTML reports for important project knowledge, research, code changes, learning, decisions, and accepted findings |

Task-specific skills:

| Skill | What it does |
|---|---|
| `skills-audit` | Audits a repo's skills against practical quality checks |
| `find-bugs` | Finds high-confidence correctness bugs and edge cases in existing code |
| `new-task` | Aligns on the goal and asks only questions that could change the outcome |
| `record-screen` | Records a UI change as a small MP4 proof: the private virtual display in Linux cloud sessions, only the app window on macOS |

## Cross-Tool Sync Model

One source repo fans out to Codex, Claude, and Cursor:

| Source | Codex destination | Claude destination | Cursor destination |
|---|---|---|---|
| `AGENTS.md` | `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` | — |
| `commands/*.md` | `~/.codex/prompts/` | `~/.claude/commands/` | — |
| `skills/*/` | `~/.agents/skills/` | `~/.claude/skills/` | `~/.cursor/skills/` |

To use these skills in Cursor Cloud Agents, enable **Settings → Agents → Context and Tools → Sync Skills for Cloud Agents** in Cursor after running the script. Cursor uploads personal skills from `~/.cursor/skills/`; it does not upload `~/.agents/skills/`. The script copies the full skill folders, including supporting files, into Cursor's sync directory.

Cursor moves uploaded skills into its managed User Context, so the local staging folders may disappear after syncing. Keep editing this source repo. The script's pruning only covers local files; remove retired cloud skills through Cursor's Customize UI.

`scripts/sync.sh` also:
- validates every `SKILL.md`, relative skill links, and this README's skill list before syncing
- warns when skills, commands, or `AGENTS.md` have uncommitted changes, since sync publishes the working tree
- skips command sync when a same-name skill exists
- prunes stale agent-guards-managed commands and skills by default
- skips `agent-only` skills for Claude
- compares skills uploaded to claude.ai (for cloud agents, as cached by Claude desktop) with this repo, and packages any out-of-date ones as zips in `~/.cache/agent-guards/upload/` for re-upload

## First-Time Setup

Prerequisites:
- `bash`
- `rsync`
- `ruby` for `./scripts/validate-skills.sh`
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
4. create an initial commit
5. optionally create and push a GitHub repo with `gh`

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
├── scripts/
├── skills/
└── templates/
```
