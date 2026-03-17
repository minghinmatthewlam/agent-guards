# Skills Audit Scorecard

**Date:** 2026-03-17
**Scope:** All skills in `~/.claude/skills/` (13) and `~/.agents/skills/` (19). Source of truth: `~/dev/agent-guards/skills/`.

---

## TL;DR

Your skills are significantly above average for a first setup. The core workflow skills (orchestrator, plan-loop, review-loop, audit-loop, new-task, simplify, self-test) form a cohesive system with clear handoffs between them. The tool-specific skills (ios-dev, ios-release, fix-ci, agent-browser, mcporter, oracle, slack) are practical and well-scoped. A few areas to tighten up, but nothing broken.

**Overall grade: B+**

---

## Inventory

### Shared (in both Claude Code + Codex via sync)

| # | Skill | Category | Available In |
|---|-------|----------|-------------|
| 1 | agent-browser | Tool wrapper | Claude, Codex |
| 2 | audit-loop | Workflow | Claude, Codex |
| 3 | fix-ci | Workflow | Claude, Codex |
| 4 | ios-dev | Tool wrapper | Claude, Codex |
| 5 | ios-release | Tool wrapper | Claude, Codex |
| 6 | mcporter | Tool wrapper | Claude, Codex |
| 7 | new-task | Workflow | Claude, Codex |
| 8 | oracle | Tool wrapper | Claude, Codex |
| 9 | orchestrator | Meta/workflow | Claude, Codex |
| 10 | plan-loop | Workflow | Claude, Codex |
| 11 | review-loop | Workflow | Claude, Codex |
| 12 | self-test | Behavioral | Claude, Codex |
| 13 | slack | Tool wrapper | Claude, Codex |

### Codex-only

| # | Skill | Category | Notes |
|---|-------|----------|-------|
| 14 | remotion-best-practices | Domain knowledge | Third-party (Remotion project) |
| 15 | rp-investigate-cli | Tool wrapper | RepoPrompt CLI |
| 16 | rp-oracle-export-cli | Tool wrapper | RepoPrompt CLI |
| 17 | rp-refactor-cli | Tool wrapper | RepoPrompt CLI |
| 18 | rp-review-cli | Tool wrapper | RepoPrompt CLI |
| 19 | simplify | Workflow | Source is in agent-guards, synced to Codex but not to Claude* |

*`simplify` is in `~/.agents/skills/` and has source in `~/dev/agent-guards/skills/simplify/` but is missing from `~/.claude/skills/`. Likely a sync issue.

---

## Scoring Criteria

Each skill scored 0-3 on five dimensions:

| Dimension | What it measures |
|-----------|-----------------|
| **Clarity** | Can the agent understand what to do without ambiguity? |
| **Scoping** | Is the skill focused on one job? Does it say when NOT to use it? |
| **Safety** | Does it have guardrails for destructive actions? |
| **Actionability** | Are the instructions concrete enough to execute (commands, examples, steps)? |
| **Composability** | Does it play well with other skills? Clear entry/exit points? |

Scale: 0 = missing/broken, 1 = needs work, 2 = solid, 3 = excellent

---

## Individual Scorecards

### 1. orchestrator
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Clear phase-by-phase flow |
| Scoping | 3 | Explicitly says "skip for simple tasks" |
| Safety | 2 | Inherits from AGENTS.md but no skill-level guardrails |
| Actionability | 2 | Delegates to sub-skills well, but Phase 3 (TeamCreate) assumes tool availability |
| Composability | 3 | Hub skill -- cleanly chains new-task -> plan-loop -> implement -> simplify -> review-loop |
| **Total** | **13/15** | |

**Verdict:** Strong. This is a well-designed orchestration layer. The "skip for simple tasks" guidance prevents over-engineering.

---

### 2. plan-loop
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Explicit steps with round-sizing guidance |
| Scoping | 3 | Clear "use X instead" redirects to audit-loop and review-loop |
| Safety | 2 | Prerequisites reference AGENTS.md, but no plan-specific guardrails |
| Actionability | 3 | Confidence thresholds, round sizing, execution rules all concrete |
| Composability | 3 | Clean handoff to review-loop after execution |
| **Total** | **14/15** | |

