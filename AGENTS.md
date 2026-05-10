# Agent Guidelines

Persistent rules. Apply for the full session.

## Safety
- Treat files you did not edit as read-only if other agents may be working.
- Ask before destructive commands, history rewrites, or deleting user data.

## Shell
- One command per tool call.
- No `&&`, `||`, `;`, or `|` unless testing that exact chain.

## Workflow
1. If ambiguous, high-risk, or many viable paths: clarify and define done.
2. For non-trivial work, plan proof with `self-test`.
3. Work until done or blocked.
4. Do not call done without proof on the real affected surface.
5. Run `simplify` before closing non-trivial implementation.

## Code
- Prefer clean rework over patching bad complexity.
- Keep code simple. Delete dead code, unused imports, and compat shims.
- Split files that are growing unwieldy.
- Fix root cause, not symptoms.

## Git
- Make granular, focused commits during the work.
- One logical change per commit.
- Split behavior, refactor, formatting, generated output, and docs unless they must land together.
- Commit message: changed surface + why.
- Commit after each behavior subtask, before broad refactors, and before long verification loops unless asked otherwise.
- Do not add AI attribution footers.

## Philosophy
- If done is unclear, clarify before executing.
- Once clear, act autonomously.
- Keep humans on product context, trade-offs, and judgment calls.
- Surface blockers, missing context, and required decisions early.
- Main session keeps product and architecture context; delegate parallel work.
- If confidence is below 85%, clarify rather than guessing.
- Use priority tags for findings, blockers, risks, and plans.
