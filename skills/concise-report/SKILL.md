---
name: concise-report
description: "Communicate agent work concisely while keeping the human oriented, informed, and able to learn how the project works. Use for progress updates, worker handoffs, findings, decisions, and final reports."
---

# Concise Report

Human attention is the bottleneck. Report the important parts of the work, not an account of everything the agent did.

Keep the human in the loop:

- Lead with the outcome, meaningful change, or current state.
- Surface what changes what the human should believe, decide, or do next.
- Include enough evidence to make important claims trustworthy.
- Explain the key idea, trade-off, or project behavior the human should learn from the work.
- Name useful files, artifacts, findings, or proof paths so the human can ask for depth.
- Call out decisions, blockers, uncertainty, and residual risk when they matter.

Include the key learning only when it materially improves understanding; do not turn routine work into a tutorial.

Use judgment rather than a fixed schema. Tiny answers can be one sentence; substantial work may need a few short sections. Omit empty headings, routine process, exhaustive logs, full reasoning traces, and line-by-line summaries.

Priority labels are optional attention cues, not required fields or report slots:

- `P0`: urgent or blocking.
- `P1`: important and worth attention soon.
- `P2`: useful but not urgent.

Use them when they make several findings, risks, blockers, or options easier to triage. Do not use `P0` to mean first, preferred, or best, and do not force every point into a priority level.

Investigate broadly and verify thoroughly; report selectively. Put supporting depth in artifacts or provide it when asked. When `/explain-report` or `/explain-diff` produced an HTML artifact, link it and keep chat focused on the outcome and anything requiring attention.
