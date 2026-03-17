# Skills Audit Scorecard

**Date:** 2026-03-17
**Locations scanned:**
- `~/.claude/skills/` (13 skills) -- Claude Code
- `~/.agents/skills/` (6 additional Codex-only skills) -- Codex
- `~/.claude/commands/` (1 command) -- Claude Code

**Total skills audited:** 19 + 1 command

---

## Per-Skill Findings (ordered by priority -- biggest wins first)

---

### 1. slack

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 294 |
| **Score** | 4/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clearly business process automation |
| Gotchas | **Missing** | No gotchas section. Key failure modes: Slack DOM changes break hardcoded ref numbers (`@e14` for Activity tab, etc.), `connect 9222` fails if Chrome debugging isn't enabled, element refs in examples are session-specific but presented as stable. |
| Progressive Disclosure | **Partial** | At 294 lines, this should be split. The sidebar structure docs, common task recipes, and data extraction patterns could each be a reference file. |
| Description Quality | **Pass** | Good trigger phrases |
| Avoids Stating the Obvious | **Partial** | The "Best Practices" section ("take snapshots before clicking", "re-snapshot after navigation") restates what agent-browser already teaches. Focus on Slack-specific knowledge instead. |
| Avoids Railroading | **Partial** | The hardcoded ref numbers (`@e14` for Activity, `@e21` for More unreads) are brittle -- these change per session. Should say "find the Activity tab element" rather than assume `@e14`. |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | Has name, description, allowed-tools |

**Claude-specific:**

| Check | Result | Notes |
|-------|--------|-------|
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **Partial** | Hardcodes port 9222. Should be configurable or at least document how to find the right port. |
| C3. Data Persistence | **N/A** | |

**Top issues:**
1. **P1**: Hardcoded element refs will mislead the agent every session. Remove specific `@eN` numbers from examples; describe elements semantically instead.
2. **P1**: Add a gotchas section covering DOM instability, debugging port discovery, and workspace-specific layouts.
3. **P2**: Split into folder structure -- main file + `references/common-tasks.md` + `references/sidebar-structure.md`.

---

### 2. agent-browser

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 632 |
| **Score** | 6/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Pure library reference |
| Gotchas | **Partial** | Ref lifecycle and shell quoting are documented well, but scattered -- no dedicated gotchas/pitfalls section. Missing: daemon process leaks if close isn't called, `--auto-connect` silently failing, state file security implications. |
| Progressive Disclosure | **Pass** | Excellent folder structure with 7 reference files and 3 templates. Main file has clear "when to read" pointers. |
| Description Quality | **Pass** | Comprehensive trigger list |
| Avoids Stating the Obvious | **Pass** | Content is highly tool-specific; agent wouldn't know this without the skill |
| Avoids Railroading | **Pass** | Provides commands and patterns, lets agent compose |
| Scripts/References | **Pass** | Templates and deep-dive reference files |
| Frontmatter | **Pass** | Has name, description, allowed-tools |

**Claude-specific:**

| Check | Result | Notes |
|-------|--------|-------|
| C1. On-Demand Hooks | **N/A** | |
| C2. Setup/Config | **Pass** | Config file pattern well-documented |
| C3. Data Persistence | **Pass** | Session/state management documented |

**Top issues:**
1. **P2**: Consolidate the scattered warnings (ref lifecycle, shell quoting, daemon cleanup) into a single "Gotchas" section at the top for fast scanning.
2. **P3**: At 632 lines the main file is very long. Consider moving some of the less common patterns (iOS simulator, profiling, color scheme) to reference files.

---

### 3. oracle

