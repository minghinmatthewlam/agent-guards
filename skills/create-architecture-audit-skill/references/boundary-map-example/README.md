# Ledger boundary map

This directory is the maintained statement of what each Ledger crate owns and what it may depend on. Read the index before auditing, then use the matching unit file as the recipe.

## Baseline preconditions

- Run every command from the workspace root, where `Cargo.toml` declares the workspace.
- Use `--offline` and `--locked` so an audit never changes `Cargo.lock` or reaches the network.
- Run `.agents/skills/audit-architecture/audit doctor` and require that every crate `cargo metadata` reports is listed in this index.
- Never edit source, manifests, or lint configuration during an audit.

## Auditing conventions

- A unit is one workspace crate. Modules inside a crate are not audited here.
- Treat every command as literal. Keep crate names and flags unchanged.
- Every check is one command. Clean is no output, and any output is a finding.
- An edge is allowed only when the dependent unit's file lists it under `May depend on`.
- Skip rules that CI already enforces. `cargo deny check bans` covers third-party licences and duplicates.
- Search with `git grep -nE`. It behaves the same in a script and in an interactive shell on every machine the team uses.
- Check hidden seams as well as imports: the SQLite file, the `LEDGER_*` environment variables, and the wire format.

## Evidence and reporting

- Every finding names the rule, the file the rule is written in, the edge or `path:line`, and the command that shows it.
- Label a finding `stated` when the code breaks a written rule, `inferred` when it comes from a check under `Open questions`, and `drift` when a doc is stale.
- Report architecture findings first. List doc drift after them, in its own section.
- Save command output under `target/audit/<unit>/`, which `.gitignore` already covers. Record the commit the audit ran against.
- Report a rule that could not be checked with the command you tried and why it failed.
- Do not report a unit as clean when only some of its checks ran.

## Unit entry contract

Each unit file starts with an H1 title and one paragraph describing what the unit is for. It then uses exactly five H2 sections in this order.

1. `Owns` lists the concepts and persistent values only this unit may define or write.
2. `May depend on` lists every allowed workspace dependency.
3. `Must not` lists the forbidden edges and behaviours.
4. `Checking it with <tool>` starts with `Preconditions:` and uses labeled bullets that pair each rule with one exact command.
5. `Open questions` lists inferred rules awaiting an owner's decision, each with its own check.

The first three sections hold stated rules only, and every line ends with its source: a doc path or a lint rule name. Keep implementation detail out of the map. Name only responsibilities, edges, and commands.

## Workspace checks

- **No cycles (stated).** Run `.agents/skills/audit-architecture/audit cycles`. Source: `docs/architecture.md`, "dependencies point down".

## Open questions

- **One spelling of each environment variable (inferred).** Nothing states it. Run `.agents/skills/audit-architecture/audit shared-names 'LEDGER_[A-Z_]+'`. It prints each variable name that two crates spell.

## Doc drift

- **Diagram matches the graph (drift).** Run `.agents/skills/audit-architecture/audit diagram-drift`. It prints each crate that `docs/architecture.md` names and `cargo metadata` does not report, and each crate the diagram omits.
- **README quotes the page size as it is (drift).** Run `.agents/skills/audit-architecture/audit quoted-constant PAGE_SIZE crates/ledger-store/README.md`. It prints the line when the number beside the name differs from the code.

## Units

- [ledger-protocol](./ledger-protocol.md)
- [ledger-store](./ledger-store.md)

## Unmapped

- `ledger-server`
- `ledger-cli`
