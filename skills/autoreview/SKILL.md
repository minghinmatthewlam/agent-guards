---
name: autoreview
description: "Run the bundled OpenClaw structured code-review helper for local changes, branches, commits, and PRs. Use for ordinary code-review requests, default closeout review, or an explicitly requested Codex/Claude review panel."
---

# Auto Review

Run the bundled structured review helper as the default code-review closeout. Codex is the default engine; use Claude or a panel only when the user asks or material risk warrants it.

## Core Workflow

1. Select the real target:
   - dirty working tree: `--mode local`
   - branch or PR: `--mode branch --base <actual-base>`
   - committed change: `--mode commit --commit <ref>`
2. Run `~/.agents/skills/autoreview/scripts/autoreview` with that target.
   Pass the task intent and success criteria through `--prompt` or `--prompt-file` when they are not obvious from the diff.
3. Verify findings against the real code path, demonstrated contracts, and task intent.
4. Fix accepted blocking findings at the correct ownership boundary. P0/P1 block by default; keep P2/P3 visible but advisory.
5. After blocking fixes, rerun focused proof and autoreview once. Continue further only while a verified P0/P1 remains unresolved.
6. Stop when the helper exits successfully. Advisory findings do not require another round.

Read `references/commands.md` when choosing flags, panels, paths, or parallel test execution. Read `references/failure-modes.md` when a run stalls, fails, reports Gitcrawl problems, or raises provenance/security questions.

## Judgment

- Treat findings as advisory. Reject speculative risks, unrealistic edge cases, and fixes that add more complexity than value.
- Prefer narrow root-cause fixes; do not broaden the refactor merely to satisfy a reviewer.
- Flag unnecessary layers, duplicate paths, and speculative fallbacks. Prefer deleting or consolidating code.
- Do not assume backward compatibility is required. Require evidence of a public contract, supported consumer, migration guarantee, test, or explicit user requirement before adding compatibility work.
- Do not add fallback paths, dual implementations, compatibility shims, or migrations for hypothetical consumers.
- Do not impose a findings cap. Use priority and impact to distinguish blocking work from advisory observations.
- Keep web search enabled unless the user requests offline review or the material should not leave the local environment.
- Do not override an explicitly requested engine, model, or thinking level.
- Do not push merely to obtain a review.
- Do not substitute review for `self-test`; code review does not prove product behavior.
- Multi-reviewer panels are opt-in unless the change is high-risk or the first result needs arbitration.

## Gotchas

- A clean `--mode local` run on a clean checkout proves only that there is no local patch. Review the branch or commit instead.
- If blocking fixes change the diff, rerun focused proof and review once. Further rounds require a verified unresolved P0/P1.
- Long model calls can be healthy. Advancing heartbeat output is progress, not a hang.
- Never blindly apply a finding or suppress it so it disappears from structured evidence.
- Do not invoke nested review tools from inside the review.
- Stop after the helper exits successfully; P2/P3 findings may remain visible. Do not rerun solely to eliminate advisory findings or improve wording.

## Closeout

Report the target and command used, focused proof run, blocking findings resolved or rejected, noteworthy advisory findings, final threshold result, and any residual review gap. Keep the report concise.
