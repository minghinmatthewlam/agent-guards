#!/bin/bash
# Run one task in a native macOS app through Codex computer use.
#
# Usage: computer.sh "<task>"      or      echo "<task>" | computer.sh
# Env:   MYCOMP_CODEX_MODEL  model for codex exec (default: ~/.codex/config.toml)
#
# Prints only Codex's final message; the full log goes to $TMPDIR/mycomp-computer/last.log.
# Codex's Chrome control does not work from `codex exec` (only the Codex desktop app hands its
# sessions the browser-access pipe), so browser tasks belong to chrome.sh.

set -euo pipefail

task="${1:-}"
[ -n "$task" ] || [ -t 0 ] || task="$(cat)"
if [ -z "$task" ]; then
  echo 'usage: computer.sh "<task>"  (or pipe the task on stdin)' >&2
  exit 64
fi

workdir="${TMPDIR:-/tmp}/mycomp-computer"
mkdir -p "$workdir"
cd "$workdir"
log="$workdir/last.log"
final="$workdir/last-message.txt"
rm -f "$final"

prompt="Use computer use (the cua_repl tool) to do the task below on the user's Mac.
Rules:
- Touch only the apps the task needs. Quit apps you opened for the task unless it says to keep them open.
- Do not use Chrome or any web browser; browser control is unavailable here. If the task needs a browser, stop and reply exactly: NEEDS_BROWSER.
- Do not send, submit, buy, delete, or change settings unless the task explicitly asks for that exact action.
- Reply with the result only, plus any error text verbatim.

Task: $task"

args=(exec --skip-git-repo-check --ephemeral -o "$final")
[ -z "${MYCOMP_CODEX_MODEL:-}" ] || args+=(-m "$MYCOMP_CODEX_MODEL")

set +e
codex "${args[@]}" "$prompt" >"$log" 2>&1
code=$?
set -e

if [ -s "$final" ]; then
  cat "$final"
  [ -z "$(tail -c1 "$final")" ] || echo
  if grep -q 'NEEDS_BROWSER' "$final"; then
    echo "mycomp: this task needs a browser; use chrome.sh instead." >&2
    exit 3
  fi
else
  echo "mycomp: codex produced no final message (exit $code). Last log lines:" >&2
  tail -20 "$log" >&2
fi
exit "$code"
