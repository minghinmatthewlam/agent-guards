# Skills Audit Scorecard

**Date:** 2026-03-17
**Locations scanned:**
- `~/.claude/skills/` (Claude Code) -- 13 skills
- `~/.agents/skills/` (Codex) -- 18 skills (12 synced from agent-guards, 6 unique)
- `~/.claude/commands/` -- no commands (only config)

**Synced skills (agent-guards managed):** audit-loop, fix-ci, ios-dev, ios-release, mcporter, new-task, oracle, orchestrator, plan-loop, review-loop, self-test, simplify (codex-only sync)

**Codex-only skills:** remotion-best-practices, rp-investigate-cli, rp-oracle-export-cli, rp-review-cli, rp-refactor-cli, agent-browser (also in claude), slack (also in claude)

---

## Per-Skill Findings (ordered by priority -- highest-impact improvements first)

---

### 1. orchestrator

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (cat 4) |
| **Agent system** | Both (claude + codex, synced) |
| **Score** | 4/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Partial** | Straddles workflow orchestration (cat 4) and code quality/review (cat 6). It's a meta-skill that chains other skills -- this is fine architecturally, but it's doing clarify + plan + implement + simplify + review in one skill. |
| 2. Gotchas | **Missing** | No gotchas section. Likely failure modes: agent team deadlocks (file ownership conflicts), plan invalidation mid-implementation, sub-skill invocation failures, token budget exhaustion across phases. |
| 3. Progressive Disclosure | **N/A** | 41 lines, single file is appropriate. |
| 4. Description Quality | **Partial** | Describes what it does but trigger conditions are vague. When should a user invoke orchestrator vs. just plan-loop or review-loop directly? |
| 5. Avoids Stating Obvious | **Pass** | Content is specific to the multi-phase agent team workflow. |
| 6. Avoids Railroading | **Pass** | Gives phases but lets the agent adapt. |
| 7. Scripts/References | **N/A** | Orchestration skill, delegates to sub-skills. |
| 8. Frontmatter | **Pass** | Has name and description. |

**Top issues:**
- **P1**: Missing gotchas. Add: "If a TeamCreate agent fails silently, the orchestrator may proceed with incomplete work. Verify each agent's output before transitioning phases." Also: "Token budget can be exhausted before Phase 5 on large tasks -- monitor usage."
- **P2**: Description should include trigger phrases: "Use when the task is complex (4+ files, multiple modules), requires parallel implementation, or the user says 'build this end to end'."

---

### 2. plan-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (cat 6) |
| **Agent system** | Both (synced) |
| **Score** | 5/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly a planning + review workflow. |
| 2. Gotchas | **Missing** | No gotchas section. Key failure modes: cross-model tool not pre-warmed (mentioned in body but not as a gotcha), plan file location conflicts if multiple plan-loops run, confidence inflation by native reviewers. |
| 3. Progressive Disclosure | **Pass** | Has `references/review-protocol.md` split out. |
| 4. Description Quality | **Pass** | Good trigger-oriented description. |
| 5. Avoids Stating Obvious | **Pass** | Dual-model review is non-obvious, specific to this workflow. |
| 6. Avoids Railroading | **Pass** | Describes phases but gives flexibility in execution. |
| 7. Scripts/References | **Pass** | Has review-protocol.md reference. |
| 8. Frontmatter | **Pass** | Has name and description. |

**Top issues:**
- **P1**: Missing gotchas section. Add: "Cross-model tools must be pre-warmed before the first review round or calls will fail silently. If the plan file already exists from a previous run, the agent may read stale context -- always check timestamps. Confidence can inflate when native reviewers agree with each other without genuine adversarial pressure."

---

### 3. review-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (cat 6) |
| **Agent system** | Both (synced) |
| **Score** | 5/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly code review. |
| 2. Gotchas | **Missing** | Same gap as plan-loop -- no gotchas. Failure modes: reviewing before all changes are committed (misses files), cross-model tool failures, auto-pushing to remote without user intent. |
| 3. Progressive Disclosure | **Pass** | Has references/review-protocol.md. |
| 4. Description Quality | **Pass** | Good trigger phrasing. |
| 5. Avoids Stating Obvious | **Pass** | Dual-model review is specific. |
| 6. Avoids Railroading | **Pass** | Flexible. |
| 7. Scripts/References | **Pass** | Has review-protocol.md. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P1**: Missing gotchas. Add: "If changes span uncommitted + staged + committed files, the agent may review an incomplete picture. Ensure all changes are committed or explicitly scoped. The >=85 confidence auto-push behavior can surprise users -- ensure they know this will happen."

