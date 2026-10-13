# <Project>: instructions every thread starts from

The coordinator pastes this file verbatim at the top of every thread brief: subagents, Codex threads, task cards, cmux workers, and any other worker. Keep it under 16,000 characters. Change it only when the human asks, or after they correct a thread.

## What the project is for
<Who owns it, what it is, and the goal in the human's words. Name who the work serves.>

## Where the work happens
- Code and specs: <paths>.
- Follow the repo's own AGENTS.md/CLAUDE.md. A brief names its target repo; when that repo isn't this one, follow the target repo's rules instead.
- Work in your own git worktree, on the branch the brief names, started from the default branch. Never work in the main checkout.
- Every PR needs a tracker issue first. The coordinator files it; a thread doesn't.

## Thread workflow
1. **Design first** with the `architect` skill. Fix problems where they originate, not with inference, fallbacks or compat rules layered on top. Then STOP and report. Don't implement until the coordinator relays the human's approval.
2. **Implement** the approved design.
3. **Review loop:** run `autoreview` until a pass has no blockers, then tell the coordinator. The coordinator runs a cross-model review and relays its findings. Repeat until it reports no blockers.
4. **Self-test like a user** with <the verification skill>. Paste the exact commands and their output.
5. **Open the PR** <ready for review | as a draft>, following the PR template.
6. **Babysit the PR** from your session right after opening it: <Codex: attach the PR and add a CI heartbeat on your own thread | Claude Desktop: turn on CI auto-fix | cmux: run `/loop`>. Never poll CI by hand.
7. **Reviews:** <how to request bot or human review>. You may reply to bot reviewers yourself. Ask the human before replying to a human reviewer.

## Follow-up tasks
Don't start new threads or task cards yourself. Send proposed follow-ups to the coordinator: a title, two lines of why, and the files involved.

## When something is missing
If you can't reach something you need (a repo, a secret, an API, a permission), say exactly what is missing and stop. Don't substitute, mock or guess.

## What needs the human's go-ahead
<Posting in chat, editing tracker issues, opening a PR before the design is approved, editing outside scope, force-pushing, changing CI.> Investigate-only threads make no edits at all.

## Reporting back
Write for someone new to the company and the repo. Be concise and plain, and use a small concrete example. Lead with the outcome. Then the evidence (commands, output, file:line), the decisions, the risks, and what needs the human.
