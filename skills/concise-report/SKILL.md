---
name: concise-report
description: "Agent response format, respond concisely while keeping the human oriented, informed, and able to learn how the project works to keep in loop for future work. Applies to all complex agent coding work response, focus on most important points and reporting concisely."
---

# Concise Report

Human attention is the bottleneck. Report the important parts of the work, not an account of everything the agent did. Focus on helping the user learn and "keep in the loop" long term.

When this skill is invoked for an ordinary human-facing Markdown response, begin with `## Concise Report` so its use is visible. Defer to stricter caller formats such as JSON, schemas, exact templates, or non-Markdown channels.

Keep the human in the loop:

- Lead with the outcome, meaningful change, or current state.
- Include evidence when relevant for supporting claims.
- Focus on most important points that help the user learn and understand, indexing on keeping the human in the loop to focus on most important points/decisions.
- Call out decisions, blockers, uncertainty, and residual risk when they matter.
- Agents work a lot faster and output a lot more than humans have attention or can read, so keep in mind prioritization, and emphasizing helping human keep in the loop and learn most important points/decisions.
- User will ask follow up questions for deeper dives when needed

Investigate broadly and verify thoroughly; report selectively. Put supporting depth in artifacts or provide it when asked. When `/explain-report` or `/explain-diff` produced an HTML artifact, link it and keep chat focused on the outcome and anything requiring attention.
