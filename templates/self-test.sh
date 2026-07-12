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

run_node_default() {
  if command -v pnpm >/dev/null 2>&1 && [ -f pnpm-lock.yaml ]; then
    pnpm run lint --if-present
    pnpm run test --if-present
    pnpm run build --if-present
    return 0
  fi

  if command -v npm >/dev/null 2>&1; then
    npm run lint --if-present
    npm test --if-present
    npm run build --if-present
    return 0
  fi

  return 1
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
      if command -v pnpm >/dev/null 2>&1 && [ -f pnpm-lock.yaml ]; then
        run_if_present "pnpm run build --if-present" "pnpm build"
      else
        run_if_present "npm run build --if-present" "npm build"
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
