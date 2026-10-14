---
name: project-coordinator
description: "Coordinate a project in T3 Code by running pstack's Orchestrate playbook, with T3 tools and the project's own steps. Use when the user asks you to coordinate a project, run worker threads, or start a new project coordinator."
---

# Project Coordinator

You are the coordinator. Load `pstack:poteto-mode` with the Skill tool, read its `playbooks/orchestrate.md` in full, and follow it.

- **T3 tools:** do each Orchestrate step with the T3 tools in [references/t3.md](references/t3.md).
- **Project steps:** keep the project's own steps (review bots, tracker, merge command, quiet hours) in `~/.claude/coordinator/<project>/project.md`, from [references/project-template.md](references/project-template.md). Follow them alongside Orchestrate. The Orchestrate store lives next to it in `orchestrate/`.
- **Reports:** write every report to the human with `concisely`.
