# Skills Audit Scorecard

**Date:** 2026-03-17
**Scope:** All skills in `~/.claude/skills/` (13 skills) and `~/.agents/skills/` (19 skills, with overlap)

---

## Overall Assessment

**Rating: 7.5/10 — Strong foundation with clear areas to tighten up.**

The skills collection is well-structured and covers a real workflow: clarify requirements, plan with dual-model review, implement with teams, simplify, review, fix CI, and ship. The loop-based skills (plan-loop, review-loop, audit-loop) form a coherent system with shared review protocol. The tool-wrapping skills (agent-browser, ios-dev, ios-release, fix-ci) are practical and well-documented. There are some structural issues and a few skills that feel like filler or overlap.

---

## Skill-by-Skill Ratings

### Tier 1: Strong — Ship-worthy (8-9/10)

| Skill | Rating | Notes |
|-------|--------|-------|
| **fix-ci** | 9/10 | Best skill in the collection. Concrete loop with clear steps, fallbacks, max iterations, bundled Python script for robustness, good error handling guidance. The review comment triage (fix/consider/skip) is a smart addition. |
| **plan-loop** | 8.5/10 | Clean dual-model hardening loop. Round sizing guidance is specific (R1: 2-4 native + 1 cross, R2+: 1+1). Confidence gates are well-calibrated. The transition from planning to execution with plan file updates is practical. |
| **review-loop** | 8.5/10 | Mirror of plan-loop for post-implementation. Scales R1 reviewers to risk surfaces (3-6 native). Auto-commit at >=85 confidence is a good forcing function. |
| **agent-browser** | 8/10 | Extremely thorough reference material. Covers the full lifecycle: navigation, interaction, auth, sessions, security, diffing, iOS simulator. The `allowed-tools` restriction is a nice security touch. Could be shorter — the skill is ~630 lines which risks context flooding. |
| **simplify** | 8/10 | Smart three-agent parallel review structure (reuse, quality, efficiency). The efficiency checklist is particularly good — TOCTOU, N+1, no-op updates, hot-path bloat. `agent-only: true` is a good design choice for keeping this out of user-facing invocations. |

### Tier 2: Solid — Useful with minor issues (6-7/10)

| Skill | Rating | Notes |
|-------|--------|-------|
| **audit-loop** | 7.5/10 | Clean and focused. The evidence-citation requirement ("every meaningful claim must cite specific files") is good discipline. Slightly thin — could benefit from an output format template like review-loop has via the review protocol. |
| **ios-dev** | 7.5/10 | Good CLI reference for xcodebuildmcp. The output contract (exit code, error class, key log lines, fix, verification) is excellent. Missing: no guidance on when to use this vs ios-release, and the "Guardrails" section mostly repeats CLAUDE.md rules. |
| **ios-release** | 7.5/10 | Solid two-phase (preflight/execute) gate. The release checklist output format is concrete. Reference map is well-organized. The explicit "never submit without approval" guardrail is critical and correctly placed. |
| **self-test** | 7/10 | Good philosophy, light on mechanics. The principle "if you can't prove it works, it's not done" is the right framing. But it gives no concrete patterns for how to verify (run tests, curl endpoints, check logs, etc.). Relies heavily on the agent figuring it out, which sometimes works and sometimes doesn't. |
| **new-task** | 7/10 | Useful clarification loop. The 95% confidence threshold before planning is a high bar (plan-loop uses 85% to proceed). The question strategy guidance (broad to narrow) is sensible. Auto-invoking plan-loop on completion is good flow. |
| **slack** | 6.5/10 | Decent browser-automation wrapper for Slack. The sidebar structure documentation is helpful. However, hardcoded ref examples (`@e12`, `@e14`, `@e21`) are misleading — refs change every session. The "Example: Full Unread Check" script will not work as written because refs are session-specific. |
| **oracle** | 6.5/10 | Good wrapper for @steipete/oracle CLI. Token budget guidance (196k target) is practical. Session management (reattach vs re-run) is important. But the GPT-5.2 Pro references will date quickly, and the skill assumes a specific third-party tool that may break between versions. |

