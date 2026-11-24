---
name: create-architecture-audit-skill
description: "Generate a project-local skill that audits a repo's architecture: what each crate, package, or module owns, which way dependencies may point, and where the code breaks those rules. Use for /create-architecture-audit-skill, \"audit the boundaries between crates\", \"is this in the right package\", or when a repo has no repeatable way to check its layering."
---

# Create an architecture audit skill

Generate a read-only, agent-facing project-local skill at `.agents/skills/audit-architecture/` (symlinked at `.claude/skills/audit-architecture -> ../../.agents/skills/audit-architecture`) that compares the real dependency graph against intended ownership and reports violations with reproducible evidence.

## 1. Interview the repo

Learn from the codebase (ask only what cannot be observed):

- **Units & Graph:** ownership units (crates, packages, modules) and exact offline graph command (`cargo metadata`, `bazel query`, `go list -deps`, manifests). Fix or report a broken graph command first.
- **Stated intent:** read design docs, READMEs, `AGENTS.md`, and each unit's entry file in full; record the source file for every rule. Keep `stated` rules strictly separate from `inferred` ones.
- **Existing enforcement:** lint/CI checks already enforced—skip what CI proves unless the map is narrower.
- **Hidden seams:** non-import coupling (shared files, DB tables, env vars, wire formats, subprocesses).
- **Search tool:** confirm which search command/flags work non-interactively on this machine.

## 2. Generate `SKILL.md`

Write `.agents/skills/audit-architecture/SKILL.md` with frontmatter (`name: audit-architecture` + repo-specific trigger `description`) and real commands (no placeholders):

- **Graph:** commands for unit graph, item-level imports, and public surface.
- **Doctor:** read-only check that the graph tool works and the map lists every unit (none missing or stale).
- **Checks:** one command per check whose clean result is empty output, covering **Direction** (disallowed edges/cycles), **Ownership** (wrong unit), **Surface** (unused public items = `inferred`, leaked dep types, entry-point bypasses), and **Hidden coupling**.
- **Doc drift:** kept in its own section with `drift` label so it doesn't crowd architecture findings.
- **Evidence & Report:** every finding includes rule, rule source file, edge/`path:line`, reproducing command, and label (`stated` / `inferred` / `drift`); drop unreproducible opinions. Save evidence to a gitignored path. Rank findings by cost with smallest fix + whether a build check could enforce it; verify flagged lines against the rule source before reporting `stated`.
- **Scope & Helpers:** read-only (hand enforcement to `repo-setup`, redesign to `architect`). Any helper script lives executable in the skill dir with invocation shown.

## 3. Seed the boundary map

Create `.agents/skills/audit-architecture/boundaries/README.md` + one file per unit matching [`references/boundary-map-example/`](references/boundary-map-example/):

- Map 5–8 highest-fan-in units (non-test dependents; tie-break by unenforced stated rules). List all other units as backticked names under `Unmapped` (mapped units as links, one per line for Doctor).
- Each unit file: 1-paragraph purpose + H2s in order: `Owns`, `May depend on`, `Must not`, `Checking it with <tool>`, `Open questions`. Every rule ends with its source; inferred rules go in `Open questions`.
- Put workspace checks (e.g. cycles), cross-unit `Open questions`, and `Doc drift` in `README.md`. Never weaken the map to hide existing violations.

## 4. Prove before handoff

1. Confirm `.claude/skills/audit-architecture/SKILL.md` resolves, then run doctor, graph, and every check on one mapped unit end-to-end.
2. Prove clean checks aren't vacuous (run without exclusions, or feed a planted case for non-search checks).
3. Commit the skill, record `git rev-parse HEAD` and `git status --porcelain`, create a scratch worktree, plant the smallest violation of an audit-only stated rule, confirm the check catches it, remove the worktree, and confirm `HEAD`/status are unchanged.

Report real findings from the first run, and point to `repo-setup` (enforcement) or `architect` (redesign) as next steps.
