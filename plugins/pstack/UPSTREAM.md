# Upstream

- Repo: https://github.com/cursor/plugins
- Path: `pstack/`
- Commit: `11713c6` (Merge pull request #543 from santiagomed/cursor/x-encryption-status-quiet-2f0c)
- Author: Lauren Tan, MIT license (see `LICENSE`)

The vendor commit ("Vendor pstack upstream 11713c6") copies that directory byte for byte. Every local change lives in two later commits, saved as patches:

- `patches/01-tool-neutral.patch`: Cursor-only mechanics made to work in Codex and Claude Code.
- `patches/02-matthew.patch`: Matthew's workflow additions, each wrapped in `<!-- matthew: start -->` / `<!-- matthew: end -->`.

## Re-sync

1. Update a clone of `cursor/plugins` to the new upstream commit.
2. Run `plugins/pstack/scripts/sync-upstream.sh <path-to-cursor-plugins-clone>`. It creates a temp branch, re-copies `pstack/` into `plugins/pstack/`, commits it, and re-applies both patches with `git am -3`.
3. Resolve any conflicts, update the commit above, and regenerate the patches.