---

### 4. audit-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (cat 6) |
| **Agent system** | Both (synced) |
| **Score** | 5/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Read-only audit, fits cleanly. |
| 2. Gotchas | **Missing** | No gotchas. Failure modes: agent making code changes despite "read-only" instruction, cross-model tool not pre-warmed, evidence claims without file citations. |
| 3. Progressive Disclosure | **Pass** | Has references/review-protocol.md. |
| 4. Description Quality | **Partial** | Description is functional but could be more trigger-oriented. Add: "Use when the user asks 'is this safe?', 'what's wrong with this?', 'analyze this code', or wants investigation without changes." |
| 5. Avoids Stating Obvious | **Pass** | Specific workflow. |
| 6. Avoids Railroading | **Pass** | Flexible. |
| 7. Scripts/References | **Pass** | Has review-protocol.md. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P1**: Missing gotchas. Add: "Agent may attempt code changes despite read-only intent -- the skill must reinforce no-write behavior. Cross-model tool pre-warming is required."
- **P2**: Description could use more trigger phrases.

---

### 5. new-task

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (cat 4) |
| **Agent system** | Both (synced) |
| **Score** | 5/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Task clarification workflow. |
| 2. Gotchas | **Missing** | No gotchas. Failure modes: agent inflating confidence to skip clarification rounds, asking too many questions per round (user fatigue), failing to transition to plan-loop after reaching 95%. |
| 3. Progressive Disclosure | **N/A** | 31 lines, appropriate as single file. |
| 4. Description Quality | **Pass** | Clear trigger. |
| 5. Avoids Stating Obvious | **Pass** | Confidence-gated clarification is specific. |
| 6. Avoids Railroading | **Pass** | Gives strategy but lets agent adapt questions. |
| 7. Scripts/References | **N/A** | Behavioral skill, no scripts needed. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P1**: Missing gotchas. Add: "Agent tends to inflate confidence to avoid asking more questions -- enforce that 95% means 'I could implement this right now with zero ambiguity.' If the user gives short answers, don't skip follow-ups."

---

### 6. self-test

| Field | Value |
|-------|-------|
| **Category** | Product Verification (cat 2) |
| **Agent system** | Both (synced) |
| **Score** | 5/6 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly verification. |
| 2. Gotchas | **Missing** | Behavioral skill but still has failure modes: agent claiming "verified" without actually running commands, reporting success based on a passing subset while ignoring edge cases, building test infrastructure that itself is buggy. |
| 3. Progressive Disclosure | **N/A** | 26 lines, appropriate. |
| 4. Description Quality | **Pass** | Excellent trigger-oriented description with specific phrases. |
| 5. Avoids Stating Obvious | **Pass** | Reinforces behavior the agent knows but routinely skips. |
| 6. Avoids Railroading | **Pass** | Principles, not rigid steps. |
| 7. Scripts/References | **N/A** | Behavioral skill. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P2**: Add a short gotchas section: "Agent claims 'verified' without showing command output -- require exact commands + output as evidence. Agent may test the happy path only -- push for edge case coverage."

---

### 7. fix-ci

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment (cat 7) |
| **Agent system** | Both (synced) |
| **Score** | 7/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly CI/CD. |
| 2. Gotchas | **Pass** | Error handling section covers auth, no PR, max iterations, external checks. |
| 3. Progressive Disclosure | **Pass** | Folder with scripts/inspect_pr_checks.py bundled. |
| 4. Description Quality | **Pass** | Good trigger phrases in description. |
| 5. Avoids Stating Obvious | **Pass** | Specific to GitHub Actions inspection workflow. |
| 6. Avoids Railroading | **Partial** | Somewhat prescriptive step-by-step, but the structure is appropriate for a CI fix loop. Could give more latitude in Step 4 (analysis). |
| 7. Scripts/References | **Pass** | Has inspect_pr_checks.py with robust fallback handling. |
| 8. Frontmatter | **Pass** | Complete with metadata. |

