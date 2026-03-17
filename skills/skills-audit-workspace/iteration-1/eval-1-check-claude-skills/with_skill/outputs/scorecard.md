# Skills Audit Scorecard

**Scope:** `~/.claude/skills/` (13 skills, all Claude Code)
**Date:** 2026-03-17

---

## Per-Skill Findings (ordered by priority)

### 1. agent-browser

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Score:** 6/11 (5 Pass, 3 Partial, 3 Missing/Partial)

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Cleanly Library & API Reference |
| 2. Gotchas Section | Missing | No dedicated gotchas section. The "Ref Lifecycle" section is close but covers only one failure mode. Real gotchas (shell quoting in `eval`, stale refs after SPA navigation, headless vs headed behavioral differences, networkidle not firing on streaming pages) should be consolidated into a top-level Gotchas section |
| 3. Progressive Disclosure | Partial | Has references/ and templates/ folders (good), but the main SKILL.md is 632 lines -- far above the ~200 line target. Much of the command reference duplicates what's in references/commands.md. The main file should be a concise workflow overview pointing to references for details |
| 4. Description Quality | Pass | Excellent trigger-oriented description with specific user intents |
| 5. Avoids Stating the Obvious | Partial | Some content (basic bash chaining with `&&`, CSS selectors) is obvious to the agent. The value is in agent-browser-specific patterns, which are good |
| 6. Avoids Railroading | Pass | Provides patterns and commands, lets agent compose |
| 7. Scripts/References | Pass | Includes references/ (7 files) and templates/ (3 scripts) |
| 8. Frontmatter | Pass | Has name, description, and allowed-tools |
| C1. On-Demand Hooks | Partial | Could benefit from a hook that auto-closes browser sessions on session end to prevent leaked processes. Currently relies on the agent remembering to `close` |
| C2. Setup/Config | Pass | Handles config via env vars, config files, and CLI flags -- flexible |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P1: Main file is 3x too long (632 lines).** Move the full command reference, common patterns, and security sections into reference files. Keep the main SKILL.md under ~200 lines with the core workflow, auth quick-start, and a reference map.
2. **P2: No gotchas section.** Add a dedicated section consolidating: shell quoting pitfalls in `eval`, ref invalidation timing, networkidle unreliability on streaming/websocket pages, and headed vs headless behavioral differences.
3. **P3: Add a session-cleanup hook.** A hook that runs `agent-browser close` on session end would prevent leaked Chrome processes.

---

### 2. slack

- **Category:** Business Process & Team Automation
- **Agent system:** Claude
- **Score:** 4/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Cleanly Business Process & Team Automation |
| 2. Gotchas Section | Missing | No gotchas section. Known failure modes: refs change every session (hardcoded `@e14` for Activity tab is unreliable), `connect 9222` fails if Chrome wasn't launched with `--remote-debugging-port`, Slack's virtual scrolling means most messages are invisible to snapshots |
| 3. Progressive Disclosure | Partial | Has references/ and templates/ (good), but main file is 294 lines -- above target. Sidebar structure docs, debugging section, and full example script could move to references |
| 4. Description Quality | Pass | Good trigger phrases covering the common user intents |
| 5. Avoids Stating the Obvious | Partial | The agent-browser workflow basics (snapshot-then-click) are already covered by the agent-browser skill. This skill should focus on Slack-specific navigation patterns, not re-teach browser automation |
| 6. Avoids Railroading | Partial | Hardcoded refs like `@e14` for Activity tab and `@e21` for More Unreads are brittle. These change per session. The skill should say "look for the Activity tab button" rather than assuming specific refs |
| 7. Scripts/References | Partial | Has references/slack-tasks.md and templates/slack-report-template.md, but could benefit from a reusable script that discovers common elements (unreads button, activity tab, DMs tab) by label rather than hardcoded ref |
| 8. Frontmatter | Pass | Has name, description, and allowed-tools |
| C1. On-Demand Hooks | N/A | No clear hook benefit |
| C2. Setup/Config | Partial | Hardcodes port 9222. Should have a config mechanism for: CDP port, default workspace URL, preferred connect method |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P1: Hardcoded refs are fundamentally unreliable.** Remove all hardcoded `@eN` examples or explicitly mark them as "example only -- always re-snapshot." Better: teach the agent to find elements by accessible name/role instead of ref number.
2. **P1: No gotchas section.** Document: virtual scrolling hides most messages, `connect 9222` requires Chrome launched with debugging flag, Slack SPA navigation means refs go stale constantly, rate limiting on rapid interactions.
3. **P2: Overlaps with agent-browser skill.** Remove the general browser automation tutorial and focus on Slack-specific navigation patterns and data extraction strategies.

