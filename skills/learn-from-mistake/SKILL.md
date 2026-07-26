---
name: learn-from-mistake
description: "Diagnose a concrete model mistake and improve the code, tests, instructions, skills, tools, or workflow so the same class of failure is less likely to recur, then retry the original task. Use when the user explicitly invokes /learn-from-mistake or asks the agent to learn from, postmortem, or prevent recurrence of a wrong output, bad implementation, missed requirement, unsupported claim, or workflow failure."
---

# Learn From Mistake

Use the current failure as evidence for improving the system, not merely correcting the immediate output. Preserve the useful failure context, implement the best durable prevention at the correct layer, validate it independently, and then retry the original task.

## Preserve And Diagnose

Contain destructive, security-sensitive, or externally harmful behavior first. Otherwise, preserve the failure before fixing it:

- the original request and success criteria;
- the wrong output, change, claim, or action;
- the instructions, context, source state, and tools available to the agent;
- the test, observation, or user correction that exposed the problem.

Reproduce or inspect the failure when practical. Determine whether it came from missing or stale context, conflicting guidance, unclear ownership, unavailable tools, weak verification, incorrect source assumptions, or poor judgment. Treat the agent's explanation of its own behavior as a hypothesis and verify it against the actual evidence.

## Choose The Best Prevention

Fix the layer that owns the failure:

- code invariant, API boundary, or regression test for machine-checkable behavior;
- verifier or real-surface self-test for proof gaps;
- skill or workflow for a recurring task pattern;
- `AGENTS.md` only for a universal behavior that must always be present;
- task context, tool access, or ownership boundaries when the agent lacked what it needed.

Choose the best durable prevention proportional to recurrence risk and impact. Optimize for recurrence prevention, generalization, enforceability, maintainability, and low false-positive or context cost. Do not limit the solution to the smallest diff or a single change when coordinated changes are materially stronger.

Avoid adding instructions when a deterministic guard is possible. Avoid compatibility layers, broad process, or global rules that do not address the demonstrated cause.

## Implement And Prove

Within the authorized scope:

1. Implement the prevention before retrying the original task.
2. Validate the prevention with the strongest practical evidence.
3. When a fresh-context agent is available and safe, give it the revised setup plus the original task or raw failure artifact without the diagnosis or expected answer. For Codex subagents, use `fork_turns: "none"`.
4. Retry or fix the original task and verify its real affected surface.

Treat invocation as authorization to investigate and propose. Ask before changing global/shared guidance, external state, or anything outside the task's existing write scope.

## Report

Use `concise-report`. State:

- what failed and its verified cause;
- the prevention implemented or proposed and why it is the best fit;
- evidence that the prevention works independently;
- the corrected original result;
- remaining recurrence risk.

## Gotchas

- Do not turn every ordinary code bug into an agent-setup rule.
- Do not accept self-analysis, repeated assertions, or a new prompt as proof.
- Do not leak the intended answer into a fresh-context validation.
- Do not fix the visible symptom while leaving the demonstrated failure path open.
- Do not prefer a minimal change when a stronger proportional prevention is justified.
