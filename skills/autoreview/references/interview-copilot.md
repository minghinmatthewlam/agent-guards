# interview-copilot Review Focus

Review macOS app behavior and packaged-app implications.

- Global shortcuts can collide with macOS system shortcuts; registration failures may be fatal during startup.
- Keep dev verification separate from updating `/Applications/Starry.app`.
- Check Tauri/Rust shortcut wiring, accessibility automation, screenshot capture, transcript fetch, and prompt dispatch as one workflow.
- Prefer findings that affect packaged app launch, keyboard shortcuts, UI automation reliability, or user-facing quick actions.
