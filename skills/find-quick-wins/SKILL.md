---
name: find-quick-wins
description: "Find low-risk, high-confidence improvements in a codebase that an agent can fix and prove on its own, and optionally fix them as small PRs. Use when the user asks for quick wins, low-hanging fruit, easy fixes, or continuous small improvements to a repo or subsystem. For a deep hunt for severe bugs regardless of fix size, use find-bugs."
---

# Find Quick Wins

A quick win is a real problem with a small, safe fix an agent can land and prove autonomously.

## Bar (all must hold)

- **Real:** observed via repro, missing/failing test, runtime probe, or traced contract violation—not style or an intentional trade-off.
- **Worth it:** a user, caller, or future engineer will notice.
- **Small & contained:** one PR, a few files, no contract/schema change, migration, or product decision.
- **Provable:** concrete before-and-after verification.

Rank by impact vs. risk, breaking ties by confidence.

## Investigate

- Check the tracker and open PRs first; skip anything already filed or in flight.
- Fan out with parallel subagents over distinct areas; verify and deduplicate centrally. Stay read-only unless asked to fix.

## Report

Heading: `[High impact, Low risk, S, 95% issue, 90% fix] Retry loop ignores Retry-After`

Briefly give evidence (`file:line`), the fix, and before/after proof—self-contained enough for a fresh agent to execute. List near-misses separately with reasons.

## Fix (when asked)

One finding per PR following repo PR/verification rules. Prove the issue before and gone after on the real surface. Drop and report any finding that turns out larger or riskier than estimated.
