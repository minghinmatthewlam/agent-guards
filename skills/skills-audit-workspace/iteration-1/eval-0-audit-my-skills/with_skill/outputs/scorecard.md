# Skills Audit Scorecard

**Date:** 2026-03-17
**Scope:** `~/.claude/skills/` (Claude Code) + `~/.agents/skills/` (Codex)

---

## Inventory Summary

| # | Skill | Agent System | Source | Category |
|---|-------|-------------|--------|----------|
| 1 | fix-ci | Both (synced) | agent-guards | CI/CD & Deployment |
| 2 | ios-release | Both (synced) | agent-guards | CI/CD & Deployment |
| 3 | ios-dev | Both (synced) | agent-guards | Library & API Reference |
| 4 | mcporter | Both (synced) | agent-guards | Library & API Reference |
| 5 | oracle | Both (synced) | agent-guards | Library & API Reference |
| 6 | new-task | Both (synced) | agent-guards | Business Process & Team Automation |
| 7 | orchestrator | Both (synced) | agent-guards | Business Process & Team Automation |
| 8 | plan-loop | Both (synced) | agent-guards | Code Quality & Review |
| 9 | review-loop | Both (synced) | agent-guards | Code Quality & Review |
| 10 | audit-loop | Both (synced) | agent-guards | Code Quality & Review |
| 11 | self-test | Both (synced) | agent-guards | Product Verification |
| 12 | simplify | Codex only | agent-guards | Code Quality & Review |
| 13 | agent-browser | Claude only* | external | Library & API Reference |
| 14 | slack | Claude only* | external | Business Process & Team Automation |
| 15 | remotion-best-practices | Codex only | external | Library & API Reference |
| 16 | rp-investigate-cli | Codex only | external (repoprompt) | Runbooks |
| 17 | rp-oracle-export-cli | Codex only | external (repoprompt) | Business Process & Team Automation |
| 18 | rp-review-cli | Codex only | external (repoprompt) | Code Quality & Review |
| 19 | rp-refactor-cli | Codex only | external (repoprompt) | Code Quality & Review |

*agent-browser and slack also exist in `~/.agents/skills/` but are not in the managed-skills list, suggesting they were installed separately.

**Totals:** 19 unique skills. 11 synced across both systems. 4 Codex-only (repoprompt). 2 externally-managed (agent-browser, slack). 1 Codex-only managed (simplify).

---

## Per-Skill Findings (ordered by priority)

### 1. self-test -- Score: 4/8

**Category:** Product Verification | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Cleanly product verification |
| Gotchas | Missing | No gotchas section. Common failure modes: agent claiming verification without running commands, environment lacking test infra, credential-gated flows. These would save future runs. |
| Progressive Disclosure | Partial | Single file, 26 lines -- short enough to not need splitting, but could benefit from a references/ with example verification patterns for different stacks (web, iOS, CLI). |
| Description Quality | Pass | Excellent trigger-oriented description with specific trigger phrases. |
| Avoids Stating the Obvious | Partial | "If you can't prove it works, it's not done" and "build verification alongside implementation" are good principles but the agent mostly knows this already. The real value would be in project-specific verification recipes. |
| Avoids Railroading | Pass | Gives goals and constraints, lets agent decide execution. |
| Scripts/References | Partial | Could benefit from bundled verification script templates per project type. |
| Frontmatter | Pass | Has name and description. |

**Top Issues:**
- **P1:** Add a gotchas section with real failure modes (agent says "verified" without running commands, missing test infra, credential-gated services).
- **P2:** Add references/ with stack-specific verification patterns (e.g., how to self-test an iOS app, a web API, a CLI tool).

---

### 2. new-task -- Score: 4/8

**Category:** Business Process & Team Automation | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean single category. |
| Gotchas | Missing | No gotchas. Common issues: agent reaches 95% too quickly without probing deeply enough, user gives vague answers that don't actually resolve ambiguity, infinite loops when user is unsure. |
| Progressive Disclosure | Partial | Single short file. Fine for now. |
| Description Quality | Partial | Describes what it does but trigger phrases are limited. Could add: "when starting a new feature", "when requirements are unclear", "when I have a new idea". |
| Avoids Stating the Obvious | Partial | The question strategy section ("start broad, narrow each round") is generic advice the agent already knows. The real value is the confidence threshold and auto-transition to plan-loop. |
| Avoids Railroading | Pass | Gives structure but lets agent adapt questions. |
| Scripts/References | Pass | N/A -- instruction-only skill, no scripts needed. |
| Frontmatter | Pass | Has name and description. |

