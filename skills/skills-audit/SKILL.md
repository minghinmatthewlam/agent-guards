---
name: skills-audit
description: "Audit agent skills for triggering quality, correctness, context efficiency, redundancy, structure, failure guidance, and coverage gaps. Use when the user asks to review, improve, compare, simplify, or evaluate skills in global, repo-local, Claude, Codex, or custom skill paths."
---

# Audit Skills

Perform a read-only, evidence-backed audit focused on decision-relevant findings.

## Discover & Evaluate

- Inspect paths in scope (`~/.agents/skills/`, `~/.claude/skills/`, `~/.claude/commands/`, repo `.agents/skills/`, `.claude/skills/`, custom paths). Deduplicate synced/linked mirrors to their source of truth.
- Consult [`references/checklist.md`](references/checklist.md) (and [`references/categories.md`](references/categories.md) when helpful); apply only relevant checks.
- Prioritize: incorrect/stale/unsafe instructions, drift-prone duplication, context efficiency (progressive disclosure), weak triggers, missing real-world gotchas, overly rigid procedures, and evidence-backed coverage gaps.
- Don't penalize short behavioral skills for lacking extra folders, and don't cut real failure knowledge just to reduce line count.

## Report & Apply

Use `concisely`. Order material findings by impact with exact file evidence and the smallest useful fix; group clean skills; separate observed facts from inference.

Audit first. If asked to apply changes, edit only approved scope, validate changed skills, and report proof.
