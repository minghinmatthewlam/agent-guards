---
name: explain-diff
description: "Create a focused self-contained HTML explanation of a code change, diff, branch, commit, PR, or worker implementation. Use when the user asks to understand code changes, needs an important implementation kept visible as a learning or handoff artifact, or when an orchestrator/worker invokes /explain-diff for a substantial change. This is the code-change specialization of /explain-report."
---

# Explain Diff

Read and follow `../explain-report/SKILL.md`, then apply the code-change requirements below using Change mode.

Create a focused, readable HTML explanation of the specified code change. The report should help the user understand the surrounding subsystem and retain the important implementation knowledge, not merely inventory modified files.

This skill is for human understanding, not verification. Do not replace tests, screenshots, videos, logs, or other proof artifacts. If proof artifacts exist, link to them from the explanation.

## Change-Mode Sections

Include:

- **Background:** Explain the existing system needed to understand the change. Explore surrounding code, not just the raw diff. Start broad enough for a reader who is new to the subsystem, then narrow to the specific concepts affected by the change.
- **Intuition:** Explain the core idea behind the change. Use concrete examples and toy data where helpful. Focus on the essence before the details.
- **Code:** Walk through the code at a high level. Group changes by concept or behavior, not by raw file order, unless file order is genuinely clearer.
- **Behavior And Proof:** Explain what should behave differently now. Link or cite tests, commands, screenshots, videos, traces, logs, or other proof artifacts when available. Clearly state anything not verified.
- **Risks And Follow-Ups:** Call out important edge cases, residual risk, migration concerns, product decisions, or follow-up work.

## Change-Mode Style

Write with clear narrative flow. Teach the change and its surrounding subsystem; do not dump a diff summary.

Use:

- callouts for key concepts, definitions, and important edge cases,
- simple HTML diagrams or figures when they make the system easier to understand,
- examples with realistic data or states,
- a responsive layout that is readable on desktop and phone.

Avoid:

- Notion output,
- quizzes,
- ASCII diagrams,
- pretending unverified behavior was tested,
- copying large raw diffs into the page without explanation.

## Change-Mode Diagrams

Prefer a small number of reusable diagram families throughout the page.

Useful diagram types:

- a simplified UI representation for UI changes,
- a system/data-flow diagram showing components and example data,
- a before/after state diagram,
- a sequence of user action -> system response -> persisted state.

Use normal HTML and CSS for diagrams. Do not use ASCII art.

## Closeout

Before reporting completion:

1. Complete the `/explain-report` closeout checks.
2. Confirm the report includes the change-mode sections or clearly justified equivalents.
3. Confirm changed behavior is separated from proof and from unverified expectations.
4. Return the absolute HTML path and mention any residual uncertainty.
