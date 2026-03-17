# Skills Audit Scorecard

**Date:** 2026-03-17
**Scope:** `~/.claude/skills/` (13 skills), `~/.agents/skills/` (19 skills, 6 Codex-only), `~/.claude/commands/` (1 command)

**Bottom line:** You have a solid collection with real depth in the right places. The tool-wrapper skills (agent-browser, ios-dev, ios-release, fix-ci) are genuinely excellent. The workflow/behavioral skills (self-test, new-task, orchestrator, loops) are clean and purposeful. The main improvement areas are (1) a few skills missing gotchas sections, (2) some descriptions that could trigger more reliably, and (3) the rp-* Codex skills have a lot of duplicated boilerplate.

---

## Per-Skill Findings

Skills are ordered by priority -- ones with the most room for improvement first.

---

### 1. slack
**Category:** Business Process & Team Automation
**Agent system:** Claude + Codex (synced)
**Score:** 4/7

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Clearly automation for Slack |
| Gotchas | Missing | No gotchas section despite browser automation being full of failure modes (stale refs after Slack UI updates, connection failures, rate limiting). The Limitations section hints at some but doesn't frame them as agent pitfalls. |
| Progressive Disclosure | Partial | 294 lines in one file. Has references/ and templates/ folders but the main SKILL.md duplicates a lot of the agent-browser skill content. Could split common patterns into a reference. |
| Description Quality | Pass | Good trigger phrases ("check my Slack", "what channels have unreads", etc.) |
| Avoids Stating the Obvious | Partial | Some content restates agent-browser basics (snapshot workflow, re-snapshot after nav). The Slack-specific parts (sidebar structure, tabs, unread patterns) are the high-value content. |
| Avoids Railroading | Partial | Hardcoded refs like `@e14` for Activity tab are brittle -- these change between sessions. Better to say "look for the Activity tab treeitem" than to suggest specific ref numbers. |
| Scripts/References | Pass | Has references/ and templates/ |
| Frontmatter | Pass | Has name and description |

