# Skills Audit Scorecard

**Date:** 2026-03-17
**Scope:** All skills in `~/.claude/skills/` (Claude Code) and `~/.agents/skills/` (Codex)

---

## Inventory

### Shared skills (synced via agent-guards)

| Skill | Source | Claude | Codex | Notes |
|-------|--------|--------|-------|-------|
| audit-loop | agent-guards | Y | Y | |
| fix-ci | agent-guards | Y | Y | |
| ios-dev | agent-guards | Y | Y | |
| ios-release | agent-guards | Y | Y | |
| mcporter | agent-guards | Y | Y | |
| new-task | agent-guards | Y | Y | |
| oracle | agent-guards | Y | Y | |
| orchestrator | agent-guards | Y | Y | |
| plan-loop | agent-guards | Y | Y | |
| review-loop | agent-guards | Y | Y | |
| self-test | agent-guards | Y | Y | |
| simplify | agent-guards | N | Y | **Sync gap** -- listed in Codex `.agent-guards-managed-skills` but NOT in Claude's |

### Claude-only skills (not in agent-guards)

| Skill | Notes |
|-------|-------|
| agent-browser | Installed separately (vendor skill) |
| slack | Depends on agent-browser |

### Codex-only skills (not in agent-guards)

| Skill | Notes |
|-------|-------|
| agent-browser | Installed separately (vendor skill), same as Claude |
| slack | Same as Claude |
| remotion-best-practices | Vendor skill (Remotion project) |
| rp-investigate-cli | RepoPrompt managed (`repoprompt_managed: true`) |
| rp-oracle-export-cli | RepoPrompt managed |
| rp-review-cli | RepoPrompt managed |
| rp-refactor-cli | RepoPrompt managed |

---

## Sync Integrity

| Issue | Severity | Detail |
|-------|----------|--------|
| `simplify` missing from Claude skills | **High** | Listed in Codex `.agent-guards-managed-skills` but absent from Claude `.agent-guards-managed-skills` and not present in `~/.claude/skills/`. The `orchestrator` skill references `simplify` as Phase 4. Claude agents hitting this phase will fail. |
| `plan-loop` and `audit-loop` share `review-protocol.md` but `review-loop` has its own copy | Low | All three reference files are identical in content. This is fine -- the shared reference pattern works, but the duplication across three directories means updates must touch three files. Consider symlinking or storing one copy and referencing it from all three skills. |
| Source of truth missing `agent-browser` and `slack` | Info | These are not in `agent-guards/skills/` but are deployed to both Claude and Codex. If they're vendor-managed, this is expected. If you customized them, they could drift. |

---

## Per-Skill Quality Audit

### Rating Scale
- **A**: Production-ready, well-structured, clear trigger/scope, good guardrails
- **B**: Good overall, minor improvements possible
- **C**: Functional but has notable gaps
- **D**: Needs significant rework

---

### agent-browser -- Grade: A

**Strengths:**
- Exceptionally thorough -- covers every command, pattern, and edge case
- Good `allowed-tools` scoping restricts to only `agent-browser` commands
- Security section with opt-in content boundaries, domain allowlist, action policy
- Ref lifecycle section prevents a common automation pitfall
- Templates for quick starts

**Issues:**
- (Low) At ~630 lines, this is very long. The deep-dive reference table mitigates this -- the agent can load sub-references on demand. But the SKILL.md itself may consume significant context on every invocation.
- (Low) Description is a wall of text. Consider shortening and relying on the body for detail.

---

### audit-loop -- Grade: A

**Strengths:**
- Clean separation from plan-loop and review-loop with explicit "use X instead" callouts
- Confidence threshold and round sizing are concrete and actionable
- Requires evidence citations -- prevents hallucinated findings
- Lean (<40 lines)

**Issues:**
- None significant.

---

### fix-ci -- Grade: A

**Strengths:**
- Complete loop: detect PR -> wait for checks -> inspect -> fix -> push -> re-check
- Bundled Python script handles `gh` CLI field drift gracefully
- External check handling (Buildkite, CircleCI) correctly scoped out
- Review comment triage with priority tiers is a nice touch
- `--check-only` flag for non-destructive use

**Issues:**
- (Low) Step 2 polling at 2-minute intervals with max 10 retries (20 min) could be slow for fast CI. Consider making interval configurable.

---

### ios-dev -- Grade: A

**Strengths:**
- Single tool (`xcodebuildmcp`) covers the entire workflow -- no tool sprawl
- Discovery step is mandatory first -- prevents wrong-scheme builds
- Failure triage organized by failure class (build, test, runtime, simulator)
- Guardrails section: simulator-first, ask before destructive ops
- Output contract ensures every iteration reports consistently

