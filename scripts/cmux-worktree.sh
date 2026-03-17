#!/bin/bash
# Opens a new cmux workspace with a git worktree.
# Usage: wtree <branch-name> [base-branch]

set -e

show_help() {
  cat <<'EOF'
Usage: wtree <branch-name> [base-branch]

Open a git worktree in a new cmux workspace.

Arguments:
  branch-name   Branch to create or check out
  base-branch   Base branch to create from (default: HEAD)

Examples:
  wtree feature/new-thing          # branch from HEAD
  wtree feature/new-thing main     # branch from main
  wtree fix/bug develop            # branch from develop

Worktrees are created at <repo>-worktrees/<branch-name>/
EOF
  exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help
branch="${1:?Usage: wtree <branch-name> [base-branch] (use --help for more info)}"
base="${2:-HEAD}"

# Must be in a git repo
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: not in a git repository" >&2
  exit 1
}
repo_name="$(basename "$repo_root")"
worktree_dir="${repo_root}-worktrees/${branch##*/}"

# Create the worktree if it doesn't exist
if [ ! -d "$worktree_dir" ]; then
  git worktree add "$worktree_dir" -b "$branch" "$base" 2>/dev/null \
    || git worktree add "$worktree_dir" "$branch"
fi

# Open a new workspace, then cd into the worktree via send
ws_id="$(cmux new-workspace | awk '{print $2}')"
cmux rename-workspace --workspace "$ws_id" "${repo_name}/${branch##*/}" >/dev/null
cmux select-workspace --workspace "$ws_id" >/dev/null
sleep 0.3
cmux send --workspace "$ws_id" "cd '$worktree_dir' && clear" >/dev/null
cmux send-key --workspace "$ws_id" enter >/dev/null
