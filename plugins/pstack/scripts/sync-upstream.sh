#!/bin/bash
# Re-sync plugins/pstack from upstream cursor/plugins and re-apply the local patches.
#
# Usage: plugins/pstack/scripts/sync-upstream.sh <cursor-plugins-clone> [base-ref]
#
# Creates branch pstack-sync-<upstream-sha> from base-ref (default HEAD), replaces
# plugins/pstack with the clone's pstack/ directory, keeps the files this repo owns,
# commits that as the vendor commit, runs git am -3 on every patches/*.patch in order, applies
# normalize-invocation.sh to every skill (new upstream skills included), and restores a
# locally edited models.md.
# Nothing is pushed. On a conflict, resolve it, run git am --continue, then
# regenerate the patches with git format-patch.

set -euo pipefail

upstream="${1:?usage: sync-upstream.sh <cursor-plugins-clone> [base-ref]}"
base="${2:-HEAD}"
repo="$(git rev-parse --show-toplevel)"
plugin="$repo/plugins/pstack"
owned=(.codex-plugin .claude-plugin UPSTREAM.md patches scripts/sync-upstream.sh scripts/install.sh scripts/normalize-invocation.sh)

[ -d "$upstream/pstack/.cursor-plugin" ] || { echo "no pstack/ plugin under $upstream" >&2; exit 1; }
[ -z "$(git -C "$repo" status --porcelain)" ] || { echo "working tree is not clean" >&2; exit 1; }

sha="$(git -C "$upstream" rev-parse --short HEAD)"
branch="pstack-sync-$sha"
keep="$(mktemp -d)"
trap 'rm -rf "$keep"' EXIT

for path in "${owned[@]}"; do
	mkdir -p "$keep/$(dirname "$path")"
	cp -a "$plugin/$path" "$keep/$path"
done
[ -f "$plugin/models.md" ] && cp -a "$plugin/models.md" "$keep/models.md"

git -C "$repo" switch -c "$branch" "$base"
git -C "$repo" rm -rq plugins/pstack
rm -rf "$plugin"
mkdir -p "$plugin"
(cd "$upstream/pstack" && git ls-files -z | xargs -0 -I{} rsync -R -a {} "$plugin/")
for path in "${owned[@]}"; do
	mkdir -p "$plugin/$(dirname "$path")"
	cp -a "$keep/$path" "$plugin/$path"
done

git -C "$repo" add plugins/pstack
git -C "$repo" commit -q -m "Vendor pstack upstream $sha"
git -C "$repo" am -3 "$keep"/patches/*.patch
"$plugin/scripts/normalize-invocation.sh"
if [ -n "$(git -C "$repo" status --porcelain plugins/pstack/skills)" ]; then
	git -C "$repo" add plugins/pstack/skills
	git -C "$repo" commit -q -m "Normalize pstack skill invocation"
fi
if [ -f "$keep/models.md" ] && ! cmp -s "$keep/models.md" "$plugin/models.md"; then
	cp -a "$keep/models.md" "$plugin/models.md"
	git -C "$repo" add plugins/pstack/models.md
	git -C "$repo" commit -q -m "Keep local pstack models.md"
fi

echo "Synced pstack to upstream $sha on branch $branch."
echo "Update the commit in plugins/pstack/UPSTREAM.md and regenerate patches/ from the patch commits (not the normalize commit)."
