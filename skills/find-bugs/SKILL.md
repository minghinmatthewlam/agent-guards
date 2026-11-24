---
name: find-bugs
description: "Find important, high-confidence correctness bugs and edge cases in an existing codebase. Use when the user asks to inspect a repository, subsystem, or implementation for bugs, failure modes, incorrect behavior, or overlooked edge cases."
---

# Find Bugs

Trace real execution paths, invariants, and failure modes before judging.

## Investigate

- Prioritize high-confidence, high-impact bugs. Favor simpler fixes when impact and confidence are close, without hiding severe bugs.
- Use subagents with distinct scopes when helpful; verify and consolidate centrally.
- Verify consequential findings with a repro, test, or runtime probe when practical.
- Stay read-only unless asked to fix.

## Report

Put priority, fix complexity, finding confidence, and fix confidence in each heading:
`P1 — [Medium fix, 98% finding confidence, 90% fix confidence] Cache entries are not isolated`

Include: affected files/symbols, trigger and expected vs. actual behavior, impact, concrete evidence, proposed fix direction, and risk/blast radius behind the fix confidence. Keep simple findings compact.

Separate verified bugs from leads. Skip style preferences, intentional trade-offs, and unrealistic edge cases.
