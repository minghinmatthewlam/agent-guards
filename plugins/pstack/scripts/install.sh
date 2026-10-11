#!/bin/bash
# Link ~/.config/pstack/models.md to the git-tracked plugins/pstack/models.md in the
# main agent-guards checkout (never a worktree), so pstack skills find it from any repo.
#
# Usage: plugins/pstack/scripts/install.sh

set -euo pipefail

common="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --path-format=absolute --git-common-dir)"
main="$(dirname "$common")"
target="$main/plugins/pstack/models.md"
link="$HOME/.config/pstack/models.md"

[ -f "$target" ] || { echo "missing $target; merge pstack into the main checkout first" >&2; exit 1; }
mkdir -p "$(dirname "$link")"
if [ -e "$link" ] && [ ! -L "$link" ]; then
	echo "$link exists and is not a symlink; move it aside first" >&2
	exit 1
fi
ln -sfn "$target" "$link"
echo "$link -> $(readlink "$link")"