**Top issues:**
- **P3**: Step 4 is slightly railroaded with specific patterns (lint, type, test, generated). Consider: "Analyze each failure using project context -- don't assume specific tooling."

---

### 8. ios-dev

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (cat 1) |
| **Agent system** | Both (synced) |
| **Score** | 5/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly a tool reference for xcodebuildmcp. |
| 2. Gotchas | **Partial** | Guardrails section covers some edge cases (simulator-first, destructive cleanup) but doesn't document common xcodebuildmcp failures: stale derived data, signing issues, simulator boot failures, daemon not running. |
| 3. Progressive Disclosure | **N/A** | 148 lines, single file is borderline but acceptable. |
| 4. Description Quality | **Pass** | Good trigger-oriented description. |
| 5. Avoids Stating Obvious | **Pass** | xcodebuildmcp CLI reference is non-obvious. |
| 6. Avoids Railroading | **Pass** | Reference-style, agent picks what to use. |
| 7. Scripts/References | **N/A** | Reference skill, command examples serve as the reference. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P2**: Expand gotchas: "xcodebuildmcp daemon may not be running -- check with `xcodebuildmcp daemon status` first. Derived data can cause phantom build failures -- `xcodebuildmcp simulator clean` before rebuilding. Signing issues require manual Xcode intervention."

---

### 9. ios-release

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment (cat 7) |
| **Agent system** | Both (synced) |
| **Score** | 7/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly deployment/release. |
| 2. Gotchas | **Pass** | Guardrails section is solid: no mutating in preflight, explicit approval required, deterministic IDs over names. |
| 3. Progressive Disclosure | **Pass** | Excellent folder structure with 4 reference files, loaded on-demand. |
| 4. Description Quality | **Pass** | Very trigger-oriented with 4 specific use cases. |
| 5. Avoids Stating Obvious | **Pass** | ASC-specific commands and workflows. |
| 6. Avoids Railroading | **Pass** | Two-phase gate is strict where needed (safety) but flexible in execution. |
| 7. Scripts/References | **Pass** | 4 reference files with clear loading guidance. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P3**: Minor -- could add a gotcha about ASC CLI version drift (commands may change between versions).

---

### 10. agent-browser

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (cat 1) |
| **Agent system** | Both (claude + codex) |
| **Score** | 6/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly a tool reference. |
| 2. Gotchas | **Partial** | Ref lifecycle section is a de facto gotcha, and security section covers risks. But missing common failure gotchas: daemon not starting, port conflicts, CDP connection failures, headless vs headed behavior differences. |
| 3. Progressive Disclosure | **Pass** | Excellent folder structure: 7 reference files, 3 templates, clear table linking to each. |
| 4. Description Quality | **Pass** | Comprehensive trigger list. |
| 5. Avoids Stating Obvious | **Pass** | agent-browser CLI specifics are non-obvious. |
| 6. Avoids Railroading | **Pass** | Reference-style, agent picks commands. |
| 7. Scripts/References | **Pass** | Templates and reference docs bundled. |
| 8. Frontmatter | **Pass** | Complete with allowed-tools. |

**Top issues:**
- **P2**: The skill is 633 lines -- consider moving "Common Patterns" and "Security" sections to reference files. The main SKILL.md could focus on core workflow + essential commands + gotchas, with pointers to references for advanced topics.
- **P3**: Add explicit gotchas section for daemon/port issues.

---

### 11. oracle

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (cat 1) |
| **Agent system** | Both (synced) |
| **Score** | 6/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | CLI tool reference. |
| 2. Gotchas | **Pass** | Sessions section covers detach/timeout recovery. Safety section covers secrets. Budget section covers token management. |
| 3. Progressive Disclosure | **N/A** | 89 lines, single file appropriate. |
| 4. Description Quality | **Pass** | Clear trigger. |
| 5. Avoids Stating Obvious | **Pass** | Oracle-specific workflows. |
| 6. Avoids Railroading | **Pass** | Reference + golden path, not rigid steps. |
| 7. Scripts/References | **N/A** | Reference skill with inline examples. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P3**: Minor -- description could include more trigger phrases like "get a second opinion", "cross-validate", "ask another model".