**Verdict:** One of your strongest skills. The confidence gates and round-sizing rules give the agent clear decision points.

---

### 3. review-loop
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Mirrors plan-loop structure -- consistent |
| Scoping | 3 | Clear "use X instead" redirects |
| Safety | 2 | Auto-commit at >=85 confidence could be risky for some repos |
| Actionability | 3 | Round sizing, confidence thresholds, escalation rules |
| Composability | 3 | Natural endpoint of plan-loop and orchestrator flows |
| **Total** | **14/15** | |

**Verdict:** Strong. Consider adding a "never auto-push to main/master" guardrail since it auto-commits at >=85.

---

### 4. audit-loop
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Simple and clear |
| Scoping | 3 | Explicit read-only constraint, redirects to other skills |
| Safety | 3 | Read-only by design -- safest skill in the set |
| Actionability | 2 | Less concrete than plan-loop/review-loop (no output format specified) |
| Composability | 2 | Standalone -- doesn't chain to other skills |
| **Total** | **13/15** | |

**Verdict:** Solid. Could benefit from a suggested output format (findings template).

---

### 5. new-task
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Simple loop with clear exit condition |
| Scoping | 2 | Focused, but 95% confidence threshold is high -- may cause excessive back-and-forth |
| Safety | 3 | Read-only clarification, no risk |
| Actionability | 3 | Concrete question strategy and confidence tracking |
| Composability | 3 | Clean handoff to plan-loop |
| **Total** | **14/15** | |

**Verdict:** Clean design. The 95% threshold works because this is a pre-planning step where ambiguity is expensive.

---

### 6. simplify
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Three parallel agents with distinct, well-defined focus areas |
| Scoping | 2 | `agent-only: true` is good but skill doesn't explain what that means |
| Safety | 2 | Fixes issues directly without approval gate |
| Actionability | 3 | Very specific checklists for each review agent |
| Composability | 3 | Designed to slot between implementation and review-loop |
| **Total** | **13/15** | |

**Verdict:** Well-designed. The three-agent parallel pattern is efficient. Note: missing from `~/.claude/skills/` (sync gap).

---

### 7. self-test
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Crystal clear mandate: "you own verification" |
| Scoping | 3 | Behavioral skill -- applies as an overlay, not a workflow |
| Safety | 2 | Could conflict with self-test in CI environments if agent runs destructive tests |
| Actionability | 3 | Concrete rules: show commands + output, never tell user to test |
| Composability | 3 | Works as a modifier on any other skill |
| **Total** | **14/15** | |

**Verdict:** Excellent behavioral skill. Short, actionable, hard to misinterpret.

---

### 8. fix-ci
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Step-by-step with clear decision points |
| Scoping | 3 | Well-defined: CI failures + PR review comments |
| Safety | 2 | Max 3 iterations is good, but auto-pushes fixes without approval |
| Actionability | 3 | Bundled Python script, fallback commands, triage tiers for comments |
| Composability | 2 | Standalone -- could integrate with review-loop but doesn't |
| **Total** | **13/15** | |

**Verdict:** Very practical. The bundled inspection script and comment triage tiers are strong. Consider asking before pushing fixes (especially to shared branches).

---

### 9. ios-dev
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Well-structured numbered sections |
| Scoping | 3 | Clearly day-to-day iOS dev, not release |
| Safety | 3 | Explicit "ask before destructive cleanup" guardrail |
| Actionability | 3 | Full command reference for every workflow |
| Composability | 2 | Standalone, but naturally pairs with ios-release |
| **Total** | **14/15** | |

**Verdict:** Excellent tool-wrapper skill. Output contract (section 6) is a nice touch.

---

### 10. ios-release
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Phase A/B split is immediately clear |
| Scoping | 3 | Both TestFlight and App Store in one skill with clear routing |
| Safety | 3 | Explicit approval gate between read-only preflight and mutating execution |
| Actionability | 3 | Full command templates, reference map for deeper dives |
| Composability | 2 | Standalone with lazy-loaded references |
| **Total** | **14/15** | |

