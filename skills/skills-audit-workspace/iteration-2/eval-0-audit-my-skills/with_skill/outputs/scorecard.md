# Skills Audit Scorecard

**Date:** 2026-03-17
**Locations scanned:**
- `~/.claude/skills/` (Claude Code) -- 13 skills
- `~/.agents/skills/` (Codex) -- 6 unique skills (rest are shared with Claude)
- `~/.claude/commands/` -- 1 command (uithub.md)

**Total unique skills audited:** 19

---

## Per-Skill Findings (ordered by priority)

---

### 1. rp-investigate-cli

| Field | Value |
|-------|-------|
| **Category** | Runbooks (#8) |
| **Agent system** | Codex only |
| **Score** | 3/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly a runbook/investigation workflow |
| Gotchas | **Missing** | Has anti-patterns section but no gotchas about rp-cli quirks, common failures, or investigation dead-ends |
| Progressive Disclosure | **N/A** | Single file, reasonable length |
| Description Quality | **Partial** | Describes what it does but not trigger conditions -- "Deep codebase investigation" is vague |
| Avoids Stating the Obvious | **Partial** | The rp-cli quick reference table is useful but repeated verbatim across 4 rp-* skills |
| Avoids Railroading | **Missing** | Very rigid 5-phase protocol with "REQUIRED" and "CRITICAL" tags everywhere. Forces builder usage even when simpler approaches might work |
| Scripts/References | **N/A** | Instruction-only workflow |
| Frontmatter | **Pass** | Has name and description |

**Top issues:**
- **P1: Massive duplication.** The rp-cli quick reference table, workspace verification section, and CLI window routing block are copied verbatim across rp-investigate, rp-oracle-export, rp-refactor, and rp-review. This should be a shared reference file.
- **P2: Overly railroaded.** The protocol forces a rigid phase sequence. The anti-patterns section literally says "don't read files manually" which removes agent flexibility for simple investigations.
- **P2: Description needs trigger phrases.** Should mention "debug", "trace", "find root cause", "why is X happening", etc.

---

### 2. rp-refactor-cli

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Codex only |
| **Score** | 3/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly code quality/refactoring |
| Gotchas | **Missing** | No gotchas about refactoring pitfalls, builder limitations, or common missteps |
| Progressive Disclosure | **N/A** | Single file, reasonable length |
| Description Quality | **Partial** | "Refactoring assistant using rp-cli" -- no trigger phrases |
| Avoids Stating the Obvious | **Partial** | Duplicated rp-cli reference table |
| Avoids Railroading | **Missing** | Requires two mandatory builder calls even for simple refactors. Anti-patterns forbid manual exploration |
| Scripts/References | **N/A** | Instruction-only |
| Frontmatter | **Pass** | Has name and description |

**Top issues:**
- **P1: Same duplication problem as all rp-* skills.** Identical boilerplate blocks.
- **P2: Rigid two-builder-call protocol** even for trivial refactors.

---

### 3. rp-review-cli

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Codex only |
| **Score** | 3/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly code review |
| Gotchas | **Missing** | No gotchas about common review misses, builder blind spots, or scope confirmation edge cases |
| Progressive Disclosure | **N/A** | Single file |
| Description Quality | **Partial** | "Code review workflow using rp-cli" -- no trigger phrases |
| Avoids Stating the Obvious | **Partial** | Duplicated boilerplate |
| Avoids Railroading | **Partial** | The mandatory scope confirmation (Step 2) is good design. But the rest is rigid |
| Scripts/References | **N/A** | Instruction-only |
| Frontmatter | **Pass** | Has name and description |

**Top issues:**
- **P1: Duplication** -- same as other rp-* skills.
- **P2: Straddles review-loop.** Both this skill and review-loop do code review. Unclear when to use which -- the description doesn't differentiate.

---

### 4. rp-oracle-export-cli

| Field | Value |
|-------|-------|
| **Category** | Data Fetching & Analysis (#3) -- borderline Business Process (#4) |
| **Agent system** | Codex only |
| **Score** | 3/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Partial** | It's a context export tool -- doesn't fit cleanly into any category |
| Gotchas | **Missing** | No gotchas about token limits, export failures, or builder timeouts |
| Progressive Disclosure | **N/A** | Short skill |
| Description Quality | **Partial** | "Export context for oracle consultation" -- no trigger phrases |
| Avoids Stating the Obvious | **Partial** | Contains duplicated workspace verification block |
| Avoids Railroading | **Pass** | Relatively flexible 2-step workflow |
| Scripts/References | **N/A** | Short instruction skill |
| Frontmatter | **Pass** | Has name and description |

**Top issues:**
- **P1: Duplicated boilerplate** with other rp-* skills.
- **P2: Overlaps with oracle skill** in Claude. Should clarify which to use when.

---

### 5. slack

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (#4) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 4/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly team automation via Slack |
| Gotchas | **Partial** | Has a Limitations section and debugging section, but no gotchas about common failures (e.g., "Slack redesigns break refs frequently", "2FA popups interrupt sessions") |
| Progressive Disclosure | **Partial** | Has references/ and templates/ dirs but the main SKILL.md is 289 lines. The "Common Tasks" section with all those code examples could be a reference file |
| Description Quality | **Pass** | Good trigger phrases -- "check my Slack", "what channels have unreads", etc. |
| Avoids Stating the Obvious | **Partial** | A lot of generic agent-browser usage patterns that duplicate the agent-browser skill. The "Best Practices" section is mostly restating agent-browser basics |
| Avoids Railroading | **Pass** | Provides patterns, lets agent choose |
| Scripts/References | **Partial** | Has references/ dir but many inline examples could be extracted |
| Frontmatter | **Pass** | Has name, description, allowed-tools |

**Top issues:**
- **P1: Duplicates agent-browser content.** The core workflow, snapshot patterns, and best practices heavily overlap with agent-browser. This skill should focus on Slack-specific knowledge (sidebar structure, element naming patterns, workspace quirks) and reference agent-browser for the tool basics.
- **P2: Main file too long at 289 lines.** Move Common Tasks and Example sections to references/.

---

### 6. agent-browser

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 6/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly a library/CLI reference |
| Gotchas | **Pass** | Ref lifecycle section is essentially a gotchas section. Security section documents non-obvious behavior. Shell quoting gotcha in eval section |
| Progressive Disclosure | **Pass** | Has references/ (7 files) and templates/ (3 files) with clear table of when to read each |
| Description Quality | **Pass** | Excellent trigger phrases covering many user intents |
| Avoids Stating the Obvious | **Pass** | Content is specific to agent-browser, not generic browser automation |
| Avoids Railroading | **Pass** | Provides information and patterns, agent decides |
| Scripts/References | **Pass** | Templates and deep-dive references well organized |
| Frontmatter | **Pass** | Has name, description, allowed-tools |

**Top issues:**
- **P2: Main file is 633 lines.** Even with good progressive disclosure, the main file could be trimmed. The "Common Patterns" section (Form Submission, Auth with State Persistence, Session Persistence, Data Extraction, etc.) largely duplicates earlier sections and could move to a reference file.

---

### 7. fix-ci

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment (#7) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 6/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly CI/CD |
| Gotchas | **Partial** | Has error handling section but could document more non-obvious failures (e.g., "gh run view sometimes returns stale logs", "external checks can't be fixed") |
| Progressive Disclosure | **Pass** | Has scripts/ with inspect_pr_checks.py |
| Description Quality | **Pass** | Good triggers -- "fix failing CI", "check PR status", "get a PR merge-ready" |
| Avoids Stating the Obvious | **Pass** | All content is specific to the CI fix workflow |
| Avoids Railroading | **Partial** | The 8-step protocol is somewhat rigid, but each step has conditional logic and flexibility within it |
| Scripts/References | **Pass** | Bundled Python script for robust log extraction |
| Frontmatter | **Pass** | Has name, description, metadata |

**Top issues:**
- **P2: Could add gotchas section** about common CI fix pitfalls (flaky tests, rate limits, timing issues).
- **P3: Step-by-step protocol is detailed but acceptable** for a workflow skill.

---

### 8. ios-release

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment (#7) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 6/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly deployment |
| Gotchas | **Partial** | Guardrails section covers safety but no gotchas about common ASC failures, timeout issues, or validation false positives |
| Progressive Disclosure | **Pass** | Has references/ (4 files) with clear reference map |
| Description Quality | **Pass** | Good trigger phrases -- "shipping to TestFlight", "preparing App Store submission", etc. |
| Avoids Stating the Obvious | **Pass** | All ASC-specific knowledge |
| Avoids Railroading | **Pass** | Phase A/B split with explicit approval gate is well-designed |
| Scripts/References | **Pass** | 4 reference files for deep-dive topics |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P3: Add a gotchas section** documenting common ASC failure modes (upload timeouts, validation edge cases, signing issues).

---

### 9. ios-dev

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 6/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Library reference for xcodebuildmcp |
| Gotchas | **Partial** | Guardrails section has some, but no dedicated gotchas section about common xcodebuildmcp failures |
| Progressive Disclosure | **N/A** | 148 lines, appropriate for single file |
| Description Quality | **Pass** | Good triggers -- "normal iOS development", "simulator/device build issues", "runtime crashes" |
| Avoids Stating the Obvious | **Pass** | All xcodebuildmcp-specific |
| Avoids Railroading | **Pass** | Provides commands and patterns, agent picks what's relevant |
| Scripts/References | **N/A** | Instruction-only, appropriate for this size |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P3: Add gotchas** about xcodebuildmcp quirks (daemon behavior, simulator boot failures, scheme discovery edge cases).

---

### 10. remotion-best-practices

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Codex only |
| **Score** | 5/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Library reference for Remotion |
| Gotchas | **Missing** | No gotchas about common Remotion pitfalls. The rules files may contain some but the main SKILL.md doesn't surface them |
| Progressive Disclosure | **Pass** | Excellent use of folder structure -- 26 rule files organized by topic |
| Description Quality | **Partial** | "Best practices for Remotion" -- no trigger phrases. Should mention "video", "animation", "composition", "rendering" as triggers |
| Avoids Stating the Obvious | **Pass** | Remotion-specific knowledge |
| Avoids Railroading | **Pass** | Reference material, no rigid protocol |
| Scripts/References | **Pass** | 26 rule files as references |
| Frontmatter | **Pass** | Has name, description, metadata |

**Top issues:**
- **P2: Description needs trigger phrases.** "Best practices for Remotion - Video creation in React" won't reliably trigger. Add: "Use when creating videos, animations, compositions with Remotion, React video rendering, timeline-based animations."
- **P2: Missing top-level gotchas.** Surface the 3-5 most common Remotion foot-guns in the main SKILL.md so the agent sees them without having to read all 26 rule files.

---

### 11. oracle

| Field | Value |
|-------|-------|
| **Category** | Data Fetching & Analysis (#3) -- cross-model consultation |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 6/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Partial** | It's a cross-model consultation tool -- doesn't map perfectly to any category, closest to Data Fetching |
| Gotchas | **Pass** | Sessions + slugs section documents non-obvious failure modes. Safety section is practical |
| Progressive Disclosure | **N/A** | 88 lines, appropriate single file |
| Description Quality | **Pass** | Mentions specific use cases -- "debugging, refactors, design checks, cross-validation" |
| Avoids Stating the Obvious | **Pass** | Oracle-specific knowledge |
| Avoids Railroading | **Pass** | Golden path with flexibility |
| Scripts/References | **N/A** | Appropriate for this skill |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P3: Category fit.** Consider this a unique "Cross-Model Consultation" type. Not a real problem, just noting.

---

### 12. orchestrator

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (#4) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Meta-workflow orchestrator |
| Gotchas | **N/A** | Meta-skill that delegates to other skills |
| Progressive Disclosure | **N/A** | 41 lines, appropriate single file |
| Description Quality | **Partial** | "Orchestrate complex tasks with agent teams" -- should add triggers like "big task", "multi-step project", "needs planning and implementation" |
| Avoids Stating the Obvious | **Pass** | Specific to the agent team workflow |
| Avoids Railroading | **Pass** | Provides phases but lets sub-skills handle details |
| Scripts/References | **N/A** | Delegates to other skills |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P3: Description could have more triggers.** The agent may not know to invoke this for complex multi-step tasks.

---

### 13. plan-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Partial** | It's a planning workflow, not exactly code review. Closest fit but not clean |
| Gotchas | **N/A** | Process skill, no tool-specific gotchas |
| Progressive Disclosure | **Pass** | Has references/review-protocol.md |
| Description Quality | **Partial** | Describes the process but no user-facing triggers. Add: "plan this", "let's think through this", "help me plan", "design this before coding" |
| Avoids Stating the Obvious | **N/A** | Intentionally generic cross-repo process |
| Avoids Railroading | **Pass** | Flexible round sizing, confidence-gated progression |
| Scripts/References | **Pass** | review-protocol.md reference |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P2: Description needs trigger phrases** for reliable invocation.

---

### 14. review-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Code review process |
| Gotchas | **N/A** | Process skill |
| Progressive Disclosure | **Pass** | Has references/review-protocol.md |
| Description Quality | **Partial** | Describes the process but not when to trigger. Add: "review my code", "check this implementation", "is this ready to ship" |
| Avoids Stating the Obvious | **N/A** | Intentionally generic cross-repo process |
| Avoids Railroading | **Pass** | Flexible round sizing |
| Scripts/References | **Pass** | review-protocol.md reference |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P2: Description needs trigger phrases.**
- **P2: Overlap with rp-review-cli.** Users may not know which review skill to use.

---

### 15. audit-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Read-only audit process |
| Gotchas | **N/A** | Process skill |
| Progressive Disclosure | **Pass** | Has references/review-protocol.md |
| Description Quality | **Partial** | Description is model-oriented ("both model families review evidence") but lacks user-facing triggers. Add: "audit this", "investigate this", "analyze this codebase", "what's going on with" |
| Avoids Stating the Obvious | **N/A** | Intentionally generic |
| Avoids Railroading | **Pass** | Flexible |
| Scripts/References | **Pass** | review-protocol.md |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P2: Description needs user-facing trigger phrases.**

---

### 16. new-task

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (#4) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/5 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Requirements clarification process |
| Gotchas | **N/A** | Short behavioral skill |
| Progressive Disclosure | **N/A** | 31 lines |
| Description Quality | **Partial** | Should add triggers: "new feature", "I want to build", "help me think through", "let's scope this" |
| Avoids Stating the Obvious | **N/A** | Behavioral/process skill |
| Avoids Railroading | **Pass** | Flexible question strategy |
| Scripts/References | **N/A** | Short skill |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P3: Description trigger phrases** would help invocation.

---

### 17. self-test

| Field | Value |
|-------|-------|
| **Category** | Product Verification (#2) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/5 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Verification behavioral overlay |
| Gotchas | **N/A** | Behavioral skill |
| Progressive Disclosure | **N/A** | 26 lines |
| Description Quality | **Pass** | Excellent trigger phrases -- "make sure it works", "test it yourself", "don't just tell me it's done" |
| Avoids Stating the Obvious | **N/A** | Behavioral overlay by design |
| Avoids Railroading | **Pass** | Provides principles, not rigid steps |
| Scripts/References | **N/A** | Behavioral skill |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- None significant. This is a well-crafted behavioral skill.

---

### 18. mcporter

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude + Codex (shared) |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | CLI reference |
| Gotchas | **Partial** | "When to use mcporter vs direct MCP" is useful but could document more failure modes |
| Progressive Disclosure | **N/A** | 41 lines |
| Description Quality | **Partial** | "CLI access to MCP servers without loading them into agent context" -- should add triggers like "call MCP tool", "use MCP without loading", "on-demand MCP" |
| Avoids Stating the Obvious | **Pass** | MCPorter-specific |
| Avoids Railroading | **Pass** | Reference material |
| Scripts/References | **N/A** | Short skill |
| Frontmatter | **Pass** | Has name, description |

**Top issues:**
- **P3: Description triggers.**

---

### 19. simplify

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Codex only (agent-only: true) |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Code quality review |
| Gotchas | **N/A** | Process skill |
| Progressive Disclosure | **N/A** | 54 lines |
| Description Quality | **Partial** | "Review changed code for reuse, quality, and efficiency" -- agent-only so triggers matter less, but still vague |
| Avoids Stating the Obvious | **Partial** | Some items in the review checklists are fairly standard (e.g., "memory leaks", "N+1 patterns") but most are specific enough to be useful |
| Avoids Railroading | **Pass** | Provides review dimensions, agent decides specifics |
| Scripts/References | **N/A** | Appropriate size |
| Frontmatter | **Pass** | Has name, description, agent-only flag |

**Top issues:**
- **P3: Some review checklist items are generic** but acceptable for a cross-repo skill.

---

## Repo-Level Gaps

### Missing Skill Categories

| Gap | Evidence | Priority | Suggested Skill |
|-----|----------|----------|----------------|
| **No testing/verification skill** (beyond self-test behavioral overlay) | Matt has iOS projects with test suites; self-test is philosophy, not tooling | **P2** | A verification skill that knows how to run the test suite, interpret results, and do targeted test fixes for specific projects |
| **No code scaffolding skill** | Multiple projects (CI Agents Platform, Screen Time App) could benefit from consistent boilerplate | **P3** | Project-specific scaffolding for new features/components |
| **No data fetching skill** | No analytics/monitoring skill despite having production apps | **P3** | Depends on whether Matt has data infrastructure to query |

### Structural Issues

| Issue | Priority | Details |
|-------|----------|---------|
| **rp-* skills have massive duplication** | **P1** | 4 skills share identical boilerplate (rp-cli reference table, workspace verification, CLI window routing). Should extract to a shared `rp-cli-reference.md` that each skill references |
| **review-loop vs rp-review overlap** | **P2** | Two review skills with unclear differentiation. review-loop is for Claude's dual-model review, rp-review uses RepoPrompt's builder. Description should clarify when to use which |
| **oracle vs rp-oracle-export overlap** | **P2** | Both are cross-model consultation tools. oracle uses @steipete/oracle CLI, rp-oracle-export uses rp-cli. Should be clear in descriptions |
| **Codex-only skills missing from Claude** | **P3** | remotion-best-practices, rp-* skills, simplify are Codex-only. simplify is agent-only which explains it, but remotion-best-practices could be useful in Claude too |

---

## Quick Wins

### 1. Extract rp-cli boilerplate into a shared reference (P1, saves ~400 lines of duplication)

Create `~/.agents/skills/_shared/rp-cli-reference.md` containing the quick reference table, workspace verification, and CLI window routing sections. Each rp-* skill references it instead of inlining.

### 2. Add trigger phrases to 8 skill descriptions (P2, 30 min of work)

Skills needing better triggers: plan-loop, review-loop, audit-loop, new-task, orchestrator, mcporter, remotion-best-practices, rp-* skills. Follow self-test and agent-browser as examples of good trigger-oriented descriptions.

### 3. Add gotchas sections to ios-dev, ios-release, and fix-ci (P2, based on real usage)

These tool-wrapper skills would benefit most from documenting real failure modes encountered during use. Even 3-5 bullet points of "things that surprised me" would significantly improve agent success rates.

### 4. Trim slack skill by removing agent-browser duplication (P2, improves focus)

The slack skill should focus on Slack-specific knowledge (sidebar structure, element naming, workspace navigation patterns) and reference agent-browser for generic browser automation. This would cut ~100 lines.

### 5. Clarify review skill boundaries in descriptions (P2, reduces confusion)

Add a "When to use this vs X" line to review-loop, rp-review, and simplify descriptions so the agent (and user) knows which review skill to invoke.

---

## Score Summary

| Skill | System | Category | Score | Top Priority |
|-------|--------|----------|-------|-------------|
| self-test | Shared | Verification | 5/5 | -- |
| agent-browser | Shared | Library Ref | 6/8 | P2: trim main file |
| ios-release | Shared | CI/CD | 6/8 | P3: add gotchas |
| fix-ci | Shared | CI/CD | 6/8 | P2: add gotchas |
| ios-dev | Shared | Library Ref | 6/7 | P3: add gotchas |
| oracle | Shared | Data/Consult | 6/7 | P3: category fit |
| orchestrator | Shared | Business Process | 5/6 | P3: triggers |
| plan-loop | Shared | Quality/Review | 5/6 | P2: triggers |
| review-loop | Shared | Quality/Review | 5/6 | P2: triggers + overlap |
| audit-loop | Shared | Quality/Review | 5/6 | P2: triggers |
| remotion-best-practices | Codex | Library Ref | 5/7 | P2: triggers + gotchas |
| new-task | Shared | Business Process | 5/5 | P3: triggers |
| mcporter | Shared | Library Ref | 5/6 | P3: triggers |
| simplify | Codex | Quality/Review | 5/6 | P3: generic items |
| slack | Shared | Business Process | 4/8 | P1: dedup from agent-browser |
| rp-investigate-cli | Codex | Runbooks | 3/7 | P1: dedup + railroading |
| rp-refactor-cli | Codex | Quality/Review | 3/7 | P1: dedup + railroading |
| rp-review-cli | Codex | Quality/Review | 3/7 | P1: dedup + overlap |
| rp-oracle-export-cli | Codex | Data/Consult | 3/6 | P1: dedup + overlap |
