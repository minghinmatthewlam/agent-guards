# Workers in poteto-mode

Read this when the human wants workers to run in poteto-mode (the pstack plugin). poteto-mode brings its own playbooks and multi-model skills (`architect`, `arena`, `interrogate`, `swarm`). The coordinator stays the outer program. Workers run one single-task playbook each (Feature, Bug fix, Refactoring, and so on). Never run poteto's Orchestrate playbook alongside this skill: both own the program, and its store would duplicate the board.

## Turn it on in the brief

A skill named at the start of a T3 message is not run as a command, so say it in the brief text:

- **Codex worker:** start the brief with `$poteto-mode`. Codex loads the skill from the mention.
- **Claude worker:** start the brief with "Before any work, load `pstack:poteto-mode` with the Skill tool and follow it."

This line goes first, above the project instructions. The project instructions and the task follow, as the SKILL.md brief section says.

## Models

Every pstack role reads `~/.config/pstack/models.md`. Map each slug to a spawn the way your mode allows:

| Slug in models.md | Same family as the caller | Other family (T3 Code) |
|---|---|---|
| `anthropic/claude-opus-5.5` | Claude's Agent tool, `model: "opus"`, or omit it when the caller already runs Opus 5.5 | `delegate_task`, the Claude provider whose `canRunChildTask` is true (now `claude_openrouter_shared`), model `claude-opus-5-5` |
| `openai/gpt-6.1-sol` | Codex's `spawn_agent` | `delegate_task`, provider `codex`, model `openai/gpt-6.1-sol` |

The models.md budget line sets the reasoning option (`large` is `{"reasoningEffort": "xhigh"}` on Codex). pstack's own fallback, `codex exec -m <slug>`, runs outside T3, where it is invisible, can't be cancelled, and never reports back. In T3, add this to every poteto brief: "A pstack role whose model your native subagent tool can't select runs through the t3-code `delegate_task` tool, not `codex exec`. `delegate_task` has no `subagent_type`, so a playbook helper that would be a `poteto-agent` gets, as the first line of its task, 'Before any work, load the pstack poteto-mode skill and follow it (Claude: the Skill tool with `pstack:poteto-mode`; Codex: `$poteto-mode`).' Review skills (`how`, `why`, `interrogate`, `reflect`, `swarm`) keep their own prompts."

Delegated children run in the caller's checkout. A pstack step that writes (arena candidates, swarm workers that edit) gives each writer its own git worktree, as arena's Phase A already says. pstack's `environment: "cloud"` is Cursor-only; in T3 every worker is local.

## The workflow, mapped

The SKILL.md default workflow still governs. Under poteto-mode each step uses these tools:

1. **Design:** pstack's `architect` (`pstack:architect` in Claude, not the personal `architect` skill), **with checkpoint**. Write "Run pstack's architect with checkpoint: stop and show me the design before implementing" in the brief. Without it, architect's Phase C goes straight to implementation. Its arena runners are already cross-model (`architect runners` in models.md).
2. **Implement:** the matched playbook. The worker restates the issue in plain English first, per poteto-mode's Non-negotiables.
3. **Review loop:** the worker runs `autoreview` until no blockers, then reports. The coordinator runs pstack `interrogate` itself, from its own session, on the worker's committed worktree. Load it with the Skill tool (`pstack:interrogate`) or, on Codex, `$interrogate`. One reviewer per `interrogate reviewers` entry in models.md, each started as the models table says, all in one message. A reviewer that didn't write the code is the independent check. Relay the Act-on findings; repeat with fresh reviewer tasks until Act-on is empty.
4. **Self-test:** the repo's `verify-*` skill. poteto-mode's `control-ui` / `control-cli` and `deslop` come from Cursor's `cursor-team-kit`, which isn't installed here; tell the worker to use the repo's verify skill and skip `deslop`.
5. **Open the PR:** poteto's Opening a PR playbook, ready unless the human said draft.
6. **Babysit:** poteto's Babysit playbook in `drive` mode, but woken by T3's `watch_pull_request` instead of `/loop` and `watch-pr` polling. Each wake is one pass: conflicts, then review threads, then CI. The playbook's understanding gate and merge rule still hold. Never enable auto-merge.
7. **Reviews:** bot comments are triaged with poteto's `references/bugbot-triage.md`. Ask the human before replying to a human reviewer.

## Reading a poteto report

poteto replies name the principles behind each decision and label every claim measured, inferred or guess. Keep those labels when you rewrite the report for the human: they are the confidence ratings the Report section asks for.
