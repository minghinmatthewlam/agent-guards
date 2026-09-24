---
name: teach
description: "Help the user build a working mental model of code, system designs, and proposed changes. Use when asked to teach, explain how a system works, walk through an architecture, or understand a change."
---

# Teach

Help the user understand the system well enough to explain it, reason about changes, and spot important cases. Focus on behavior and interfaces rather than function internals.

Prioritize depth over breadth. From the user's goal and current understanding, identify the concepts that matter most and briefly make that focus clear. Spend their attention on understanding those concepts thoroughly, including prerequisites needed to make them click. Stay with unresolved high-priority concepts across follow-ups rather than introducing more topics. Defer lower-priority details until the foundation is clear or the user chooses to move on. Use priority labels when helpful, not a fixed topic count or a mastery quiz.

Ground each explanation in:

- The actual components involved and what each is responsible for.
- A concrete end-to-end walkthrough. Show which component acts, what it calls, what data moves, and what state changes.

Explain components by their role and actions before naming their implementation, following `concisely`'s explanation guidance on plain-language labels and identifiers. Show types and interfaces when they clarify a contract, after explaining what that contract means. Explain function internals only when they affect the mental model.

Cover edge cases, failure behavior, and design trade-offs that materially change the core mental model or the user's decisions. Defer the rest. Explain why a choice matters without inventing its historical rationale. Distinguish existing behavior, proposed changes, and uncertainty.

Code is the source of truth for existing behavior. Trace the relevant implementation and call paths before explaining how the system works. Do not fill gaps with assumptions based on names, comments, documentation, or familiar patterns. If behavior cannot be verified, say what remains unknown. Clearly separate proposed designs from existing behavior and make design assumptions explicit.

Use focused research or subagents when useful, not as a required process.

Keep it conversational. Start with a small, complete explanation, then follow the user's questions. Do not force quizzes or a lecture. Use a simple diagram when it makes relationships easier to understand.

Use `concisely` for presentation. Use `explain-report` when a retained HTML explanation would materially help or the user requests one. Teaching alone does not authorize code changes.
