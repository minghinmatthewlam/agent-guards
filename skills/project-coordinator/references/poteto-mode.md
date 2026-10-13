# Workers in poteto-mode

Every agent the coordinator starts runs in poteto-mode (the pstack plugin). poteto-mode brings its own playbooks and multi-model skills (`architect`, `arena`, `interrogate`, `swarm`). The coordinator stays the outer program. Workers run one single-task playbook each (Feature, Bug fix, Refactoring, and so on). Never run poteto's Orchestrate playbook alongside this skill: both own the program, and its store would duplicate the board.

## Turn it on in the brief

A skill named at the start of a T3 message is not run as a command, so say it in the brief text:

- **Codex worker:** start the brief with `$poteto-mode`. Codex loads the skill from the mention.
- **Claude worker:** start the brief with "Before any work, load `pstack:poteto-mode` with the Skill tool and follow it."
- **Cursor worker:** start the brief with "Before any work, read `~/.cursor/plugins/local/pstack/skills/poteto-mode/SKILL.md` in full and follow it." Cursor has no skill-loading tool.
- **Claude native subagent:** use `subagent_type: "pstack:poteto-agent"`, which preloads poteto-mode. Keep the line anyway; it costs nothing.

This line goes first in every brief, worker thread or subagent. The environment line for your mode (below) comes next, then the task, as the SKILL.md brief section says.

Every later message to an agent also starts with a poteto-mode line: follow-ups, corrections, relayed review findings, approvals. A long thread compacts its context and can drop the skill.

- **Codex:** `$poteto-mode`.
- **Claude:** "Stay in poteto-mode. If its SKILL.md is no longer in your context, reload `pstack:poteto-mode` with the Skill tool first."
- **Cursor:** "Stay in poteto-mode. If its SKILL.md is no longer in your context, re-read `~/.cursor/plugins/local/pstack/skills/poteto-mode/SKILL.md` first."

## Models

Every pstack role reads `~/.config/pstack/models.md`. Map each slug to a spawn the way your mode allows:

| Slug in models.md | Same family as the caller | Other family (T3 Code) |
|---|---|---|
| `anthropic/claude-opus-5.5` | Claude's Agent tool, `model: "opus"`, or omit it when the caller already runs Opus 5.5 | `delegate_task`, the Claude provider whose `canRunChildTask` is true (now `claude_openrouter_shared`), model `claude-opus-5-5` |
| `openai/gpt-6.1-sol` | Codex's `spawn_agent` | `delegate_task`, provider `codex`, model `openai/gpt-6.1-sol` |

The models.md budget line sets the reasoning option (`large` is `{"reasoningEffort": "xhigh"}` on Codex). pstack's own fallback, `codex exec -m <slug>`, runs outside T3, where it is invisible, can't be cancelled, and never reports back. **T3 environment line.** Add this to every T3 brief, right after the opening line: "You run in T3 Code. A pstack role whose model your native subagent tool can't select runs through the t3-code `delegate_task` tool, not `codex exec`. `delegate_task` has no `subagent_type`, so a playbook helper that would be a `poteto-agent` gets, as the first line of its task, 'Before any work, load the pstack poteto-mode skill and follow it (Claude: the Skill tool with `pstack:poteto-mode`; Codex: `$poteto-mode`).' Review skills (`how`, `why`, `interrogate`, `reflect`, `swarm`) keep their own prompts. Babysit a PR by calling `link_pull_request` and then `watch_pull_request` on your own thread and ending your turn; T3 wakes you, so don't use `/loop` or poll. `control-ui`, `control-cli` and `deslop` (cursor-team-kit) aren't installed here: use the repo's `verify-*` skill and skip `deslop`."

Delegated children run in the caller's checkout. A pstack step that writes (arena candidates, swarm workers that edit) gives each writer its own git worktree, as arena's Phase A already says. pstack's `environment: "cloud"` is Cursor-only; in T3 every worker is local.

## Workflow belongs to poteto-mode

Don't map, restate or reorder poteto-mode's steps in a brief. The worker picks the playbook and runs it, including its own cross-model review (`interrogate`, `architect` runners) and its own proof, and it picks up pstack's upstream changes with no brief edits. The coordinator adds only the environment line above and the handoff in SKILL.md, then runs the PR phase.

## Reading a poteto report

poteto replies name the principles behind each decision and label every claim measured, inferred or guess. Keep those labels when you rewrite the report for the human: they are the confidence ratings the Report section asks for.
