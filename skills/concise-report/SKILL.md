---
name: concise-report
description: "Produce focused, priority-aware agent updates and final reports. Use when summarizing work, reporting worker results, closing a loop, presenting audit findings, asking for a decision, or returning orchestrator status where the human needs the most important points, evidence, and decisions without exhaustive detail."
---

# Concise Report

Agents can produce more output than the human can read line by line. Help the human stay in the loop by focusing on the most important points, what was proven, what changed, and what needs judgment. Put deeper explanation in artifacts or provide it when asked.

This applies to every reply, not only to reports produced under this skill. The rules here are the reference implementation of the global Output rules; invoking the skill is a way to ask for the shape, not the trigger that makes concision apply.

## The Report Is An Entry Point

The human reads the most important points, then asks follow-up questions to go deeper. The report exists to make those follow-ups possible, not to pre-empt them.

So: say the few things that change what the human does next, and make it obvious what they can drill into. Name the artifact, file, or finding they would ask about, and stop there. Do not include depth in case it is wanted — it costs the human attention on every read, and they will ask when they want it.

A report that answers every possible question has failed, because the human has to find the important part themselves.

Use priority tags when ranking matters:

- `P0`: urgent, blocks correctness, safety, shipping, money, or major product direction.
- `P1`: important and worth acting on soon.
- `P2`: useful but not urgent.

Only include the top few items. Use priorities to communicate importance, not to label every sentence.

When a tool or reviewer emits its own severity scheme, translate it before reporting to the human: `blocker` → P0, `high` → P1, `medium`/`low` → P2. The human reads one vocabulary.

## Default Shape

Use this shape unless the caller requested a different format:

```text
Status: done | running | blocked | needs decision
Result: 1-2 sentences
Evidence: commands, checks, links, artifact paths, or "not verified"
Decision needed: only if needed
Next: one recommended action
Risk: residual risk or "low"
```

Omit empty fields. For tiny answers, use one short paragraph instead.

## Findings Shape

For audits, reviews, or research, lead with the highest-impact items only:

```text
P0: <critical item>
P1: <important item>
P2: <nice-to-have item>
```

Keep each item focused on what matters and the evidence behind it. Do not write a full explanation for every item unless asked.

If there are many possible findings, report the top 3 by default and put the rest in an artifact or say they are available on request.

## Worker And Loop Reports

Workers and loop agents should report:

- final status,
- concrete result,
- evidence or proof artifact paths,
- files changed when relevant,
- blockers or decisions,
- residual risk.

Do not include exhaustive logs, full reasoning traces, broad background, or line-by-line change summaries. Put those in `/explain-diff`, proof artifacts, PR descriptions, or a ledger.

## Detail Policy

Default to the shortest report that keeps the caller informed enough to decide the next action.

Add detail only when:

- the caller asks,
- a risk needs explanation,
- evidence is surprising or conflicts,
- a decision depends on the reasoning,
- the result would otherwise be misleading.
