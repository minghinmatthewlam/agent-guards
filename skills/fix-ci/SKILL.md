---
name: fix-ci
description: Check GitHub Actions status on the current PR, wait for checks to finish, analyze failures and review comments, fix issues, and repeat until CI passes. Use when a user asks to fix failing CI, check PR status, or get a PR merge-ready.
metadata:
  short-description: Fix failing CI and address PR feedback
---

Usage:

- `/fix-ci` - Fix CI failures on current branch's PR
- `/fix-ci <pr-number>` - Fix specific PR
- `/fix-ci --check-only` - Only report status, don't fix

**Instructions:**

Automated CI fix loop. Wait for checks, inspect failures, fix, push, repeat until green.

**Step 1: Parse Input**

- Input: $ARGUMENTS
- If a PR number is provided, use that
- If `--check-only` flag is present, only report status without fixing
- If no arguments, detect PR for current branch via `gh pr view --json number,url`

**Step 2: Readiness Gate**

Before inspecting, ensure CI checks have finished running. Poll every 2 minutes (max 10 iterations / 20 minutes).

```bash
# Count checks still running
gh pr checks <pr-number> --json state --jq '[.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED")] | length'
```

- If 0 → proceed to Step 3
- If > 0 → wait 2 minutes, retry
- After 10 retries → exit with timeout, report which checks never completed

**On subsequent iterations** (after pushing a fix): also wait for CI to re-run on the new commit before inspecting again.

**Step 3: Inspect Failures**

Use the bundled inspection script for robust log extraction:

```bash
python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "<pr-number>" --json
```

The script handles:
- `gh` CLI field drift (auto-detects available fields, retries with fallbacks)
- Smart log extraction (finds failure markers, extracts context window)
- Job-level log fallback when run logs aren't available yet
- External check detection (non-GitHub Actions checks reported as URL-only)

If the script is unavailable, fall back to manual inspection:

```bash
gh pr checks <pr-number> --json name,state,conclusion,detailsUrl
gh run view <run-id> --log-failed
```

**External checks** (Buildkite, CircleCI, etc.): report the URL only, mark as out-of-scope. Don't attempt to fetch logs from non-GitHub Actions providers.

**Step 4: Analyze and Fix**

For each failure, read the log snippet and determine the fix. Let the repo context guide you — read project config files, package.json, Makefile, etc. to find the right commands. Don't assume specific tooling.

General patterns:
- **Lint errors**: Read failing files, fix issues, run the project's lint command to verify
- **Type errors**: Fix type mismatches, run the project's type-check command
- **Test failures**: Read test + implementation files, fix the root cause, run the specific test
- **Generated file drift**: Run the project's generation commands, stage the output

If `--check-only`, skip this step — just report findings and exit.

**Step 5: Commit and Push**

```bash
git add <specific-files>
git commit -m "fix: resolve CI failures

- Fixed [describe what was fixed]
- Resolves failures in [job names]"
git push
```

**Step 6: Loop Until Success**

After pushing, go back to Step 2 (readiness gate). Wait for CI to re-run, then re-inspect.

- Max 3 iterations
- If still failing after 3 iterations → report remaining failures, ask for help

**Step 7: Check PR Review Comments**

After CI passes (or in parallel with fixing), fetch review feedback from all sources:

```bash
# Code-level inline comments
gh api "repos/{owner}/{repo}/pulls/<pr-number>/comments" > /tmp/pr_review_comments.json

# PR-level review bodies
gh api "repos/{owner}/{repo}/pulls/<pr-number>/reviews" > /tmp/pr_reviews.json

# General PR conversation
gh pr view <pr-number> --comments
```

**Triage each actionable comment into tiers:**
- **Fix** — real bug, security issue, logic error, correctness problem
- **Consider** — reasonable improvement, not critical
- **Skip** — nitpick, stylistic preference, bot noise

Human reviewer comments weighted higher than bot comments. Present the triage to the user and ask which to address. After fixing approved comments, commit, push, and loop back to Step 2.

**Step 8: Report Results**

```
## CI Fix Results: PR #<number>

**Status:** PASSED | FAILED | IN_PROGRESS
**Branch:** <branch> | **URL:** <pr-url>

### Actions Taken
1. [Fix description]
2. [Fix description]

### Review Comments
- [Summary of addressed/skipped comments]

### Next Steps
[If still failing: what needs manual intervention]
```

**Error Handling:**
- `gh` not authenticated → inform user to run `gh auth login`
- No PR exists → inform user to create PR first
- Max iterations reached → report remaining failures
- External checks failing → report URL, mark out-of-scope

## Bundled Resources

### scripts/inspect_pr_checks.py

Robust CI check inspector. Handles gh CLI field drift, smart log context extraction, job-level log fallbacks, and external check detection.

```bash
python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "123"
python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "123" --json
python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --max-lines 200 --context 40
```
