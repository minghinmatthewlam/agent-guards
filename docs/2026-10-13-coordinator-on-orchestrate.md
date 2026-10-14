# Coordinator on pstack Orchestrate

Status: implemented 2026-10-13 (skill rewritten; ori project switch-over next). Audit behind it: `~/.claude/coordinator/library/2026-10-13-coordinator-skill-audit.md`.

## Goal

The coordinator runs pstack's Orchestrate playbook (`plugins/pstack/skills/poteto-mode/playbooks/orchestrate.md`) as its program. The project-coordinator skill shrinks to what Orchestrate can't know: the T3 Code tools, this human's gates and reporting, and per-project review steps such as perry. Workers stay in single-task poteto-mode playbooks.

Why: we rely on pstack and pick up its upstream changes; we expect many parallel items; and the coordinator skill re-invents Orchestrate's parts more weakly (hand board, no verifier, poll-every-thread).

## Split of ownership

Orchestrate owns:
- the program loop: frame, pilot, scale with a rolling in-flight cap, drain, land, close;
- the store, through `scripts/orch/orch.ts` with `ORCH_STORE=<project home>/orchestrate`: `units.tsv`, `ledger.tsv`, `inbox/`, `gates.md`, `standing` orders, `decisions.tsv`, derived `status.md`;
- the brief template (GOAL, SCOPE, CONTEXT, ACCEPTANCE, VERIFY, TIMEBOX, FORBIDDEN, REPORT, STANDING), sized to the unit;
- verification: a verifier on a different model family from the worker, a ledger verdict per PR plus head SHA, a new SHA voids it;
- liveness, retries, escalation rules.

project-coordinator owns, as an overlay Orchestrate reads first:
- **T3 mapping.**
  - Spawn a worker: `t3_thread_launch` with a worktree strategy.
  - Spawn a verifier: `delegate_task` on the other family, read-only, pointed at the worker's worktree.
  - Resume: `t3_thread_send`, starting with the poteto-mode follow-up line.
  - Inbox producers: the worker's completion message to the coordinator, plus the scheduled check, which turns T3 thread status changes into `orch inbox push`.
  - The scheduled check is the "watcher wake" drain point.
  - PR watching: `watch_pull_request` on the worker's thread.
- **Human layer.**
  - The understanding gate and merge rule: merge needs a ledger verdict for the current head, plus the project's bot review, plus the rule.
  - Quiet hours.
  - Plain reports with priorities.
  - Linear issue before spawn.
  - Peer messages carry no authority.
- **Per-project PR steps** from `project-instructions.md`: perry in #agents-ori, Matthew-merges cases.
- **Worker opening lines:** the poteto-mode line and the T3 environment line.

Dropped from Orchestrate for T3:
- `environment: "cloud"` placement, since all T3 workers are local;
- the `gt` stacker and `frontier.json`, since we don't stack with Graphite;
- sub-coordinators, until in-flight exceeds about 10;
- a dedicated pilot pipeline for cheap units, where the first unit is the pilot.

Dropped from project-coordinator:
- the hand-maintained `board.md`, replaced by orch tables and a derived status;
- the read-every-thread check;
- the "never run Orchestrate" rule in `references/poteto-mode.md:3`, which becomes "the coordinator runs Orchestrate; workers never do";
- the Claude Desktop, cmux and Codex modes, moved to an archive note unless still wanted.

## Standing orders vs project-instructions

Orchestrate pastes standing orders verbatim into every brief, while project-coordinator says never paste project-instructions. Split the file:
- `standing` (orch): rules workers must follow. Key source (`ori login`), `ORI_TELEMETRY=0`, branch naming, PR title and Linear line, no draft PRs, report to coordinator, never merge.
- `project-instructions.md`: coordinator-only rules. perry, merge rule, quiet hours, reporting style.

## Review gap fix (ships with this)

`playbooks/opening-a-pr.md:48`: `interrogate` applies to every agent that opens a PR, not only subagents. With the verifier ledger this gives two layers: the worker's own panel before the PR, and the coordinator's cross-family verifier at the merge-ready head.

## Migration

1. `orch init` in `~/.claude/coordinator/ori/orchestrate/`.
2. Seed `units.tsv` from the current board: rows 30, 31, 32, 35 and 37, plus open PRs.
3. Keep `ori-board.md` read-only as the history.
4. Switch the scheduled check prompt to the drain prompt.

## Verification

Prove it on one real unit (the pilot):
- a new ticket spawned from the Orchestrate brief;
- the worker's `interrogate` panel ran before its PR;
- the coordinator's cross-family verifier wrote a ledger row for the head SHA;
- a later push voided the row;
- merged under the rule.

Check that `orch status` matches `gh` for each open PR.

## Open questions for Matthew

- In-flight cap to start with: 5?
- Non-T3 modes: archive (Matthew, 2026-10-13).