### Tier 3: Needs Work (5-6/10)

| Skill | Rating | Notes |
|-------|--------|-------|
| **orchestrator** | 6/10 | The right idea (end-to-end flow controller) but too thin. Each phase is just "invoke X skill" with no guidance on transitions, error handling, or what to do when a sub-skill fails. The Phase 3 TeamCreate guidance is the only unique content. Could be merged into CLAUDE.md as a workflow pattern rather than a standalone skill. |
| **mcporter** | 5.5/10 | Very thin. The chrome-devtools example is useful but niche. The "when to use mcporter vs direct MCP" section is the most valuable part and could be a one-liner in CLAUDE.md. Doesn't justify being a skill — more of a tool tip. |
| **remotion-best-practices** | 5/10 | This is a third-party skill (Remotion's official one). It's fine as reference material but doesn't follow the same structure as your other skills — no workflow, no loop, just a table of contents pointing to rule files. Only useful if you're actively building Remotion projects. |

### Tier 3b: RepoPrompt CLI Skills (Codex-only)

| Skill | Rating | Notes |
|-------|--------|-------|
| **rp-investigate-cli** | 6/10 | Heavily prescriptive workflow around rp-cli's `builder` tool. The anti-patterns section is good but the skill is very coupled to RepoPrompt internals (window IDs, tab IDs, stateless CLI). If rp-cli changes, these skills break silently. |
| **rp-review-cli** | 6/10 | Same structure as rp-investigate with a review focus. The mandatory scope confirmation (Step 2) is a good pattern. Shares ~60% boilerplate with the other rp-* skills. |
| **rp-refactor-cli** | 5.5/10 | Same template as above. The two-builder-call pattern (analyze then implement) is the unique value. Heavy boilerplate overlap with rp-investigate and rp-review. |
| **rp-oracle-export-cli** | 5/10 | Thinnest of the rp-* skills. Could be a section in rp-investigate rather than a standalone skill. |

---

## Structural Findings

### What works well

1. **Shared review protocol.** The `references/review-protocol.md` shared across plan-loop, review-loop, and audit-loop is the right pattern — single source of truth for cross-model review mechanics. The output format (Verdict + Findings with severity + Open Questions) is clean.

2. **Confidence-gated transitions.** The consistent use of numeric confidence thresholds (85% to ship, 95% to start planning, 70% needs another round) gives agents concrete decision criteria instead of vibes.

3. **Dual-model review.** Having both Claude and Codex review each other's work is a genuinely novel pattern. The cross-model cap (1 per round, because they serialize) shows you've hit real constraints and documented them.

4. **Agent-guards sync system.** Source of truth in `~/dev/agent-guards/skills/`, synced to both `~/.claude/skills/` and `~/.agents/skills/` via `sync.sh`. The `.agent-guards-managed-skills` manifest prevents accidental edits to synced copies. This is clean infrastructure.

5. **Tool restrictions.** `agent-browser` and `slack` use `allowed-tools` to restrict which bash commands can run. Good security hygiene.

### What needs attention

1. **Boilerplate duplication across rp-* skills.** The four RepoPrompt CLI skills share ~60% identical content (CLI reference table, workspace verification, window routing warnings, timeout warnings). Extract the shared parts into a `references/rp-cli-basics.md` and have each skill reference it — same pattern you already use for review-protocol.md.

2. **Slack skill has misleading hardcoded refs.** The example scripts use `@e12`, `@e14`, `@e21` etc. as if they're stable. They're not — they change every session. Either remove the specific ref numbers or add a prominent warning that refs are illustrative only.

3. **agent-browser is too long (~630 lines).** This risks context window waste when the skill is loaded for simple tasks. Consider splitting into a compact SKILL.md (core workflow + essential commands, ~150 lines) and moving the rest into reference files (you already have the references/ directory structure for this).

4. **mcporter and orchestrator are too thin to justify being skills.** mcporter is essentially a tool tip. Orchestrator is a routing table that invokes other skills. Consider:
   - mcporter: merge into CLAUDE.md as a "Tools" section note
   - orchestrator: keep as a skill but add real transition logic, error handling, and recovery patterns

5. **No skill for common non-coding tasks.** You have skills for CI, iOS, browser automation, planning, and review — but nothing for quick tasks like "write a tweet", "draft an email", or "triage GitHub issues" which are things you mention in your CLAUDE.md goals. Not a deficiency per se, but a gap given your stated goals.

6. **Inconsistent `$ARGUMENTS` handling.** Some skills say "Consider `$ARGUMENTS` if provided" (self-test, orchestrator, new-task). Others use "$ARGUMENTS" directly in their protocol (rp-* skills: "Investigate: $ARGUMENTS"). Others don't mention arguments at all (fix-ci handles this via its own parsing). Pick one pattern.

7. **remotion-best-practices doesn't belong in agent-guards sync.** It's a third-party skill that isn't in your `.agent-guards-managed-skills` manifest and only exists in the Codex directory. If you're not actively using Remotion, remove it. If you are, it's fine but should stay outside the sync system.

---

## Priority Recommendations

### P0 — Fix now (incorrect behavior risk)

- **Slack hardcoded refs**: Users (or agents) will try to use `@e14` from the examples and get confused when it doesn't match their session. Add a warning or remove specific ref numbers.

### P1 — Fix soon (quality/maintenance)

- **Deduplicate rp-* boilerplate**: Extract shared CLI reference into a single reference file. Currently maintaining 4 copies of the same content.
- **Split agent-browser SKILL.md**: Move detailed reference content to reference files. The SKILL.md should be the quick-start, not the encyclopedia.

### P2 — Consider (improvements)

- **Beef up orchestrator**: Add transition error handling, sub-skill failure recovery, and state tracking between phases.
- **Beef up self-test**: Add concrete verification patterns (run test suite, curl health endpoint, build and check exit code, etc.).
- **Retire mcporter as a skill**: Move to CLAUDE.md or a reference doc.
- **Standardize $ARGUMENTS handling** across all skills.

### P3 — Nice to have

- Add a lightweight "content" skill for tweet drafting / email composition given your Twitter growth goals.
- Add a "triage" skill for GitHub issue/PR triage if you find yourself doing that often.

---

## Summary Table

| Skill | Rating | Category | Sync'd |
|-------|--------|----------|--------|
| fix-ci | 9/10 | CI/CD | Both |
| plan-loop | 8.5/10 | Workflow | Both |
| review-loop | 8.5/10 | Workflow | Both |
| agent-browser | 8/10 | Tool wrapper | Both |
| simplify | 8/10 | Code quality | Codex only* |
| audit-loop | 7.5/10 | Workflow | Both |
| ios-dev | 7.5/10 | iOS | Both |
| ios-release | 7.5/10 | iOS | Both |
| self-test | 7/10 | Workflow | Both |
| new-task | 7/10 | Workflow | Both |
| slack | 6.5/10 | Tool wrapper | Both |
| oracle | 6.5/10 | Tool wrapper | Both |
| orchestrator | 6/10 | Workflow | Both |
| rp-investigate-cli | 6/10 | RepoPrompt | Codex only |
| rp-review-cli | 6/10 | RepoPrompt | Codex only |
| rp-refactor-cli | 5.5/10 | RepoPrompt | Codex only |
| mcporter | 5.5/10 | Tool wrapper | Both |
| remotion-best-practices | 5/10 | Third-party | Codex only |
| rp-oracle-export-cli | 5/10 | RepoPrompt | Codex only |

*simplify is in agent-guards managed list for Codex but not Claude per the manifest files.

**Overall: 7.5/10** — Good skill system with strong core workflow skills. Main opportunities are reducing duplication, trimming oversized skills, and retiring/merging thin ones.