**Verdict:** Excellent. The Phase A/B safety gate is the gold standard for skills that can mutate external state.

---

### 11. agent-browser
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Comprehensive with clear patterns |
| Scoping | 2 | Very large (~630 lines) -- covers everything from basic nav to iOS simulator |
| Safety | 2 | Security section exists but is all opt-in; no default guardrails |
| Actionability | 3 | Extensive examples, common patterns, debugging section |
| Composability | 2 | Used by slack skill; could be referenced by more skills |
| **Total** | **12/15** | |

**Verdict:** Thorough but long. Consider splitting iOS simulator and advanced features into references/ to keep the main SKILL.md under ~200 lines. The core workflow section at the top is exactly right.

---

### 12. mcporter
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Quick start is immediately useful |
| Scoping | 3 | Clear "when to use mcporter vs direct MCP" decision guide |
| Safety | 2 | "Report and continue with fallback" is good; no data safety guidance |
| Actionability | 3 | Three commands to know, one non-obvious workflow documented |
| Composability | 3 | Utility skill, works anywhere |
| **Total** | **14/15** | |

**Verdict:** Model skill for tool wrappers. Short, clear, opinionated about when to use it vs alternatives.

---

### 13. oracle
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 3 | Well-organized with golden path |
| Scoping | 2 | Covers API, browser, and manual modes -- could be tighter |
| Safety | 3 | Explicit consent for API runs, secret-handling guidance, budget controls |
| Actionability | 3 | Command templates, prompt template, session management |
| Composability | 2 | Referenced by review protocol but not directly composed with other skills |
| **Total** | **13/15** | |

**Verdict:** Solid. The prompt template section is valuable -- it prevents the common mistake of sending Oracle a context-free question.

---

### 14. slack
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 2 | Clear structure but relies on hard-coded ref numbers (@e14, @e21) that will drift |
| Scoping | 3 | Well-defined browser-based Slack automation |
| Safety | 1 | No guardrails on sending messages or performing actions in Slack |
| Actionability | 2 | Good examples but ref-dependent patterns are fragile |
| Composability | 2 | Depends on agent-browser skill |
| **Total** | **10/15** | |

**Verdict:** Weakest of your custom skills. The hard-coded refs (@e14 for Activity, @e21 for More unreads) will break as Slack updates. Replace with semantic locators or "find the element labeled X" patterns. Add a safety guardrail for message-sending actions.

---

### 15. remotion-best-practices (Codex-only)
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 2 | Index file pointing to 30+ rule files -- agent must load each one |
| Scoping | 3 | Clear domain: Remotion video creation only |
| Safety | 3 | Read-only knowledge, no risk |
| Actionability | 2 | Depends on rule files being well-written (not audited individually) |
| Composability | 2 | Standalone reference |
| **Total** | **12/15** | |

**Verdict:** Third-party skill, well-scoped. The 30+ rule files may cause agents to over-read. Consider adding a "start here" section with the 5 most common rules.

---

### 16-19. rp-* skills (Codex-only, RepoPrompt)
| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 2 | Very verbose -- each is 100-200 lines of protocol |
| Scoping | 3 | Each has a clear single purpose (investigate, export, refactor, review) |
| Safety | 2 | Workspace verification is good; destructive ops not gated |
| Actionability | 3 | Detailed step-by-step with CLI command reference |
| Composability | 1 | Self-contained, don't interact with your other skills at all |
| **Total** | **11/15** | |

**Verdict:** These are auto-generated by RepoPrompt (`repoprompt_managed: true`). They work but are verbose and don't integrate with your workflow skills. That's fine -- they're a separate tool ecosystem.

---

## Summary Table