**Issues:**
- (Low) No mention of SwiftUI previews or preview debugging, which is a common iOS dev need.

---

### ios-release -- Grade: A

**Strengths:**
- Two-phase design (read-only preflight vs. mutating execution) is excellent safety
- Explicit "never run mutating commands without approval" guardrail
- Reference map with lazy loading -- only load docs when needed
- Both TestFlight and App Store paths covered
- Release checklist output format ensures nothing is missed

**Issues:**
- None significant.

---

### mcporter -- Grade: B

**Strengths:**
- Very concise -- does one thing well
- "Always run list before first call" prevents tool name drift issues
- Clear when-to-use guidance (mcporter vs direct MCP)

**Issues:**
- (Medium) No error handling guidance. What happens when a server is down, returns malformed JSON, or auth fails? The "report it and continue" note is vague.
- (Low) Only one non-obvious workflow example (Chrome debugging). More examples would help.

---

### new-task -- Grade: B+

**Strengths:**
- Confidence-gated progression prevents premature planning
- Question strategy guidance (broad -> narrow) is practical
- Auto-transitions to plan-loop when ready

**Issues:**
- (Medium) 95% confidence threshold is high and subjective. The skill doesn't define what 95% means concretely. Compare to plan-loop (85) and review-loop (85) which have clearer thresholds.
- (Low) No guidance on what to do if the user stops engaging before 95%. Need an escape hatch.

---

### oracle -- Grade: B+

