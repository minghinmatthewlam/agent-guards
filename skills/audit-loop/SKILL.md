---
name: audit-loop
description: "Lightweight read-only audit. Use host-appropriate review coverage for evidence and findings. Iterate on disagreement or low confidence. No code changes."
---

# Audit Loop

Read-only audit with review coverage appropriate to the current host. No code changes.

Planning before implementation → use `plan-loop` instead.
Reviewing completed code changes → use `review-loop` instead.

## Prerequisites

Read `~/dev/agent-guards/AGENTS.md` before starting — the safety and workflow conventions that govern all agent work.

## How It Works

1. **Investigate** the question. Collect evidence (files, commands, source material).
2. **Review** your findings per `references/review-protocol.md`. Spin up all review agents in parallel using the host-specific coverage rules. Pre-warm any deferred tools only when the selected host path actually needs them.
3. **Iterate** if reviewers disagree, confidence is low, or key claims lack evidence.
4. **Write a final verdict**: scope reviewed, evidence basis, findings, residual risks, next steps.

Every meaningful claim must cite specific files, commands, or source material.

## Round Sizing

- Claude host:
  - R1: 1 native + 1 Codex cross-model.
  - R2+ only when triggered: confidence below 85, reviewer disagreement, or high-impact finding lacks evidence. Focus on previous round's findings and unresolved gaps — not a fresh re-review.
  - Escalate to 3+1 for high-risk or persistent disagreement.
- Codex host:
  - R1: 1-2 native reviewers only.
  - R2+ only when triggered: confidence below 85, reviewer disagreement, or high-impact finding lacks evidence. Focus on previous round's findings and unresolved gaps — not a fresh re-review.
  - Escalate to 3 native reviewers for high-risk or persistent disagreement.

## Confidence

After each round, assess confidence 0-100 with top unknowns and what evidence is still missing:
- Below 85: consider another round.
- 85+: eligible to close.
