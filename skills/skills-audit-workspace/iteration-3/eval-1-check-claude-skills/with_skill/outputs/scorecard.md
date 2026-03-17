# Skills Audit Scorecard

**Location audited:** `~/.claude/skills/`
**Agent system:** Claude Code
**Skills found:** 13
**Date:** 2026-03-17

---

## Per-Skill Findings (ordered by priority)

---

### 1. slack

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (#4) |
| **Agent system** | Claude |
| **Lines** | 294 |
| **Structure** | Folder (references/, templates/) |
| **Score** | **5/11** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Clearly a team automation / business process skill |
| 2. Gotchas | Missing | No gotchas section. Needs: (1) refs like `@e14` are session-specific and will be wrong in different workspaces/states -- never hardcode them, always re-snapshot; (2) `connect 9222` fails silently if Chrome isn't running with remote debugging; (3) Slack's SPA routing means URL-based navigation is unreliable; (4) workspace switcher breaks session state |
| 3. Progressive Disclosure | Partial | Has references/ and templates/ folders, but the 294-line SKILL.md contains a lot of example code that could be moved to references. The main file reads more like a tutorial than a concise skill |
| 4. Description Quality | Pass | Good trigger phrases: "check my Slack", "what channels have unreads", etc. |
| 5. Avoids Stating the Obvious | Partial | Sections like "Sidebar Structure" and "Tabs in Slack" describe generic Slack UI. The hardcoded ref numbers (`@e12` - Home tab, `@e13` - DMs tab) are actively harmful -- they vary by session and will mislead the agent |
| 6. Avoids Railroading | Partial | The examples with hardcoded refs (`@e14`, `@e21`) are overly rigid. The workflow is flexible but the specific refs railroad the agent into wrong actions |
| 7. Includes Scripts/References | Partial | Has references/slack-tasks.md and a template, but the main file duplicates a lot of what should be in references |
| 8. Has Frontmatter | Pass | Name, description, allowed-tools |
| C1. On-Demand Hooks | N/A | No clear hook use case |
| C2. Setup / Config | Missing | Hardcodes port 9222. Should have a config pattern for: which port Chrome remote debugging is on, default workspace URL, preferred connection method |
| C3. Data Persistence | N/A | Doesn't accumulate data |

**Top issues (P1 first):**
1. **P1: Hardcoded refs are dangerous.** Lines like `@e12` - Home tab, `@e13` - DMs tab will be wrong in most sessions. Remove all hardcoded ref numbers. Instead, teach the agent to identify elements by their text/role after snapshotting.
2. **P1: Missing gotchas section.** The connect-to-existing-browser flow has several failure modes that should be documented.
3. **P2: Too much in SKILL.md.** Move the extended examples and the full unread check script to references/. Keep SKILL.md to core workflow + gotchas + pointers.
4. **P2: Missing config for connection.** Port 9222 should be configurable, not hardcoded.

---

### 2. agent-browser

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude |
| **Lines** | 632 |
| **Structure** | Folder (references/, templates/) |
| **Score** | **7/10** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Clearly a library/tool reference |
| 2. Gotchas | Missing | No dedicated gotchas section. Needs: (1) shell quoting issues with `eval` (partially covered inline but not consolidated); (2) refs invalidated on navigation (covered but not in a gotchas section); (3) headless Chrome crashes on large pages; (4) `--auto-connect` port conflicts; (5) state files containing plaintext secrets |
| 3. Progressive Disclosure | Partial | Has references/ and templates/ (good), but the 632-line SKILL.md is too long. The iOS Simulator section, detailed auth patterns, and security config should live in references/. The main file should be ~200-300 lines max |
| 4. Description Quality | Pass | Excellent trigger list covering many user intents |
| 5. Avoids Stating the Obvious | Pass | Highly specific to agent-browser CLI -- none of this is agent default knowledge |
| 6. Avoids Railroading | Pass | Provides patterns and options, lets agent decide approach |
| 7. Includes Scripts/References | Pass | 7 reference files + 3 templates. Well-structured deep-dive docs |
| 8. Has Frontmatter | Pass | Name, description, allowed-tools |
| C1. On-Demand Hooks | N/A | No clear hook use case |
| C2. Setup / Config | Pass | Documents config file pattern (`agent-browser.json`), env vars, priority chain |
| C3. Data Persistence | N/A | No accumulated data |

**Top issues (P1 first):**
1. **P1: 632 lines is too long for SKILL.md.** Move iOS Simulator, detailed auth patterns (Options 2-5), security section, and configuration file section to references/. Keep SKILL.md to: core workflow, essential commands, top 2-3 patterns, gotchas, and pointers to references.
2. **P2: Missing consolidated gotchas section.** Warnings are scattered (ref lifecycle, shell quoting, state file security). Consolidate into a dedicated section at the top.

---

### 3. orchestrator

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (#4) — straddles Code Quality (#6) |
| **Agent system** | Claude |
| **Lines** | 40 |
| **Structure** | Single file |
| **Score** | **5/8** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Partial | Meta-workflow that orchestrates other skills. Straddles business process automation and code quality review. This is acceptable given its nature as a coordinator, but it's worth noting |
| 2. Gotchas | Missing | Needs: (1) TeamCreate can fail if file ownership boundaries aren't enforced; (2) sub-skill invocations may not return control cleanly; (3) the simplify phase can conflict with review-loop findings; (4) "skip this for simple tasks" threshold is subjective -- define it |
| 3. Progressive Disclosure | N/A | 40 lines, single file is appropriate |
| 4. Description Quality | Partial | "Orchestrate complex tasks with agent teams" is vague. Should include triggers: "big feature", "multi-file refactor", "need a plan first", "coordinate multiple agents" |
| 5. Avoids Stating the Obvious | Pass | Defines a specific multi-phase workflow the agent wouldn't do on its own |
| 6. Avoids Railroading | Pass | Phases are clear but flexible; agent drives transitions |
| 7. Includes Scripts/References | N/A | Coordinator skill, scripts would be overkill |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P2: Missing gotchas.** TeamCreate coordination failures and sub-skill return control are real failure modes.
2. **P2: Vague description.** Add trigger phrases so the model knows when to use this vs. just implementing directly.

---

### 4. new-task

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation (#4) |
| **Agent system** | Claude |
| **Lines** | 30 |
| **Structure** | Single file |
| **Score** | **5/7** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Clearly a requirements clarification workflow |
| 2. Gotchas | Missing | Needs: (1) agent inflates confidence to skip clarification -- define what 95% actually means; (2) agent asks too many rounds of questions when user wants to just start; (3) transition to plan-loop can lose context if conversation is long |
| 3. Progressive Disclosure | N/A | 30 lines |
| 4. Description Quality | Partial | Describes what it does but lacks trigger phrases. Add: "new feature", "I want to build", "let's scope this out", "before we start" |
| 5. Avoids Stating the Obvious | Pass | Specific iterative process with confidence gating |
| 6. Avoids Railroading | Pass | Flexible question strategy, not prescriptive |
| 7. Includes Scripts/References | N/A | |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P2: Missing gotchas.** Confidence inflation is a known agent failure mode -- the skill should guard against it.
2. **P3: Description could use trigger phrases.**

---

### 5. plan-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Claude |
| **Lines** | 46 |
| **Structure** | Folder (references/) |
| **Score** | **7/8** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Planning + review workflow |
| 2. Gotchas | Partial | No dedicated section, but the "re-plan if plan breaks" instruction is a gotcha. Missing: (1) cross-model tool serialization causing timeouts; (2) plan files growing stale if execution diverges; (3) research phase can blow token budget |
| 3. Progressive Disclosure | N/A | 46 lines + references/ |
| 4. Description Quality | Pass | Good trigger-oriented description mentioning both model families |
| 5. Avoids Stating the Obvious | Pass | Specific dual-model review protocol is non-obvious |
| 6. Avoids Railroading | Pass | Flexible round sizing, confidence-based gates |
| 7. Includes Scripts/References | Pass | Has references/review-protocol.md |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P3: Add a gotchas section.** Cross-model serialization and token budget are real failure modes worth documenting.

---

### 6. review-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Claude |
| **Lines** | 35 |
| **Structure** | Folder (references/) |
| **Score** | **7/8** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Clearly code review |
| 2. Gotchas | Partial | Same as plan-loop -- cross-model serialization, plus: (1) review-loop on large changesets can miss issues due to context limits; (2) "auto commit and create PR" at 85+ confidence can be premature for high-risk changes |
| 3. Progressive Disclosure | N/A | 35 lines + references/ |
| 4. Description Quality | Pass | Good trigger description |
| 5. Avoids Stating the Obvious | Pass | Dual-model review is non-default behavior |
| 6. Avoids Railroading | Pass | Flexible round sizing |
| 7. Includes Scripts/References | Pass | Has references/review-protocol.md |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P3: Add gotchas section.** Auto-commit at 85+ confidence and large changeset context limits are worth documenting.

---

### 7. audit-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review (#6) |
| **Agent system** | Claude |
| **Lines** | 37 |
| **Structure** | Folder (references/) |
| **Score** | **6/8** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Read-only audit/review |
| 2. Gotchas | Missing | Needs: (1) agent may claim it investigated without actually running commands; (2) "every meaningful claim must cite evidence" is good but agent may cite irrelevant evidence; (3) read-only constraint can be violated if agent forgets mid-session |
| 3. Progressive Disclosure | N/A | 37 lines + references/ |
| 4. Description Quality | Partial | "Lightweight read-only audit" -- add triggers: "investigate", "analyze this", "audit the code", "what's going on with" |
| 5. Avoids Stating the Obvious | Pass | Evidence-based audit with cross-model verification is non-default |
| 6. Avoids Railroading | Pass | Flexible investigation approach |
| 7. Includes Scripts/References | Pass | Has references/review-protocol.md |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P2: Missing gotchas.** Agent claiming investigation without running commands is a real failure mode.
2. **P3: Description needs trigger phrases.**

---

### 8. fix-ci

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment (#7) |
| **Agent system** | Claude |
| **Lines** | 150 |
| **Structure** | Folder (scripts/) |
| **Score** | **8/10** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Clearly CI/CD |
| 2. Gotchas | Partial | Error handling section covers some edge cases (no gh auth, no PR, max iterations). Missing: (1) polling every 2 min can hit GitHub API rate limits; (2) script path `<path-to-skill>` needs to resolve correctly; (3) fix-push-wait loop can create noisy commit history |
| 3. Progressive Disclosure | N/A | 150 lines with scripts/ folder is well-sized |
| 4. Description Quality | Pass | Good triggers: "fix failing CI", "check PR status", "get a PR merge-ready" |
| 5. Avoids Stating the Obvious | Pass | Specific to the fix-ci loop pattern, bundled script, review comment triage |
| 6. Avoids Railroading | Partial | The step-by-step flow is somewhat rigid, but necessary for a CI fix loop. The comment triage section lets agent adapt. Minor: step numbering implies strict sequence when some steps could be parallel |
| 7. Includes Scripts/References | Pass | Bundled `inspect_pr_checks.py` with fallback instructions |
| 8. Has Frontmatter | Pass | Name, description, metadata |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P3: Consolidate gotchas.** Rate limits, script path resolution, and noisy commit history should be in a dedicated section.

---

### 9. ios-dev

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude |
| **Lines** | 147 |
| **Structure** | Single file |
| **Score** | **7/10** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Tool reference for xcodebuildmcp CLI |
| 2. Gotchas | Partial | Guardrails section covers some (prefer simulator, ask before erase). Missing: (1) simulator boot can hang if Xcode processes are stuck; (2) scheme names are case-sensitive; (3) `build-and-run` can silently install old build if build fails partially; (4) log capture session IDs are ephemeral |
| 3. Progressive Disclosure | N/A | 147 lines, single file is fine |
| 4. Description Quality | Pass | Good trigger list with multiple use cases |
| 5. Avoids Stating the Obvious | Pass | xcodebuildmcp CLI is not default agent knowledge |
| 6. Avoids Railroading | Pass | Provides commands and patterns, agent picks what to use |
| 7. Includes Scripts/References | N/A | CLI reference doesn't need bundled scripts |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | Partial | Mentions config.yaml but recommends explicit flags. Could note where to find/create the config |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P3: Expand gotchas.** Simulator hang, case-sensitive schemes, and partial build failures are real issues.

---

### 10. ios-release

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment (#7) |
| **Agent system** | Claude |
| **Lines** | 147 |
| **Structure** | Folder (references/) |
| **Score** | **9/10** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Clearly deployment/release |
| 2. Gotchas | Partial | Guardrails are good (never submit without approval, prefer IDs over names). Missing dedicated gotchas section: (1) ASC auth tokens expire mid-session; (2) `--wait` can hang indefinitely on processing builds; (3) version string must match Xcode project |
| 3. Progressive Disclosure | Pass | Clean reference map with 4 reference files, loaded on-demand |
| 4. Description Quality | Pass | Excellent trigger list covering TestFlight, App Store, blockers, playbooks |
| 5. Avoids Stating the Obvious | Pass | ASC CLI specifics are not agent defaults |
| 6. Avoids Railroading | Pass | Phase A/B gate pattern gives structure without over-prescribing |
| 7. Includes Scripts/References | Pass | 4 reference files covering different aspects |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | Pass | APP_ID, VERSION_ID, BUILD_ID are documented as required inputs |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P3: Add dedicated gotchas section.** Auth expiry and `--wait` hangs are real failure modes.

---

### 11. self-test

| Field | Value |
|-------|-------|
| **Category** | Product Verification (#2) |
| **Agent system** | Claude |
| **Lines** | 25 |
| **Structure** | Single file |
| **Score** | **7/7** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Behavioral verification overlay |
| 2. Gotchas | Pass | The entire skill IS a gotchas list -- it documents agent misbehavior patterns (claiming done without testing, reporting success with known failures, telling user to test) |
| 3. Progressive Disclosure | N/A | 25 lines |
| 4. Description Quality | Pass | Excellent trigger phrases: "make sure it works", "test it yourself", "don't just tell me it's done" |
| 5. Avoids Stating the Obvious | Pass | Agents routinely skip self-verification without this nudge |
| 6. Avoids Railroading | Pass | States principles, lets agent decide how to verify |
| 7. Includes Scripts/References | N/A | Behavioral skill |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | N/A | |
| C3. Data Persistence | N/A | |

**Top issues:** None. This is a well-crafted behavioral skill.

---

### 12. oracle

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude |
| **Lines** | 88 |
| **Structure** | Single file |
| **Score** | **7/9** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Tool reference for oracle CLI |
| 2. Gotchas | Partial | Safety section covers secrets. Sessions section covers detach/reattach. Missing consolidated gotchas: (1) browser mode can take up to 1 hour -- agent shouldn't treat this as a quick tool call; (2) duplicate prompt guard can block legitimate re-runs; (3) `--dry-run` output format varies between versions |
| 3. Progressive Disclosure | N/A | 88 lines is appropriate for single file |
| 4. Description Quality | Pass | Clear trigger: "second-model review", "debugging", "cross-validation" |
| 5. Avoids Stating the Obvious | Pass | Oracle CLI is not default agent knowledge |
| 6. Avoids Railroading | Pass | Golden path with alternatives, agent picks approach |
| 7. Includes Scripts/References | N/A | CLI reference, no scripts needed |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | Partial | Mentions `ORACLE_HOME_DIR` but doesn't document API key setup or browser prerequisites |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P3: Consolidate gotchas.** Long browser mode duration and duplicate prompt guard are worth highlighting.

---

### 13. mcporter

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference (#1) |
| **Agent system** | Claude |
| **Lines** | 40 |
| **Structure** | Single file |
| **Score** | **6/8** |

| Check | Score | Notes |
|-------|-------|-------|
| 1. Category Clarity | Pass | Tool reference for mcporter CLI |
| 2. Gotchas | Partial | "Always run list --schema before first call" is a gotcha. Missing: (1) server startup time can cause first call to timeout; (2) mcporter output format may differ from native MCP tool output; (3) some MCP servers require env vars that mcporter doesn't auto-inherit |
| 3. Progressive Disclosure | N/A | 40 lines |
| 4. Description Quality | Pass | Clear triggers for when to use vs. native MCP |
| 5. Avoids Stating the Obvious | Pass | mcporter is not default knowledge |
| 6. Avoids Railroading | Pass | Minimal rules, flexible usage |
| 7. Includes Scripts/References | N/A | Short CLI reference |
| 8. Has Frontmatter | Pass | Name + description |
| C1. On-Demand Hooks | N/A | |
| C2. Setup / Config | Missing | Doesn't explain how to configure servers (where's the server registry? config file?) |
| C3. Data Persistence | N/A | |

**Top issues (P1 first):**
1. **P2: Missing setup/config.** Where does mcporter find its server definitions? Agent needs to know this.
2. **P3: Expand gotchas.** Server startup timeouts and env var inheritance are real issues.

---

## Repo-Level Gaps

| Gap | Evidence | Priority | Suggested Skill |
|-----|----------|----------|-----------------|
| No test/verification skill for specific projects | ios-dev and fix-ci exist but there's no general "run tests and verify" skill for non-iOS projects | Low | Covered by self-test behavioral overlay -- probably sufficient |
| No code scaffolding skill (#5) | No template/scaffolding skills for creating new projects or components | Low | Only needed if Matt has recurring scaffolding patterns |
| No data fetching skill (#3) | No skills for querying databases, dashboards, or analytics | Low | Only relevant when a project needs it |
| No runbook skill (#8) | No incident response or debugging runbooks | Low | Could be valuable for production projects later |

Overall the skill collection is well-targeted to Matt's actual workflow (iOS dev, CI, browser automation, multi-agent coordination). No high-priority gaps.

---

## Quick Wins

### 1. Add gotchas sections to slack and agent-browser (P1)
These are the two most-used tool skills and both lack consolidated gotchas. The hardcoded refs in slack (`@e12`, `@e13`, `@e14`) are actively harmful -- they'll be wrong in most sessions and mislead the agent. Remove them and replace with guidance to identify elements by text/role after snapshotting.

### 2. Split agent-browser SKILL.md (P1)
At 632 lines, this is the longest skill by far. Move iOS Simulator, detailed auth options, security config, and configuration file sections to references/. Target ~250 lines for SKILL.md. The progressive disclosure infrastructure (references/, templates/) already exists -- use it.

### 3. Trim slack SKILL.md and remove hardcoded refs (P1)
Remove all specific ref numbers (`@e12`, `@e13`, `@e14`, `@e21`). Move extended examples to references/. The "Full Unread Check" script at the bottom should be a template, not inline.

### 4. Add trigger phrases to descriptions for orchestrator, new-task, audit-loop (P2)
These descriptions explain what the skill does but not when to use it. Adding 3-5 trigger phrases to each will improve auto-invocation accuracy.

### 5. Add setup/config documentation to mcporter (P2)
The agent needs to know where server definitions live and how to configure new ones. Without this, mcporter is hard to use for the first time.

---

## Summary

| Skill | Score | Top Priority |
|-------|-------|-------------|
| self-test | 7/7 (100%) | None -- exemplary |
| ios-release | 9/10 (90%) | P3: gotchas section |
| fix-ci | 8/10 (80%) | P3: consolidate gotchas |
| plan-loop | 7/8 (88%) | P3: gotchas section |
| review-loop | 7/8 (88%) | P3: gotchas section |
| ios-dev | 7/10 (70%) | P3: expand gotchas |
| oracle | 7/9 (78%) | P3: consolidate gotchas |
| agent-browser | 7/10 (70%) | P1: split SKILL.md |
| audit-loop | 6/8 (75%) | P2: gotchas + description |
| mcporter | 6/8 (75%) | P2: setup/config |
| orchestrator | 5/8 (63%) | P2: gotchas + description |
| new-task | 5/7 (71%) | P2: gotchas + description |
| slack | 5/11 (45%) | P1: remove hardcoded refs, add gotchas |

**Overall health:** Good. The skill collection is well-targeted and most skills follow best practices. The main systemic issue is missing gotchas sections (10 of 13 skills lack or have incomplete gotchas). The highest-impact fixes are in slack (hardcoded refs causing wrong actions) and agent-browser (SKILL.md too long for effective context use).
