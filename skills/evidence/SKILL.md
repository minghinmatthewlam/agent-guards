---
name: evidence
description: "Verify the actual material evidence behind a selected assertion, claim, finding, or final result. Use when the user explicitly invokes evidence or asks to substantiate, prove, check, or challenge something an agent reported."
---

# Evidence

Check whether the selected claim is supported by evidence that actually proves it. This is an on-demand verification pass, not a requirement to expand every normal report.

- Restate the claim being checked so the scope is clear.
- Identify what evidence would materially support or refute that claim.
- Inspect the strongest practical source: code for implementation, tests or runtime for behavior, live UI for visible state, authoritative sources for external facts, and concrete artifacts for completed work.
- Lead with the verdict, then cite the exact evidence used: file paths, commands and results, artifacts, URLs, task IDs, timestamps, or observed state.
- Distinguish verified fact from inference. If the available evidence is incomplete, say what remains unproven and what would verify it.
- Stay focused on the selected claim. Do not turn the check into a broad audit unless the evidence exposes a material adjacent issue.

## Gotchas

- Agent reasoning, plans, summaries, and repeated assertions are not independent evidence.
- Source code can prove what is implemented, but not necessarily what ran or what a user saw.
- A passing internal test does not prove a different runtime or user-facing surface.
- Do not overstate certainty when evidence is stale, indirect, mocked, or from the wrong environment.
