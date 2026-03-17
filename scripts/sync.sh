#!/bin/bash
# Sync agent-guards to shared agent skill paths and tool-specific prompt files.
#
# Defaults:
# - Prune stale agent-guards-managed entries from destination paths.
# - Validate skill frontmatter before syncing.
#
# Flags:
#   --dry-run, -n  Preview actions without modifying files.
#   --no-prune     Do not remove stale agent-guards-managed entries.
#   --help, -h     Show usage.

set -euo pipefail

GUARDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_PROMPTS="$HOME/.codex/prompts"
CODEX_AGENTS="$HOME/.codex/AGENTS.md"
CLAUDE_COMMANDS="$HOME/.claude/commands"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CLAUDE_SKILLS="$HOME/.claude/skills"
AGENT_SKILLS="$HOME/.agents/skills"
LOCAL_BIN="$HOME/.local/bin"

CODEX_MANIFEST="$CODEX_PROMPTS/.agent-guards-managed-commands"
CLAUDE_MANIFEST="$CLAUDE_COMMANDS/.agent-guards-managed-commands"
AGENT_SKILLS_MANIFEST="$AGENT_SKILLS/.agent-guards-managed-skills"
CLAUDE_SKILLS_MANIFEST="$CLAUDE_SKILLS/.agent-guards-managed-skills"

DRY_RUN=false
PRUNE=true

usage() {
  cat <<'EOF'
Usage: ./scripts/sync.sh [--dry-run|-n] [--no-prune]

Syncs:
  - AGENTS.md -> ~/.codex/AGENTS.md, ~/.claude/CLAUDE.md
  - commands/*.md -> ~/.codex/prompts, ~/.claude/commands
  - skills/*/ -> ~/.agents/skills, ~/.claude/skills
  - external-skills.json -> installed via npx skills (global)

Behavior:
  - Validates SKILL.md frontmatter before syncing
  - Skips command sync when a same-name skill exists (skills take precedence)
  - Prunes stale entries previously managed by agent-guards (unless --no-prune)
  - Installs/updates external skills from external-skills.json via npx skills
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    --no-prune)
      PRUNE=false
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

log() {
  echo "$1"
}

mkdir_p() {
  if $DRY_RUN; then
    echo "  [dry-run] mkdir -p $1"
  else
    mkdir -p "$1"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"
  if $DRY_RUN; then
    echo "  [dry-run] ln -sf $src $dst"
  else
    ln -sf "$src" "$dst"
  fi
}

remove_path() {
  local path="$1"
  [ -e "$path" ] || [ -L "$path" ] || return 0
  if $DRY_RUN; then
    echo "  [dry-run] rm -rf $path"
  else
    rm -rf "$path"
  fi
}

is_agent_only() {
  local skill_md="$1/SKILL.md"
  [ -f "$skill_md" ] || return 1
  # Extract agent-only value from YAML frontmatter (between first two --- lines)
  local in_front=false
  while IFS= read -r line; do
    if [ "$line" = "---" ]; then
      if $in_front; then return 1; fi
      in_front=true
      continue
    fi
    if $in_front; then
      case "$line" in
        agent-only:*true*) return 0 ;;
      esac
    fi
  done < "$skill_md"
  return 1
}

list_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

prune_from_manifest() {
  local manifest="$1"
  local target_dir="$2"
  shift 2
  local current=("$@")

  $PRUNE || return 0
  [ -f "$manifest" ] || return 0

  local old
  while IFS= read -r old || [ -n "$old" ]; do
    [ -n "$old" ] || continue
    if ! list_contains "$old" "${current[@]}"; then
      remove_path "$target_dir/$old"
    fi
  done < "$manifest"
}

write_manifest() {
  local manifest="$1"
  shift
  local entries=("$@")

  if $DRY_RUN; then
    echo "  [dry-run] write manifest $manifest"
    return 0
  fi

  : > "$manifest"
  local entry
  for entry in "${entries[@]}"; do
    printf '%s\n' "$entry" >> "$manifest"
  done
}

sync_skills_to() {
  local target_dir="$1"
  shift
  local current_skills=("$@")
  local skill_name
  local src_dir
  for skill_name in "${current_skills[@]}"; do
    src_dir="$GUARDS_DIR/skills/$skill_name/"
    mkdir_p "$target_dir/$skill_name"
    if $DRY_RUN; then
      echo "  [dry-run] rsync -a --delete --copy-links --exclude .DS_Store $src_dir $target_dir/$skill_name/"
    else
      rsync -a --delete --copy-links --exclude ".DS_Store" "$src_dir" "$target_dir/$skill_name/"
    fi
  done
}

ensure_claude_skills_dir() {
  if [ -L "$CLAUDE_SKILLS" ]; then
    if $DRY_RUN; then
      echo "  [dry-run] rm $CLAUDE_SKILLS"
    else
      rm "$CLAUDE_SKILLS"
    fi
  fi

  if [ -e "$CLAUDE_SKILLS" ] && [ ! -d "$CLAUDE_SKILLS" ]; then
    local backup="${CLAUDE_SKILLS}.backup-$(date +%Y%m%d%H%M%S)"
    if $DRY_RUN; then
      echo "  [dry-run] mv $CLAUDE_SKILLS $backup"
    else
      mv "$CLAUDE_SKILLS" "$backup"
    fi
  fi

  mkdir_p "$CLAUDE_SKILLS"
}