| Field | Value |
|-------|-------|
| **Category** | Data Fetching & Analysis (cross-model consultation) |
| **Agent system** | Claude |
| **Lines** | 88 |
| **Score** | 6/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clear single purpose -- second-model consultation |
| Gotchas | **Pass** | Session detach/timeout, duplicate prompt guard, file size cap, secrets warning, token budget -- all covered |
| Progressive Disclosure | **N/A** | 88 lines, single file is appropriate |
| Description Quality | **Partial** | Describes what oracle does but could include more trigger conditions: "when stuck on a bug", "need a second opinion", "want cross-model validation" |
| Avoids Stating the Obvious | **Pass** | Highly tool-specific knowledge |
| Avoids Railroading | **Pass** | Golden path with flexibility |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P3**: Strengthen description with trigger phrases to reduce undertriggering.

---

### 4. ios-dev

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 147 |
| **Score** | 5/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clear xcodebuildmcp reference |
| Gotchas | **Missing** | No gotchas. Common failure modes: simulator not booted, wrong scheme name, code signing errors in CI, DerivedData corruption, `xcodebuildmcp` not installed. |
| Progressive Disclosure | **N/A** | 147 lines, fine as single file |
| Description Quality | **Pass** | Good trigger conditions |
| Avoids Stating the Obvious | **Pass** | Tool-specific CLI commands |
| Avoids Railroading | **Pass** | Provides commands, lets agent compose |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P1**: Add a gotchas section -- iOS dev has many non-obvious failure modes (signing, DerivedData, simulator state, SPM resolution). This is where the skill would provide the most value beyond command reference.

---

### 5. ios-release

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 147 |
| **Score** | 7/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clear deployment skill |
| Gotchas | **Partial** | Guardrails section covers safety, but no dedicated gotchas for common ASC failures: expired certificates, missing compliance answers, processing stuck builds, rate limits. |
| Progressive Disclosure | **Pass** | Uses references/ folder with 4 sub-files and clear "load only when needed" pointers |
| Description Quality | **Pass** | Excellent trigger conditions |
| Avoids Stating the Obvious | **Pass** | Highly specific to ASC CLI |
| Avoids Railroading | **Pass** | Phase A/B gate is a good pattern -- provides structure without rigidity |
| Scripts/References | **Pass** | 4 reference files |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P2**: Expand guardrails into a proper gotchas section covering common ASC/App Store failure modes.

---

### 6. fix-ci

| Field | Value |
|-------|-------|
| **Category** | CI/CD & Deployment |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 150 |
| **Score** | 7/8 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Clear CI/CD skill |
| Gotchas | **Partial** | Error handling section covers some edge cases, but missing: flaky tests (retry vs real failure), `gh` token expiry, log truncation hiding real errors, cascading failures from unrelated PRs. |
| Progressive Disclosure | **N/A** | 150 lines, fine as single file |
| Description Quality | **Pass** | Good trigger phrases |
| Avoids Stating the Obvious | **Pass** | The bundled script and triaging approach add real value |
| Avoids Railroading | **Pass** | Step-by-step but with flexibility in analysis |
| Scripts/References | **Pass** | Bundled `inspect_pr_checks.py` script |
| Frontmatter | **Pass** | Has metadata.short-description too |

**Top issues:**
1. **P2**: Add gotchas for flaky tests and log truncation -- these are the most common CI debugging traps.

---

### 7. plan-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 46 |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Workflow skill for planning |
| Gotchas | **Missing** | Key failure modes: agent skipping research and going straight to planning, cross-model tool warmup failures, plan drift during long execution without updating plan file. But at 46 lines, this is borderline -- the skill is deliberately concise. |
| Progressive Disclosure | **N/A** | 46 lines |
| Description Quality | **Pass** | Clear trigger |
| Avoids Stating the Obvious | **Pass** | Dual-model review and confidence gates are non-default behavior |
| Avoids Railroading | **Pass** | |
| Scripts/References | **Pass** | References `review-protocol.md` (shared) |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P3**: A brief gotchas note about common agent shortcuts (skipping research, not updating plan file mid-execution) would help.

---

