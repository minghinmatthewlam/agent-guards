---
name: ori-pr
description: "Take an OpenRouterIncubator/ori or OpenRouterTeam/openrouter-web PR from ready to merged. Matthew runs /ori-pr once he has decided the PR is ready and understands the change. Asks perry for review once CI is green, handles perry's comments, and enqueues the merge once perry approves the head and CI is green, within quiet hours."
disable-model-invocation: true
---

# ori PR steps

Matthew running `/ori-pr` on a PR means he has approved its intent and passed the understanding gate in Matthew's rules (pstack's `playbooks/opening-a-pr.md`). Do not ask him again. Run the steps below to the merge.

If a coordinator's brief tells you never to merge, follow the brief: stop at merge-ready and report, even when `/ori-pr` was run here.

## 1. perry

- perry (OpenRouter's review bot): once CI is green, post in Slack #agents-ori (C0BS37QUK7T) exactly `<@U0C6K71R40G> review/approve <PR URL>`. That is perry (perryv2). `U0AQD847T6C` is perry-old and no longer answers. perry answers in that thread, usually within 10 minutes, and leaves inline GitHub comments.
- Triage each comment per pstack's `references/bugbot-triage.md`. Fix real findings, and answer bot reviewers (perry, Devin) on GitHub yourself. Replies to a human reviewer need Matthew first.
- After a fix lands, reply in the same thread naming the new head SHA.
- After approval, file non-blocking bot suggestions as a follow-up Linear issue by default; take one on the PR only if it's a real gap or makes a test meaningful. A push that changes the PR's own diff costs a perry re-approval, so batch fixes.

## 2. Merge

- Merge when perry has approved the PR's current diff, every comment is addressed, and CI is green on the current head. Read pstack's `playbooks/opening-a-pr.md` (Matthew's rules) in full at the moment you merge; never merge from memory or a summary.
- **An approval survives a push that leaves the PR's own diff unchanged.** Neither repo dismisses an approval on push (`dismiss_stale_reviews_on_push: false`): ori requires no approval and openrouter-web requires one, which a later push keeps. The perry gate on ori is this skill's rule, and its point is that perry reviewed the code that lands. A commit that only merges `main` or the parent PR in, with no conflict resolution, changes the head but not that code, so do not ask perry again. Check it rather than judging it: with `<base>` the PR's base branch and `<approved>` the head perry approved, the PR's own diff is unchanged when these two print the same patch id:
  ```bash
  own() { git diff "$(git merge-base origin/<base> "$1")" "$1" | git patch-id --stable | cut -d' ' -f1; }
  own <approved>; own HEAD
  ```
  Different ids (a resolved conflict, a fix, a context change from `main` near the PR's lines) mean the code moved: ask perry again.
- Command: enqueue with GraphQL, never `gh pr merge`: `id=$(gh pr view <n> --repo <owner/repo> --json id --jq .id); gh api graphql -f query="mutation{enqueuePullRequest(input:{pullRequestId:\"$id\"}){mergeQueueEntry{state position}}}"`. Then confirm `autoMergeRequest` is null: `gh pr view <n> --repo <owner/repo> --json autoMergeRequest --jq .autoMergeRequest` prints `null`. `gh pr merge` silently enables auto-merge when the PR is BLOCKED (unresolved thread, pending check), which happened on #3835 on 2026-10-15. The mutation errors instead, naming the blocker. Never enable auto-merge.
- PRs are ready for review, never draft (`gh pr ready <n>`).
- `<owner/repo>` is the PR's own repository: `OpenRouterIncubator/ori` or `OpenRouterTeam/openrouter-web`. Follow that repository's own AGENTS.md steps for leaving draft too.

## Quiet hours

Quiet hours are 20:00 to 08:00 local on weekdays (active 08:00–20:00), and all of Saturday and Sunday.

- **Weekdays.** If Matthew hasn't messaged since the most recent 20:00, pause merges and perry requests.
- **Weekends.** Pause the same things unless Matthew has messaged in this session within the last hour. Every Slack post goes out under his name.
- **During quiet hours.** Keep working. Record verdicts, and hold every Slack post and merge until quiet hours end.
