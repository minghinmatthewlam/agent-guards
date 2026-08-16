---
name: explain-report
description: "Create a self-contained HTML explanation when the user requests one or when important, durable project knowledge is materially easier to understand visually than in concise chat. Use for significant architecture, research, decisions, incidents, audits, or changes that the user may revisit. Do not use for routine status, simple answers, or unverified findings."
---

# Explain Report

Create a focused HTML artifact that helps the user understand and retain important project knowledge. Default to concise chat when an artifact would not add meaningful value.

## Content

- Lead with the essential mental model, result, or decision.
- Focus on what helps the user understand the project and decide what to do next.
- Support claims with source files, tests, screenshots, logs, citations, or other material evidence.
- Separate verified facts from inference, uncertainty, and open questions.
- Put supporting depth after the main explanation or behind `<details>`.
- Adapt the structure and depth to the subject. Do not force fixed modes, sections, or finding counts.

Use a visual only when it makes an important relationship easier to understand. Choose the simplest useful form, such as a flow, comparison, timeline, hierarchy, or before-and-after view.

## Artifact

Write one self-contained `.html` file with embedded CSS. Keep it readable without JavaScript, responsive, accessible, and concise at the top.

Store retained reports at:

```text
~/.codex/artifacts/reports/YYYY-MM-DD-<slug>.html
```

Use `/tmp` for disposable or exploratory reports. Keep reports outside the repository unless the user asks otherwise.

Before closing, confirm the file exists, opens as HTML, and represents important evidence accurately. Then use `concisely` for the chat response: state the result, link the report, and mention any decision or residual uncertainty without repeating the report.

## Avoid

- Do not use presentation as a substitute for investigation or verification.
- Do not create decorative dashboards or visuals that repeat the prose.
- Do not bury information that changes what the user should believe or do.