**Top Issues:**
- **P1:** Add gotchas: "Don't inflate confidence -- if the user's answers are vague, confidence should not increase", "Don't ask questions the codebase can answer -- investigate first".
- **P2:** Improve description with more trigger phrases.

---

### 3. orchestrator -- Score: 4/8

**Category:** Business Process & Team Automation | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Partial | Straddles Business Process (orchestration) and Code Quality (review phase). Acceptable since it's a meta-skill that composes other focused skills. |
| Gotchas | Missing | No gotchas. Key failure modes: TeamCreate agent file conflicts, plan invalidation during implementation, simplify finding too many issues and creating a long fix cycle. |
| Progressive Disclosure | Partial | Single file, 41 lines. Fine for size, but could use a references/ with guidelines on team sizing and file ownership strategies. |
| Description Quality | Partial | Describes what it does but lacks trigger phrases. Should add: "complex feature", "big task", "needs multiple agents", "end-to-end". |
| Avoids Stating the Obvious | Pass | Content is specific to the agent-team workflow, not generic. |
| Avoids Railroading | Pass | Clear phases but flexible execution within each. |
| Scripts/References | Partial | Could benefit from a reference on team sizing heuristics and agent assignment patterns. |
| Frontmatter | Pass | Has name and description. |

**Top Issues:**
- **P1:** Add gotchas section covering TeamCreate pitfalls (file ownership conflicts, stale plan handling).
- **P2:** Add trigger phrases to description.

---

### 4. plan-loop -- Score: 5/8

**Category:** Code Quality & Review | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Cleanly code quality/review. |
| Gotchas | Missing | No gotchas in main file. Failure modes: cross-model tool not warmed causing failures, plans that are too detailed (rigid) vs too vague, over-iterating on review rounds. |
| Progressive Disclosure | Pass | Folder with references/review-protocol.md. Clear pointer in main file. |
| Description Quality | Pass | Good trigger-oriented description. |
| Avoids Stating the Obvious | Pass | Dual-model review, round sizing, confidence gates -- all org-specific. |
| Avoids Railroading | Pass | Provides structure but agent decides round count and focus areas. |
| Scripts/References | Pass | Has references/review-protocol.md. |
| Frontmatter | Pass | Has name and description. |

**Top Issues:**
- **P1:** Add a gotchas section: "Pre-warm ToolSearch before first cross-model call or it will fail", "Plans that are too detailed become rigid -- keep to architecture-level decisions", "Cross-model calls serialize -- never launch 2 in the same round".

---

### 5. review-loop -- Score: 5/8

**Category:** Code Quality & Review | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Cleanly code quality/review. |
| Gotchas | Missing | Same gap as plan-loop -- no gotchas section. |
| Progressive Disclosure | Pass | Folder with references/. |
| Description Quality | Pass | Good. |
| Avoids Stating the Obvious | Pass | Org-specific dual-model process. |
| Avoids Railroading | Pass | Flexible within rounds. |
| Scripts/References | Pass | Has references/review-protocol.md. |
| Frontmatter | Pass | Has name and description. |

**Top Issues:**
- **P1:** Add gotchas: "Don't re-review the entire changeset each round -- focus on what changed since last round", "Auto-commit at >=85 confidence can be surprising if the PR isn't ready -- confirm scope first".

---

### 6. audit-loop -- Score: 5/8

**Category:** Code Quality & Review | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean. |
| Gotchas | Missing | No gotchas. Key issue: "Every meaningful claim must cite evidence" is good but the agent needs to know what to do when evidence is ambiguous or contradictory. |
| Progressive Disclosure | Pass | Folder with references/. |
| Description Quality | Partial | "Lightweight read-only audit" -- could use more trigger phrases like "analyze this code", "investigate this bug", "audit this system". |
| Avoids Stating the Obvious | Pass | Specific process. |
| Avoids Railroading | Pass | Flexible. |
| Scripts/References | Pass | Has references/. |
| Frontmatter | Pass | Has name and description. |