| Skill | Clarity | Scoping | Safety | Actionability | Composability | Total |
|-------|---------|---------|--------|---------------|---------------|-------|
| orchestrator | 3 | 3 | 2 | 2 | 3 | **13** |
| plan-loop | 3 | 3 | 2 | 3 | 3 | **14** |
| review-loop | 3 | 3 | 2 | 3 | 3 | **14** |
| audit-loop | 3 | 3 | 3 | 2 | 2 | **13** |
| new-task | 3 | 2 | 3 | 3 | 3 | **14** |
| simplify | 3 | 2 | 2 | 3 | 3 | **13** |
| self-test | 3 | 3 | 2 | 3 | 3 | **14** |
| fix-ci | 3 | 3 | 2 | 3 | 2 | **13** |
| ios-dev | 3 | 3 | 3 | 3 | 2 | **14** |
| ios-release | 3 | 3 | 3 | 3 | 2 | **14** |
| agent-browser | 3 | 2 | 2 | 3 | 2 | **12** |
| mcporter | 3 | 3 | 2 | 3 | 3 | **14** |
| oracle | 3 | 2 | 3 | 3 | 2 | **13** |
| slack | 2 | 3 | 1 | 2 | 2 | **10** |
| remotion-best-practices | 2 | 3 | 3 | 2 | 2 | **12** |
| rp-investigate-cli | 2 | 3 | 2 | 3 | 1 | **11** |
| rp-oracle-export-cli | 2 | 3 | 2 | 3 | 1 | **11** |
| rp-refactor-cli | 2 | 3 | 2 | 3 | 1 | **11** |
| rp-review-cli | 2 | 3 | 2 | 3 | 1 | **11** |

**Average: 12.7/15 (85%)**

---

## Top Findings

### What's working well

1. **Cohesive workflow chain.** orchestrator -> new-task -> plan-loop -> simplify -> review-loop is a complete development lifecycle. Each skill knows where it fits and when to hand off.

2. **Confidence-gated decisions.** plan-loop, review-loop, audit-loop, and new-task all use numeric confidence thresholds with clear action rules. This prevents agents from shipping uncertain work.

3. **Tool wrappers are practical.** ios-dev, ios-release, mcporter, and oracle give agents exactly the commands they need without burying them in documentation. The ios-release Phase A/B gate is particularly well done.

4. **"When not to use" guidance.** Multiple skills redirect to better alternatives (e.g., plan-loop says "read-only analysis -> use audit-loop"). This prevents skill misuse.

5. **self-test as a behavioral overlay.** Short, clear, composable with anything. Every skill set should have something like this.

### What to improve

1. **[P1] Sync gap: simplify missing from Claude Code.** `simplify` exists in `~/dev/agent-guards/skills/simplify/` and `~/.agents/skills/simplify/` but not `~/.claude/skills/`. Run `~/dev/agent-guards/scripts/sync.sh` to fix.

2. **[P1] slack skill uses hard-coded refs.** `@e14`, `@e21`, etc. will break when Slack updates its UI. Replace with semantic locators (`agent-browser find text "Activity" click`) or pattern descriptions ("look for the Activity tab").

3. **[P2] agent-browser is too long (~630 lines).** Move iOS simulator, advanced auth patterns, and deep-dive sections into `references/` files. Keep SKILL.md to core workflow + essential commands (~200 lines).

4. **[P2] No message-sending guardrail in slack.** The skill can send Slack messages without any approval gate. Add a "confirm before sending" rule similar to ios-release's Phase B.

5. **[P3] review-loop auto-commits without push protection.** At >=85 confidence it says "auto commit, push, and create PR." Consider adding a "never force-push" or "never push to main directly" guardrail.

6. **[P3] rp-* skills are verbose and isolated.** These are managed by RepoPrompt so you can't easily trim them, but be aware they add ~800 lines of context when loaded. Not a problem unless token budget is tight.

---

## Recommendations (prioritized)

| Priority | Action | Effort |
|----------|--------|--------|
| P1 | Run `sync.sh` to fix simplify not appearing in Claude Code | 1 min |
| P1 | Rewrite slack skill to use semantic locators instead of hard-coded refs | 30 min |
| P2 | Split agent-browser into core SKILL.md + references/ | 20 min |
| P2 | Add send-message approval gate to slack skill | 10 min |
| P3 | Add "no force-push, no push to main" to review-loop guardrails | 5 min |
| P3 | Add output format template to audit-loop | 10 min |
