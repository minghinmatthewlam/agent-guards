---
name: create-architecture-audit-skill
description: "Generate a project-local skill that audits a repo's architecture: what each crate, package, or module owns, which way dependencies may point, and where the code breaks those rules. Use for /create-architecture-audit-skill, \"audit the boundaries between crates\", \"is this in the right package\", or when a repo has no repeatable way to check its layering."
---

# Create an architecture audit skill

Boundaries erode one convenient import at a time, and nobody re-reads the whole dependency graph. This skill generates a project-local skill (`.agents/skills/audit-architecture/`) that reads the real graph, compares it with what each unit is meant to own, and reports where they disagree, with evidence. The generated audit is read-only. You write its output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the repo.

## 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Units:** what are boundaries drawn between? Crates, workspace packages, build targets, top-level modules, services. Pick the level where ownership is decided and note any finer one.
- **Graph:** how do you get the real dependency graph from a tool? `cargo metadata`, `bazel query`, `go list -deps`, the workspace manifests, a dependency scanner the repo already runs. Read imports by hand only when no tool exists. The command must be exact and must not need the network.
- **Stated intent:** where does the repo say what a unit is for and what it may depend on? Module docs, READMEs, `AGENTS.md`, RFCs, design docs, lint configuration, visibility rules. Read every design doc in full, and each unit's entry file and README, before you write a word about that unit. Record the file for every rule you find. A unit whose purpose you know only from its name is not ready to map.
- **Existing enforcement:** which rules already fail the build? Name the lint rule or CI check. The audit skips what CI proves and spends its time on what nothing checks. Keep a direction check of your own only where the map is narrower than the build's rule.
- **Hidden seams:** what couples two units with no import between them? Shared files, database tables, environment variables, wire formats, subprocess calls, generated code. To find them, search for names and string literals that appear in more than one unit: a variable name, a file path, a format tag.
- **Search tools:** which search command works in a non-interactive script on this machine? An interactive shell may alias `rg`, and the system `grep` may lack `-P` or ignore `\b`. Run each pattern you plan to ship against code you know matches.

Keep two lists apart from the start: rules the repo states, and rules you infer from the code. Never present an inferred rule as a stated one. If the graph command fails on the checkout, fix that first or report it precisely; a skill written against a broken base teaches wrong steps.

## 2. Generate the skill

Write `.agents/skills/audit-architecture/SKILL.md` with YAML frontmatter (`name: audit-architecture` and a `description` that names the repo, the units, and when to reach for it; without frontmatter the skill never registers) and these sections, each grounded in what the interview found, with no placeholders left:

- **Graph:** the exact commands that print the unit graph and, for one unit, its item-level imports and its public surface. Say how to tell the output is complete.
- **Doctor:** one read-only check that answers "is this audit worth running?" The graph tool runs, the workspace resolves, and the map lists every unit the tool reports, with none missing and none stale.
- **Checks:** the audit recipe with real commands from this repo, not examples. Write every check as one command whose clean result is no output, so a helper can run the map and a reader never has to judge the output. Cover each of these, or say why it does not apply:
  - **Direction.** An edge the map does not allow, and any cycle.
  - **Ownership.** Code doing a job another unit owns. Name the concept and both places.
  - **Surface.** Public items no other unit uses, a dependency's types leaking through a unit's public API, and imports that reach past a unit's entry point. Unused public items are always `inferred`: a library may export them for callers outside the repo.
  - **Hidden coupling.** The seams found in the interview.
