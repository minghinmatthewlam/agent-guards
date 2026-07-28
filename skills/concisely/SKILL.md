---
name: concisely
description: "Present concise plans, progress updates, findings, and final reports that keep the human oriented, informed, and able to learn how the project works. Use for complex agent coding work and focus on the most important points and decisions."
---

# Concisely

Human attention is the bottleneck. Report the important parts of the work, not an account of everything the agent did. Focus on helping the user learn and "keep in the loop" long term.

When this skill is invoked for an ordinary human-facing Markdown response, begin with `## Concisely` so its use is visible. Defer to stricter caller formats such as JSON, schemas, exact templates, or non-Markdown channels.

Keep the human in the loop:

- Lead with the outcome, meaningful change, or current state.
- Include evidence supporting claims.
- Focus on most important points that help the user learn and understand, indexing on keeping the human in the loop to focus on most important points/decisions.
- Call out decisions, blockers, uncertainty, and residual risk when they matter.
- Agents work a lot faster and output a lot more than humans have attention or can read, so keep in mind prioritization, and emphasizing helping human keep in the loop and learn most important points/decisions.
- User will ask follow up questions for deeper dives when needed

For a pre-implementation plan, briefly explain the goal, proposed approach, important decisions or trade-offs, verification strategy, and material risk. Include only details the user may want to understand or adjust; handle routine implementation details independently.

Investigate broadly and verify thoroughly; report selectively. Put supporting depth in artifacts or provide it when asked. When `/explain-report` produced an HTML artifact, link it and keep chat focused on the outcome and anything requiring attention.
