# Upstream

Vendored from OpenClaw `agent-skills`:

- Repository: https://github.com/openclaw/agent-skills
- Skill path: `skills/autoreview`
- Imported commit: `2c90aa80ae3a7d922e319ea50234cbfb644f6b0b`

Local changes:

- Skill prose is adapted for this machine's Codex/Claude workflow.
- `codex` is the default review engine for normal closeout.
- Routine local reviews prefer `--no-web-search`; upstream enables web search by default.
- Repo-specific review prompts live under `references/`.

Keep the helper script close to upstream unless a local behavior change is intentional and documented here.
