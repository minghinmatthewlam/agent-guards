# ledger-protocol

`ledger-protocol` defines the request, response, and event types that cross a process boundary. Every other crate speaks these types and none redefines them.

## Owns

- The serialized shape of every request, response, and event. Source: `crates/ledger-protocol/src/lib.rs` module doc.
- The protocol version constant. Source: `docs/architecture.md`.

## May depend on

- No workspace crate. Source: `docs/architecture.md`, "protocol is the leaf".

## Must not

- Depend on `ledger-store`, `ledger-server`, or `ledger-cli`. Source: `docs/architecture.md`.
- Perform I/O: no file, network, clock, or environment access. Source: `crates/ledger-protocol/src/lib.rs` module doc.

## Checking it with cargo and git grep

Preconditions:

- `.agents/skills/audit-architecture/audit doctor` passes at the commit under audit.
- `target/audit/ledger-protocol/` is empty.

- **Leaf rule (stated).** Run `cargo tree -p ledger-protocol -e normal --depth 1 --offline --prefix none | grep '^ledger-' | grep -v '^ledger-protocol '`.
- **No I/O (stated).** Run `git grep -nE 'std::(fs|net|env)|SystemTime|tokio::' -- crates/ledger-protocol/src`.
- **One definition (stated).** Run `git grep -nE 'struct (Request|Response|Event)[ <{]' -- crates ':!crates/ledger-protocol'`.
- **Evidence.** Run `.agents/skills/audit-architecture/audit save ledger-protocol`. One file per check appears under `target/audit/ledger-protocol/`, with the commit hash in `commit.txt`.

## Open questions

- **No async runtime types in the public API (inferred).** Nothing states it, and the crate has none today, so the rule would cost nothing to adopt. Run `git grep -nE 'pub .*(tokio|futures)::' -- crates/ledger-protocol/src`.
- **No unused public items (inferred).** Run `.agents/skills/audit-architecture/audit unused-surface ledger-protocol`. It prints each public item no other crate names. Some may exist for callers outside the workspace.