**Top Issues:**
- **P1:** Add gotchas: "When evidence is contradictory, state both sides with confidence levels", "Don't treat absence of evidence as evidence of absence".
- **P2:** Improve description trigger phrases.

---

### 7. fix-ci -- Score: 7/8

**Category:** CI/CD & Deployment | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean CI/CD. |
| Gotchas | Partial | Error handling section covers some edge cases (no auth, no PR, max iterations, external checks) but it's not labeled as gotchas and misses: flaky tests requiring re-run not fix, CI checks that pass on re-run but fail again, rate limiting on gh API. |
| Progressive Disclosure | Pass | Folder with scripts/inspect_pr_checks.py. |
| Description Quality | Pass | Excellent trigger-oriented description. |
| Avoids Stating the Obvious | Pass | Highly specific to the CI fix workflow. |
| Avoids Railroading | Partial | Quite prescriptive step-by-step, though this is appropriate for a CI fix loop where consistency matters. |
| Scripts/References | Pass | Has bundled Python script for robust CI inspection. |
| Frontmatter | Pass | Full frontmatter with metadata. |

**Top Issues:**
- **P2:** Consolidate error handling into a dedicated gotchas section and add flaky-test handling (detect flaky vs real failure pattern).

---

### 8. ios-release -- Score: 7/8

**Category:** CI/CD & Deployment | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean CI/CD. |
| Gotchas | Partial | Guardrails section covers safety but misses operational gotchas: ASC token expiry mid-flow, network timeouts during upload, build processing delays at Apple's end. |
| Progressive Disclosure | Pass | Excellent -- 4 reference files with clear "load only when needed" guidance. |
| Description Quality | Pass | Strong trigger-oriented description with 4 specific use cases. |
| Avoids Stating the Obvious | Pass | Highly specific to ASC CLI. |
| Avoids Railroading | Pass | Two-phase (preflight/execute) with clear gates but flexible within each. |
| Scripts/References | Pass | 4 reference files covering different aspects. |
| Frontmatter | Pass | Full frontmatter. |

**Top Issues:**
- **P2:** Add a gotchas section for operational issues (token expiry, upload timeouts, processing delays).

---

### 9. ios-dev -- Score: 6/8

**Category:** Library & API Reference | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean library/API reference. |
| Gotchas | Partial | Guardrails section has some (prefer simulator-first, ask before destructive cleanup), but no dedicated gotchas section for common failures: DerivedData corruption, simulator boot failures, code signing issues. |
| Progressive Disclosure | Partial | Single file at 148 lines. Could split device builds, debugging, and swift package sections into references/. |
| Description Quality | Pass | Excellent trigger-oriented with 4 use cases. |
| Avoids Stating the Obvious | Pass | Specific to xcodebuildmcp CLI. |
| Avoids Railroading | Pass | Provides commands and patterns, lets agent compose. |
| Scripts/References | Partial | No bundled scripts. Could benefit from a diagnostic script that checks Xcode/simulator health. |
| Frontmatter | Pass | Full frontmatter. |

**Top Issues:**
- **P1:** Add dedicated gotchas section for DerivedData corruption, code signing failures, simulator boot issues.
- **P2:** Split into folder with references/ for device builds and debugging.

---

### 10. oracle -- Score: 6/8

**Category:** Library & API Reference | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean library reference. |
| Gotchas | Partial | Session management section covers some pitfalls (detached sessions, duplicate prompt guard). But scattered -- not a dedicated section. Missing: API cost surprises, browser mode timeouts, GPT-5.2 Pro rate limits. |
| Progressive Disclosure | Partial | Single file at 88 lines. Manageable size but growing. |
| Description Quality | Partial | Describes usage but could be more trigger-oriented: "second opinion", "cross-validate", "debug with another model". |
| Avoids Stating the Obvious | Pass | Specific to oracle CLI. |
| Avoids Railroading | Pass | Gives golden path but explicitly allows flexibility. |
| Scripts/References | Partial | No bundled scripts. A common prompt template file would save the agent from reconstructing it each time. |
| Frontmatter | Pass | Full frontmatter. |

**Top Issues:**
- **P1:** Consolidate scattered warnings into a dedicated gotchas section.
- **P2:** Bundle a prompt template file in references/.

