# Claude Code Subagents

Use Claude Code's native `Agent` tool for focused delegated work. Each subagent has its own context window and returns its result to the parent, keeping intermediate searches, logs, and file reads out of the coordinator's context.

## Choose The Native Mode

- Use a foreground subagent when the coordinator needs the result before continuing.
- Use a background subagent for independent work and inspect it through `/tasks`.
- Use agent teams only when workers genuinely need a shared task list and direct peer communication; teams are experimental and cost more.
- Use [headless Pi workers](claude-pi.md) only when the user explicitly requests Pi or the task requires a detached external process with heartbeat and schema-bound result files.

Use the built-in general-purpose subagent unless a recurring role justifies a custom agent under `~/.claude/agents/` or `.claude/agents/`. Preload skills only when the worker needs them.

## Context And Ownership

Claude subagents start with fresh conversation context. Put the product goal, bounded assignment, relevant paths or errors, starting commit or working-tree state, permissions, success criteria, and expected evidence directly in the prompt.

Give concurrent edit workers disjoint file ownership or isolate them with worktrees. Tell leaf workers to finish directly; native subagents do not need nested delegation for ordinary bounded tasks.

## Follow-up And Acceptance

Resume the same general-purpose or custom subagent with `SendMessage` when implementation directly follows its audit; completed subagents retain their context and return an agent ID. Built-in Explore and Plan agents are one-shot, so start a focused new subagent with the accepted findings and current repository state when they were used.

Treat the returned summary as worker-reported evidence. Inspect the claimed files and rerun the highest-signal proof before accepting or integrating the result.
