# pi-goal Review Focus

Review goal/runtime behavior against the actual Codex and pi-gui integration paths.

- Distinguish runtime-level state from session-level state.
- Check continuation, completion, blocked-state, and token-budget behavior around `create_goal`, `update_goal`, and goal visibility.
- Look for orphaned continuations, stale goal state, inconsistent status transitions, and mismatches between CLI exposure and backend primitives.
- Verify extension contracts from the caller perspective: inputs, outputs, error handling, and compatibility with current pi-gui expectations.