---

### 3. ios-dev

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Score:** 5/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Library & API Reference for xcodebuildmcp |
| 2. Gotchas Section | Missing | No gotchas section. iOS dev has many non-obvious failure modes: derived data corruption, simulator boot races, code signing in CI, SwiftUI preview crashes, SPM resolution conflicts |
| 3. Progressive Disclosure | Partial | Single file at 147 lines (acceptable size), but no references/ folder for deeper content like common build errors, signing troubleshooting, or simulator quirks |
| 4. Description Quality | Pass | Good trigger conditions covering normal dev, build issues, crashes, and fix loops |
| 5. Avoids Stating the Obvious | Pass | Focuses on xcodebuildmcp-specific workflows the agent wouldn't know |
| 6. Avoids Railroading | Pass | Provides tools and patterns, lets agent decide |
| 7. Scripts/References | Partial | No scripts or reference files. Would benefit from: a references/common-errors.md mapping error messages to fixes, and a references/signing.md for code signing troubleshooting |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No clear hook benefit |
| C2. Setup/Config | Partial | Expects project path, scheme, simulator name on every call. A config.json storing defaults would reduce repetition across invocations |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P1: No gotchas section.** Add common failure modes: derived data corruption (clean doesn't always fix it -- delete DerivedData), simulator boot timing issues, code signing identity mismatches, SPM cache issues.
2. **P2: No reference files.** Create references/common-errors.md with error-to-fix mappings and references/signing.md for code signing troubleshooting.

---

### 4. ios-release

- **Category:** CI/CD & Deployment
- **Agent system:** Claude
- **Score:** 7/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Cleanly CI/CD & Deployment |
| 2. Gotchas Section | Missing | No gotchas. App Store submissions have many non-obvious failure modes: processing stuck builds, encryption compliance gotchas, screenshot dimension mismatches, review rejection patterns |
| 3. Progressive Disclosure | Pass | Good folder structure with 4 reference files and clear "load only when needed" pointers |
| 4. Description Quality | Pass | Good triggers covering TestFlight, App Store, release blockers, and playbooks |
| 5. Avoids Stating the Obvious | Pass | Highly specific to `asc` CLI -- agent wouldn't know this |
| 6. Avoids Railroading | Pass | Provides phase-gated workflow with flexibility within each phase |
| 7. Scripts/References | Pass | 4 reference files covering distinct concerns |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | Partial | Could benefit from a pre-command hook that blocks `asc publish` and `asc submit` unless the preflight phase has passed -- enforcing the Phase A/B gate programmatically rather than relying on skill instructions |
| C2. Setup/Config | Partial | APP_ID, common GROUP_IDs, and default IPA paths are repeated on every invocation. A config.json with defaults would streamline the workflow |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: No gotchas section.** Add: builds stuck in "Processing" (wait up to 30 min), encryption compliance (ITAR/EAR), missing screenshots for specific device classes, "Missing Compliance" flag on new builds.
2. **P3: Config for repeated identifiers.** Store APP_ID, default group, and IPA path in a config so every invocation doesn't require them.

---

### 5. fix-ci

- **Category:** CI/CD & Deployment
- **Agent system:** Claude
- **Score:** 7/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Cleanly CI/CD & Deployment |
| 2. Gotchas Section | Missing | No gotchas section. Known issues: `gh run view --log-failed` can be empty for recently-failed runs (API delay), external checks (Buildkite etc.) aren't inspectable, flaky tests need different handling than real failures |
| 3. Progressive Disclosure | Partial | Main file is 150 lines (acceptable), has scripts/ with inspect_pr_checks.py (good). Could benefit from a references/common-failures.md |
| 4. Description Quality | Pass | Good triggers: "fix failing CI", "check PR status", "get PR merge-ready" |
| 5. Avoids Stating the Obvious | Pass | CI-specific patterns with `gh` CLI -- agent wouldn't reliably do this unprompted |
| 6. Avoids Railroading | Partial | Steps are fairly prescriptive (Step 1 through Step 8). The overall structure is good, but some steps could be more flexible |
| 7. Scripts/References | Pass | Bundled Python script for robust CI inspection |
| 8. Frontmatter | Pass | Has name, description, and metadata |
| C1. On-Demand Hooks | N/A | No clear hook benefit |
| C2. Setup/Config | Pass | Detects PR from git context -- no config needed |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: No gotchas section.** Add: `--log-failed` empty for recent failures, flaky test detection strategy, external checks are out-of-scope, max 3 iteration limit reasoning.
2. **P3: Slightly over-prescriptive.** The 8-step flow is reasonable for a CI fix loop, but the agent should be able to skip steps when context makes them unnecessary (e.g., skip readiness gate if user says "CI just failed").

---

### 6. oracle

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Score:** 6/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Library & API Reference for the oracle CLI |
| 2. Gotchas Section | Partial | Has a "Sessions + slugs" section that covers some pitfalls (detached sessions, stuck "running" status). But not a dedicated gotchas section, and missing: token budget overruns, ChatGPT rate limiting, stale session reattachment |
| 3. Progressive Disclosure | Partial | Single file at 88 lines (acceptable size). No references/ folder, but the content is concise enough |
| 4. Description Quality | Partial | Describes what the tool does but trigger conditions are weak. Should include: "get a second opinion", "cross-validate with another model", "debug with GPT", "review this with a different model" |
| 5. Avoids Stating the Obvious | Pass | Highly specific to oracle CLI |
| 6. Avoids Railroading | Pass | Provides patterns and defaults, lets agent decide |
| 7. Scripts/References | Partial | No scripts or references. A references/prompt-templates.md with battle-tested prompt templates for common tasks (debug, review, architecture) would be valuable |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No clear hook benefit |
| C2. Setup/Config | Partial | References `ORACLE_HOME_DIR` and `AGENT_BROWSER_ENCRYPTION_KEY` but doesn't provide a config pattern. API vs browser choice, default model, default engine could be configurable |
| C3. Data Persistence | Pass | Stores sessions in ~/.oracle/sessions (stable location) |

**Top issues:**
1. **P2: Weak trigger description.** Add user intents: "get a second opinion", "cross-validate", "ask another model", "debug with GPT".
2. **P3: Consolidate gotchas.** Move session pitfalls into a dedicated Gotchas section and add: token budget management, API cost consent, ChatGPT browser mode timeouts.

---

### 7. mcporter

- **Category:** Library & API Reference
- **Agent system:** Claude
- **Score:** 5/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Library & API Reference |
| 2. Gotchas Section | Missing | No gotchas. Should cover: server startup latency, tool name drift between versions (mentioned in rules but not as a gotcha), auth-gated servers, timeout behavior |
| 3. Progressive Disclosure | Partial | Single file at 40 lines -- appropriately concise for a small skill |
| 4. Description Quality | Partial | Describes what it does but trigger phrases are weak. Should add: "call an MCP tool", "use [server-name]", "run a tool without loading it" |
| 5. Avoids Stating the Obvious | Pass | MCPorter-specific -- agent wouldn't know this |
| 6. Avoids Railroading | Pass | Minimal and flexible |
| 7. Scripts/References | Partial | No references. A references/known-servers.md listing available servers and their common tools would save discovery time every session |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No clear hook benefit |
| C2. Setup/Config | Partial | No config for default servers or preferences. If the user always uses certain servers, a config would help |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: No gotchas section.** Add: tool name drift (already mentioned but deserves more emphasis), server startup latency, offline/auth-gated fallback behavior.
2. **P2: Weak trigger description.** Add specific MCP server names and common intents.
3. **P3: Add known-servers reference.** A list of available servers and their most-used tools would eliminate redundant `mcporter list` calls.

---

### 8. orchestrator

- **Category:** Business Process & Team Automation
- **Agent system:** Claude
- **Score:** 5/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Partial | Straddles Business Process & Team Automation and Code Quality & Review. It's a meta-workflow that composes other skills. This is a valid pattern but doesn't fit cleanly into one category |
| 2. Gotchas Section | Missing | No gotchas. Should cover: TeamCreate file ownership conflicts, when to skip orchestrator for simple tasks (mentioned but not as a gotcha), agent team sizing pitfalls |
| 3. Progressive Disclosure | Partial | Single file at 40 lines -- appropriately concise since it delegates to other skills |
| 4. Description Quality | Partial | "Orchestrate complex tasks with agent teams" is vague. Should include: "big feature", "multi-file change", "complex refactor", "need a plan before coding" |
| 5. Avoids Stating the Obvious | Pass | Specific to the agent team workflow |
| 6. Avoids Railroading | Pass | Defines phases but lets sub-skills handle details |
| 7. Scripts/References | Pass | Delegates to sub-skills which have their own references |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No clear hook benefit |
| C2. Setup/Config | N/A | Delegates config to sub-skills |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: Vague trigger description.** Rewrite to include: "build a feature", "big refactor", "multi-file change", "I need a plan first".
2. **P3: No gotchas about team sizing and file ownership.** Add guidance on when TeamCreate conflicts arise and how to avoid them.

---

### 9. new-task

- **Category:** Business Process & Team Automation
- **Agent system:** Claude
- **Score:** 5/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Business Process & Team Automation |
| 2. Gotchas Section | Missing | No gotchas. Should cover: users who want to skip clarification and just build, when 95% is unreachable (vague tasks), question fatigue |
| 3. Progressive Disclosure | Pass | 30 lines -- appropriately minimal |
| 4. Description Quality | Partial | Description mentions 95% confidence but not trigger phrases. Should include: "new feature", "build me X", "I have an idea", "start a new project" |
| 5. Avoids Stating the Obvious | Partial | The question strategy section ("start broad, narrow each round") is somewhat obvious for the agent. The value is in the transition to plan-loop |
| 6. Avoids Railroading | Pass | Provides a framework but lets agent decide questions |
| 7. Scripts/References | Pass | Appropriately simple -- no scripts needed |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No hook benefit |
| C2. Setup/Config | N/A | No config needed |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: Weak trigger description.** Add: "new feature", "build me X", "I have an idea for", "start a new project".
2. **P3: Question strategy section is obvious.** Replace with non-obvious guidance like "always ask about deployment target and existing code that overlaps" rather than generic "start broad, narrow each round".

---

### 10. plan-loop

- **Category:** Code Quality & Review (planning phase)
- **Agent system:** Claude
- **Score:** 6/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Partial | Planning is a meta-activity. Closest fit is Code Quality & Review but it also has Business Process elements. Acceptable as a workflow skill |
| 2. Gotchas Section | Missing | No gotchas. Should cover: cross-model tool warmup failure, plan file location conflicts (multiple agents planning simultaneously), over-planning small tasks |
| 3. Progressive Disclosure | Pass | 46-line main file with references/review-protocol.md -- good structure |
| 4. Description Quality | Pass | Good description with both model families context |
| 5. Avoids Stating the Obvious | Pass | Specific to dual-model review workflow |
| 6. Avoids Railroading | Pass | Confidence-based flow with flexibility |
| 7. Scripts/References | Pass | Has references/review-protocol.md |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No hook benefit |
| C2. Setup/Config | N/A | No config needed |
| C3. Data Persistence | Partial | Plans stored in `plans/<task>/plan.md` in the repo. The instruction to gitignore `plans/` is good, but this pattern could conflict if multiple plan-loop invocations run on overlapping tasks |

**Top issues:**
1. **P2: No gotchas section.** Add: ToolSearch pre-warming requirement, plan file naming collisions, when to skip planning (simple tasks), cross-model tool serialization.
2. **P3: Data persistence for plans.** Consider namespacing plan files with timestamps or session IDs to avoid collisions.

---

### 11. audit-loop

- **Category:** Code Quality & Review
- **Agent system:** Claude
- **Score:** 6/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Code Quality & Review |
| 2. Gotchas Section | Missing | No gotchas. Should cover: cross-model tool warmup, evidence citation requirements, when audit-loop vs review-loop |
| 3. Progressive Disclosure | Pass | 37-line main file with references/ -- good |
| 4. Description Quality | Partial | Describes the mechanism but not user triggers. Add: "investigate", "audit", "is this code correct", "check for issues" |
| 5. Avoids Stating the Obvious | Pass | Specific to dual-model audit workflow |
| 6. Avoids Railroading | Pass | Confidence-based with flexibility |
| 7. Scripts/References | Pass | Has references/review-protocol.md |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No hook benefit |
| C2. Setup/Config | N/A | No config needed |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: No gotchas.** Add: ToolSearch pre-warming, when to use audit-loop vs review-loop vs plan-loop (decision tree), evidence citation standards.
2. **P3: Trigger description could be stronger.** Add user-facing intents.

---

### 12. review-loop

- **Category:** Code Quality & Review
- **Agent system:** Claude
- **Score:** 6/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Code Quality & Review |
| 2. Gotchas Section | Missing | Same pattern as audit-loop and plan-loop |
| 3. Progressive Disclosure | Pass | 35-line main file with references/ |
| 4. Description Quality | Pass | Clear description with both model families context |
| 5. Avoids Stating the Obvious | Pass | Specific workflow |
| 6. Avoids Railroading | Pass | Confidence-based |
| 7. Scripts/References | Pass | Has references/review-protocol.md |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No hook benefit |
| C2. Setup/Config | N/A | No config needed |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: No gotchas.** Add: ToolSearch pre-warming (same pattern as siblings), when auto-PR creation happens vs not (confidence >= 85), how to handle review findings that require re-planning.

---

### 13. self-test

- **Category:** Product Verification
- **Agent system:** Claude
- **Score:** 5/11

| Check | Result | Notes |
|-------|--------|-------|
| 1. Category Clarity | Pass | Product Verification |
| 2. Gotchas Section | Missing | No gotchas. Should cover: tests that require network access, tests that need credentials, flaky verification strategies, when "can't verify" is the honest answer |
| 3. Progressive Disclosure | Pass | 25 lines -- appropriately minimal |
| 4. Description Quality | Pass | Excellent trigger description with specific user phrases |
| 5. Avoids Stating the Obvious | Partial | "Run your verification end-to-end" and "If it fails, fix and re-verify" are somewhat obvious. The value is in the mindset shift but the agent likely already knows to test its work |
| 6. Avoids Railroading | Pass | Provides principles, not rigid steps |
| 7. Scripts/References | Pass | Appropriately simple -- no scripts needed for a mindset skill |
| 8. Frontmatter | Pass | Has name and description |
| C1. On-Demand Hooks | N/A | No hook benefit |
| C2. Setup/Config | N/A | No config needed |
| C3. Data Persistence | N/A | No persistent data |

**Top issues:**
1. **P2: No gotchas.** Add: common verification blockers (no simulator, no test DB, missing credentials), how to surface blockers to the user, verification strategies for UI-heavy code.
2. **P3: Content leans obvious.** Add more non-obvious guidance: "for UI changes, take before/after screenshots", "for API changes, hit the endpoint and show the response", "for data migrations, show a before/after row".

---

## Repo-Level Gaps

Based on the repo contents and current skill set:

| Gap | Rationale | Priority |
|-----|-----------|----------|
| **No testing/linting skill** | The repo has validate-skills.yml in CI. No skill teaches agents how to run validation locally or what the CI checks enforce | P3 -- low impact since the repo is mostly markdown |
| **No content/tweet skill** | Matt posts daily on Twitter. The memory/ system has tweet queues. A skill for drafting, scheduling, or managing tweet batches could save significant time | P2 -- high frequency task with no automation |
| **No project scaffolding skill** | Multiple side projects at various stages. A skill for bootstrapping new projects with standard config (CLAUDE.md, CI, git hooks) would reduce setup time | P3 -- infrequent but valuable |

---

## Quick Wins

These 5 changes would have the biggest impact across all skills:

1. **Add gotchas sections to the top 5 skills (agent-browser, slack, ios-dev, fix-ci, ios-release).** This is the single highest-value improvement. Every skill is missing this, and gotchas are the highest-signal content for preventing agent failures. Start with agent-browser and slack since they have the most known failure modes.

2. **Shrink agent-browser SKILL.md from 632 to ~150 lines.** Move the command reference, common patterns, security section, and advanced features into reference files. This reduces always-loaded context by ~3,000 tokens per session.

3. **Remove hardcoded `@eN` refs from slack skill.** Replace with instructions to discover elements by accessible name/role. Current hardcoded refs will fail in every session, causing wasted retries.

4. **Improve trigger descriptions on 5 skills (oracle, mcporter, orchestrator, new-task, audit-loop).** Add specific user phrases that should activate each skill. Weak descriptions mean the model won't invoke the skill when it should.

5. **Add a shared gotchas note to the three loop skills (plan-loop, audit-loop, review-loop).** All three reference cross-model review and ToolSearch pre-warming but none document the failure modes. A shared references/gotchas.md (or adding to the existing review-protocol.md) would cover all three at once.

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| Total skills | 13 |
| Average score | 5.5 / 11 |
| Skills with gotchas section | 0 / 13 |
| Skills with good progressive disclosure | 8 / 13 |
| Skills with strong trigger descriptions | 7 / 13 |
| Skills with frontmatter | 13 / 13 |
| Most urgent fix | Gotchas sections (universal gap) |
| Biggest single-skill fix | agent-browser SKILL.md size reduction |
