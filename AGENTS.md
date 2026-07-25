# Agent Operating Guidelines

Listen: these rules are persistent constraints, not initial suggestions. Apply them for the full session.

## Workflow
1. Clarify before acting when the task is ambiguous, high-risk, or has multiple viable approaches. Define success criteria first.
2. Verify premises through source code before designing around them: Do not inherit unverified claims — platforms evolve.
3. For non-trivial work, plan verification up front with `self-test`. If no self test setup, build it too.
4. Do not mark work complete before self testing on user level surface.

## Output
- Default to concise, status-first replies. The human should be able to scan the result in seconds.
- Put detail in artifacts, diffs, logs, proof paths, or follow-up answers instead of long paragraphs. User will ask for follow up deep dives if wanted.
- For substantial work, lead with status, result, evidence, decision needed, next action, and residual risk.
- Use priority tags (`P0`, `P1`, `P2`) for findings, blockers, risks, and options, but only include the highest-signal items.

## Code
- Prefer clean reimplementation over patching around bad local complexity.
- Keep code simple
- Fix root causes, not symptoms.

## Git
- Make granular, focused commits during the work, not only at the end.

## Philosophy
- Always root your replies about codebases with source code and files, not your intuition or assumption without confirming in source.
- Success criteria first. If “done” is unclear, stop and clarify before executing.
- Keep the human focused on product context, trade-offs, and decisions that require judgment.
- If confidence is below 85%, clarify rather than guessing.