---

### 12. mcporter

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (cat 1) |
| **Agent system** | Both (synced) |
| **Score** | 5/6 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | CLI tool reference. |
| 2. Gotchas | **Pass** | "tool names drift between versions" and offline/auth-gated fallback are documented. |
| 3. Progressive Disclosure | **N/A** | 41 lines, single file appropriate. |
| 4. Description Quality | **Pass** | Clear trigger. |
| 5. Avoids Stating Obvious | **Pass** | mcporter-specific. |
| 6. Avoids Railroading | **Pass** | Reference-style. |
| 7. Scripts/References | **N/A** | Short reference skill. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P3**: Could add more non-obvious workflows beyond Chrome debugging.

---

### 13. slack

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (cat 4) |
| **Agent system** | Both (claude + codex) |
| **Score** | 4/8 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Partial** | Straddles tool reference (cat 1 -- agent-browser for Slack) and business automation (cat 4 -- Slack workflows). The browser automation mechanics dominate, but the value is in the Slack-specific patterns. |
| 2. Gotchas | **Partial** | Limitations section covers API absence, rate limiting. But missing: Slack DOM changes frequently breaking refs, workspace-specific sidebar layout differences, 2FA re-auth interrupting sessions. |
| 3. Progressive Disclosure | **Partial** | 295 lines in a single file. Has references/ and templates/ folders but the main file contains a lot of repetitive examples that could be split out. |
| 4. Description Quality | **Pass** | Good trigger phrases. |
| 5. Avoids Stating Obvious | **Partial** | Much of the content restates agent-browser commands in a Slack context. The truly valuable Slack-specific content (sidebar structure, ref hints for tabs) is buried. |
| 6. Avoids Railroading | **Pass** | Reference-style with examples. |
| 7. Scripts/References | **Pass** | Has references/slack-tasks.md and templates/. |
| 8. Frontmatter | **Pass** | Complete with allowed-tools. |

**Top issues:**
- **P1**: Too much overlap with agent-browser. Restructure to focus only on Slack-specific knowledge: sidebar structure, ref patterns for common elements, workspace navigation. Remove generic agent-browser command examples (the agent already has that skill).
- **P2**: Add Slack-specific gotchas: "Slack's DOM structure changes with updates -- refs for sidebar elements are not stable across sessions. Always re-snapshot. 2FA re-auth can interrupt sessions unexpectedly."
- **P2**: Move the full unread check example and common tasks to a reference file. Keep the main skill focused on Slack structure + patterns.

---

### 14. simplify

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (cat 6) |
| **Agent system** | Codex (synced from agent-guards, agent-only) |
| **Score** | 5/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly code quality review. |
| 2. Gotchas | **Missing** | No gotchas. Failure modes: agents flagging intentional patterns as issues (false positives), agents fixing things that break tests, parallel agents producing conflicting fixes. |
| 3. Progressive Disclosure | **N/A** | 54 lines, appropriate. |
| 4. Description Quality | **Partial** | Description is functional but not trigger-oriented. It's agent-only so trigger matching matters less, but it could still clarify when orchestrator should invoke it. |
| 5. Avoids Stating Obvious | **Pass** | Specific review checklists for reuse/quality/efficiency. |
| 6. Avoids Railroading | **Pass** | Gives review criteria but lets agents decide. |
| 7. Scripts/References | **N/A** | Behavioral skill with checklists. |
| 8. Frontmatter | **Pass** | Complete with agent-only flag. |

**Top issues:**
- **P2**: Add gotchas: "Parallel review agents may flag the same issue -- deduplicate findings before fixing. Some 'duplicate' code is intentional (e.g., similar but semantically different handlers) -- verify before consolidating."

---

