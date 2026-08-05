---
name: find-bugs
description: "Find important, high-confidence correctness bugs and edge cases in an existing codebase. Use when the user asks to inspect a repository, subsystem, or implementation for bugs, failure modes, incorrect behavior, or overlooked edge cases."
---

# Find Bugs

Understand the real behavior before judging it. Trace relevant entrypoints,
callers, tests, state transitions, invariants, and failure paths.

## Investigate

- Prioritize findings by impact and confidence, reporting important,
  high-confidence bugs first.
- Explore adaptively. Use subagents when they materially improve coverage, keep
  their scopes distinct, and consolidate their findings centrally.
- Verify consequential findings with a focused reproduction, test, or runtime
  probe when practical.
- Remain read-only unless the user asks for fixes.

## Report Findings

For each material finding, include enough of the following to substantiate it:

- priority and confidence;
- affected files and symbols;
- trigger or edge case;
- expected versus actual behavior;
- user or system impact;
- concrete code, test, or runtime evidence;
- fix direction when useful.

Keep simple findings compact; omit fields that do not add clarity.

Only call something a bug when the execution path and expected contract support
that conclusion. Separate verified bugs from plausible investigation leads. Do
not report style preferences, intentional trade-offs, or unrealistic edge cases
as correctness bugs.
