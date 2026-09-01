#!/usr/bin/env bash
set -euo pipefail

mode="${1:-default}"

run_if_present() {
  local cmd="$1"
  local name="$2"

  if eval "$cmd"; then
    echo "[self-test] passed: $name"
  else
    echo "[self-test] failed: $name" >&2
    return 1
  fi
}

node_package_manager() {
  if command -v pnpm >/dev/null 2>&1 && [ -f pnpm-lock.yaml ]; then
    echo "pnpm"
  elif command -v npm >/dev/null 2>&1; then
    echo "npm"
  else
    return 1
  fi
}

node_has_script() {
  local script="$1"
  node -e 'const p = require("./package.json"); process.exit(p.scripts?.[process.argv[1]] ? 0 : 1)' "$script"
}

run_node_script() {
  local script="$1"
  local manager

  if ! manager="$(node_package_manager)"; then
    echo "[self-test] no Node package manager available." >&2
    return 2
  fi

  "$manager" run "$script"
  echo "[self-test] passed: $manager run $script"
}

run_node_default() {
  local script
  local checks_run=0

  for script in lint test build; do
    if node_has_script "$script"; then
      run_node_script "$script"
      checks_run=$((checks_run + 1))
    fi
  done

  if [ "$checks_run" -eq 0 ]; then
    echo "[self-test] package.json has no lint, test, or build scripts." >&2
    echo "[self-test] add at least one real verification command." >&2
    return 2
  fi
}

case "$mode" in
  default)
    if [ -f package.json ]; then
      run_node_default
    elif [ -f pyproject.toml ] || [ -f pytest.ini ] || [ -d tests ]; then
      run_if_present "python3 -m pytest" "pytest"
    else
      echo "[self-test] no default lane configured yet."
      echo "[self-test] add repo-specific checks to scripts/self-test.sh."
      exit 2
    fi
    ;;
  build)
    if [ -f package.json ]; then
      if node_has_script "build"; then
        run_node_script "build"
      else
        echo "[self-test] package.json has no build script." >&2
        exit 2
      fi
    else
      echo "[self-test] no build lane configured yet."
      exit 2
    fi
    ;;
  ui)
    echo "[self-test] configure this lane for browser, Electron, native app, or Computer Use proof."
    echo "[self-test] save artifacts under /Users/matthewlam/.codex/proofs/<repo>/<task>/."
    exit 2
    ;;
  *)
    echo "Usage: scripts/self-test.sh [default|build|ui]" >&2
    exit 2
    ;;
esac
