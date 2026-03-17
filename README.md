# agent-guards

Shared guardrails, commands, skills, and docs for AI agent workflows (Codex + Claude).

## First-Time Setup

```bash
git clone https://github.com/minghinmatthewlam/agent-guards.git
cd agent-guards
./scripts/sync.sh
```

The sync script:
1. Symlinks `AGENTS.md` to `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`
2. Symlinks all commands to `~/.codex/prompts/` and `~/.claude/commands/`
3. Copies skills to `~/.agents/skills/` and `~/.claude/skills/`
4. Prunes stale agent-guards-managed commands/skills by default
5. Skips syncing commands that have a same-name skill (skills take precedence)

## Setting Up a New Repo

Use the setup wizard:

```bash
./scripts/new-repo.sh <repo-name>
```

It creates:
- `.gitignore`
- `docs/.gitkeep`

Default mode assumes you use global config only (`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`).

If you want repo-local pointer files too:

```bash
./scripts/new-repo.sh --with-agents <repo-name>
```

`--with-agents` additionally creates:
- `AGENTS.md` from `templates/repo-agents.md`
- `CLAUDE.md` as a symlink to `AGENTS.md` (copy fallback if symlinks are unavailable)

`templates/repo-agents.md` currently contains:

```markdown
Always read the global `AGENTS.md` (synced to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`) before any repo-specific instructions.
```

Add project-specific content to repo `AGENTS.md` as needed.

## Structure

```
agent-guards/
├── AGENTS.md           # Global guardrails (symlinked to both tools)
├── commands/           # Shared commands (symlinked)
│   └── archive/        # Archived commands (not synced)
├── skills/             # Detailed workflow guidance
├── templates/          # Templates for new repos
└── scripts/            # Sync and utility scripts
```

## Synced Locations

| Source | Destination |
|---|---|
| `AGENTS.md` | `~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md` |
| `commands/*.md` | `~/.codex/prompts/`, `~/.claude/commands/` |
| `skills/*/` | `~/.agents/skills/`, `~/.claude/skills/` |

## Commands

Invoked with `/command-name`. Synced to both Codex and Claude unless a same-name skill exists.

| Command | Purpose |
|---------|---------|
| `/pickup` | Rehydrate context when resuming work |
| `/new-task` | Iterative clarification to 95% confidence |
| `/oracle` | Bundle files for second-model review |
| `/pr-comments-review` | Review PR comments |
| `/update-context` | Update config files with learnings |
| `/uithub` | Fetch GitHub repo context via UiThub |

Archived commands live in `commands/archive/` and are not synced by `scripts/sync.sh`.

## Skills

Extended guidance for complex workflows. Read by agents when relevant.

| Skill | Purpose |
|-------|---------|
| `ios-dev` | Simulator-first iOS dev loop (discover, build/test/run, logs, triage) |
| `ios-release` | Preflight-gated ASC release flow for TestFlight and App Store |
| `mcporter` | On-demand MCP tool calls without loading MCP context |
| `gh-fix-ci` | Debug and fix GitHub Actions |
| `oracle` | Detailed Oracle CLI patterns |
| `agent-browser` | Browser automation for verification and web workflows |
| `repoprompt` | Fast repo context building with RepoPrompt CLI |
| `audit-loop` | Lightweight read-only audit loop with evidence-first cross-model checks |
| `plan-loop` | Multi-round Codex+Claude planning hardening loop (plan-only, human sign-off before implementation) |
| `review-loop` | Post-implementation Codex+Claude review/fix hardening loop |
| `test-criteria` | Autonomous phase-by-phase execution with end-to-end verification and blocker surfacing |

## Editing

| What | Where |
|------|-------|
| Global guardrails | `AGENTS.md` |
| Commands | `commands/*.md` then `./scripts/sync.sh` |
| Skills | `skills/*/SKILL.md` |
| Per-repo config | Optional: add `AGENTS.md` + `CLAUDE.md` only when repo-local guidance is needed |

## After Changes

```bash
./scripts/validate-skills.sh
./scripts/sync.sh --dry-run
./scripts/sync.sh
git status
# then commit + push
```

Sync options:
- `./scripts/sync.sh --dry-run` previews changes with no filesystem writes.
- `./scripts/sync.sh --no-prune` disables stale managed entry cleanup.

## How Commands Work

Commands are prompt templates. When you invoke `/command-name`:
1. Tool finds the matching `.md` file
2. File content is injected as instructions
3. `$ARGUMENTS` is replaced with user input
4. Agent follows the instructions

Both Codex and Claude use the same format — one file works for both.
