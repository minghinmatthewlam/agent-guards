---
name: explain-report
description: "Create a focused, self-contained HTML report that helps the user understand, retain, and act on important information. Use when the user requests an HTML report or visual explanation; when substantial research, architecture, project knowledge, audits, incidents, comparisons, or accepted findings are important enough to keep the user in the loop and teach them how the project works; or when chat must stay concise while useful supporting depth remains available. Do not trigger for routine status, simple answers, or unverified worker output."
---

# Explain Report

Create one readable HTML artifact that presents important, accepted information with a concise entry point and progressively available depth.

This skill owns presentation and understanding, not investigation quality or verification. Build the report from source-backed or orchestrator-accepted material. Link tests, screenshots, recordings, traces, logs, citations, and source files; never treat the report as proof by itself.

## Decide When To Use It

Use the report when at least one of these is true:

- the user explicitly asks for an HTML report, visual explanation, learning guide, or durable handoff;
- the information is important to understanding the project, its architecture, a major decision, or a significant body of work;
- several sources, components, findings, states, or trade-offs are easier to understand together than as linear chat;
- keeping chat concise would otherwise hide supporting context the user is likely to revisit;
- a visual relationship, comparison, hierarchy, flow, or timeline materially improves understanding.

Skip it for routine progress, transient heartbeat updates, small factual answers, minor changes, or material that has not been verified enough to present as accepted. Importance, not raw task size, is the deciding factor.

## Choose A Mode

Choose the mode without requiring the user to name it:

- **Learning:** concepts, mental model, examples, misconceptions, and how the pieces fit.
- **Research:** synthesized findings, source agreement or conflict, evidence quality, and implications.
- **Decision:** options, trade-offs, recommendation, assumptions, and decision criteria.
- **Audit or incident:** findings, impact, timeline when relevant, evidence, remediation, and residual risk.
- **System or architecture:** components, boundaries, ownership, data or control flow, and operational behavior.
- **Change:** when this skill was invoked directly for a code change, switch to `/explain-diff`. When already following this skill from `/explain-diff`, continue with these shared rules and add its code-change requirements.

Combine modes only when it improves the user's understanding. Do not create separate reports when one coherent report can cover the accepted material.

## Build The Report

Write one self-contained `.html` file with embedded CSS and only small optional JavaScript for navigation or lightweight interaction. The page must remain readable without JavaScript.

Use a durable global path when the user requested the artifact, the orchestrator designated it as the integrated report, or the report is intended as retained project knowledge:

```text
~/.codex/artifacts/reports/YYYY-MM-DD-<slug>.html
```

Use `/tmp/YYYY-MM-DD-<slug>.html` for forward tests, exploratory or worker-local reports, and other disposable artifacts. Create the parent directory when needed. Return the absolute path.

Adapt depth to the subject. Do not force a long report when a compact page is clearer.

## Information Architecture

Start with a concise layer that lets the user understand the outcome without reading the entire page:

1. **At A Glance:** purpose, result, and every item that materially affects what the user should do or believe.
2. **Mental Model Or Key Findings:** the central explanation, organized by concept rather than source order.
3. **Evidence And Confidence:** citations, source or proof links, verified facts, inference, conflicts, and unknowns.
4. **Implications Or Decisions:** actions, trade-offs, or how this changes the user's understanding.
5. **Risks And Open Questions:** residual uncertainty and follow-up work.
6. **Supporting Detail:** useful depth placed later or in semantic `<details>` blocks.

Rename or omit sections when the selected mode makes another structure clearer, but preserve the functions above. Use P0/P1/P2 as priority classes when ranking matters; repeat them as needed and never impose a fixed findings count.

## Visual And Writing Style

Choose the smallest useful visual:

- a flow or sequence for processes and interactions;
- a comparison table for options or repeated fields;
- a timeline for incidents or evolution;
- a hierarchy for ownership or nesting;
- a before/after representation for changed state;
- a simplified system or UI representation when spatial relationships matter.

Use normal semantic HTML and CSS. Avoid ASCII diagrams, decorative dashboards, quizzes, excessive cards, top-level tabs, and visuals that merely repeat prose. Prefer a table of contents for longer pages and `<details>` for optional supporting depth.

Make the artifact:

- responsive on desktop and phone;
- printable with sensible print CSS;
- accessible through semantic headings, readable contrast, and labels for meaningful visuals;
- concise at the top and progressively detailed below;
- explicit about verified, inferred, disputed, and unknown claims;
- free of large copied source dumps when a focused explanation is clearer.

Use `<pre>` for code or literal text. If custom wrappers are used, preserve line breaks with `white-space: pre` or `white-space: pre-wrap`.

## Relationship To Chat

After creating the artifact, defer to `/concise-report` for the chat response and include the HTML path. Do not duplicate the report's supporting depth in chat.

## Closeout

Before reporting completion:

1. Confirm the file exists outside the repository and has a date-prefixed filename.
2. Confirm the opening layer states the purpose, result, and material findings.
3. Confirm factual claims cite evidence or are labeled as inference or unknown.
4. Confirm links and proof paths are represented accurately.
5. Confirm the page is readable without JavaScript and code blocks preserve whitespace.
6. Confirm the report does not conceal material findings merely to stay concise.
7. Return the absolute HTML path and residual uncertainty.