**Strengths:**
- Good security guidance (don't attach secrets, redact aggressively)
- Token budget awareness with `--files-report` and `--dry-run`
- Session management (reattach, don't re-run) prevents wasted work
- Prompt template section is high-value -- prevents "zero context" prompts

**Issues:**
- (Medium) Hardcoded model reference "GPT-5.2 Pro" will rot as models change. Consider parameterizing or noting this is the current default.
- (Low) The skill is somewhat verbose for what is essentially "bundle files + send to another model". The core loop could be tighter.

---

### orchestrator -- Grade: B+

**Strengths:**
- Clean 5-phase pipeline with explicit transitions
- "For simple tasks, skip this" -- avoids over-engineering small changes
- Each phase delegates to a specialized skill -- good composition
- TeamCreate guidance with vertical-slice ownership

**Issues:**
- (Medium) References `simplify` skill which is missing from Claude (see sync gap above).
- (Low) No guidance on what happens when a sub-skill fails or user rejects a plan mid-flow. Need fallback/abort paths.

---

### plan-loop -- Grade: A

**Strengths:**
- Research phase explicitly says "don't skimp" -- prevents shallow plans
- Cross-model review with coverage invariant (both families every round)
- Confidence bands with different exit criteria (< 70, 70-84, >= 85)
- "If plan breaks mid-execution, stop and re-plan" -- prevents sunk cost
- Round cap (R3) prevents infinite loops

**Issues:**
- (Low) `plans/` directory is gitignored. Good for keeping plans out of version control, but means plans are ephemeral. If a plan is valuable, there's no guidance on preserving it.

---

### review-loop -- Grade: A

**Strengths:**
- Same cross-model coverage invariant as plan-loop -- consistent
- Round sizing scales with risk surfaces (3-6 native for R1)
- Auto-commit at >= 85 confidence streamlines the happy path
- Atomic commits per fix

**Issues:**
- (Low) No guidance on what reviewers should prioritize. The review-protocol.md has a format but not a checklist of what to look for. Compare to simplify which has detailed review checklists.

---

### self-test -- Grade: B+

**Strengths:**
- Philosophy is right: "if you can't prove it works, it's not done"
- Explicit about surfacing blockers vs silently failing
- "Build verification alongside implementation" prevents afterthought testing

**Issues:**
- (Medium) Very short (~25 lines of content). No concrete examples of verification strategies. What does "run your verification end-to-end" look like for a UI change vs. an API change vs. a config change? Specific patterns would make this more actionable.
- (Low) No mention of how to handle flaky tests or environment-dependent verification.

---

### simplify -- Grade: A

**Strengths:**
- Three-agent parallel review (reuse, quality, efficiency) is thorough
- Each agent has a specific, non-overlapping checklist -- no redundant work
- Efficiency agent covers subtle issues (TOCTOU, no-op updates, N+1 patterns)
- Quality agent catches JSX-specific issues showing framework awareness
- `agent-only: true` correctly restricts this to agent use

**Issues:**
- (Low) Phase 3 says "fix each issue directly" but doesn't specify commit granularity. Should each fix be atomic?

---

### slack -- Grade: B

**Strengths:**
- Practical patterns for common Slack tasks
- Sidebar structure documentation helps navigation
- Best practices section with good tips (re-snapshot, JSON for parsing)
- Limitations section sets expectations

**Issues:**
- (Medium) Hardcoded ref numbers (`@e12`, `@e13`, `@e14`, `@e21`) are fragile. The skill acknowledges "varies by session" but still presents them as defaults. This will mislead agents into using stale refs.
- (Medium) `sleep 1` recommendation in best practices conflicts with agent-guards philosophy of avoiding unnecessary sleeps. Use `agent-browser wait` instead.
- (Low) No mention of workspace switching for multi-workspace users.

---

### remotion-best-practices (Codex only) -- Grade: B+

**Strengths:**
- Comprehensive topic coverage (30+ rule files)
- Each rule is a separate file -- agents only load what they need
- Vendor-maintained quality (Remotion project)

**Issues:**
- (Low) SKILL.md is just an index. No quick-start guidance for someone who doesn't know Remotion patterns. A 5-line "start here" section would help.
- (Info) This is a domain-specific vendor skill. Relevance depends on whether you're actively using Remotion.

---

### rp-investigate-cli, rp-oracle-export-cli, rp-review-cli, rp-refactor-cli (Codex only) -- Grade: B

**Strengths:**
- Consistent structure across all four skills (workspace verification, builder usage, anti-patterns)
- Timeout warnings for long-running commands
- Mandatory `builder` usage prevents shallow analysis
- Anti-patterns section catches common mistakes

**Issues:**
- (Medium) Heavy boilerplate duplication. All four skills repeat the same rp-cli quick reference table, workspace verification section, and CLI routing warnings verbatim (~40 lines each). This should be extracted to a shared reference.
- (Medium) `repoprompt_managed: true` means you don't control updates. Version drift could introduce breaking changes without notice.
- (Low) 45-minute timeout recommendation is extreme. If an agent blocks for 45 min on a single command, something is wrong.

---

## Summary Statistics

| Grade | Count | Skills |
|-------|-------|--------|
| A | 8 | agent-browser, audit-loop, fix-ci, ios-dev, ios-release, plan-loop, review-loop, simplify |
| B+ | 4 | new-task, oracle, orchestrator, self-test, remotion-best-practices |
| B | 3 | mcporter, slack, rp-* (grouped) |
| C or below | 0 | -- |

**Overall quality: Strong.** The core workflow skills (plan-loop, review-loop, audit-loop, fix-ci) are well-designed and consistent. The cross-model review protocol is a differentiator.

---

## Top Findings by Priority

### Must-Fix (P0)

1. **`simplify` not synced to Claude.** The `orchestrator` skill calls it in Phase 4. Claude agents will hit a dead end. Either add `simplify` to Claude's managed skills list and re-sync, or update orchestrator to handle the missing skill gracefully.

### Should-Fix (P1)

2. **Hardcoded refs in `slack` skill.** Replace specific `@eN` references with guidance to discover refs via snapshot. The current approach trains agents to use stale refs.

3. **`self-test` needs concrete verification patterns.** The philosophy is good but the skill is too abstract to be consistently useful. Add 3-5 verification strategy examples by task type.

4. **rp-* skills: extract shared boilerplate.** 160+ lines of duplicated content across four skills. A shared `rp-cli-reference.md` would reduce maintenance burden and context waste.

### Nice-to-Have (P2)

5. **`review-protocol.md` stored in three places.** Symlink or single-source it.

6. **`oracle` model reference will rot.** Parameterize "GPT-5.2 Pro" or note it as a default that changes.

7. **`agent-browser` description is too long.** Trim the frontmatter description to 1-2 sentences and let the body speak.

8. **`new-task` needs an escape hatch** for when the user disengages before 95% confidence.

9. **`slack` recommends `sleep 1`** -- should use `agent-browser wait` instead for consistency.

---

## Architecture Observations

**What's working well:**
- The skill composition pattern (orchestrator -> new-task -> plan-loop -> review-loop) is clean and each skill has a clear single responsibility.
- The dual-model review protocol (coverage invariant, round sizing, confidence gates) is sophisticated and well-documented.
- The agent-guards sync mechanism keeps shared skills consistent across Claude and Codex (when it works -- see simplify gap).
- Lazy reference loading (ios-release, agent-browser) keeps context lean while still having depth available.

**Structural risks:**
- The sync mechanism is file-list based (`.agent-guards-managed-skills`). There's no checksum or version validation -- if a file is modified in the destination but not the source, the drift is silent.
- Vendor skills (agent-browser, slack, remotion, rp-*) are outside your control. No pinning mechanism means updates could break workflows.
- The review-protocol.md is the linchpin of three skills. A bug in that file breaks plan-loop, review-loop, and audit-loop simultaneously.
