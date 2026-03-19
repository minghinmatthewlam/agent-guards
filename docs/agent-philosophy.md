# Agent Philosophy

Principles for how agents should work, how to configure them, and when to build tooling around them.

## Core Belief: Models Keep Getting Smarter

Frontier AI models are rapidly improving at code understanding, planning, and context management. Don't over-invest in infrastructure around limitations that will be solved by the next model generation. Focus custom configuration on things that are genuinely repo-specific and team-shared.

**But don't sit on friction waiting for frontier improvements.** If you repeat a workflow often with real pain, build a skill for it now. You can always trim later as models improve. High-priority daily workflows override the "wait for models" rule.

## Roles

**Human's role = product context.** Trade-offs, architectural decisions, product goals — things not in code. Everything else (planning, coding, reviewing, shipping) agents do better. The human steers; agents execute.

**Main session = orchestrator.** Keep product and architectural context concentrated in the main session when possible. Offload parallelizable research, implementation, cleanup, and review to fresh-context agents, then integrate results centrally.

**Agents should auto-chain when confidence is high.** Don't require human coordination between steps. Plan, implement, review, ship should flow automatically after plan approval. Human intervention is for course correction, not handoffs.

## Tools + Success Criteria > Step-by-Step Guidance

Agents are capable of figuring out complex paths on their own. The human's job is to provide two things: **the right tools** and **clear success criteria**. Don't over-specify the how — specify what "done" looks like and let the agent work toward it. If success criteria are unclear, the agent should stop and clarify before executing.

## Quality Over Speed

- **Plan for self-test, not just implementation.** A good plan includes how the agent will verify the work end-to-end, what tools or access are required, and what blockers must be resolved before coding.
- **Confidence thresholds.** Prefer correctness over speed. Keep working until confident (85%+). Don't ship uncertain work.
- **Simplify before final review.** Agents tend to overcomplicate solutions and inherit bad local patterns. After implementation, run `simplify` before the final review loop on non-trivial changes.
- **Priority levels on all outputs.** Agents find too many things — focus on what matters. Tag findings by priority so humans can triage.
- **Don't limit token costs.** The output quality is worth the cost.

## Instruction Files (AGENTS.md / CLAUDE.md)

### Principles
- Every line must prevent real agent mistakes — if removing it wouldn't cause failures, delete it
- Never restate what models already know from training
- Under 50 lines is gold standard for global instruction files
- Skills/on-demand loading over inline content — zero context cost until invoked
- Self-correcting rules ("search online for current conventions") over static snapshots
- Use compressed HTML metadata for structured info (commands, packages, stack)

### What Belongs
- Safety rules the model can't infer (multi-agent coordination, destructive commands)
- Workflow shape that differs from defaults
- Opinionated code rules that counteract model tendencies
- Specific choices the model can't infer (commit format, branch naming)
- Source-of-truth pointers and compressed metadata

### What Does NOT Belong
- Generic software engineering advice
- Tool usage docs (use skills)
- Code snippets, formatting rules, codebase descriptions
- Anything that changes frequently

## Skills

Skills are on-demand workflows that load only when invoked — zero context cost otherwise.

**Skill bar:** Before adding a skill, verify you can't solve it with a 1-2 line AGENTS.md addition or improvement to an existing skill. Skills have maintenance cost; don't create one for something a rule can handle.

## Documentation: Less Is More

Docs describing current code state drift when code changes without doc updates. Agents trust stale docs over reading code — this is worse than no docs.

| Need | Better mechanism |
|------|-----------------|
| "Why" at a decision point | Code comment (lives with code, can't drift) |
| Project structure overview | CLAUDE.md metadata HTML comments |
| Path-specific gotchas | .claude/rules/ with path scoping |
| Personal patterns | Auto memory (agent maintains its own) |
| What was done and when | Git history |
| Multi-step workflows | Skills (on-demand) |
| Team conventions | Instruction file |

No custom documentation frameworks. Use built-in mechanisms.

## Summary

1. Lean instruction files — under 50 lines
2. Design for model improvement — capabilities will grow
3. Build skills for high-friction daily workflows now
4. Human steers product decisions; agents do the rest
5. Tools + success criteria > step-by-step guidance
6. Auto-chain steps; minimize human handoffs
7. Main session orchestrates; agent teams research, implement, simplify, and review
8. Correctness over speed; prioritize outputs
9. No frameworks — use built-in mechanisms
10. Self-correcting rules over static snapshots
