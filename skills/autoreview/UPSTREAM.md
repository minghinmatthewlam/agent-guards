# Upstream

Vendored from OpenClaw `agent-skills`:

- Repository: https://github.com/openclaw/agent-skills
- Skill path: `skills/autoreview`
- Imported commit: `2c90aa80ae3a7d922e319ea50234cbfb644f6b0b`

Local changes:

- The workflow now uses native subagents rather than the upstream CLI helper.
- The helper, engine-specific references, and helper tests have been retired.
- Review judgment retains local scope, simplicity, evidence, and priority rules.

This is a local workflow adaptation, not a drop-in copy of the upstream helper.