### 8. review-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 35 |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **Missing** | Same pattern as plan-loop. Key failure mode: agent claiming "reviewed" without actually spawning cross-model review. |
| Progressive Disclosure | **N/A** | 35 lines |
| Description Quality | **Pass** | |
| Avoids Stating the Obvious | **Pass** | |
| Avoids Railroading | **Pass** | |
| Scripts/References | **Pass** | References shared review-protocol.md |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P3**: Brief gotchas note about agents faking review completion.

---

### 9. audit-loop

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 37 |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **Missing** | Same family as plan-loop/review-loop. Agent may claim "investigated" without running commands, or cite files without actually reading them. |
| Progressive Disclosure | **N/A** | 37 lines |
| Description Quality | **Pass** | |
| Avoids Stating the Obvious | **Pass** | |
| Avoids Railroading | **Pass** | |
| Scripts/References | **Pass** | References shared review-protocol.md |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P3**: Brief gotchas note.

---

### 10. self-test

| Field | Value |
|-------|-------|
| **Category** | Product Verification (behavioral overlay) |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 25 |
| **Score** | 5/5 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **N/A** | The skill itself IS a gotcha -- it corrects the agent's tendency to skip verification. At 25 lines, a separate gotchas section would be forced. |
| Progressive Disclosure | **N/A** | 25 lines |
| Description Quality | **Pass** | Excellent -- "don't just tell me it's done", "I don't want to test this" are great trigger phrases |
| Avoids Stating the Obvious | **Pass** | Reinforces behavior agents routinely skip |
| Avoids Railroading | **Pass** | Gives principles, not rigid steps |
| Scripts/References | **N/A** | Behavioral skill |
| Frontmatter | **Pass** | |

**Top issues:** None. This is a model behavioral skill -- concise, high-signal, well-triggered.

---

### 11. new-task

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 30 |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **Missing** | Agent may ask too many questions per round or ask obvious questions. But at 30 lines, borderline. |
| Progressive Disclosure | **N/A** | 30 lines |
| Description Quality | **Partial** | Good description but could add trigger phrases: "I have a new idea", "help me think through this", "what should we build" |
| Avoids Stating the Obvious | **Pass** | The 95% confidence gate and auto-transition to plan-loop are non-default |
| Avoids Railroading | **Pass** | |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P3**: Add trigger phrases to description.

---

### 12. orchestrator

| Field | Value |
|-------|-------|
| **Category** | Business Process & Team Automation |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 40 |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Meta-workflow orchestrator |
| Gotchas | **Missing** | Key failure mode: agent getting stuck in a sub-skill and not returning to the orchestrator. Also: TeamCreate file ownership conflicts. |
| Progressive Disclosure | **N/A** | 40 lines |
| Description Quality | **Pass** | |
| Avoids Stating the Obvious | **Pass** | Agent team coordination and phase transitions are non-default |
| Avoids Railroading | **Pass** | |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P3**: Brief gotchas about sub-skill transitions and TeamCreate file ownership.

---

### 13. mcporter

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference |
| **Agent system** | Claude (also synced to Codex) |
| **Lines** | 40 |
| **Score** | 6/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **Pass** | "tool names drift between versions" and offline/auth-gated handling covered. The "when to use mcporter vs direct MCP" section prevents misuse. |
| Progressive Disclosure | **N/A** | 40 lines |
| Description Quality | **Pass** | |
| Avoids Stating the Obvious | **Pass** | |
| Avoids Railroading | **Pass** | |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | |

**Top issues:** None. Clean, focused, well-scoped.

---

### 14. simplify (Codex-only)

