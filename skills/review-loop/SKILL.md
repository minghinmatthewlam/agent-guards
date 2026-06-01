---
name: review-loop
description: "Post-implementation review/fix loop. Use host-appropriate review coverage on your implementation, fix issues, iterate until highly confident, then commit."
---

# Review Loop

After implementation, harden it with structured `autoreview` coverage first. Fix, iterate, commit.

Read-only analysis → use `audit-loop` instead.
Planning before implementation → use `plan-loop` instead.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before applying fixes — the safety, workflow, and code conventions that govern all agent work.

## How It Works

1. **Review** your implementation per `references/review-protocol.md`. Use the `autoreview` skill as the default closeout reviewer for actual code diffs. Pass relevant context through `--prompt-file` when a repo-specific reference exists. Use fresh-context reviewer agents only for focused follow-up, ambiguous findings, or non-diff review.
2. **Fix** issues found. Atomic commits (one logical fix per commit). After fixes that affect behavior, invoke `self-test` to re-verify on the real surface — don't trust code review alone.
3. **Repeat** until confident. Follow the host-specific coverage rules every round. Run autonomously — do not pause for user input between rounds.
4. **Commit and close** when confident.

## Gotchas

- **Self-test after behavioral fixes is mandatory.** When a review round finds a behavioral bug and you fix it, use the Skill tool to invoke `self-test` to re-verify — don't trust the code review alone to confirm the fix works on the real surface. Skipping this is how "reviewed and fixed" changes still ship broken.
- In Codex-hosted runs, do not invoke Oracle, Claude, or other cross-model tooling just to satisfy review coverage. `autoreview --engine codex` is the expected path unless the human explicitly asks for an external second opinion or panel.

## Round Sizing

- Default:
  - R1: one `autoreview --engine codex` pass on the full diff. Add `--prompt-file` for known repos. Use `--no-web-search` unless current docs/API/platform behavior matter.
  - R2+: rerun `autoreview` after accepted fixes. Focus any extra reviewer agents only on unresolved findings and changed code, not a fresh broad re-review.
- Optional panel:
  - Use `--reviewers codex,claude` only when the user asks for Claude coverage, the change is high-risk, or the Codex-only result has low confidence.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what must be true to close:
- `<70`: another round, mandatory.
- `70-84`: one more focused round on residual risks. If still 70-84 after that, escalate to user with findings.
- `>=85`: eligible to close. Auto commit, push, and create PR.