- **Doc drift, kept apart:** a doc that describes the code as it used to be: a stale number, a diagram missing a unit, a list missing an entry. Drift is not a boundary violation. Give these checks their own label and their own section, so they never crowd the architecture findings.
- **Evidence:** every finding carries the rule, the file the rule is written in, the exact edge or `path:line`, and the command whose output shows it. Label each finding `stated` (the code breaks a written architecture rule), `inferred` (looks wrong and needs an owner's decision), or `drift` (a doc is stale). A finding no command reproduces is an opinion: drop it or list it as a question. Save evidence to a path the repo already ignores, and name that path.
- **Report:** architecture findings first, ranked by what it costs to leave them. For each, the smallest fix and whether a build check could enforce it. Doc drift follows in its own short list. Before you report a `stated` finding, open the flagged line and the rule's source and confirm the rule covers that case. A rule about one kind of thing does not cover its neighbour; when it does not, fix the check.
- **Scope:** the audit reads. It never moves code, edits manifests, or adds lint rules. It hands enforcement to `repo-setup` and redesign to `architect`.
- **Helpers:** any script the skill ships lives inside the skill directory, is executable, and has its invocation shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

Codex reads `.agents/skills/`; Claude Code reads `.claude/skills/`. Keep `.agents/skills/audit-architecture/` as the only copy and register it for Claude with a relative symlink: `.claude/skills/audit-architecture -> ../../.agents/skills/audit-architecture`. Commit both, following the repo's own commit conventions.

## 3. Seed the boundary map

Create `.agents/skills/audit-architecture/boundaries/README.md` plus one file per unit. Follow the shape in [`references/boundary-map-example/`](references/boundary-map-example/), with a README index and one file per unit.

- **Which units first.** Map five to eight. Rank by direct dependents from the graph tool, not counting test-only dependencies. Break ties toward units with stated rules that no build check enforces, because that is where the audit adds something. List every other unit by name under `Unmapped` so Doctor still accounts for it.
- **Unit files.** Each opens with one paragraph on what the unit is for, then uses five H2s in this order: `Owns`, `May depend on`, `Must not`, `Checking it with <tool>`, and `Open questions`.
- **Stated and inferred.** Every rule line ends with its source: a doc path or a lint rule name. `Owns`, `May depend on`, and `Must not` hold stated rules only. An inferred rule goes under `Open questions` with its own check, and its findings are labelled `inferred` until an owner confirms the rule.
- **Workspace checks.** Rules that belong to no single unit, such as cycles, go in a `Workspace checks` section of the README. The README has its own `Open questions` for inferred rules that span units, and a `Doc drift` section for every drift check, whichever unit the doc belongs to.
- **Machine-readable index.** Doctor parses the index, so list mapped units as links and unmapped units as names in backticks, one per line.

If the code already breaks a rule, the map keeps the rule and the audit reports the violation. Never weaken the map to make the audit pass. The map is the repo's maintained statement of its architecture; an audit that checks one convenient unit is incomplete when the map lists others.

## 4. Prove the generated skill before handing it over

Confirm `.claude/skills/audit-architecture/SKILL.md` resolves through the symlink. Run the skill's own instructions end to end once: doctor, graph, every check against ONE mapped unit (one is enough; the map exists so later runs cover the rest), and save the evidence.

Prove every clean result is real. For each check that printed nothing, run its pattern again without the exclusions and confirm it matches code somewhere. A pattern that can match nothing reports clean forever. When the thing forbidden appears nowhere in the repo, widen the pattern until it matches something, and say so beside the check. For a check that is not a search, such as a cycle detector, feed it a planted case once.

Then prove the audit can fail:

1. Commit the generated skill, and record `git rev-parse HEAD` and `git status --porcelain` in the checkout you are working in.
2. Create a scratch worktree. Never plant anything in the checkout you are working in.
3. Add the smallest change that breaks one stated rule. Pick a rule only the audit checks. A violation the build already rejects proves the build, not the audit.
4. Run the matching check and confirm it reports that line under that rule.
5. Remove the worktree and confirm the two recorded values are unchanged.

An audit that has never reported a planted violation is a draft, not a deliverable. Report what the first real run found. Real violations go to the user as findings, not into the map as exceptions.

## 5. Offer the next step

The audit finds; it does not fix. Point the user at `repo-setup` to turn a confirmed rule into a build failure and at `architect` when a unit's responsibilities need redrawing. Suggest rerunning the audit after a unit is added, split, or merged. Suggest a cadence only if they ask.
