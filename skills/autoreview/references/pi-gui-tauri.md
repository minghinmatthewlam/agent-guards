# pi-gui-tauri Review Focus

Review Tauri behavior against the Electron product behavior it is trying to preserve.

- Check workspace opening, new-thread routing, and selected-session hydration against Electron expectations.
- Treat sidecar state polling and event delivery as race-prone; look for stale snapshots overwriting newer renderer state.
- Keep demo-mode behavior separate from production behavior.
- Tauri-deferred Electron features should be explicit and non-breaking, not silent no-ops in expected user flows.
- Prefer user-visible findings in app launch, folder opening, session selection, streaming transcript, and state persistence.