---

### 11. mcporter -- Score: 5/8

**Category:** Library & API Reference | **Agent System:** Both (synced)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean library reference. |
| Gotchas | Partial | "Tool names drift between versions" is a good gotcha but it's in the Rules section, not a dedicated section. Missing: server startup latency, auth token requirements per server, output size limits. |
| Progressive Disclosure | Pass | Single file, 41 lines. Appropriate size. |
| Description Quality | Pass | Good trigger-oriented description. |
| Avoids Stating the Obvious | Pass | Specific to mcporter. |
| Avoids Railroading | Pass | Minimal, lets agent decide. |
| Scripts/References | Partial | Could benefit from a reference listing common server names and their tools. |
| Frontmatter | Pass | Full frontmatter. |

**Top Issues:**
- **P2:** Add dedicated gotchas section with server-specific failure modes.
- **P2:** Add references/ with common MCP server catalog.

---

### 12. agent-browser -- Score: 6/8

**Category:** Library & API Reference | **Agent System:** Claude (+ Codex, separately installed)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean library reference. |
| Gotchas | Partial | Ref Lifecycle section is effectively a gotcha (refs invalidated on page change). Security section has warnings. But no consolidated gotchas section for common failures: stale daemon processes, snapshot returning empty results on SPAs before hydration, CDP connection failures. |
| Progressive Disclosure | Pass | Excellent folder structure -- 7 reference files and 3 templates with clear table pointing to each. |
| Description Quality | Pass | Strong trigger-oriented description with many specific trigger phrases. |
| Avoids Stating the Obvious | Pass | Highly specific to agent-browser CLI. |
| Avoids Railroading | Pass | Shows patterns, lets agent compose. |
| Scripts/References | Pass | 7 references + 3 templates. |
| Frontmatter | Pass | Full frontmatter with allowed-tools. |

**Top Issues:**
- **P1:** At 633 lines, the main SKILL.md is very large. Move some "Common Patterns" and "Security" sections into references/ to reduce always-loaded context.
- **P2:** Add a dedicated gotchas section for stale daemons, SPA hydration timing, CDP connection failures.

---

### 13. slack -- Score: 4/8

**Category:** Business Process & Team Automation | **Agent System:** Claude (+ Codex, separately installed)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean business process/automation. |
| Gotchas | Partial | Limitations section covers some (no API, session-specific, rate limiting) but hardcoded ref numbers (`@e12`, `@e13`, `@e14`) throughout are a gotcha waiting to happen -- these change per session. |
| Progressive Disclosure | Partial | Has references/ and templates/ but main file is 295 lines with a lot of example code that could live in references/. |
| Description Quality | Pass | Good trigger phrases. |
| Avoids Stating the Obvious | Partial | "Take snapshots before clicking" and "Re-snapshot after navigation" are obvious to anyone using agent-browser. The agent-browser skill itself already covers this. |
| Avoids Railroading | Partial | The hardcoded ref numbers (`@e12 - Home tab`, `@e14 - Activity tab`) are misleading -- they vary per session. This railroads the agent into using wrong refs. |
| Scripts/References | Partial | Has templates/slack-report-template.md and references/slack-tasks.md but could use more. |
| Frontmatter | Pass | Full frontmatter with allowed-tools. |

**Top Issues:**
- **P1:** Remove hardcoded ref numbers (`@e12`, `@e14`, `@e21`) -- they change per session and mislead the agent. Replace with "look for the Home tab button" or similar semantic descriptions.
- **P1:** Remove duplicate agent-browser instructions (snapshot-before-click, re-snapshot-after-nav) -- the agent-browser skill already teaches this.
- **P2:** Move example scripts to references/ to shrink the main file.

---

### 14. simplify -- Score: 5/8

**Category:** Code Quality & Review | **Agent System:** Codex only (managed)

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean code quality. |
| Gotchas | Missing | No gotchas. Key issues: agents flagging intentional patterns as issues, false positives from efficiency review, "fix each issue directly" can cascade into large changes. |
| Progressive Disclosure | Pass | Single file, 54 lines. Appropriate. |
| Description Quality | Partial | "Review changed code for reuse, quality, and efficiency" -- generic. Should add: "after implementation", "clean up code", "reduce duplication". |
| Avoids Stating the Obvious | Pass | The three-agent parallel review with specific focus areas is org-specific. |
| Avoids Railroading | Partial | "Fix each issue directly" is quite rigid -- sometimes findings should be deferred or discussed. |
| Scripts/References | Pass | N/A -- agent-orchestration skill, no scripts needed. |
| Frontmatter | Pass | Has name, description, and agent-only flag. |

