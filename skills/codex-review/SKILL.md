---
name: codex-review
description: "Run Codex's built-in `codex review` command as a fallback or explicit compatibility check for local changes, branches, commits, and PR work."
---

# Codex Review

Use Codex's dedicated review command as an independent fallback check. This is `codex review`, not OpenClaw `autoreview`, not Guardian approval `auto_review`, and not a generic "ask a subagent to review" pass.

For plain "autoreview" or normal closeout review requests, use the `autoreview` skill instead. Use this skill only when the user explicitly asks for built-in Codex review, when comparing review tools, or when `autoreview` is unavailable.

Use when:
- the user asks specifically for built-in Codex review or `codex review`
- comparing `codex review` against `autoreview`
- `autoreview` fails or is unavailable and a fallback review is still useful
- reviewing a local dirty tree, branch, commit, or PR branch after fixes

## Contract

- Treat review output as advisory. Verify every finding against the real code path before changing code.
- Prefer small fixes at the right ownership boundary. Do not add broad refactors just to satisfy a speculative finding.
- Reject findings that depend on unstated assumptions, unrealistic edge cases, intentional behavior, or over-complicated fixes.
- If a review finding causes a code change, rerun the focused proof/tests and rerun Codex review.
- Keep looping until the final review has no accepted/actionable findings, or until a remaining finding is explicitly rejected with a short reason.
- Do not push only to run review. Push only when the user asked for push, ship, or PR update.

## Pick The Target

Dirty local work:

```bash
codex review --uncommitted
```

Use this only when the working tree actually has staged, unstaged, or untracked changes. A clean `--uncommitted` run only proves there is no local patch.

Branch or PR work:

```bash
git fetch origin
codex review --base origin/main
```

If an open PR exists, review against its actual base:

```bash
base=$(gh pr view --json baseRefName --jq .baseRefName)
codex review --base "origin/$base"
```

Committed single change:

```bash
codex review --commit HEAD
```

Custom review prompt:

```bash
codex review "Review the error handling in the new auth flow."
```

Current Codex CLI targets are mutually exclusive. Do not combine `--base`, `--commit`, or `--uncommitted` with a positional custom prompt.

## Helper

This skill includes a helper that chooses a sensible target and can run focused tests in parallel:

```bash
~/.agents/skills/codex-review/scripts/codex-review --help
```

After sync, Claude can call the same helper here:

```bash
~/.claude/skills/codex-review/scripts/codex-review --help
```

The helper:
- chooses dirty `--uncommitted` first in `--mode auto`
- otherwise uses the current PR base if `gh pr view` works
- otherwise uses `origin/main` for non-main branches
- supports `--mode local`, `--mode branch`, `--base`, `--commit`, `--dry-run`, and `--parallel-tests`
- supports `--full-access` for nested Codex review runs that need the local command to bypass Codex sandbox prompts
- prints `codex-review clean: no accepted/actionable findings reported` when the selected review command exits 0 and no priority findings are detected

Format first if formatting can move line numbers, then it is OK to run tests and review together:

```bash
~/.agents/skills/codex-review/scripts/codex-review --parallel-tests "npm test -- --runInBand"
```

If tests or review lead to edits, rerun the affected tests and rerun review. Once the final review/helper run exits cleanly, stop. Do not run an extra review just to get nicer wording.

## Subagent Filter

`codex review` is already a dedicated review harness with a review-specific rubric, constrained tools, fresh context, and structured findings. A normal subagent reviewer is more flexible but easier to bias with the main agent's framing.

For larger diffs, use a subagent as a filter over `codex review` when available. Ask it to run the review and return only:
- findings it accepts as actionable
- findings it rejects, with one-line reasons
- exact files and tests to rerun

For tiny changes, run the review inline.

## Final Report

Include:
- review command used
- tests or proof run
- accepted findings and fixes
- rejected findings with short reasons
- final clean review result, or why any remaining finding was consciously rejected
