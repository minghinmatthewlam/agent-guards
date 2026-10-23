#!/bin/bash
# Run sync.sh against a throwaway HOME and a copy of this repo, then check the result.
# Covers: validation under a non-UTF-8 locale, skill/command/AGENTS.md destinations,
# agent-only exclusion from Claude, pruning of retired managed skills,
# detection of out-of-date skills uploaded to claude.ai, and the poteto-reminder
# hook: entries merged into Claude and Codex config, re-sync as a no-op, and the
# script staying silent outside T3 or outside its scoped folders.

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

# Fixture: Claude settings with unrelated keys, other hooks, and an old poteto-reminder entry.
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/settings.json" <<'EOF'
{
  "enabledPlugins": {"pstack@agent-guards": true},
  "hooks": {
    "SessionStart": [
      {"matcher": "startup", "hooks": [{"type": "command", "command": "/other/session-hook.sh"}]},
      {"matcher": "startup|compact|clear", "hooks": [{"type": "command", "command": "/old/place/poteto-reminder.py"}]}
    ],
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "/other/bash-guard.sh"}]}]
  }
}
EOF

LC_ALL=C LANG=C "$SRC/scripts/sync.sh" --dry-run > "$WORK/dry-run.log"
dry_run_wrote_codex_hooks=false
[ -e "$HOME/.codex/hooks.json" ] && dry_run_wrote_codex_hooks=true

LC_ALL=C LANG=C "$SRC/scripts/sync.sh" > "$WORK/sync.log"

hook_snapshot() {
  { cat "$HOME/.claude/settings.json" "$HOME/.codex/hooks.json" \
    "$HOME/.claude/hooks"/poteto-reminder.* "$HOME/.codex/hooks"/poteto-reminder.* 2>/dev/null || true; } | shasum
}
first_snapshot="$(hook_snapshot)"
LC_ALL=C LANG=C "$SRC/scripts/sync.sh" > "$WORK/resync.log"
second_snapshot="$(hook_snapshot)"

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

registers_hook() {
  python3 - "$1" "$2" <<'EOF'
import json, sys
path, command = sys.argv[1:]
hooks = json.load(open(path))["hooks"]
ours = lambda event: [g for g in hooks.get(event, []) if any("poteto-reminder.py" in h["command"] for h in g["hooks"])]
handler = [{"type": "command", "command": command}]
assert ours("SessionStart") == [{"matcher": "startup|compact|clear", "hooks": handler}], ours("SessionStart")
assert ours("UserPromptSubmit") == [{"hooks": handler}], ours("UserPromptSubmit")
EOF
}

keeps_unrelated_settings() {
  python3 - "$HOME/.claude/settings.json" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
assert d["enabledPlugins"] == {"pstack@agent-guards": True}
assert [g["hooks"][0]["command"] for g in d["hooks"]["PreToolUse"]] == ["/other/bash-guard.sh"]
assert d["hooks"]["SessionStart"][0] == {"matcher": "startup", "hooks": [{"type": "command", "command": "/other/session-hook.sh"}]}
EOF
}

run_hook() {
  local tool="$1" cwd="$2"
  printf '{"cwd": "%s", "hook_event_name": "UserPromptSubmit"}' "$cwd" |
    env -u T3CODE_CLI_PATH "$HOME/.$tool/hooks/poteto-reminder.py" "$tool"
}

reminds() {
  run_hook "$1" "$HOME/dev/ori/apps" | python3 -c '
import json, sys
out = json.load(sys.stdin)["hookSpecificOutput"]
assert out == {"hookEventName": "UserPromptSubmit", "additionalContext": "Follow pstack'"'"'s /poteto-mode strictly"}, out'
}

mkdir -p "$HOME/dev/ori/apps" "$HOME/dev/ori-other"

check "Claude settings register the synced hook once per event" \
  "registers_hook '$HOME/.claude/settings.json' '$HOME/.claude/hooks/poteto-reminder.py claude'"
check "Codex hooks.json registers the synced hook once per event" \
  "registers_hook '$HOME/.codex/hooks.json' '$HOME/.codex/hooks/poteto-reminder.py codex'"
check "Claude settings keep unrelated keys and hooks" "keeps_unrelated_settings"
check "dry-run previews the Codex hook merge" \
  "grep -qF '[dry-run] merge poteto-reminder hooks into $HOME/.codex/hooks.json' '$WORK/dry-run.log'"
check "dry-run writes no Codex hooks.json" "! $dry_run_wrote_codex_hooks"
check "second sync leaves hook files and config unchanged" "[ '$first_snapshot' = '$second_snapshot' ]"
check "second sync reports both hook configs current" "[ \"\$(grep -c 'Hooks already current' '$WORK/resync.log')\" = 2 ]"
check "hook reminds Claude in scope outside T3" "reminds claude"
check "hook reminds Codex in scope outside T3" "reminds codex"
check "hook is silent out of scope" "[ -z \"\$(run_hook claude '$WORK')\" ]"
check "hook is silent in a sibling folder sharing the prefix" "[ -z \"\$(run_hook codex '$HOME/dev/ori-other')\" ]"

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed. sync.sh output:" >&2
  cat "$WORK/sync.log" "$WORK/resync.log" >&2
  exit 1
fi
echo "sync smoke test passed"