| Field | Value |
|-------|-------|
| **Category** | Code Quality & Review |
| **Agent system** | Codex |
| **Lines** | ~65 |
| **Score** | 5/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **Missing** | Agent may flag false positives aggressively, or miss that "duplicate" code is intentionally separate. But the "if a finding is a false positive, skip it" line partially addresses this. |
| Progressive Disclosure | **N/A** | Short enough |
| Description Quality | **Partial** | Description is functional but sparse -- "Review changed code for reuse, quality, and efficiency" doesn't include trigger phrases. |
| Avoids Stating the Obvious | **Pass** | The three-agent parallel review pattern and specific anti-patterns (TOCTOU, recurring no-op updates, JSX nesting) are high-value, non-obvious guidance |
| Avoids Railroading | **Pass** | Specific checks but flexible execution |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | Has `agent-only: true` flag |

**Top issues:**
1. **P3**: Strengthen description with triggers like "clean up my code", "review for quality", "check for duplication".

---

### 15. remotion-best-practices (Codex-only)

| Field | Value |
|-------|-------|
| **Category** | Library & API Reference |
| **Agent system** | Codex |
| **Lines** | ~50 (index) + 34 rule files |
| **Score** | 5/7 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Pure library reference |
| Gotchas | **Missing** | No gotchas section. Remotion has many non-obvious pitfalls (useCurrentFrame performance, bundle size, codec compatibility). |
| Progressive Disclosure | **Pass** | Excellent -- index file with 30+ topic-specific rule files |
| Description Quality | **Partial** | "Use this skills whenever you are dealing with Remotion code" -- generic. Should include: "video rendering", "animation", "React video", "Remotion composition" as triggers. |
| Avoids Stating the Obvious | **Pass** | Highly domain-specific |
| Avoids Railroading | **Pass** | Reference material, not procedure |
| Scripts/References | **Pass** | 30+ rule files |
| Frontmatter | **Pass** | Has tags metadata |

**Top issues:**
1. **P2**: Add a gotchas section to the main SKILL.md covering top Remotion pitfalls.
2. **P3**: Improve description with specific trigger phrases.

---

### 16-19. rp-investigate, rp-oracle-export, rp-refactor, rp-review (Codex-only)

These four RepoPrompt CLI skills share the same structure and patterns. Scoring them together.

| Field | Value |
|-------|-------|
| **Category** | Runbooks (investigation), Code Quality & Review (review/refactor), Data Fetching (oracle-export) |
| **Agent system** | Codex |
| **Lines** | 100-200 each |
| **Score** | 4/7 (average) |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | Each has a clear purpose |
| Gotchas | **Missing** | No gotchas in any of them. Key issues: `builder` command timeout (partially addressed with timeout warning), window ID stale after workspace change, `rp-cli` not installed. |
| Progressive Disclosure | **N/A** | Reasonable lengths |
| Description Quality | **Partial** | Descriptions are functional but lack trigger phrases. "Deep codebase investigation" -- when would you use this vs just reading code? |
| Avoids Stating the Obvious | **Partial** | Heavy repetition of the rp-cli command table and workspace verification block across all 4 skills. This shared boilerplate could be a single reference file. |
| Avoids Railroading | **Missing** | Very rigid step-by-step with extensive anti-pattern lists. The "CRITICAL: Do NOT skip this step" and "REQUIRED" markers appear heavily. These are managed by RepoPrompt (`repoprompt_managed: true`) so may not be yours to change. |
| Scripts/References | **N/A** | |
| Frontmatter | **Pass** | |

**Top issues:**
1. **P1**: Heavy duplication -- the rp-cli command table and workspace verification block are copy-pasted across all 4 skills. Extract to a shared reference.
2. **P2**: Add gotchas for each (timeout, stale window IDs, missing CLI).
3. **P2**: Very prescriptive/railroading style. If these are RepoPrompt-managed (`repoprompt_managed: true`), this may be intentional and out of your control.

---

### Command: uithub

| Field | Value |
|-------|-------|
| **Category** | Data Fetching & Analysis |
| **Agent system** | Claude (command, not skill) |
| **Score** | 4/6 |

