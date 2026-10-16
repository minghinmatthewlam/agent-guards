---
name: find-quick-wins
description: "Find low-risk, high-confidence improvements in a codebase that an agent can fix and prove on its own, and optionally fix them as small PRs. Use when the user asks for quick wins, low-hanging fruit, easy fixes, or continuous small improvements to a repo or subsystem. For a deep hunt for severe bugs regardless of fix size, use find-bugs."
---

# Find Quick Wins

A quick win is a real problem with a small, safe fix that an agent can make and prove without a human steering it. Trace the current behavior before judging it.

## The bar

Report a finding only when all of these hold:

- **Real.** You observed it: a reproduction, a failing or missing test, a runtime probe, or a traced code path that contradicts a stated contract. Not a style preference or an intentional trade-off.
- **Worth it.** Someone would notice the fix: a user, a caller, or the next engineer reading the code.
- **Small and contained.** One PR, a few files, no public contract or schema change, no migration, no product decision.
- **Provable.** There is a concrete way to show it before and after.

Rank what passes by impact against risk. Prefer the fix you are most sure of when impact is close.

## Investigate

- Check the tracker and open PRs first, and skip anything already filed or in flight.
- Spread wide. Use parallel subagents over distinct areas, then verify and deduplicate their findings centrally. Keep only what you confirmed yourself.
- Stay read-only unless the user asks for fixes.

## Report

For each finding, a heading with impact, risk, fix size, issue confidence and fix confidence, for example `[High impact, Low risk, S, 95% issue, 90% fix] Retry loop ignores Retry-After`. Then, briefly:

- the evidence and file:line;
- the fix;
- how to prove it, before and after.

Each finding should read as a self-contained brief a fresh agent could fix from. List near-misses that failed the bar separately, with the reason.

## Fix (when asked)

One finding per PR, following the repository's own PR, review and verification rules. Show the problem before the fix and gone after it on the real surface. Drop a finding that turns out larger or riskier than estimated, and report why.
