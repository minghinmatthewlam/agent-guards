# Upstream

- Repo: https://github.com/cursor/plugins
- Path: `pstack/`
- Commit: `11713c6` (Merge pull request #543 from santiagomed/cursor/x-encryption-status-quiet-2f0c)
- Author: Lauren Tan, MIT license (see `LICENSE`)

The vendor commit ("Vendor pstack upstream 11713c6") copies that directory byte for byte. Every local change lives in later commits, saved as patches and applied in order:

- `patches/01-tool-neutral.patch`: fixes so pstack works in Codex and Claude Code, `models.md`, and the Codex `agents/openai.yaml` policies.
- `patches/02-matthew.patch`: Matthew's workflow rules, each between `<!-- matthew: start -->` and `<!-- matthew: end -->`. The rules live once, in `playbooks/opening-a-pr.md`; every other playbook that merges carries the same one-line pointer.
- `patches/03-verification-skills.patch`: the two verification skills adapted for Codex and Claude Code.

## Invocation

Upstream sets `disable-model-invocation: true` on 50 of 51 skills. In Claude Code that blocks the Skill tool and subagent preloading, so poteto-mode could not load the skills it routes to. `scripts/normalize-invocation.sh` owns the replacement rule, not a patch, so it also covers skills upstream adds later:

- No skill sets `disable-model-invocation`.
- Every skill except `poteto-mode`, `poteto-help`, `setup-pstack`, `make-bot-ui`, `automate-me`, `create-verification-skill`, and `maintain-verification-skill` sets `user-invocable: false` and has `allow_implicit_invocation: false` in `agents/openai.yaml`.

`sync-upstream.sh` runs it after the patches and commits the result as "Normalize pstack skill invocation". CI runs it with `--check`. To change the entry list, edit `ENTRY_SKILLS` in the script and run it. `agents/poteto-agent.md` preloads `poteto-mode` with `skills:` (patch 01).

## Verification skills

`skills/create-verification-skill` and `skills/maintain-verification-skill` at the repo root are symlinks to this plugin's copies. `scripts/sync.sh` copies with `--copy-links`, so the global installs stay real directories that work without the plugin.

## Model roles

Skills read `~/.config/pstack/models.md`. Run `plugins/pstack/scripts/install.sh` once per machine. It links that path to `plugins/pstack/models.md` in the main `~/dev/agent-guards` checkout, so `/setup-pstack` edits the tracked file. Commit the change there.

## How a plugin change reaches each tool

Both tools run a cached copy of the plugin, not this directory.

- Codex: edit in `~/dev/agent-guards`, commit, then run `codex plugin add pstack@agent-guards`. That re-copies the plugin into `~/.codex/plugins/cache/agent-guards/pstack/<version>/`. Start a new Codex session. The marketplace is `[marketplaces.agent-guards]` in `~/.codex/config.toml`, a local source at `/Users/matthewlam/dev/agent-guards`.
- Claude Code: install once with `claude plugin marketplace add /Users/matthewlam/dev/agent-guards`, then `claude plugin install pstack@agent-guards`. After a change, run `claude plugin marketplace update agent-guards`, then `claude plugin update pstack@agent-guards`, and start a new session. `update` skips the change while `version` in `.claude-plugin/plugin.json` is unchanged; bump it, or run `claude plugin uninstall pstack@agent-guards` then `claude plugin install pstack@agent-guards`.
- Cursor: copy the plugin with `rsync -a --delete plugins/pstack/ ~/.cursor/plugins/local/pstack/`.
- A `models.md` change needs no refresh, because skills read it through the `~/.config/pstack` symlink.

## Re-sync

1. Update a clone of `cursor/plugins` to the new upstream commit.
2. Run `plugins/pstack/scripts/sync-upstream.sh <path-to-cursor-plugins-clone>`. It creates a temp branch, re-copies `pstack/` into `plugins/pstack/`, commits it, re-applies both patches with `git am -3`, and keeps a locally edited `models.md`.
3. Resolve any conflicts, update the commit above, and regenerate the patches from the two patch commits, not the normalize commit.
