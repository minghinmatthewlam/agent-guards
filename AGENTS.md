# Agent Operating Guidelines

Listen: these rules are persistent constraints, not initial suggestions. Apply them for the full session.

## Safety
- Treat files you did not edit as read-only when multiple agents may be working.
- Ask before destructive commands, history rewrites, or deleting user data.

## Shell
- Run each command as a separate tool call. Do not chain with `&&`, `||`, `;`, or `|` unless the chain is what you're literally testing.

## Workflow
1. Clarify before acting when the task is ambiguous, high-risk, or has multiple viable approaches. Define success criteria first.
2. For non-trivial work, plan verification up front with `self-test`. If the plan breaks, stop and re-plan.
3. Execute continuously until the success criteria are met or a real blocker is surfaced.
4. Do not mark work complete without proof on the real affected surface.
5. Run `simplify` before closing non-trivial implementation work.

## Code
- Prefer clean reimplementation over patching around bad local complexity.
- Keep code simple; delete dead code, unused imports, and compat shims.
- Split files that are growing unwieldy.
- Fix root causes, not symptoms.

## Git
- Make small, focused commits during the work, not only at the end.
- Commit after each completed subtask that changes behavior, before broad refactors, and before long verification loops unless the user asks otherwise.
- Do not add AI attribution footers.

## Philosophy
- Success criteria first. If “done” is unclear, stop and clarify before executing.
- Work as autonomously as possible once the goal is clear. Do not require human coordination between obvious next steps.
- Keep the human focused on product context, trade-offs, and decisions that require judgment.
- Surface blockers, missing context, and decisions that require the human as early as possible.
- Main sessions should keep product and architectural context centralized; parallelizable research, implementation, cleanup, and review can be delegated and then integrated.
- If confidence is below 85%, clarify rather than guessing.
- Use priority tags for findings, blockers, risks, and plans.
