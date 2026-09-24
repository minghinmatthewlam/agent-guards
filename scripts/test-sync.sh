#!/bin/bash
# Run sync.sh against a throwaway HOME and a copy of this repo, then check the result.
# Covers: validation under a non-UTF-8 locale, skill/command/AGENTS.md destinations,
# agent-only exclusion from Claude, pruning of retired managed skills, and
# detection of out-of-date skills uploaded to claude.ai.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

SRC="$WORK/agent-guards"
export HOME="$WORK/home"
mkdir -p "$HOME"
rsync -a --exclude .git "$REPO_ROOT/" "$SRC/"

# Fixture: an agent-only skill must reach ~/.agents/skills but not ~/.claude/skills.
mkdir -p "$SRC/skills/agent-only-fixture"
cat > "$SRC/skills/agent-only-fixture/SKILL.md" <<'EOF'
---
name: agent-only-fixture
description: "Test fixture."
agent-only: true
---
EOF
echo '`agent-only-fixture`' >> "$SRC/README.md"

# Fixture: a skill recorded as managed by a previous sync, now retired.
for dir in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.cursor/skills"; do
  mkdir -p "$dir/retired-skill" "$dir/user-owned-skill"
  echo "retired-skill" > "$dir/.agent-guards-managed-skills"
done

# Fixture: claude.ai uploaded-skill cache with one current and one stale skill.
CACHE="$HOME/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/a/b/skills"
mkdir -p "$CACHE"
cp -R "$SRC/skills/find-bugs" "$SRC/skills/teach" "$CACHE/"
echo "old line" >> "$CACHE/teach/SKILL.md"

LC_ALL=C LANG=C "$SRC/scripts/sync.sh" > "$WORK/sync.log"

failures=0
check() {
  if eval "$2"; then
    echo "ok   - $1"
  else
    echo "FAIL - $1" >&2
    failures=$((failures + 1))
  fi
}

skills=()
for skill_dir in "$REPO_ROOT"/skills/*/; do
  skills+=("$(basename "$skill_dir")")
done

for skill in "${skills[@]}"; do
  for dir in .agents/skills .claude/skills .cursor/skills; do
    check "$dir/$skill synced" "[ -f '$HOME/$dir/$skill/SKILL.md' ]"
  done
done

check "AGENTS.md linked for Codex" "[ '$(readlink "$HOME/.codex/AGENTS.md")' = '$SRC/AGENTS.md' ]"
check "AGENTS.md linked for Claude" "[ '$(readlink "$HOME/.claude/CLAUDE.md")' = '$SRC/AGENTS.md' ]"
for cmd in "$REPO_ROOT"/commands/*.md; do
  name="$(basename "$cmd")"
  check "command $name linked for Claude" "[ -L '$HOME/.claude/commands/$name' ]"
done

check "agent-only skill synced to ~/.agents" "[ -f '$HOME/.agents/skills/agent-only-fixture/SKILL.md' ]"
check "agent-only skill excluded from ~/.claude" "[ ! -e '$HOME/.claude/skills/agent-only-fixture' ]"

for dir in .agents/skills .claude/skills .cursor/skills; do
  check "$dir retired managed skill pruned" "[ ! -e '$HOME/$dir/retired-skill' ]"
  check "$dir unmanaged skill kept" "[ -d '$HOME/$dir/user-owned-skill' ]"
done

check "stale uploaded skill packaged" "[ -f '$HOME/.cache/agent-guards/upload/teach.zip' ]"
check "current uploaded skill not packaged" "[ ! -e '$HOME/.cache/agent-guards/upload/find-bugs.zip' ]"
check "stale uploaded skill reported" "grep -q -- '- teach ->' '$WORK/sync.log'"

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed. sync.sh output:" >&2
  cat "$WORK/sync.log" >&2
  exit 1
fi
echo "sync smoke test passed"
