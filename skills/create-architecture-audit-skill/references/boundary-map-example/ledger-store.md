# ledger-store

`ledger-store` persists accounts and entries in one SQLite file. It is the only crate that opens that file, and it hands callers typed rows rather than SQL.

## Owns

- The SQLite file at `$LEDGER_DATA_DIR/ledger.db` and its schema migrations. Source: `crates/ledger-store/README.md`.
- Every write to the `accounts` and `entries` tables. Source: `docs/architecture.md`, "one writer".
- The `LEDGER_DATA_DIR` environment variable. Source: `crates/ledger-store/README.md`.

## May depend on

- `ledger-protocol`, for the types it stores and returns. Source: `docs/architecture.md`.

## Must not

- Depend on `ledger-server` or `ledger-cli`. Source: `docs/architecture.md`.
- Return a `rusqlite` type from a public function. Source: `crates/ledger-store/README.md`, "callers never see SQL".

## Checking it with cargo and git grep

Preconditions:

- `.agents/skills/audit-architecture/audit doctor` passes at the commit under audit.
- `target/audit/ledger-store/` is empty.

- **Allowed edges (stated).** Run `cargo tree -p ledger-store -e normal --depth 1 --offline --prefix none | grep '^ledger-' | grep -vE '^ledger-(store|protocol) '`.
- **One writer (stated).** Run `git grep -nE 'rusqlite|ledger\.db|INSERT INTO|UPDATE (accounts|entries)' -- crates ':!crates/ledger-store'`.
- **One reader of the variable (stated).** Run `git grep -n 'LEDGER_DATA_DIR' -- crates ':!crates/ledger-store'`.
- **No leaked SQL types (stated).** Run `git grep -nE 'pub (async )?fn .*rusqlite::' -- crates/ledger-store/src`.
- **Evidence.** Run `.agents/skills/audit-architecture/audit save ledger-store`. One file per check appears under `target/audit/ledger-store/`, with the commit hash in `commit.txt`.

## Open questions

- **No session state in the store (inferred).** Nothing states it. One function, `entries_for_session`, takes a session id today. Run `git grep -nE 'session|header' -- crates/ledger-store/src`.
