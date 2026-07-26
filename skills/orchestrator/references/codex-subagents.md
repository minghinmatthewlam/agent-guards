# Codex Subagents

Use native collaboration subagents for bounded delegated work. Keep the coordinator in the current user-facing session; do not create a separate Codex task unless the user explicitly asks for one.

## Tools

Use the native collaboration tools:

- `spawn_agent`: start a bounded worker.
- `followup_task`: continue an idle worker with preserved context.
- `send_message`: pass information without starting another turn.
- `wait_agent`: wait for completion, blockers, or mailbox updates.
- `list_agents`: inspect current worker state.
- `interrupt_agent`: stop work that is stale, incorrect, or no longer needed.

Use the shared checkout for read-only work and one safe edit worker when its state and ownership are understood. Read [worktrees.md](worktrees.md) before concurrent editing or risky isolated work.

Set `fork_turns: "none"` for independent research or review. Pass the smallest useful positive turn count when recent task history matters, and use full history only when the worker cannot reasonably reconstruct the needed context from its task contract. Full-history forks inherit the parent model and reasoning effort; use fresh or bounded context when an override is required.

Match reasoning effort to the assignment: low for narrow scouts, medium for routine implementation, and high for difficult or ambiguous work. Treat these as defaults, not fixed roles.

Tell leaf workers to complete the assignment directly and not delegate. Allow nested delegation only when the worker owns a genuinely separable outcome and the concurrency budget supports it.

## Coordinate And Accept

Workers may message one another when a dependency is clear, but the coordinator retains task ownership, conflict resolution, acceptance, and final reporting.

Use bounded waits rather than polling worker transcripts. Follow up on the same worker when implementation directly follows its audit or its prior reasoning remains useful. Start a fresh worker when independence matters.

Before accepting, inspect the claimed files, proof, and real affected surface according to the shared acceptance rules. Interrupt only for a concrete stall, incorrect scope, new user direction, or work that is no longer needed.
