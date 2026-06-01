# codex-zig-port Review Focus

Review primarily for Rust parity.

- Compare feature flags, config overrides, protocol schemas, and validation behavior against `/Users/matthewlam/dev/codex` when available.
- Watch for defaults that diverge from Rust tests or generated schemas.
- Check both happy-path parsing and invalid-value rejection.
- Pay special attention to nested config maps, network proxy settings, sandbox overrides, review/exec path differences, and enum value parity.
- A finding is strongest when it cites the Zig change and the Rust/source schema it diverges from.