log "Syncing agent-guards..."
if $DRY_RUN; then
  log "Mode: dry-run (no files will be modified)"
fi
if $PRUNE; then
  log "Prune: enabled (managed stale entries will be removed)"
else
  log "Prune: disabled"
fi

if [ -x "$GUARDS_DIR/scripts/validate-skills.sh" ]; then
  log "  Validating skills..."
  "$GUARDS_DIR/scripts/validate-skills.sh"
fi

shopt -s nullglob

mkdir_p "$CODEX_PROMPTS"
mkdir_p "$CLAUDE_COMMANDS"
mkdir_p "$AGENT_SKILLS"
mkdir_p "$LOCAL_BIN"

log "  Linking AGENTS.md..."
link_file "$GUARDS_DIR/AGENTS.md" "$CODEX_AGENTS"
link_file "$GUARDS_DIR/AGENTS.md" "$CLAUDE_MD"

log "  Linking scripts to PATH..."

log "  Ensuring ~/.claude/skills is a real directory..."
ensure_claude_skills_dir

current_skills=()
claude_skills=()
for skill_dir in "$GUARDS_DIR/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  current_skills+=("$name")
  if is_agent_only "$skill_dir"; then
    log "  Skill $name is agent-only (skipping Claude sync)"
  else
    claude_skills+=("$name")
  fi
done

log "  Syncing commands..."
current_commands=()
for cmd in "$GUARDS_DIR/commands"/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")
  base="${name%.md}"
  if list_contains "$base" "${current_skills[@]}"; then
    log "  Skipping command $name (covered by skill $base)"
    continue
  fi
  current_commands+=("$name")
  link_file "$cmd" "$CODEX_PROMPTS/$name"
  link_file "$cmd" "$CLAUDE_COMMANDS/$name"
done

prune_from_manifest "$CODEX_MANIFEST" "$CODEX_PROMPTS" "${current_commands[@]}"
prune_from_manifest "$CLAUDE_MANIFEST" "$CLAUDE_COMMANDS" "${current_commands[@]}"
write_manifest "$CODEX_MANIFEST" "${current_commands[@]}"
write_manifest "$CLAUDE_MANIFEST" "${current_commands[@]}"

log "  Syncing skills to ~/.agents/skills..."
sync_skills_to "$AGENT_SKILLS" "${current_skills[@]}"

log "  Syncing skills to ~/.claude/skills (excluding agent-only)..."
sync_skills_to "$CLAUDE_SKILLS" "${claude_skills[@]}"

prune_from_manifest "$AGENT_SKILLS_MANIFEST" "$AGENT_SKILLS" "${current_skills[@]}"
prune_from_manifest "$CLAUDE_SKILLS_MANIFEST" "$CLAUDE_SKILLS" "${claude_skills[@]}"
write_manifest "$AGENT_SKILLS_MANIFEST" "${current_skills[@]}"
write_manifest "$CLAUDE_SKILLS_MANIFEST" "${claude_skills[@]}"

external_count=0
EXTERNAL_SKILLS_FILE="$GUARDS_DIR/external-skills.json"
if [ -f "$EXTERNAL_SKILLS_FILE" ] && command -v npx &>/dev/null && command -v jq &>/dev/null; then
  log "  Installing/updating external skills..."
  while IFS= read -r entry; do
    source=$(echo "$entry" | jq -r '.source')
    skill=$(echo "$entry" | jq -r '.skill')
    if $DRY_RUN; then
      echo "  [dry-run] npx skills add $source -g --skill $skill"
    else
      if npx -y skills add "$source" -g -y -a claude-code --skill "$skill" </dev/null 2>/dev/null; then
        external_count=$((external_count + 1))
      else
        echo "  Warning: failed to install external skill $skill from $source" >&2
      fi
    fi
  done < <(jq -c '.[]' "$EXTERNAL_SKILLS_FILE")
elif [ -f "$EXTERNAL_SKILLS_FILE" ]; then
  echo "  Skipping external skills (requires npx and jq)"
fi

command_count=${#current_commands[@]}
skill_count=${#current_skills[@]}
claude_skill_count=${#claude_skills[@]}
agent_only_count=$((skill_count - claude_skill_count))

echo ""
echo "Done! Synced:"
echo "  - AGENTS.md -> ~/.codex/AGENTS.md, ~/.claude/CLAUDE.md"
echo "  - $command_count commands -> ~/.codex/prompts, ~/.claude/commands"
echo "  - $skill_count skills -> ~/.agents/skills"
echo "  - $claude_skill_count skills -> ~/.claude/skills ($agent_only_count agent-only skipped)"
echo "  - $external_count external skills (via npx skills)"