| Check | Result | Notes |
|-------|--------|-------|
| Category Clarity | **Pass** | |
| Gotchas | **Missing** | No mention of rate limiting, large repos timing out, private repo auth, or UiThub service downtime. |
| Progressive Disclosure | **N/A** | Single file command |
| Description Quality | **N/A** | Commands don't have frontmatter descriptions the same way |
| Avoids Stating the Obvious | **Pass** | UiThub-specific knowledge |
| Avoids Railroading | **Partial** | Step-by-step is appropriate for a command, but fallback logic could be more flexible |
| Scripts/References | **N/A** | |
| Frontmatter | **Missing** | No frontmatter (commands don't require it, but it would help) |

**Top issues:**
1. **P2**: Add gotchas for rate limits, private repos, service downtime.

---

## Repo-Level Gaps

| Gap | Evidence | Suggested Skill | Impact |
|-----|----------|----------------|--------|
| No testing/verification skill for specific projects | Has iOS apps (Screen Time App), but self-test is generic. No project-specific verification flows. | **screen-time-verifier**: Simulator-based test flow for the Screen Time app (launch, trigger streak, verify UI state) | High -- currently relies on manual testing |
| No deployment skill for non-iOS | CI Agents Platform is a project but no deploy skill for web services | **deploy-web**: Deploy flow for web projects (Vercel, Railway, etc.) | Medium -- depends on hosting choice |
| No content/marketing skill | Twitter is a key goal, tweets-queue exists, but no skill to help draft/schedule/publish | **twitter-drafts**: Draft tweets from content queue, check against voice guidelines, stage for review | Medium -- would save daily time |
| No data fetching skill | No skills for querying analytics, user metrics, or monitoring | Lower priority until products have users | Low |

---

## Quick Wins

These are the top 5 changes that would improve your skills the most, roughly in order of effort-to-impact:

### 1. Add gotchas to ios-dev (5 min, high impact)
iOS development has the most non-obvious failure modes of any skill here. A 10-line gotchas section covering signing, DerivedData, simulator state, and SPM resolution would prevent hours of debugging loops.

### 2. Fix hardcoded refs in slack skill (10 min, high impact)
Every `@e14`, `@e21` etc. in the Slack skill will mislead the agent. Replace with semantic descriptions ("click the Activity tab element", "find the More unreads button"). This is actively harmful as-is.

### 3. Add gotchas to agent-browser (10 min, medium impact)
Consolidate the scattered warnings (ref lifecycle, shell quoting, daemon leaks) into one scannable section near the top. The information exists but is buried in a 632-line file.

### 4. Split slack into folder structure (15 min, medium impact)
At 294 lines with distinct sections (sidebar structure, common tasks, data extraction, debugging), this is a natural candidate for a `references/` folder. Main file stays under 100 lines.

### 5. Extract shared rp-cli boilerplate (15 min, medium impact for Codex users)
The 4 RepoPrompt skills repeat ~50 lines of identical setup. A shared `references/rp-cli-setup.md` would cut duplication and make updates easier. (Skip this if RepoPrompt manages these files automatically.)

---

## Summary

**Overall impression:** This is a strong skill collection -- well above average for a first setup. The standouts are `self-test` (perfect behavioral skill), `agent-browser` (comprehensive reference with great progressive disclosure), `ios-release` (well-structured with reference files), and `mcporter` (clean and focused). The `*-loop` family (plan, review, audit) is a clever shared architecture.

**Main pattern to address:** Most skills are missing gotchas sections. This is the single highest-value content you can add -- it's where skills pay off most, because gotchas capture knowledge that only comes from real usage failures. Even 5-10 lines of "things that go wrong" per skill would meaningfully improve agent behavior.

**Score distribution:**
- Perfect or near-perfect (5+/6 or 6+/7): self-test, mcporter, oracle, fix-ci, ios-release, plan-loop, review-loop, audit-loop
- Good with clear improvements: agent-browser, ios-dev, new-task, orchestrator, simplify
- Needs attention: slack (hardcoded refs), rp-* skills (duplication, railroading)
