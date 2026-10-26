# Upstream

- Repo: https://github.com/cursor/plugins
- Path: `pstack/`
- Commit: `99b609a` (Merge pull request #810 from cursor/eliu/tailscale-skill-1.0.3)
- Author: Lauren Tan, MIT license (see `LICENSE`)

The vendor commit ("Vendor pstack upstream 99b609a") copies that directory byte for byte. Every local change lives in later commits, saved as patches and applied in order. Each patch line exists because upstream leaves something broken in Claude Code or Codex, or because Matthew asked for it (02). Where upstream covers a fix, take upstream's version.

- `patches/01-tool-neutral.patch`: upstream's `docs/harness/claude-code.md` maps Cursor names to Claude Code. The patch points poteto-mode at it (upstream adds that pointer only in its generated harness tree), names Codex's role file and transcripts (upstream has no Codex adapter), runs non-Claude roles through a cross-provider tool instead of the session model (so the two-family review panel stays two families), and makes `worktree-audit.sh` search Claude Code and Codex transcripts.
- `patches/02-matthew.patch`: Matthew's workflow rules, each between `<!-- matthew: start -->` and `<!-- matthew: end -->`. The rules live once, in `playbooks/opening-a-pr.md`; every other playbook that merges carries the same one-line pointer.
- `patches/03-verification-skills.patch`: the verification skills write to `.agents/skills/` with a `.claude/skills/` symlink, because neither tool reads upstream's `.cursor/skills/`.

## Invocation

Upstream sets `disable-model-invocation: true` on 57 of 58 skills. In Claude Code that blocks the Skill tool, so the poteto-reminder hook's "load poteto-mode" fails. Codex ignores the flag and would invoke every skill implicitly. `scripts/normalize-invocation.sh` owns the replacement rule, not a patch, so it also covers skills upstream adds later:

- No skill sets `disable-model-invocation`.
- Every skill except `poteto-mode`, `poteto-help`, `setup-pstack`, `make-bot-ui`, `automate-me`, `create-verification-skill`, and `maintain-verification-skill` sets `user-invocable: false` and has `allow_implicit_invocation: false` in `agents/openai.yaml`.

`sync-upstream.sh` runs it after the patches and commits the result as "Normalize pstack skill invocation". CI runs it with `--check`. To change the entry list, edit `ENTRY_SKILLS` in the script and run it.

## Verification skills

`skills/create-verification-skill` and `skills/maintain-verification-skill` at the repo root are symlinks to this plugin's copies. `scripts/sync.sh` copies with `--copy-links`, so the global installs stay real directories that work without the plugin.

## Model roles

`models.md` holds Matthew's roles. It is owned by this repo, not a patch, so a sync never touches it. Upstream's Claude Code adapter reads the role file at `~/.claude/rules/pstack-models.md`, and Claude Code loads every file in `~/.claude/rules/` into each session. Claude Code skips symlinked rule files, so `plugins/pstack/scripts/install.sh` copies `plugins/pstack/models.md` from the main `~/dev/agent-guards` checkout to that path. The tracked file is the source of truth. Run the script after changing the tracked file. After `/setup-pstack` writes the installed copy, the script refuses to overwrite it and prints the `cp` that brings the change back to the tracked file, which you then commit. Codex has no upstream role path, so patch 01 points Codex at the same file.

## How a plugin change reaches each tool

Both tools run a cached copy of the plugin, not this directory.

- Codex: edit in `~/dev/agent-guards`, commit, then run `codex plugin add pstack@agent-guards`. That re-copies the plugin into `~/.codex/plugins/cache/agent-guards/pstack/<version>/`. Start a new Codex session. The marketplace is `[marketplaces.agent-guards]` in `~/.codex/config.toml`, a local source at `/Users/matthewlam/dev/agent-guards`.
- Claude Code: install once with `claude plugin marketplace add /Users/matthewlam/dev/agent-guards`, then `claude plugin install pstack@agent-guards`. After a change, run `claude plugin marketplace update agent-guards`, then `claude plugin update pstack@agent-guards`, and start a new session. `update` skips the change while `version` in `.claude-plugin/plugin.json` is unchanged; bump it, or run `claude plugin uninstall pstack@agent-guards` then `claude plugin install pstack@agent-guards`.
- Cursor: copy the plugin with `rsync -a --delete plugins/pstack/ ~/.cursor/plugins/local/pstack/`.
- A `models.md` change needs no plugin refresh. Run `install.sh` to copy it to `~/.claude/rules/pstack-models.md`; Claude Code and Codex read it there from the next new session.

## Re-sync

1. Update a clone of `cursor/plugins` to the new upstream commit.
2. Run `plugins/pstack/scripts/sync-upstream.sh <path-to-cursor-plugins-clone>`. It creates a temp branch, re-copies `pstack/` into `plugins/pstack/`, commits it, re-applies every patch with `git am -3`, and runs `normalize-invocation.sh`.
3. Resolve any conflicts, update the commit above, and regenerate the patches from the three patch commits, not the normalize commit: `git format-patch --zero-commit --no-signature <vendor-commit>..<last-patch-commit>`.
