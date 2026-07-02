---
name: explain-diff
description: "Create a rich self-contained HTML explanation of a code change, diff, branch, commit, PR, or worker implementation. Use when the user asks to explain code changes, wants to understand what an agent changed, needs a reviewable handoff artifact, or when an orchestrator/worker is asked to invoke /explain-diff for a substantial change."
---

# Explain Diff

Create a rich, readable HTML explanation of the specified code change.

This skill is for human understanding, not verification. Do not replace tests, screenshots, videos, logs, or other proof artifacts. If proof artifacts exist, link to them from the explanation.

## Output

Write one self-contained `.html` file with embedded CSS and any small JavaScript needed for navigation or lightweight interactions.

Use a global path outside the repo so the artifact does not enter version control. The filename must start with today's date in `YYYY-MM-DD-` format so explanations sort by time.

Example:

```text
/tmp/2026-07-02-explanation-<slug>.html
```

Return the absolute file path when done.

## Required Sections

Use one long page with section headers and a table of contents. Do not use tabs for the top-level structure.

Include:

- **Background:** Explain the existing system needed to understand the change. Explore surrounding code, not just the raw diff. Start broad enough for a reader who is new to the subsystem, then narrow to the specific concepts affected by the change.
- **Intuition:** Explain the core idea behind the change. Use concrete examples and toy data where helpful. Focus on the essence before the details.
- **Code:** Walk through the code at a high level. Group changes by concept or behavior, not by raw file order, unless file order is genuinely clearer.
- **Behavior And Proof:** Explain what should behave differently now. Link or cite tests, commands, screenshots, videos, traces, logs, or other proof artifacts when available. Clearly state anything not verified.
- **Risks And Follow-Ups:** Call out important edge cases, residual risk, migration concerns, product decisions, or follow-up work.

## Style

Write with clear narrative flow. The explanation should teach the change, not dump a diff summary.

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

## Diagrams

Prefer a small number of reusable diagram families throughout the page.

Useful diagram types:

- a simplified UI representation for UI changes,
- a system/data-flow diagram showing components and example data,
- a before/after state diagram,
- a sequence of user action -> system response -> persisted state.

Use normal HTML and CSS for diagrams. Do not use ASCII art.

## Code Blocks

Use `<pre>` tags for code blocks.

If you use custom wrappers for code, ensure the CSS preserves line breaks with `white-space: pre` or `white-space: pre-wrap`. Before saving, scan code-block CSS and confirm whitespace preservation is present.

## Closeout

Before reporting completion:

1. Confirm the HTML file exists outside the repo.
2. Confirm it has a date-prefixed filename.
3. Confirm it includes the required sections.
4. Confirm code blocks preserve whitespace.
5. Return the absolute HTML path and mention any residual uncertainty.