### 15. remotion-best-practices

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (cat 1) |
| **Agent system** | Codex only |
| **Score** | 4/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Clearly a library reference. |
| 2. Gotchas | **Missing** | No gotchas in the main SKILL.md. Remotion has many pitfalls: frame timing vs. seconds confusion, bundle size with heavy assets, SSR vs. client rendering differences, calculateMetadata async gotchas. |
| 3. Progressive Disclosure | **Pass** | Excellent folder structure with 30+ rule files and code assets. |
| 4. Description Quality | **Missing** | "Best practices for Remotion - Video creation in React" is generic. Should include triggers: "Use when writing Remotion compositions, dealing with video/audio timing, animation sequences, captions, or any React-based video generation." |
| 5. Avoids Stating Obvious | **Pass** | Remotion-specific patterns are non-obvious. |
| 6. Avoids Railroading | **Pass** | Reference-style, agent picks relevant rules. |
| 7. Scripts/References | **N/A** | Rule files serve as references. |
| 8. Frontmatter | **Partial** | Has name and description but description is weak (see check 4). |

**Top issues:**
- **P1**: Description needs trigger phrases. Current description won't reliably trigger the skill.
- **P2**: Add a gotchas section to the main SKILL.md with cross-cutting Remotion pitfalls.

---

### 16. rp-investigate-cli

| Field | Value |
|-------|-------|
| **Category** | Runbooks (cat 8) |
| **Agent system** | Codex only (repoprompt-managed) |
| **Score** | 5/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Investigation runbook. |
| 2. Gotchas | **Pass** | Anti-patterns section serves as gotchas -- covers skipping builder, manual file reading, forgetting window ID. |
| 3. Progressive Disclosure | **N/A** | 196 lines, single file appropriate for a runbook. |
| 4. Description Quality | **Partial** | "Deep codebase investigation and architecture research with rp-cli commands" -- functional but not trigger-oriented. |
| 5. Avoids Stating Obvious | **Pass** | rp-cli-specific workflow. |
| 6. Avoids Railroading | **Partial** | Quite prescriptive ("Now begin the investigation. First run..."). The phased approach is appropriate for a runbook, but the final directive is rigid. |
| 7. Scripts/References | **N/A** | Runbook skill. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P2**: Description should include triggers: "Use when debugging issues, investigating architecture, tracing data flow, or doing root cause analysis."
- **P3**: The timeout warning (45 minutes) is important but buried -- could be a top-level gotcha.

---

### 17. rp-review-cli

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (cat 6) |
| **Agent system** | Codex only (repoprompt-managed) |
| **Score** | 6/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Code review. |
| 2. Gotchas | **Pass** | Anti-patterns section is thorough: skipping scope confirmation, manual review without builder, assuming diff is sufficient. |
| 3. Progressive Disclosure | **N/A** | 162 lines, single file appropriate. |
| 4. Description Quality | **Partial** | Functional but not trigger-oriented. |
| 5. Avoids Stating Obvious | **Pass** | rp-cli-specific review workflow. |
| 6. Avoids Railroading | **Pass** | Mandatory scope confirmation is appropriate safety; otherwise flexible. |
| 7. Scripts/References | **N/A** | Workflow skill. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P3**: Description could use trigger phrases.

---

### 18. rp-refactor-cli

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (cat 6) |
| **Agent system** | Codex only (repoprompt-managed) |
| **Score** | 6/7 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Code quality/refactoring. |
| 2. Gotchas | **Pass** | Anti-patterns section covers skipping builder, skipping analysis, manual exploration. |
| 3. Progressive Disclosure | **N/A** | 150 lines, appropriate. |
| 4. Description Quality | **Partial** | Generic description. |
| 5. Avoids Stating Obvious | **Pass** | rp-cli-specific refactoring workflow. |
| 6. Avoids Railroading | **Pass** | Two-phase (analyze then implement) is appropriate structure. |
| 7. Scripts/References | **N/A** | Workflow skill. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P3**: Description could use trigger phrases.

---

### 19. rp-oracle-export-cli

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (cat 4) |
| **Agent system** | Codex only (repoprompt-managed) |
| **Score** | 5/6 |

**Checklist:**

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | **Pass** | Workflow automation for oracle export. |
| 2. Gotchas | **Partial** | Workspace verification is documented but missing: token budget concerns, export path permissions, large repo context explosion. |
| 3. Progressive Disclosure | **N/A** | 64 lines, appropriate. |
| 4. Description Quality | **Partial** | "Export context for oracle consultation" -- functional but should mention triggers. |
| 5. Avoids Stating Obvious | **Pass** | rp-cli-specific. |
| 6. Avoids Railroading | **Pass** | Clear steps but flexible. |
| 7. Scripts/References | **N/A** | Short workflow. |
| 8. Frontmatter | **Pass** | Complete. |

