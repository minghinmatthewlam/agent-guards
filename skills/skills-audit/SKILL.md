---
name: skills-audit
description: "Audit agent skills for triggering quality, correctness, context efficiency, redundancy, structure, failure guidance, and coverage gaps. Use when the user asks to review, improve, compare, simplify, or evaluate skills in global, repo-local, Claude, Codex, or custom skill paths."
---

# Audit Skills

Perform a read-only, evidence-backed audit of the requested skills. Default to decision-relevant findings, not an exhaustive ceremony.

## Discover

Inspect the paths in scope, including when relevant:

- `~/.agents/skills/`, `~/.claude/skills/`, and `~/.claude/commands/`;
- repo-local `.agents/skills/` and `.claude/skills/`;
- custom paths named by the user.

Deduplicate synced or linked copies and identify the source of truth. Note agent system, folder resources, frontmatter, and broken links or scripts.

## Evaluate

Read `references/checklist.md` and apply only relevant checks. Use `references/categories.md` when classification helps reveal mixed responsibilities or a repository-level coverage gap; do not force classification when it adds no decision value.

Prioritize:

- incorrect, stale, conflicting, or unsafe instructions;
- duplicated guidance likely to drift;
- always-loaded detail better routed through references or scripts;
- weak trigger descriptions;
- missing real-world failure guidance;
- rigid procedures that prevent capable agents from adapting;
- missing skills only when repository evidence shows repeated value.

Numeric scores are optional comparison aids, not required output. Never penalize a short behavioral skill for lacking unnecessary resources.

## Report

Use `concisely`. Include every material finding, ordered by impact, with exact file evidence and the smallest useful change. Group clean or low-priority skills rather than producing filler.

Distinguish observed evidence from inference. Do not impose a fixed findings count.

## Apply Mode

Audit first. If the user asks for changes, edit only the approved scope, preserve useful non-obvious guidance through progressive disclosure, validate the changed skills, and report proof.

## Gotchas

- Do not audit installed mirrors as independent skills when they share one source.
- Do not optimize for line count at the cost of deleting real failure knowledge.
- Do not treat a large command reference as always-loaded context when it is properly routed.
- Do not recommend generic new skills without repository evidence that they would recur.
