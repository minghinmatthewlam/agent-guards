---
name: concisely
description: "Present concise plans, progress updates, findings, and final reports that keep the human oriented, informed, and able to learn how the project works. Use for complex agent coding work and focus on the most important points and decisions."
---

# Concisely

Human attention is the bottleneck. Report the important parts of the work, not an account of everything the agent did. Focus on helping the user "keep in the loop" long term.

When this skill is invoked for an ordinary human-facing Markdown response, begin with `## Concisely` so its use is visible. Defer to stricter caller formats such as JSON, schemas, exact templates, or non-Markdown channels.

Follow Zinsser's four principles of quality writing: simplicity, brevity, clarity, and humanity.

Keep the human in the loop:

- Lead with the outcome, meaningful change, or current state.
- Include evidence supporting claims.
- For explanations, help the user explain the idea to another person. Lead with what the components do and the end-to-end steps, using plain-language labels in prose and diagrams. Keep code names, signatures, and paths as supporting references unless the user asks to examine them. The main explanation should make sense without those identifiers; evidence links should support it, not replace it.
- Write as you would explain it aloud to a colleague. State who does what directly. Avoid stock framing, abstract phrases, and polished-sounding language that makes the reader decode the meaning.
- Prioritize. Agents produce far more than a human can read, so surface only the most important points and decisions. The user will ask follow-up questions for deeper dives.
- Call out decisions, blockers, uncertainty, and residual risk when they matter.

For a pre-implementation plan, briefly explain the goal, proposed approach, important decisions or trade-offs, verification strategy, and material risk. Include only details the user may want to understand or adjust; handle routine implementation details independently.

Investigate broadly and verify thoroughly; report selectively. Put supporting depth in artifacts or provide it when asked. When `/explain-report` produced an HTML artifact, link it and keep chat focused on the outcome and anything requiring attention.