**Top issues:**
- **P1:** Add a gotchas section. Key gotchas: refs change every session (don't hardcode), Slack's SPA navigation means you must re-snapshot frequently, `connect 9222` only works if Chrome was launched with `--remote-debugging-port=9222`, login state can expire mid-session.
- **P2:** Remove hardcoded ref examples (`@e14`, `@e21`) or clearly label them as "example refs that will vary." An agent seeing `@e14 # Activity tab` may try that ref literally.
- **P3:** Trim content that duplicates agent-browser (the core workflow section, best practices about snapshots).

---

### 2. rp-investigate-cli / rp-oracle-export-cli / rp-refactor-cli / rp-review-cli
**Category:** Code Quality & Review (rp-review, rp-refactor), Runbooks (rp-investigate), Data Fetching & Analysis (rp-oracle-export)
**Agent system:** Codex only
**Score:** 4/7 (averaged across the four)

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Each fits one category cleanly |
| Gotchas | Missing | None of the four have a gotchas section despite all sharing a complex CLI with real failure modes (window routing, timeout, stateless sessions) |
| Progressive Disclosure | N/A | Each is a single file at 63-195 lines, appropriate size |
| Description Quality | Partial | Descriptions are functional but not trigger-oriented. E.g., "Code review workflow using rp-cli" doesn't tell the model when to pick this vs the native review-loop. |
| Avoids Stating the Obvious | Partial | The rp-cli boilerplate (quick reference table, JSON args, timeout warning) is duplicated verbatim across all four skills. This is ~30 lines of identical content in each. |
| Avoids Railroading | Partial | Very rigid step ordering ("REQUIRED", "Do NOT skip", "CRITICAL") with heavy emphasis on not deviating. The anti-patterns section is good but the overall tone is restrictive. |
| Scripts/References | N/A | CLI-wrapper skills, scripts not needed |
| Frontmatter | Pass | All have name and description |

**Top issues:**
- **P1:** Extract the shared rp-cli boilerplate (quick reference table, JSON args, timeout warning, window routing) into a single `rp-cli-reference.md` that all four skills reference. This cuts ~120 lines of duplication and means updates happen in one place.
- **P2:** Add a shared gotchas section. Key gotchas: forgetting `-w` causes silent wrong-window targeting, `builder` timeouts need 2700s+ timeout, session tabs are ephemeral, `builder` has no memory between calls.
- **P3:** Make descriptions more trigger-oriented. E.g., rp-review: "Review code changes using rp-cli's context_builder for deep architectural review. Use when: reviewing a PR, checking branch changes, wanting a thorough code review that goes beyond surface-level diff reading."

---

### 3. remotion-best-practices
**Category:** Library & API Reference
**Agent system:** Codex only
**Score:** 5/7

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Classic library reference |
| Gotchas | Missing | No gotchas section. Remotion has real pitfalls (useCurrentFrame in wrong context, SSR vs client rendering, bundle size issues, audio codec support). The individual rule files may contain some, but the main SKILL.md should surface the top 5-10. |
| Progressive Disclosure | Pass | Excellent folder structure with 25+ rule files, each covering a specific topic. Main SKILL.md is a clean index. |
| Description Quality | Partial | "Best practices for Remotion - Video creation in React" is too generic. Should include trigger phrases like "creating video with React", "animation with Remotion", "rendering video compositions". |
| Avoids Stating the Obvious | Pass | Remotion-specific knowledge the model can't infer |
| Avoids Railroading | Pass | Pure reference material, no rigid process |
| Scripts/References | Pass | 25+ rule files |
| Frontmatter | Pass | Has name and description |

**Top issues:**
- **P1:** Add a "Top Gotchas" section to the main SKILL.md pulling the most common mistakes from across the rule files.
- **P2:** Improve description for better triggering: "Best practices and patterns for Remotion video creation in React. Use when writing or editing Remotion compositions, animations, captions, transitions, audio/video handling, or any React-based video rendering code."

---

### 4. oracle
**Category:** Data Fetching & Analysis (cross-model consultation)
**Agent system:** Claude + Codex (synced)
**Score:** 5/7

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Fits as a data fetching / cross-model consultation tool |
| Gotchas | Pass | Has practical warnings about shell quoting, token budgets, session reattachment, secrets |
| Progressive Disclosure | N/A | 88 lines, right size for single file |
| Description Quality | Partial | "Use the @steipete/oracle CLI to bundle a prompt..." describes what it does but not when to trigger. Could add: "Use when you need a second opinion from another model, want to cross-validate a design, debug something you're stuck on, or need architectural review." |
| Avoids Stating the Obvious | Pass | Org-specific knowledge about oracle CLI |
| Avoids Railroading | Pass | Flexible, gives golden path but allows deviation |
| Scripts/References | N/A | CLI wrapper, no scripts needed |
| Frontmatter | Pass | Has name and description |

**Top issues:**
- **P2:** Improve description with trigger conditions: "Use when you need a second-model opinion, want to cross-validate with GPT, debug a problem you're stuck on, or need architectural review from an external model."

---

### 5. agent-browser
**Category:** Library & API Reference
**Agent system:** Claude + Codex (synced)
**Score:** 6/8

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Tool reference for agent-browser CLI |
| Gotchas | Pass | Ref lifecycle section, security notes, timeout handling, shell quoting in eval -- all real pitfalls |
| Progressive Disclosure | Pass | 632 lines is large but uses references/ and templates/ folders well with clear pointers. The main file is a comprehensive quick-reference which is the right call for a CLI tool. |
| Description Quality | Pass | Excellent trigger phrases covering many user intents |
| Avoids Stating the Obvious | Pass | Agent-browser-specific knowledge throughout |
| Avoids Railroading | Pass | Provides patterns and options, lets agent choose |
| Scripts/References | Pass | references/ (7 files) and templates/ (3 files) |
| Frontmatter | Pass | Has name, description, and allowed-tools |
| C1: On-Demand Hooks | N/A | No hooks needed |
| C2: Setup/Config | Pass | Documents config file, env vars, profiles |

**Top issues:**
- **P3:** Consider splitting the main SKILL.md. At 632 lines it's the longest skill. The sections on iOS Simulator, Semantic Locators, and Video Recording could move to references/ with a one-liner in the main file. This would reduce initial context load.

---

### 6. fix-ci
**Category:** CI/CD & Deployment
**Agent system:** Claude + Codex (synced)
**Score:** 6/7

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Classic CI/CD skill |
| Gotchas | Pass | Error handling section covers real failure modes (gh not auth'd, no PR, external checks) |
| Progressive Disclosure | Pass | Has scripts/ folder with inspect_pr_checks.py |
| Description Quality | Pass | Good trigger conditions |
| Avoids Stating the Obvious | Pass | CI-specific patterns and tooling |
| Avoids Railroading | Partial | Fairly prescriptive step ordering, but for a CI fix loop this is appropriate. The "Let the repo context guide you" in Step 4 is good. |
| Scripts/References | Pass | Bundled Python script for robust log extraction |
| Frontmatter | Pass | name, description, metadata |

**Top issues:**
- **P3:** The `sleep 120` polling in Step 2 could be a gotcha -- mention that this blocks the agent for 2 minutes per iteration, up to 20 minutes total. Consider suggesting the user can set a shorter poll interval.

---

### 7. ios-dev
**Category:** Library & API Reference (tool wrapper for xcodebuildmcp)
**Agent system:** Claude + Codex (synced)
**Score:** 6/7

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Tool reference for xcodebuildmcp |
| Gotchas | Pass | Guardrails section covers key pitfalls (simulator-first, destructive cleanup, loop sizing) |
| Progressive Disclosure | N/A | 147 lines, right size |
| Description Quality | Pass | Good trigger conditions covering multiple use cases |
| Avoids Stating the Obvious | Pass | xcodebuildmcp-specific commands the model won't know |
| Avoids Railroading | Pass | Output contract section is well-structured without being rigid |
| Scripts/References | N/A | CLI wrapper, no scripts needed |
| Frontmatter | Pass | name and description |

**Top issues:**
- Minor: the "iPhone 17 Pro" simulator name will date. Consider noting that the user should check available simulators with the list command first.

---

### 8. ios-release
**Category:** CI/CD & Deployment (release management)
**Agent system:** Claude + Codex (synced)
**Score:** 6/7

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Release/deployment skill |
| Gotchas | Pass | Guardrails section is strong -- never run mutating without approval, prefer IDs over names |
| Progressive Disclosure | Pass | Has references/ folder with 4 deep-dive files, loaded on demand |
| Description Quality | Pass | Good trigger conditions |
| Avoids Stating the Obvious | Pass | ASC-specific workflows the model won't know |
| Avoids Railroading | Partial | Fairly prescriptive but the Phase A/B split with explicit approval gate is appropriate for release management |
| Scripts/References | Pass | 4 reference files |
| Frontmatter | Pass | name and description |

**Top issues:**
- Solid skill. No major issues.

---

### 9. mcporter
**Category:** Library & API Reference (tool wrapper)
**Agent system:** Claude + Codex (synced)
**Score:** 5/5

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Tool wrapper |
| Gotchas | N/A | Too short/simple for gotchas beyond what's stated |
| Progressive Disclosure | N/A | 40 lines, right size |
| Description Quality | Pass | Clear trigger conditions |
| Avoids Stating the Obvious | Pass | MCP-specific knowledge |
| Avoids Railroading | Pass | Minimal, informational |
| Scripts/References | N/A | Not needed at this size |
| Frontmatter | Pass | name and description |

**Top issues:** None. Clean, minimal, does its job.

---

### 10. self-test
**Category:** Code Quality & Review (behavioral overlay)
**Agent system:** Claude + Codex (synced)
**Score:** 5/5

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Behavioral overlay for verification |
| Gotchas | N/A | Philosophy skill, no tool-specific failure modes |
| Progressive Disclosure | N/A | 25 lines |
| Description Quality | Pass | Excellent trigger phrases ("make sure it works", "test it yourself", "don't just tell me it's done") |
| Avoids Stating the Obvious | N/A | Intentionally generic/cross-repo by design |
| Avoids Railroading | Pass | Gives principles, lets agent adapt |
| Scripts/References | N/A | Behavioral skill |
| Frontmatter | Pass | name and description |

**Top issues:** None. This is a model behavioral skill -- short, clear, actionable.

---

### 11. new-task
**Category:** Business Process & Team Automation (workflow)
**Agent system:** Claude + Codex (synced)
**Score:** 5/5

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Clarification workflow |
| Gotchas | N/A | Simple workflow, no tool failure modes |
| Progressive Disclosure | N/A | 30 lines |
| Description Quality | Partial | "Iteratively clarify requirements..." describes the process but could use trigger phrases like "new feature", "I want to build", "help me think through". |
| Avoids Stating the Obvious | N/A | Workflow/behavioral |
| Avoids Railroading | Pass | Flexible question strategy |
| Scripts/References | N/A | Not needed |
| Frontmatter | Pass | name and description |

**Top issues:**
- **P3:** Add trigger phrases to description.

---

### 12. orchestrator
**Category:** Business Process & Team Automation (meta-workflow)
**Agent system:** Claude + Codex (synced)
**Score:** 5/5

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Meta-workflow orchestrator |
| Gotchas | N/A | Orchestration wrapper, delegates to sub-skills |
| Progressive Disclosure | N/A | 40 lines |
| Description Quality | Partial | "Orchestrate complex tasks with agent teams" is vague. Should trigger on: "big feature", "multi-file change", "I need a team on this", "full implementation". |
| Avoids Stating the Obvious | N/A | Workflow definition |
| Avoids Railroading | Pass | Phases are clear but flexible |
| Scripts/References | N/A | Not needed |
| Frontmatter | Pass | name and description |

**Top issues:**
- **P3:** Improve description triggers.

---

### 13. plan-loop / review-loop / audit-loop
**Category:** Code Quality & Review (workflow)
**Agent system:** Claude + Codex (synced)
**Score:** 5/6 (averaged)

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Each is clearly one thing |
| Gotchas | N/A | Workflow skills with minimal tool interaction |
| Progressive Disclosure | Pass | Each has a references/ folder |
| Description Quality | Pass | Good descriptions with clear when-to-use guidance and cross-references to sibling skills |
| Avoids Stating the Obvious | N/A | Workflow definitions |
| Avoids Railroading | Partial | Round sizing is prescriptive but justified for quality control. The confidence thresholds are helpful constraints. |
| Scripts/References | Pass | references/ folders |
| Frontmatter | Pass | All have name and description |

**Top issues:**
- Minor: The cross-references between the three ("use plan-loop instead", "use audit-loop instead") are helpful for disambiguation. Well done.

---

### 14. simplify
**Category:** Code Quality & Review
**Agent system:** Codex only
**Score:** 5/5

| Check | Score | Notes |
|-------|-------|-------|
| Category Clarity | Pass | Code quality review |
| Gotchas | N/A | Workflow skill |
| Progressive Disclosure | N/A | 54 lines |
| Description Quality | Partial | "Review changed code for reuse, quality, and efficiency" is functional but not trigger-oriented. |
| Avoids Stating the Obvious | Pass | The three review dimensions (reuse, quality, efficiency) are specific and actionable |
| Avoids Railroading | Pass | Tells agents what to look for, not how to fix |
| Scripts/References | N/A | Not needed |
| Frontmatter | Pass | name, description, agent-only flag |

**Top issues:** Clean. The `agent-only: true` flag is a nice touch.

---

### Command: uithub
**Category:** Data Fetching & Analysis
**Agent system:** Claude (command)
**Score:** N/A (command, not skill -- lighter evaluation)

Functional command that fetches repo context via UiThub API. Well-structured with clear flow, fallback strategies, and error handling. The curl-based approach is practical.

---

## Repo-Level Gaps

| Gap | Evidence | Impact | Priority |
|-----|----------|--------|----------|
| No verification/testing skill beyond self-test | self-test is behavioral only -- no tool-specific testing patterns (e.g., how to run the repo's test suite, what test framework is used) | Medium -- self-test philosophy is good but project-specific test commands would help | P3 |
| No deployment skill for non-iOS | fix-ci handles CI, ios-release handles iOS, but no skill for deploying web services, infrastructure, etc. | Low -- may not be needed if all projects are iOS + static sites | P3 |

The gap list is short because your skills already cover the major categories relevant to your projects. The iOS stack has particularly good coverage (ios-dev + ios-release + fix-ci).

---

## Quick Wins

These are the highest-impact changes across all skills, ordered by effort-to-value ratio:

1. **Add gotchas to slack skill** (P1, ~15 min). The slack skill is the most-used skill without a gotchas section. Document: stale refs, connection prereqs, login expiry, Slack SPA navigation quirks. This prevents the most common agent failures.

2. **Extract rp-cli shared boilerplate** (P1, ~30 min). The four rp-* skills duplicate ~30 lines each. Create `~/.agents/skills/rp-cli-reference.md` and have each skill reference it. Easier to maintain, shorter context per skill.

3. **Add gotchas to remotion-best-practices** (P2, ~15 min). Surface the top 5-10 Remotion pitfalls in the main SKILL.md. The rule files likely contain these already -- just elevate them.

4. **Improve descriptions on workflow skills** (P3, ~10 min). Add trigger phrases to new-task, orchestrator, and simplify descriptions. This helps the model auto-select the right skill without the user having to invoke by name.

5. **Remove hardcoded refs from slack skill** (P2, ~10 min). Replace `@e14 # Activity tab` style examples with "look for the Activity tab element in the snapshot" to prevent the agent from using stale refs.

---

## Overall Assessment

**Verdict: These are good.** You have 19 unique skills spanning 7 of the 9 categories. The tool-wrapper skills (agent-browser, ios-dev, ios-release, fix-ci) are the standouts -- they have real depth, practical gotchas, and bundled resources. The behavioral/workflow skills (self-test, loops, orchestrator) are appropriately minimal. The main area for improvement is the Codex-only rp-* skills which carry duplicated boilerplate, and a few missing gotchas sections on skills that interact with flaky browser automation.

For a first setup, this is well above average. Most people's first skills are either too short (just a description) or too long (dump everything into one file). Yours hit a good balance, especially the progressive disclosure pattern in agent-browser, ios-release, and the loop skills.
