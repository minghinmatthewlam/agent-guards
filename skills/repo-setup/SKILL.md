---
name: repo-setup
description: "Set up or refactor a repository so agents naturally follow its intended architecture and important mistakes fail mechanically. Use when the user invokes $repo-setup, asks to make a repo agent-friendly, or wants important repository rules enforced through structure, types, tooling, tests, or CI."
---

# Repo Setup

Agents take shortcuts and copy nearby patterns. Shape the repository so the
shortest, most obvious implementation follows the intended architecture. Make
important wrong paths impossible or fail early instead of relying on reminders.

## Understand The Repository

Read the source, build and test entrypoints, CI, static-analysis configuration,
and existing instructions. Trace representative product flows to learn:

- where a new feature naturally belongs;
- which modules can change persistent state;
- which shortcuts or recurring mistakes would be costly;
- where external data is validated;
- which local command proves a change is safe.

Separate the architecture the code currently has from the architecture the user
actually wants. Present a concise mental model and the important choices before
making judgment-heavy or broad structural changes. Ask only questions that can
materially change the product or architecture.

## Establish The Contract

Agree on the important rules for the repository. Focus on rules that prevent
real confusion, coupling, or recurring mistakes, such as:

- one obvious place to add each kind of feature;
- one clear module or API that writes each persistent value;
- simple code paths that make important invariants hard to bypass;
- validation at external boundaries rather than scattered through the system;
- one canonical local verification command that CI also runs.

Do not copy another repository's layout blindly. Use its principles only when
they fit this product and codebase.

## Make The Correct Path Easy

Remove misleading, duplicate, and bypass paths when safe. Prefer the strongest
proportional mechanism that fits the rule:

1. code structure, data models, or types that make the mistake impossible;
2. dependency rules, lint, or static analysis that fail the build;
3. one canonical API, helper, generator, or extension convention;
4. focused tests or runtime checks;
5. written instructions only when the decision requires human judgment.

Avoid speculative frameworks, broad compatibility layers, growing allowlists,
and suppressions that hide existing violations. Improve the highest-value
constraints first and keep the system easy to understand.

## Prove Each New Constraint

Do not only show that normal code still works. Choose a real shortcut, past
failure, or likely high-impact mistake from this repository. Reproduce the
smallest safe example and show that the new structure or check rejects it with
a clear failure. Remove the temporary violation, run the normal path again, and
confirm that CI executes the same guard. Keep temporary violations out of the
final change.

## Learn From Failures

After an agent mistake or user correction, fix the immediate problem and ask:
"Did the repository make this mistake easy?" If recurrence would be material,
strengthen the owning structure or check and prove it catches the same class of
failure. Do not add machinery for harmless one-off judgment errors.

## Report

Use `concisely`. Explain the before-and-after mental model, enforced rules,
commands and evidence, decisions made with the user, remaining prose-only
constraints, and residual risk.

## Gotchas

- Do not treat the nearest existing pattern as the intended architecture.
- Do not add import or package-boundary rules unless this repository needs them.
- Do not encode an architectural choice before the user understands and accepts it.
- Do not claim a guard works without showing it reject a representative violation.
- Do not replace a simple repository with a complicated enforcement framework.
- Do not leave both the new canonical path and the old shortcut in place by default.
