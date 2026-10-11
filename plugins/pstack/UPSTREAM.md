# Upstream

- Repo: https://github.com/cursor/plugins
- Path: `pstack/`
- Commit: `11713c6` (Merge pull request #543 from santiagomed/cursor/x-encryption-status-quiet-2f0c)
- Author: Lauren Tan, MIT license (see `LICENSE`)

The vendor commit ("Vendor pstack upstream 11713c6") copies that directory byte for byte. Every local change lives in two later commits, saved as patches:

- `patches/01-tool-neutral.patch`: the tool-neutral fixes for Codex and Claude Code, `models.md`, and the Codex `agents/openai.yaml` policies that turn off implicit invocation.
- `patches/02-matthew.patch`: Matthew's workflow additions, each wrapped in `<!-- matthew: start -->` / `<!-- matthew: end -->`.

## Model roles

Skills read `~/.config/pstack/models.md`. Run `plugins/pstack/scripts/install.sh` once per machine. It links that path to `plugins/pstack/models.md` in the main `~/dev/agent-guards` checkout, so `/setup-pstack` edits the tracked file. Commit the change there.

## How a plugin change reaches each tool

Both tools run a cached copy of the plugin, not this directory.

- Codex: edit in `~/dev/agent-guards`, commit, then run `codex plugin add pstack@agent-guards`. That re-copies the plugin into `~/.codex/plugins/cache/agent-guards/pstack/<version>/`. Start a new Codex session. The marketplace is `[marketplaces.agent-guards]` in `~/.codex/config.toml`, a local source at `/Users/matthewlam/dev/agent-guards`.
- Claude Code: install once with `claude plugin marketplace add /Users/matthewlam/dev/agent-guards`, then `claude plugin install pstack@agent-guards`. After a change, run `claude plugin marketplace update agent-guards`, then `claude plugin update pstack@agent-guards`, and start a new session.
- A `models.md` change needs no refresh, because skills read it through the `~/.config/pstack` symlink.

## Re-sync

1. Update a clone of `cursor/plugins` to the new upstream commit.
2. Run `plugins/pstack/scripts/sync-upstream.sh <path-to-cursor-plugins-clone>`. It creates a temp branch, re-copies `pstack/` into `plugins/pstack/`, commits it, re-applies both patches with `git am -3`, and keeps a locally edited `models.md`.
3. Resolve any conflicts, update the commit above, and regenerate the patches.
