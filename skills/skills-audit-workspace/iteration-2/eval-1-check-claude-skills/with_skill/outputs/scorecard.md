# Skills Audit Scorecard

**Location audited:** `~/.claude/skills/` (13 skills)
**Agent system:** Claude Code
**Date:** 2026-03-17

---

## Per-Skill Findings (ordered by priority)

---

### 1. agent-browser

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Lines:** 632 (SKILL.md) + 7 reference files + 3 templates
- **Score:** 8/10 (Universal 7/8, Claude-specific 1/2 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Library & API Reference skill |
| 2. Gotchas Section | **Partial** | "Ref Lifecycle (Important)" and "Timeouts and Slow Pages" cover some pitfalls inline, but there's no consolidated gotchas section. Failure modes are scattered across sections (shell quoting in eval, ref invalidation, session cleanup). A dedicated "Gotchas" section linking these would help. |
| 3. Progressive Disclosure | **Pass** | Excellent folder structure: references/ (7 files), templates/ (3 scripts), clear pointers from main file via reference table and inline links. |
| 4. Description Quality | **Pass** | Trigger-rich description with specific user intents: "open a website", "fill out a form", "take a screenshot", etc. Slightly pushy in the right way. |
| 5. Avoids Stating the Obvious | **Pass** | Content is tool-specific CLI reference, not generic web automation advice. |
| 6. Avoids Railroading | **Pass** | Provides patterns and options (5 auth approaches, multiple wait strategies) without forcing a single path. |
| 7. Includes Useful Scripts/Refs | **Pass** | 7 deep-dive reference files + 3 ready-to-use template scripts. Model of good progressive disclosure. |
| 8. Has Frontmatter | **Pass** | Name, description, and allowed-tools. |
| C1. On-Demand Hooks | **N/A** | Browser automation doesn't benefit from hooks. |
| C2. Setup/Config | **Pass** | Documents config file, env vars, and CLI flags. Multiple configuration layers explained. |
| C3. Data Persistence | **N/A** | No cross-run data accumulation. |

**Top issues:**
- **P2:** Consolidate scattered gotchas (ref invalidation, shell quoting in eval, session cleanup leaks, Lightpanda feature gaps) into a single "Gotchas" section at the top or bottom of the main file. This is the highest-signal content for agents hitting errors.
- **P3:** At 632 lines the main SKILL.md is long. The "Common Patterns" section (form submission, auth, data extraction, parallel sessions, etc.) could move to a `references/common-patterns.md` with a pointer from the main file.

---

### 2. slack

- **Category:** Business Process & Team Automation
- **Agent system:** Claude
- **Lines:** 294 (SKILL.md) + 1 reference + 1 template
- **Score:** 5/10 (Universal 5/8, Claude-specific 0/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Business Process & Team Automation skill. |
| 2. Gotchas Section | **Missing** | The "Limitations" section is a start but doesn't cover real failure modes encountered during use: e.g., Slack's aggressive DOM changes breaking refs between snapshots, auth cookie expiry, elements hidden behind "Show more" buttons, rate limiting behavior. These are exactly the kind of agent-tripping gotchas that should be documented. |
| 3. Progressive Disclosure | **Partial** | Has references/ and templates/ dirs, but the main file at 294 lines contains a lot of example code that could be split. The full unread check bash script, the detailed sidebar structure, and the data extraction patterns could all live in references. |
| 4. Description Quality | **Pass** | Good trigger phrases: "check my Slack", "what channels have unreads", "send a message to", etc. |
| 5. Avoids Stating the Obvious | **Partial** | "Take snapshots before clicking" and "Re-snapshot after navigation" are agent-browser fundamentals already covered in the agent-browser skill. The Slack skill should focus on Slack-specific knowledge (sidebar structure, DOM patterns, workspace-specific quirks) and not reteach agent-browser basics. |
| 6. Avoids Railroading | **Partial** | Hardcoded ref examples (`@e12`, `@e13`, `@e14`, `@e21`) with comments like "usually" are misleading. Refs change every session. The skill should teach the agent to discover refs via snapshot, not memorize specific numbers. |
| 7. Includes Useful Scripts/Refs | **Partial** | Has a reference and template, but the "Best Practices" are generic agent-browser tips. The reference file and template should contain Slack-specific workflows. |
| 8. Has Frontmatter | **Pass** | Name, description, and allowed-tools. |
| C1. On-Demand Hooks | **N/A** | No hook use case. |
| C2. Setup/Config | **Missing** | Hardcodes port 9222 for connecting to existing Chrome. Should have a config mechanism or at minimum document how to discover/set the debug port. Different users will have different setups. |
| C3. Data Persistence | **N/A** | No cross-run data. |

**Top issues:**
- **P1:** Remove hardcoded ref numbers (`@e12`, `@e13`, `@e14`, `@e21`). These change every session and will mislead the agent. Replace with descriptions of how to identify these elements from snapshot output (e.g., "look for treeitem with name containing 'Activity'").
- **P1:** Add a real gotchas section with Slack-specific failure modes (DOM instability, auth expiry, hidden elements, rate limiting).
- **P2:** Remove agent-browser basics ("take snapshots before clicking", "re-snapshot after navigation") — the agent already knows this from the agent-browser skill.
- **P2:** Add config for the Chrome debug port instead of hardcoding 9222.

---

### 3. fix-ci

- **Category:** CI/CD & Deployment
- **Agent system:** Claude
- **Lines:** 150 (SKILL.md) + 1 script
- **Score:** 7/9 (Universal 6/7, Claude-specific 1/2 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean CI/CD skill. |
| 2. Gotchas Section | **Missing** | No gotchas despite having clear failure modes: `gh` auth issues, rate limits on log fetching, external checks that can't be inspected, flaky tests that pass on retry, max iteration exhaustion. The "Error Handling" section at the bottom covers some but reads more like a status list than agent-actionable gotchas. |
| 3. Progressive Disclosure | **N/A** | At 150 lines, single file is appropriate. Has a bundled script which is good. |
| 4. Description Quality | **Pass** | Good trigger coverage: "fix failing CI", "check PR status", "get a PR merge-ready". |
| 5. Avoids Stating the Obvious | **Pass** | Content is specific to the CI fix workflow with concrete commands and patterns. |
| 6. Avoids Railroading | **Partial** | The step-by-step structure is somewhat rigid, but the "General patterns" in Step 4 give flexibility. The "Let the repo context guide you" instruction is good. However, the polling interval (2 min) and max iterations (3) are hardcoded without explaining when to deviate. |
| 7. Includes Useful Scripts/Refs | **Pass** | Bundles `inspect_pr_checks.py` with robust fallback handling. |
| 8. Has Frontmatter | **Pass** | Name, description, and metadata. |
| C1. On-Demand Hooks | **N/A** | No hook use case. |
| C2. Setup/Config | **Pass** | No user-specific config needed; uses gh CLI which handles its own auth. |
| C3. Data Persistence | **N/A** | No cross-run data. |

**Top issues:**
- **P2:** Add a dedicated gotchas section. Real failure modes: gh auth expired mid-loop, rate limits on log APIs, flaky tests that need retry vs. real fix, external checks (Buildkite, etc.) that the script can't parse, permission errors on pushing fixes.
- **P3:** Make polling interval and max iterations configurable or explain the reasoning behind the defaults so the agent knows when to deviate.

---

### 4. ios-dev

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Lines:** 147
- **Score:** 6/8 (Universal 5/7, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Library & API Reference for xcodebuildmcp. |
| 2. Gotchas Section | **Missing** | iOS simulator development is riddled with gotchas (stale derived data, simulator boot hangs, signing issues, scheme resolution failures, SwiftUI preview crashes). None are documented. This is the single highest-value addition. |
| 3. Progressive Disclosure | **N/A** | At 147 lines, single file is appropriate. |
| 4. Description Quality | **Pass** | Good trigger list with specific scenarios. |
| 5. Avoids Stating the Obvious | **Pass** | xcodebuildmcp-specific CLI patterns the agent wouldn't know. |
| 6. Avoids Railroading | **Pass** | Provides tool reference and workflow patterns, lets agent adapt. |
| 7. Includes Useful Scripts/Refs | **N/A** | Short enough that bundled scripts aren't needed. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | No hook use case. |
| C2. Setup/Config | **Partial** | Documents config.yaml but recommends explicit flags for agents. Good advice, but no guidance on discovering the project path / scheme when starting fresh in a repo. A "first-time setup" pattern would help. |
| C3. Data Persistence | **N/A** | No cross-run data. |

**Top issues:**
- **P1:** Add a gotchas section. Must-haves: stale DerivedData causing phantom errors (clean fix), simulator boot failures after Xcode updates, signing config mismatches between CLI and Xcode GUI, `xcodebuildmcp` version drift, scheme name case sensitivity.
- **P3:** Add a "Discovery" note about how to find the right project path and scheme when dropped into an unfamiliar repo (beyond just `discover-projects`).

---

### 5. ios-release

- **Category:** CI/CD & Deployment
- **Agent system:** Claude
- **Lines:** 147 (SKILL.md) + 4 reference files
- **Score:** 7/8 (Universal 6/7, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean CI/CD & Deployment skill. |
| 2. Gotchas Section | **Missing** | App Store submission has many gotchas (processing time after upload, export compliance questions, metadata rejections, entitlement mismatches). These are likely covered in the reference files but should be surfaced as a quick-reference list in the main file. |
| 3. Progressive Disclosure | **Pass** | Excellent: 4 focused reference files loaded only when needed, clear reference map with when-to-load guidance. |
| 4. Description Quality | **Pass** | Good triggers: "shipping to TestFlight", "preparing App Store submission", "diagnosing release blockers". |
| 5. Avoids Stating the Obvious | **Pass** | ASC CLI specifics the agent wouldn't know. |
| 6. Avoids Railroading | **Pass** | Phase A/B gating is a smart pattern — read-only by default, mutating only with approval. Gives structure without over-constraining. |
| 7. Includes Useful Scripts/Refs | **Pass** | 4 reference files covering distinct release concerns. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | No hook use case. |
| C2. Setup/Config | **Pass** | APP_ID, VERSION_ID, BUILD_ID are documented as required inputs. Auth is handled by `asc auth status`. |
| C3. Data Persistence | **N/A** | No cross-run data. |

**Top issues:**
- **P2:** Add a brief gotchas section in the main SKILL.md summarizing the top 5 release pitfalls (even if details are in references). Agents hitting errors need fast answers, not file traversal.

---

### 6. oracle

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Lines:** 88
- **Score:** 6/8 (Universal 5/7, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Library & API Reference for the oracle CLI. |
| 2. Gotchas Section | **Partial** | "Sessions + slugs" section covers the detach/timeout/reattach gotcha well. But missing: token budget overruns, shell quoting issues with -p flag, `--file` glob patterns not matching expected files, browser mode requiring specific Chrome setup. |
| 3. Progressive Disclosure | **N/A** | At 88 lines, single file is appropriate. |
| 4. Description Quality | **Partial** | Describes what oracle does but lacks trigger phrases. When would a user invoke this? "Get a second opinion", "cross-validate with another model", "debug with GPT", "review this with a different model". |
| 5. Avoids Stating the Obvious | **Pass** | Oracle-specific CLI knowledge. |
| 6. Avoids Railroading | **Pass** | Multiple workflow options (browser, API, manual paste), lets agent choose. |
| 7. Includes Useful Scripts/Refs | **N/A** | Short skill, no scripts needed. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | No hook use case. |
| C2. Setup/Config | **Partial** | Mentions `AGENT_BROWSER_ENCRYPTION_KEY` and `ORACLE_HOME_DIR` but doesn't document required setup (is Chrome needed? What env vars are mandatory?). |
| C3. Data Persistence | **N/A** | Sessions stored in ~/.oracle/ (external tool). |

**Top issues:**
- **P2:** Improve description with trigger phrases so the model knows when to invoke it.
- **P3:** Expand gotchas: token budget overruns, glob matching surprises, browser mode prerequisites.

---

### 7. orchestrator

- **Category:** Business Process & Team Automation
- **Agent system:** Claude
- **Lines:** 40
- **Score:** 5/7 (Universal 5/7 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Partial** | Straddles Business Process & Team Automation and Code Quality & Review. It's a meta-workflow that composes other skills. This is fine as a "conductor" skill, but the category isn't clean. |
| 2. Gotchas Section | **N/A** | Short behavioral/workflow overlay. Gotchas would live in the sub-skills it invokes. |
| 3. Progressive Disclosure | **N/A** | 40 lines — single file is correct. |
| 4. Description Quality | **Partial** | "Orchestrate complex tasks with agent teams" is vague. When should the agent use orchestrator vs. just invoking plan-loop directly? Needs trigger phrases: "this is a big task", "we need to plan and implement this", "use agent teams for this". |
| 5. Avoids Stating the Obvious | **N/A** | Intentionally generic workflow overlay. |
| 6. Avoids Railroading | **Pass** | "For simple tasks (1-3 files), skip this" is good self-scoping. Phase structure provides guidance without over-constraining. |
| 7. Includes Useful Scripts/Refs | **N/A** | Behavioral overlay, no scripts needed. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **N/A** | |
| C3. Data Persistence | **N/A** | |

**Top issues:**
- **P2:** Improve description with clearer trigger conditions. When orchestrator vs. plan-loop directly? The "complex tasks" threshold is ambiguous.
- **P3:** Clarify category: this is a meta-workflow/conductor. Consider adding a note like "This skill composes: new-task, plan-loop, review-loop, simplify."

---

### 8. plan-loop

- **Category:** Code Quality & Review
- **Agent system:** Claude
- **Lines:** 46 (SKILL.md) + 1 reference
- **Score:** 6/7 (Universal 5/6, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Planning + review workflow. Fits Code Quality & Review. |
| 2. Gotchas Section | **N/A** | Workflow skill. Gotchas would be about the review-protocol, which lives in its reference file. |
| 3. Progressive Disclosure | **N/A** | 46 lines + reference file is right-sized. |
| 4. Description Quality | **Pass** | Trigger-oriented: "Plan-first dual-model hardening loop." Clear when to use vs. audit-loop and review-loop. |
| 5. Avoids Stating the Obvious | **N/A** | Intentionally a process overlay. |
| 6. Avoids Railroading | **Pass** | Confidence thresholds and round sizing give structure while allowing escalation. "Execute continuously — no mandatory stop gates" is good flexibility. |
| 7. Includes Useful Scripts/Refs | **Pass** | review-protocol.md reference. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **Partial** | References `~/dev/agent-guards/AGENTS.md` — this is a hardcoded absolute path. If someone forks or moves the repo, it breaks. Consider a relative reference or env var. |
| C3. Data Persistence | **N/A** | Plan files go in `plans/` in the project, not in the skill dir. |

**Top issues:**
- **P3:** Hardcoded path `~/dev/agent-guards/AGENTS.md` should be made portable.

---

### 9. review-loop

- **Category:** Code Quality & Review
- **Agent system:** Claude
- **Lines:** 35 (SKILL.md) + 1 reference
- **Score:** 6/7 (Universal 5/6, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Code Quality & Review. |
| 2. Gotchas Section | **N/A** | Short workflow overlay. |
| 3. Progressive Disclosure | **N/A** | 35 lines + reference. Right-sized. |
| 4. Description Quality | **Pass** | Clear trigger and differentiation from audit-loop and plan-loop. |
| 5. Avoids Stating the Obvious | **N/A** | Process overlay. |
| 6. Avoids Railroading | **Pass** | Confidence thresholds with flexibility. |
| 7. Includes Useful Scripts/Refs | **Pass** | review-protocol.md reference. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **Partial** | Same hardcoded `~/dev/agent-guards/AGENTS.md` path issue. |
| C3. Data Persistence | **N/A** | |

**Top issues:**
- **P3:** Same hardcoded path issue as plan-loop.

---

### 10. audit-loop

- **Category:** Code Quality & Review
- **Agent system:** Claude
- **Lines:** 37 (SKILL.md) + 1 reference
- **Score:** 6/7 (Universal 5/6, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Code Quality & Review (read-only variant). |
| 2. Gotchas Section | **N/A** | Short workflow overlay. |
| 3. Progressive Disclosure | **N/A** | 37 lines + reference. Right-sized. |
| 4. Description Quality | **Partial** | Description says "Both model families review evidence and findings" which is implementation detail, not trigger-oriented. Better: "Use when you need to investigate, analyze, or validate something without making changes — code audits, security reviews, architecture assessments, dependency checks." |
| 5. Avoids Stating the Obvious | **N/A** | Process overlay. |
| 6. Avoids Railroading | **Pass** | Flexible investigation structure. |
| 7. Includes Useful Scripts/Refs | **Pass** | review-protocol.md reference. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **Partial** | Same hardcoded path. |
| C3. Data Persistence | **N/A** | |

**Top issues:**
- **P2:** Rewrite description to be trigger-oriented rather than implementation-detail-oriented.
- **P3:** Same hardcoded path issue.

---

### 11. new-task

- **Category:** Business Process & Team Automation
- **Agent system:** Claude
- **Lines:** 30
- **Score:** 6/6 (Universal 5/5, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean process automation (requirements clarification). |
| 2. Gotchas Section | **N/A** | Short behavioral skill. |
| 3. Progressive Disclosure | **N/A** | 30 lines. Right-sized. |
| 4. Description Quality | **Pass** | Clear trigger: "Iteratively clarify requirements for a new task." |
| 5. Avoids Stating the Obvious | **N/A** | Process overlay. |
| 6. Avoids Railroading | **Pass** | Question strategy section gives guidance without scripting exact questions. |
| 7. Includes Useful Scripts/Refs | **N/A** | Short behavioral skill. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **N/A** | |
| C3. Data Persistence | **N/A** | |

**Top issues:** None significant. Well-scoped and clean.

---

### 12. self-test

- **Category:** Product Verification
- **Agent system:** Claude
- **Lines:** 25
- **Score:** 5/5 (Universal 4/4, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Product Verification (behavioral overlay). |
| 2. Gotchas Section | **N/A** | Short behavioral skill. |
| 3. Progressive Disclosure | **N/A** | 25 lines. Right-sized. |
| 4. Description Quality | **Pass** | Excellent trigger phrases: "make sure it works", "test it yourself", "don't just tell me it's done". |
| 5. Avoids Stating the Obvious | **N/A** | Behavioral overlay — its purpose IS to state principles. |
| 6. Avoids Railroading | **Pass** | Gives philosophy and goals, not rigid steps. |
| 7. Includes Useful Scripts/Refs | **N/A** | Behavioral skill. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **N/A** | |
| C3. Data Persistence | **N/A** | |

**Top issues:** None. This is a model skill — concise, clear, well-triggered.

---

### 13. mcporter

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Lines:** 40
- **Score:** 5/6 (Universal 4/5, Claude-specific 1/1 applicable)

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | **Pass** | Clean Library & API Reference. |
| 2. Gotchas Section | **Partial** | "If a server is offline or auth-gated, report it and continue with fallback tools" is one gotcha but inline. Missing: tool name drift between MCP server versions (mentioned as a reason to run `--schema` but not framed as a gotcha), timeout behavior, argument format edge cases. |
| 3. Progressive Disclosure | **N/A** | 40 lines. Right-sized. |
| 4. Description Quality | **Pass** | Clear trigger: CLI access to MCP servers without context overhead. |
| 5. Avoids Stating the Obvious | **Pass** | mcporter-specific workflow. |
| 6. Avoids Railroading | **Pass** | Provides patterns, lets agent adapt. |
| 7. Includes Useful Scripts/Refs | **N/A** | Short skill. |
| 8. Has Frontmatter | **Pass** | Name and description. |
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **N/A** | |
| C3. Data Persistence | **N/A** | |

**Top issues:**
- **P3:** Minor — could formalize the "always run --schema first" rule as a gotcha with the reason (tool names drift between versions).

---

## Repo-Level Gaps

| Gap | Evidence | Priority | Suggested Skill |
|-----|----------|----------|-----------------|
| No code scaffolding skill | User has multiple side projects (Screen Time App, Homeschool Tools, CI Agents Platform). No skill for bootstrapping new projects or features with consistent patterns. | **P3** | A scaffolding skill for new side projects (repo setup, standard config, CI template) could save repeated setup time. |
| No data fetching/analysis skill | No dashboards, analytics, or data pipeline skills. | **P3 (low)** | Not needed yet — side-project stage. Revisit when products have users and need analytics. |
| Duplicate review-protocol.md | `audit-loop/references/review-protocol.md`, `plan-loop/references/review-protocol.md`, and `review-loop/references/review-protocol.md` appear to be copies. | **P2** | Consolidate to a single shared location (e.g., a shared references skill or a common dir) and have all three loop skills point to it. Drift between copies is a maintenance risk. |

---

## Quick Wins

### 1. Add gotchas sections to ios-dev, fix-ci, and slack (P1-P2)
These three skills cover error-prone domains (Xcode, CI, browser automation against a complex SPA) and have zero documented gotchas. Even 5-10 bullet points each from real usage would dramatically improve agent success rates.

### 2. Fix hardcoded refs in slack skill (P1)
Remove `@e12`, `@e13`, `@e14`, `@e21` examples. These change every session and will cause the agent to click wrong elements. Replace with snapshot-based discovery patterns.

### 3. Improve descriptions for audit-loop and orchestrator (P2)
Both descriptions focus on implementation mechanics rather than trigger conditions. Rewriting them to include user-intent phrases will improve skill invocation accuracy.

### 4. Deduplicate review-protocol.md across loop skills (P2)
Three copies of the same file is a maintenance risk. Consolidate to one canonical location.

### 5. Make `~/dev/agent-guards/AGENTS.md` path portable (P3)
plan-loop, review-loop, and audit-loop all hardcode this absolute path. If the repo moves or someone else uses these skills, they break. Use a relative path or document the expected location.
