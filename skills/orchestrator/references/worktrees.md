# Worktree Lifecycle

Worktrees are isolation resources, not the default worker target.

## Choose And Create

- Use the shared checkout for read-only work and one safe edit worker when no other worker or live process owns it and its status is understood.
- Use a worktree for concurrent editors, risky experiments, conflicting branches, or independently reviewable work.
- Inspect `git worktree list --porcelain` before creating one. Reuse only a registered worktree owned by the same task and branch with no active user or process.
- Let Codex App manage its own worktree location.
- For manual Claude/Pi worktrees, preallocate a task id and use `<repo>/.worktrees/<task>-<id>/` with branch `agent/<task>-<id>`.
- Resolve and record the exact integration-base commit before manual creation. Use the task branch, verified default branch, or predecessor branch according to dependency.

Before the first repo-local worktree, ensure `/.worktrees/` exists in the local exclude file returned by `git rev-parse --git-path info/exclude`. Do not change committed `.gitignore` only for agent infrastructure.

Create and validate a manual worktree before spawning: registered path, expected branch, clean status, and worker cwd must agree.

## Operate And Close

- Record owner, path, purpose, and retained reason in orchestration status.
- Keep `.worktrees/` out of recursive search, watchers, formatters, test discovery, and bulk operations.
- Never run `git clean -x` or an equivalent cleaner against a parent checkout with registered nested worktrees.
- Worker completion does not authorize removal.
- Remove only after acceptance, external proof preservation, no live user/process, and integration or other preservation of wanted work.
- Use `git worktree remove <path>` without `--force`; never `rm -rf`.
- Use `git worktree prune --dry-run --verbose` before pruning suspected stale registrations.
- Remove nested worktrees before moving or deleting the parent repository.
- Report retained and removed worktrees at closeout.