**Top Issues:**
- **P1:** Add gotchas: "Not all findings are worth fixing -- skip false positives without debate", "Cascading fixes can bloat the changeset -- keep fixes minimal".
- **P2:** Improve description with trigger phrases.

---

### 15. remotion-best-practices -- Score: 6/8

**Category:** Library & API Reference | **Agent System:** Codex only

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Clean library reference. |
| Gotchas | Missing | No gotchas section. Common Remotion pitfalls: SSR vs client rendering differences, bundle size from heavy animations, font loading race conditions. |
| Progressive Disclosure | Pass | Excellent -- 27 rule files in rules/ with clear index in main file. |
| Description Quality | Missing | "Best practices for Remotion - Video creation in React" is generic. Should include trigger phrases: "Remotion code", "video composition", "animation", "rendering video". |
| Avoids Stating the Obvious | Pass | Remotion-specific knowledge the agent wouldn't have. |
| Avoids Railroading | Pass | Reference material, not prescriptive steps. |
| Scripts/References | Pass | 27 rule files with code examples including .tsx assets. |
| Frontmatter | Pass | Has name, description, and tags. |

**Top Issues:**
- **P1:** Rewrite description to be trigger-oriented: when should the agent load this skill?
- **P2:** Add a gotchas section in the main file for cross-cutting Remotion pitfalls.

---

### 16-19. rp-investigate-cli, rp-oracle-export-cli, rp-review-cli, rp-refactor-cli

These four skills are RepoPrompt-managed (`repoprompt_managed: true`). They share the same structure and patterns, so I'll score them together.

**Category:** Runbooks (investigate), Code Quality & Review (review, refactor), Business Process (oracle-export) | **Agent System:** Codex only

| Check | Verdict | Notes |
|-------|---------|-------|
| Category Clarity | Pass | Each fits cleanly. |
| Gotchas | Partial | Anti-patterns sections serve as gotchas. Good coverage of "don't skip builder" and "don't forget -w". Missing: timeout/retry strategies, what to do when builder returns low-quality results. |
| Progressive Disclosure | Partial | Single files each, 150-195 lines. The massive repeated rp-cli reference table (same 12-line block in all 4) should be extracted to a shared reference. |
| Description Quality | Missing | Generic descriptions: "Deep codebase investigation and architecture research with rp-cli commands". No trigger phrases. |
| Avoids Stating the Obvious | Pass | rp-cli specific knowledge. |
| Avoids Railroading | Partial | Very prescriptive step-by-step with multiple "REQUIRED" and "CRITICAL" labels. Some warranted (workspace verification), some overkill. |
| Scripts/References | Partial | No bundled scripts. The shared rp-cli reference table should be a reference file. |
| Frontmatter | Pass | Have name, description, and repoprompt metadata. |

**Top Issues (all 4):**
- **P1:** Descriptions are not trigger-oriented -- need specific trigger phrases per skill.
- **P2:** Extract the repeated rp-cli command reference table into a shared `references/rp-cli-commands.md` to reduce duplication.
- **P2:** Tone down CRITICAL/REQUIRED markers where they're not truly critical.

---

## Repo-Level Gap Analysis

### Categories Present

| Category | Skills | Count |
|----------|--------|-------|
| Library & API Reference | ios-dev, mcporter, oracle, agent-browser, remotion-best-practices | 5 |
| Code Quality & Review | plan-loop, review-loop, audit-loop, simplify, rp-review-cli, rp-refactor-cli | 6 |
| CI/CD & Deployment | fix-ci, ios-release | 2 |
| Business Process & Team Automation | new-task, orchestrator, slack, rp-oracle-export-cli | 4 |
| Product Verification | self-test | 1 |
| Runbooks | rp-investigate-cli | 1 |

### Categories Missing

