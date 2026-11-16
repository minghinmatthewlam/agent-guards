#!/bin/bash
# Run one task in the user's signed-in Chrome through the Claude CLI's Claude in Chrome tools.
#
# Usage: chrome.sh "<task>"      or      echo "<task>" | chrome.sh
# Env:   MYCOMP_CLAUDE_MODEL       model for the Claude CLI (default: the CLI's default)
#        MYCOMP_CLAUDE_CONFIG_DIR  Claude config dir (default: ~/.claude; used by tests)
#
# Claude in Chrome loads only for an Anthropic (claude.ai) login. The calling agent may run
# on OpenRouter, so this script strips every inherited ANTHROPIC_*/CLAUDE* variable and skips
# user settings (where the OpenRouter apiKeyHelper lives), leaving the keychain login.

set -euo pipefail

task="${1:-}"
[ -n "$task" ] || [ -t 0 ] || task="$(cat)"
if [ -z "$task" ]; then
  echo 'usage: chrome.sh "<task>"  (or pipe the task on stdin)' >&2
  exit 64
fi

for var in $(compgen -e | grep -E '^(ANTHROPIC_|CLAUDE)' || true); do unset "$var"; done
[ -z "${MYCOMP_CLAUDE_CONFIG_DIR:-}" ] || export CLAUDE_CONFIG_DIR="$MYCOMP_CLAUDE_CONFIG_DIR"

# A neutral cwd, so no project .claude/settings.json can bring an API key back.
workdir="${TMPDIR:-/tmp}/mycomp-chrome"
mkdir -p "$workdir"
cd "$workdir"

login_help='Fix: in a terminal run `claude --setting-sources project,local`, then type /login (Anthropic account, not OpenRouter).'

status="$(claude --setting-sources project,local auth status 2>&1 || true)"
if ! grep -q '"authMethod": "claude.ai"' <<<"$status"; then
  echo "mycomp: the Claude CLI is not signed in with an Anthropic account, so Claude in Chrome is unavailable." >&2
  echo "$login_help" >&2
  exit 2
fi

guard='You are operating the user'\''s real, signed-in Chrome. Use only the claude-in-chrome tools. Open your own tabs, and close the tabs you opened when you finish. Do not send, submit, post, buy, delete, or change account settings unless the task explicitly asks for that exact action. Opening an email or message marks it read, so read from list views when the task does not need the full text. Finish the whole task in this one session, then reply with the result only.'

args=(-p --chrome --setting-sources project,local
  --allowedTools mcp__claude-in-chrome
  --append-system-prompt "$guard")
[ -z "${MYCOMP_CLAUDE_MODEL:-}" ] || args+=(--model "$MYCOMP_CLAUDE_MODEL")

out="$(mktemp)"
trap 'rm -f "$out"' EXIT
# The prompt goes on stdin: --allowedTools is variadic and would swallow a trailing prompt.
set +e
printf '%s' "$task" | claude "${args[@]}" 2>&1 | tee "$out"
code=${PIPESTATUS[1]}
set -e

if grep -qiE 'OAuth session expired|not logged in|please run /login|invalid api key' "$out"; then
  echo "mycomp: the Anthropic login has expired." >&2
  echo "$login_help" >&2
  exit 2
fi
if grep -qiE 'no (chrome|browser)s? (is )?connected|extension (is )?not (connected|installed)' "$out"; then
  echo "mycomp: Chrome is not connected. Open Chrome and check the Claude extension is installed and signed in." >&2
  exit 3
fi
exit "$code"
