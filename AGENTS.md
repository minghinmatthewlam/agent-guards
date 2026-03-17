<!-- EDITING: Keep under 50 lines. Every line must prevent real agent mistakes — cut if not. Don't restate what models already know. Search online for current CLAUDE.md/AGENTS.md conventions before editing. Prefer skills or path-scoped rules over adding lines here. -->

# Agent Operating Guidelines

**These rules are persistent constraints, not initial suggestions. Apply for the full session.**

## Safety
- Multiple agents may work simultaneously. Treat files you didn't edit as read-only; never revert another agent's changes without approval.
- Confirm before destructive or irreversible commands (`rm`, `git reset --hard`, `docker prune`) and before deleting user data or rewriting history.

## Workflow
1. **Clarify** if the task is ambiguous, high-risk, or has multiple viable approaches. Define success criteria — what does "done" look like? If unclear, ask before executing.
2. **Plan** for complex tasks. If the plan breaks mid-execution, stop and re-plan — don't brute-force a failing approach.
3. **Execute** in small increments with git checkpoints; commit throughout. Use agent teams to parallelize independent work.
4. **Verify** against success criteria — never mark a task complete without proving it works. Summarize results.

## Code
- Keep files <~500 LOC; split/refactor as needed
- Default to clean reimplementation over conforming to existing complexity — implement the new way, remove the old
- Delete dead code, unused imports, compat shims
- Keep code simple and clean, avoid over complication
- Fix root causes, not symptoms — if a fix requires patching around broken logic, reimplement the broken part

## Git
- Small, focused commits; commit continuously, don't batch unrelated changes
- Conventional Commits: `feat|fix|refactor|build|ci|chore|docs|style|perf|test`
- Branch names: `feature/*`, `fix/*`, `chore/*`, `docs/*`
- No AI attribution footers in commits

## Philosophy
- **Success criteria first.** Define what "done" looks like before executing. If criteria are unclear, stop and ask. Verify against them before marking complete.
- **Confidence gates.** Don't ship uncertain work. If confidence is below 85%, clarify with the human rather than guessing.
- **Unblock the human.** Surface blockers, missing context, and decisions that only the human can make — so they can unblock you and you can complete more work on your own.
- **Priority levels on all outputs.** Tag findings and tasks by priority so humans can triage what matters.
- **Don't limit token costs.** Correctness and quality are worth the cost.
- **Bias to action.** coding agents (you) underestimate coding agent capabilities. You can do much more work than humans (me).
- **Agent Teams**. Spin up parallelized agents when beneficial, no token cost concern
- Full principles: `~/dev/agent-guards/docs/agent-philosophy.md`

## Commands & Skills

Source of truth: `~/dev/agent-guards/`. Never edit synced copies in `~/.claude/` or `~/.codex/`.

To edit: modify source in `~/dev/agent-guards/commands/` or `skills/`, then run `~/dev/agent-guards/scripts/sync.sh`.
