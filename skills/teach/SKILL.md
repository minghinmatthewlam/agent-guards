---
name: teach
description: "Help the user build a working mental model of code, system designs, and proposed changes, including code outside the current repo. Use when asked to teach, explain how a system works, walk through an architecture, compare a design with ours, or understand a change."
---

# Teach

Help the user understand the system well enough to explain it to someone else, reason about changes, and design with it. Focus on behavior, data shapes, and interfaces rather than function internals.

## Get the source

Code is the source of truth. Trace the implementation and call paths before explaining. Do not fill gaps with names, comments, docs, or familiar patterns; say what remains unknown.

The code may not be in a repo you already have, such as an open-source project the user wants to learn from. Clone it under `~/dev/<repo>` so the user can open the same files in their own IDE. Read its docs and spec, but trust the code where they disagree.

For a large subject, split reading across subagents by area and have a second pass check each claim against the cited lines before you teach it.

## Pick the focus

From the user's goal and current understanding, choose the few concepts that matter most and say briefly what you will cover. Go deep on those, including the prerequisites that make them click. Stay with an unresolved concept across follow-ups instead of adding topics.

## Shape each explanation

Teach every concept in this order:

1. **Plain bullets.** What it is and why it exists, in a few short bullets with no code. The explanation must make sense with no identifiers at all.
2. **One concrete example.** A small scenario with real values ("you ask X, the tool runs `npm test`, the process crashes"). When the concept is a data shape, show one filled-in instance of it, not just its type.
3. **Where it lives.** A repo-relative `path:line` the user can open in their IDE.
4. **Shape, only after.** A short type or interface sketch, kept in a collapsible section or offered as a follow-up. Never lead with code.

Name easily confused terms side by side and say how they differ, for example a recipe versus its saved progress versus its status. Give each concept one name and keep it; if two words mean the same thing, say so once and use one.

Ground the mental model in a concrete end-to-end walkthrough. At each step say which component acts, what it calls, and what state changes. Include the failure path that matters most, such as what happens after a crash at that step.

Cover edge cases and trade-offs only when they change the mental model or the user's decisions. Separate existing behavior, proposed changes, inference, and unknowns.

## Follow-ups

Answer follow-ups in a few bullets. When the user says "simplify", "concise", or "I don't get it", drop to three bullets and one example, and change the explanation instead of repeating it with more words. No quizzes or lecture pacing.

## HTML explanations

When a retained explanation helps, use `explain-report`, with these additions:

- Lead every section with the plain bullets, then the example, then `path:line` as plain text. Clickable file links do not open the Claude desktop file pane from an HTML panel, so give paths, not links.
- Make the walkthrough interactive: a stepper where each step shows what changed in each store, with new items highlighted and a toggle for the failure path at the steps where it matters.
- Make enumerations clickable when each item has its own explanation, such as the states of a state machine.
- Keep it readable without JavaScript.

Use `concisely` for chat presentation. Teaching alone does not authorize code changes.
