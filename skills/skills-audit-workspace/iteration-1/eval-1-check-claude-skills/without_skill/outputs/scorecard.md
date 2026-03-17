# Skills Audit Scorecard

**Date:** 2026-03-17
**Scope:** `~/.claude/skills/` (14 skill directories)
**Source of truth:** `~/dev/agent-guards/skills/`

---

## Summary

14 skills deployed to `~/.claude/skills/`. 11 are managed by agent-guards sync, 2 are external (agent-browser, slack), and 1 (simplify) is missing from the deployed set due to `agent-only: true` in its frontmatter. All managed skills are byte-identical with their source. The triplicated review-protocol.md is identical across all three copies. Overall the skill set is well-structured with only a few issues worth addressing.

---

## Issues Found

### HIGH: `simplify` skill not available as a Claude Code skill

- **What:** The `simplify` skill has `agent-only: true` in its SKILL.md frontmatter, so `sync.sh` intentionally skips it for `~/.claude/skills/`. However, the `orchestrator` skill (Phase 4) directly invokes `simplify` as a skill. If orchestrator runs in Claude Code, invoking `/simplify` will fail because the skill is not present.
- **Impact:** Orchestrator workflow breaks at Phase 4. The user would need to manually run simplify or skip it.
- **Fix:** Either remove `agent-only: true` from `simplify/SKILL.md` so it syncs to Claude skills, or add a fallback instruction in orchestrator for when simplify is unavailable, or document which environment orchestrator is designed to run in.

### MEDIUM: Triplicated `review-protocol.md` across audit-loop, plan-loop, review-loop

- **What:** The exact same file (`references/review-protocol.md`, md5 `cd01cc45...`) is duplicated in three skill directories. All three copies are currently identical, but this creates drift risk if one copy is edited without updating the others.
- **Impact:** Future edits may create inconsistency. Maintenance burden.
- **Fix:** Since skills are synced via rsync from source, the real fix is in `~/dev/agent-guards/skills/`. Options: (a) keep one canonical copy and symlink from the other two, or (b) extract it to a shared `references/` directory at the skills root level and adjust the relative paths in each SKILL.md. The sync script already handles `--copy-links` so symlinks in source would become real files at the destination.

### MEDIUM: `oracle` skill references outdated model name "GPT-5.2 Pro"

- **What:** The oracle skill references `gpt-5.2-pro` and `GPT-5.2 Pro` as the default model. This may or may not be current -- worth verifying the model name is still valid for the oracle CLI.
- **Impact:** If the model name has changed, browser-mode oracle runs would fail or use the wrong model.
- **Fix:** Run `npx -y @steipete/oracle --help` to confirm currently supported models and update the skill if needed.

### LOW: `slack` and `agent-browser` skills are unmanaged (not in agent-guards)

- **What:** `agent-browser` and `slack` exist in `~/.claude/skills/` but are not in `~/dev/agent-guards/skills/` and not listed in `.agent-guards-managed-skills`. They appear to have been installed externally (possibly via `npx skills` or manual creation).
- **Impact:** These skills won't be backed up, version-controlled, or synced via `sync.sh`. If `~/.claude/skills/` is ever pruned or recreated, they would be lost. However, the prune logic only removes entries listed in the manifest, so they are safe from accidental deletion.
- **Fix:** If these are meant to persist, either add them to agent-guards source or document them in an external-skills manifest. The `agent-browser` skill in particular is substantial (600+ lines with 7 reference files) and worth preserving.

### LOW: `fix-ci` references `<path-to-skill>` placeholder in script paths

- **What:** The SKILL.md uses `python "<path-to-skill>/scripts/inspect_pr_checks.py"` as a placeholder. Claude Code skills don't have a built-in variable for the skill's own directory path.
- **Impact:** The agent calling this skill needs to resolve the path itself. Claude Code agents typically can find the script via the skill directory structure, so this works in practice but is fragile.
- **Fix:** Consider using an absolute path (`~/.claude/skills/fix-ci/scripts/inspect_pr_checks.py`) or a relative path from the repo root, or document how the agent should resolve the placeholder.

### LOW: `ios-dev` hardcodes "iPhone 17 Pro" simulator name

- **What:** Examples reference `--simulator-name "iPhone 17 Pro"` which may not exist on all systems.
- **Impact:** Minimal -- agents should discover available simulators first (Step 0), but copy-paste of examples could fail.
- **Fix:** Add a note that the simulator name is an example and should be replaced with output from `xcodebuildmcp simulator list`.

### LOW: `slack` skill has hardcoded ref numbers in examples

- **What:** Examples reference specific refs like `@e14` for Activity tab, `@e13` for DMs, `@e21` for More unreads. The "Key refs to look for" section suggests these are stable, but refs change every session.
- **Impact:** Could mislead an agent into using stale refs without snapshotting first. The "Best Practices" section does say to snapshot first, but the hardcoded ref guidance contradicts this.
- **Fix:** Remove the "Key refs to look for" section or reword it to make clear these are approximate examples only.

---

## Structural Observations

| Aspect | Status | Notes |
|--------|--------|-------|
| Source-deployed sync | OK | All 11 managed skills match source exactly |
| Frontmatter format | OK | All SKILL.md files have valid `---` delimited YAML frontmatter with name and description |
| Description quality | OK | Descriptions are actionable with clear trigger phrases |
| Cross-skill references | Issue | orchestrator -> simplify broken (see HIGH above) |
| Reference deduplication | Issue | review-protocol.md x3 (see MEDIUM above) |
| Allowed-tools declarations | OK | agent-browser and slack correctly scope to `Bash(agent-browser:*)` and `Bash(npx agent-browser:*)` |
| Skill sizing | OK | Most skills are well under 500 LOC. agent-browser is large (~630 lines) but justified as a comprehensive reference |

---

## Skill Inventory

| Skill | Managed | Lines | Has References | Notes |
|-------|---------|-------|----------------|-------|
| agent-browser | No (external) | ~630 | 7 files | Comprehensive browser automation |
| audit-loop | Yes | ~38 | 1 (review-protocol) | Clean |
| fix-ci | Yes | ~150 | 1 script | `<path-to-skill>` placeholder |
| ios-dev | Yes | ~148 | None | Clean |
| ios-release | Yes | ~148 | 4 files | Clean, well-structured phases |
| mcporter | Yes | ~41 | None | Clean, minimal |
| new-task | Yes | ~31 | None | Clean |
| oracle | Yes | ~88 | None | Model name may need update |
| orchestrator | Yes | ~41 | None | Broken simplify reference |
| plan-loop | Yes | ~46 | 1 (review-protocol) | Clean |
| review-loop | Yes | ~35 | 1 (review-protocol) | Clean |
| self-test | Yes | ~25 | None | Clean, well-scoped |
| simplify | Source only | ~54 | None | agent-only, not in ~/.claude/skills |
| slack | No (external) | ~289 | 2 files | Hardcoded refs issue |
