---
name: perry-review
description: "Take an OpenRouterTeam/openrouter-web PR from ready to merged. Matthew runs /perry-review once he has decided the PR is ready and understands the change. Asks perry for review once CI is green, handles perry's comments, and enqueues the merge once perry approves the head and CI is green, within quiet hours."
disable-model-invocation: true
---

# perry review

Running `/perry-review` means Matthew has approved the PR's intent and passed the understanding gate (pstack's `playbooks/opening-a-pr.md`); don't ask him again. If a coordinator brief forbids merging, stop at merge-ready and report.

## 1. perry

- Once CI is green, post in Slack `#agents-ori` (`C0BS37QUK7T`) exactly: `<@U0C6K71R40G> review/approve <PR URL>` (`U0AQD847T6C` is dead). perry replies in thread (~10m) and leaves inline GitHub comments.
- Triage comments per pstack's `references/bugbot-triage.md`. Fix real findings and reply to bot reviewers (perry, Devin) on GitHub yourself; replies to human reviewers need Matthew first. After pushing fixes, reply in the Slack thread with the new head SHA.
- Batch fixes—changing the PR's own diff requires perry re-approval. File non-blocking bot suggestions as follow-up Linear issues by default.

## 2. Merge

- Read pstack's `playbooks/opening-a-pr.md` in full before merging. PRs must be ready (never draft; follow `openrouter-web`'s `AGENTS.md` steps for leaving draft), CI green, comments addressed, and perry approved on the current diff.
- **Unchanged diff keeps approval:** `openrouter-web` has `dismiss_stale_reviews_on_push: false`. Clean merges of `main`/parent PR don't need re-review; verify with `git patch-id` instead of guessing:
  ```bash
  own() { git diff "$(git merge-base origin/<base> "$1")" "$1" | git patch-id --stable | cut -d' ' -f1; }
  own <approved>; own HEAD
  ```
  Different IDs mean the diff moved—ask perry again.
- **Enqueue via GraphQL, never `gh pr merge`** (`gh pr merge` silently enables auto-merge when BLOCKED):
  ```bash
  id=$(gh pr view <n> --repo OpenRouterTeam/openrouter-web --json id --jq .id)
  gh api graphql -f query="mutation{enqueuePullRequest(input:{pullRequestId:\"$id\"}){mergeQueueEntry{state position}}}"
  gh pr view <n> --repo OpenRouterTeam/openrouter-web --json autoMergeRequest --jq .autoMergeRequest # must be null
  ```

## Quiet hours

Quiet hours: 20:00–08:00 local weekdays, and all weekend.

- **Weekdays:** hold Slack posts and merges if Matthew hasn't messaged since 20:00.
- **Weekends:** hold unless Matthew messaged in this session within the last hour (Slack posts go out under his name).
- Keep working during quiet hours; record verdicts and hold posts/merges until active hours.
