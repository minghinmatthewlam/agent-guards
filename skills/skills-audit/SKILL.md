---
name: skills-audit
description: "Audit agent skills in a repo against best practices — checks .claude/skills/ and .agents/skills/ for quality, structure, and coverage gaps. Use when the user wants to review, improve, or evaluate their skills, or when they mention skill quality, skill audit, or skill best practices."
---

# Audit Skills

Scan a repo's agent skills and audit them against field-tested best practices. Works across agent systems — Claude Code (`.claude/skills/`), Codex (`.agents/skills/`), or custom paths.

## What This Skill Does

1. **Discover** all skills in the repo across agent systems
2. **Classify** each skill into a known category (flag skills that straddle multiple)
3. **Score** each skill against a quality checklist (agent-system-aware)
4. **Identify gaps** — skill categories missing given what the repo actually contains
5. **Output** a prioritized scorecard with specific, actionable recommendations

## Phase 1: Discover Skills

Search for skills in these locations (and any the user specifies):

- `.claude/skills/` — Claude Code skills
- `.agents/skills/` — Codex / generic agent skills
- `.claude/commands/` — Claude Code commands (lightweight skills)
- Any custom paths the user provides

For each skill found, note:
- Its agent system (claude, codex, generic)
- Whether it's a single file or a folder with resources
- The presence of frontmatter (name, description fields)

If no skills are found, tell the user and offer to help them create their first one.

## Phase 2: Classify Each Skill

Assign each skill to one of the 9 categories in `references/categories.md`. Read that file for the full taxonomy.

**Classification signals:**
- The skill name and description
- What the skill body instructs the agent to do
- What tools/scripts it references

If a skill clearly straddles two categories, flag it — this is a smell. Good skills fit cleanly into one category. Suggest how to split or refocus.

## Phase 3: Score Each Skill

Apply the checklist from `references/checklist.md` to each skill. The checklist has two tiers:

- **Universal checks** — apply to all skills regardless of agent system
- **Claude-specific checks** — only apply to skills in `.claude/skills/`

**Use judgment about applicability.** Not every check applies to every skill. The checklist has N/A options — use them. A 25-line behavioral skill shouldn't be penalized for lacking progressive disclosure or bundled scripts. A generic cross-repo skill shouldn't be penalized for "stating the obvious" when stating principles IS its purpose. Score only checks that are meaningful for that skill's purpose and size. The score denominator should reflect only the checks that apply (e.g., 5/6 if 2 checks were N/A out of 8).

For each applicable check, score as:
- **Pass** — the skill does this well
- **Partial** — present but could be better (explain how)
- **Missing** — not present (explain why it matters and how to add it)
- **N/A** — check doesn't apply to this skill (doesn't count toward total)

## Phase 4: Repo-Level Gap Analysis

Look at the repo's actual contents to identify missing skill categories:

- Has CI config (`.github/workflows/`, etc.) but no CI/CD skill?
- Has a test suite but no verification skill?
- Has internal libraries/SDKs but no library reference skill?
- Has deployment scripts but no deployment skill?
- Has data pipelines but no data fetching skill?

Suggest the highest-value skills to create, prioritized by how much time they'd save.

## Phase 5: Output the Scorecard

Present findings as a prioritized scorecard. Structure:

### Per-Skill Findings (ordered by priority)

For each skill, show:
- **Category**: which of the 9 types
- **Agent system**: claude / codex / generic
- **Score**: X/Y checks passing
- **Top issues** (P1 first): what to fix and how, with specific suggestions

### Repo-Level Gaps

- Missing skill categories with rationale
- Suggested new skills, ordered by estimated impact

### Quick Wins

Top 3-5 changes that would have the biggest impact across all skills. These are the "do these first" items.

## Apply Mode

If the user asks to fix/improve a specific skill, interactively apply the audit findings:

1. Show the specific issues for that skill
2. Propose concrete changes (restructure into folder, add gotchas section, rewrite description, etc.)
3. Get approval before making changes
4. Make the changes

Don't batch-apply fixes across all skills without asking — let the user pick which to improve.
