#!/bin/bash
# Install ~/.claude/rules/pstack-models.md, the role file upstream's Claude Code adapter reads,
# as a copy of the git-tracked plugins/pstack/models.md in the main agent-guards checkout
# (never a worktree). Claude Code skips symlinked rule files, so this copies. If the installed
# copy differs from the tracked file, it stops and names the command for each direction.
# Removes the retired ~/.config/pstack/models.md link when it points at the tracked file.
#
# Usage: plugins/pstack/scripts/install.sh

set -euo pipefail

common="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --path-format=absolute --git-common-dir)"
main="$(dirname "$common")"
target="$main/plugins/pstack/models.md"
dest="$HOME/.claude/rules/pstack-models.md"
retired="$HOME/.config/pstack/models.md"

[ -f "$target" ] || { echo "missing $target; merge pstack into the main checkout first" >&2; exit 1; }
mkdir -p "$(dirname "$dest")"
[ -L "$dest" ] && rm "$dest"
if [ -f "$dest" ] && ! cmp -s "$dest" "$target"; then
	diff -u "$target" "$dest" >&2 || true
	echo "$dest differs from $target. Keep the installed roles: cp '$dest' '$target' and commit. Keep the tracked roles: cp '$target' '$dest'." >&2
	exit 1
fi
cp "$target" "$dest"
echo "$dest = $target"

if [ -L "$retired" ] && [ "$(readlink "$retired")" = "$target" ]; then
	rm "$retired"
	rmdir "$(dirname "$retired")" 2>/dev/null || true
	echo "removed $retired"
fi