| Category | Relevance | Priority |
|----------|-----------|----------|
| **Code Scaffolding & Templates** | You have multiple projects (CI Agents Platform, Screen Time App, Homeschool Tools). A scaffolding skill for new project setup (Next.js, iOS, or monorepo) would save time on each new project. | **Medium** |
| **Data Fetching & Analysis** | No current skills for querying analytics, databases, or metrics. Low priority unless projects start needing data pipelines. | **Low** |
| **Infrastructure Operations** | No infra skills. Low priority for side projects unless you start managing cloud resources. | **Low** |

### Structural Gaps

1. **No test/verification skill for web projects.** `self-test` is generic philosophy; `ios-dev` handles iOS. But there's no skill for verifying web apps (e.g., "run the dev server, open in browser, check these flows"). Given CI Agents Platform is a web project, a web verification skill would be high value.

2. **agent-browser + slack skill duplication.** The slack skill re-teaches agent-browser basics (snapshot before click, re-snapshot after nav). These instructions should live only in agent-browser.

3. **simplify is Codex-only but not Claude-only.** The managed-skills file shows simplify syncs to Codex but not Claude. The orchestrator skill (which calls simplify) is on both systems. Claude Code users hitting orchestrator will fail at Phase 4.

---

## Quick Wins

### 1. Add gotchas sections to the top 5 skills (self-test, new-task, orchestrator, plan-loop, review-loop)

**Impact:** High. Gotchas are the single highest-signal content in a skill. Every future agent run benefits from documented failure modes. These 5 skills have zero gotchas and are used frequently.

**Effort:** Low. 5-10 lines per skill based on real usage patterns.

### 2. Fix hardcoded refs in slack skill

**Impact:** High. Hardcoded `@e12`, `@e14`, `@e21` refs actively mislead the agent -- they change every session. This causes failures every time the skill is used.

**Effort:** Low. Replace with semantic descriptions ("look for the Activity tab button").

### 3. Sync simplify to Claude Code

**Impact:** Medium-high. The orchestrator skill calls simplify in Phase 4, but simplify isn't synced to Claude Code. This means orchestrator breaks on Claude Code.

**Effort:** Trivial. Add "simplify" to the Claude managed-skills list in agent-guards sync config.

### 4. Shrink agent-browser SKILL.md

**Impact:** Medium. At 633 lines, it's the largest skill file. Every session that loads this skill consumes significant context. Move Common Patterns, Security, and example-heavy sections to references/.

**Effort:** Medium. Requires splitting content and updating references.

### 5. Rewrite descriptions for remotion-best-practices and rp-* skills to be trigger-oriented

**Impact:** Medium. Generic descriptions mean the model may not trigger these skills when it should. Better descriptions = better skill activation.

**Effort:** Low. 1-2 sentences per skill.

---

## Score Summary

| Skill | Score | Top Priority Fix |
|-------|-------|-----------------|
| fix-ci | 7/8 | Consolidate gotchas |
| ios-release | 7/8 | Add operational gotchas |
| agent-browser | 6/8 | Shrink main file, add gotchas |
| ios-dev | 6/8 | Add gotchas, split into folder |
| oracle | 6/8 | Consolidate gotchas, add template |
| remotion-best-practices | 6/8 | Rewrite description |
| plan-loop | 5/8 | Add gotchas |
| review-loop | 5/8 | Add gotchas |
| audit-loop | 5/8 | Add gotchas, improve description |
| mcporter | 5/8 | Add gotchas, add server catalog |
| simplify | 5/8 | Add gotchas, sync to Claude |
| self-test | 4/8 | Add gotchas, add verification patterns |
| new-task | 4/8 | Add gotchas, improve description |
| orchestrator | 4/8 | Add gotchas, improve description |
| slack | 4/8 | Remove hardcoded refs, deduplicate |
| rp-investigate-cli | 4/8 | Rewrite description, extract shared ref |
| rp-oracle-export-cli | 4/8 | Rewrite description, extract shared ref |
| rp-review-cli | 4/8 | Rewrite description, extract shared ref |
| rp-refactor-cli | 4/8 | Rewrite description, extract shared ref |

**Average score: 5.3/8**

The biggest systemic gap across all skills is **missing gotchas sections** -- 10 of 19 skills have no gotchas at all, and only 2 have a proper dedicated section. This is the single highest-leverage improvement area.