**Top issues:**
- **P3**: Add gotcha about token budget for large repos.

---

## Score Summary

| Skill | Category | Score | Priority Issues |
|-------|----------|-------|----------------|
| orchestrator | Process/Automation | 4/8 | Missing gotchas, weak triggers |
| slack | Process/Automation | 4/8 | Too much agent-browser overlap, needs restructure |
| remotion-best-practices | Library Reference | 4/7 | Weak description/triggers |
| plan-loop | Code Quality | 5/8 | Missing gotchas |
| review-loop | Code Quality | 5/8 | Missing gotchas |
| audit-loop | Code Quality | 5/8 | Missing gotchas, weak triggers |
| new-task | Process/Automation | 5/7 | Missing gotchas |
| self-test | Verification | 5/6 | Minor gotchas gap |
| ios-dev | Library Reference | 5/7 | Incomplete gotchas |
| simplify | Code Quality | 5/7 | Missing gotchas |
| mcporter | Library Reference | 5/6 | Minor |
| rp-investigate-cli | Runbooks | 5/7 | Weak description |
| rp-oracle-export-cli | Process/Automation | 5/6 | Minor |
| agent-browser | Library Reference | 6/8 | Too long, should split |
| oracle | Library Reference | 6/7 | Minor |
| rp-review-cli | Code Quality | 6/7 | Minor |
| rp-refactor-cli | Code Quality | 6/7 | Minor |
| fix-ci | CI/CD | 7/8 | Minor |
| ios-release | CI/CD | 7/8 | Minor |

---

## Repo-Level Gaps

### Missing Skill Categories

| Gap | Evidence | Impact |
|-----|----------|--------|
| **No Code Scaffolding skill (cat 5)** | The repo has `templates/` directory and `scripts/new-repo.sh`. No skill teaches the agent how to scaffold new projects or components. | **Medium** -- When starting new side projects, the agent has to be told conventions each time. A scaffolding skill would encode project setup patterns. |
| **No Data Fetching skill (cat 3)** | Matt has Gmail + Calendar connected via Cowork MCP, and uses GitHub data. No skill teaches the agent how to query or analyze data from these sources. | **Low** -- Cowork handles most of this. |
| **No dedicated Deployment skill for non-iOS** | ios-release covers iOS, but there's nothing for web deployments (Vercel, Netlify, etc.) if side projects need them. | **Low** -- depends on project needs. |

### Suggested New Skills (by impact)

1. **project-scaffold** (cat 5) -- Encode Matt's preferred project setup: stack choices, directory structure, auth patterns, CI config. Would save significant time on new side projects. Source from `scripts/new-repo.sh` and `templates/`.

2. **content-writer** (cat 4) -- Matt posts daily on Twitter. A skill that helps draft tweets from the content queue (`memory/content/tweets-queue.md`) with his voice/style constraints would be high-value.

---

## Quick Wins

**Do these first -- highest impact across all skills:**

1. **Add gotchas sections to the trio: plan-loop, review-loop, audit-loop.** These three skills share the same dual-model review pattern and have the same gaps. Each needs 5-10 lines covering: cross-model tool pre-warming failures, confidence inflation, and scope mismatches. This is the single highest-impact improvement because these skills are used on nearly every task.

2. **Add gotchas to orchestrator.** It chains all the other skills and has zero failure mode documentation. Agent team deadlocks and token exhaustion are real risks.

3. **Restructure slack skill.** Remove duplicated agent-browser content, focus on Slack-specific knowledge (sidebar structure, ref hints, workspace patterns). This turns a 295-line unfocused skill into a tight, high-signal one.

4. **Fix remotion-best-practices description.** The current description won't reliably trigger the skill. Add specific trigger phrases. One-line fix, big impact for Codex users.

5. **Add trigger phrases to rp-* skill descriptions.** The four repoprompt skills all have functional but non-trigger-oriented descriptions. A quick pass to add "Use when..." phrases would improve invocation reliability.
