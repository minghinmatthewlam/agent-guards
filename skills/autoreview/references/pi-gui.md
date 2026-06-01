# pi-gui Review Focus

Review for real product behavior, not just type-level correctness.

- Keep packaged `/Applications/pi-gui.app`, worktree Electron app, and local browser/dev-server proof separate.
- Watch for Electron single-instance lock confusion; an opened app may be the installed app, not the worktree build.
- Treat Computer Use as a real desktop workflow: accessibility, screen recording, locked-session behavior, focus preservation, pointer takeover, and helper availability matter.
- Check `/goal` and extension flows against runtime/session semantics, not only UI state.
- Prefer findings that would break installed-app behavior, session continuity, Computer Use safety, or model/runtime configuration.
