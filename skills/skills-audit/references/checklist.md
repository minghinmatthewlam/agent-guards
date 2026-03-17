# Skill Quality Checklist

## Important: Not Every Check Applies to Every Skill

Skills vary widely in purpose and size. Before scoring, classify the skill:

- **Behavioral skills** (e.g., self-test) — short, philosophy-driven, meant to work across all repos. Don't penalize for missing scripts or references. Gotchas still apply — even behavioral skills have failure modes (e.g., agent claiming it verified without actually running anything).
- **Tool wrapper skills** (e.g., ios-dev, agent-browser) — reference material for a specific tool. Most checks apply.
- **Workflow skills** (e.g., plan-loop, orchestrator) — define a multi-step process. Most checks apply.
- **Simple/short skills** (<~100 lines) — don't penalize for missing progressive disclosure or folder structure. A 30-line file doesn't need a references/ folder.

If a check genuinely doesn't apply to a skill, score it **N/A** — it doesn't count toward the total. Only score checks that are meaningful for that specific skill's purpose and size.

---

## Universal Checks (all agent systems)

### 1. Category Clarity
Does the skill fit cleanly into one of the 9 categories?

- **Pass**: Clearly one category
- **Partial**: Mostly one but bleeds into another
- **Missing**: Tries to do multiple unrelated things — should be split

### 2. Gotchas Section
Does the skill document common failure points and edge cases the agent hits?

This is the highest-signal content in any skill. It should capture real failure modes discovered through use, not hypothetical ones. Almost every skill has gotchas — even behavioral skills have agent misbehavior patterns, and short workflow skills have edge cases.

- **Pass**: Has a gotchas/pitfalls section with specific, non-obvious failure points
- **Partial**: Has some warnings scattered through the body but no dedicated section
- **Missing**: No gotchas. When flagging this, suggest concrete gotchas based on the skill type:
  - **Tool wrappers**: tool-specific failure modes (timeouts, auth, version drift)
  - **Workflow skills**: edge cases (infinite loops, stale state, conflicting concurrent runs)
  - **Behavioral skills**: agent misbehavior patterns (e.g., "agent claims verified without running commands", "inflates confidence without probing")

### 3. Progressive Disclosure (Folder Structure)
Does the skill use its file system to manage context, or is everything crammed into one file?

- **Pass**: Folder with sub-files (references/, scripts/, assets/) and clear pointers from the main file about when to read each
- **Partial**: Single file at 200-300 lines that would benefit from splitting
- **Missing**: Single large file (300+ lines) that should be split
- **N/A**: Skill is under ~150 lines — small enough that a single file is the right choice. Don't suggest splitting short skills.

### 4. Description Quality (Trigger-Oriented)
Is the description written to help the model decide when to invoke the skill?

The description isn't a human summary — it's what the model scans at session start to decide "should I use this skill for this request?" It should describe trigger conditions and contexts, not just what the skill does abstractly.

- **Pass**: Description includes specific trigger phrases, user intents, and contexts. Slightly "pushy" to avoid undertriggering
- **Partial**: Describes what the skill does but not when to trigger it
- **Missing**: Vague or generic (e.g., "helps with deployment")

### 5. Avoids Stating the Obvious
Does the skill focus on information that pushes the agent beyond its defaults?

The agent already knows a lot about coding and common tools. Skills should focus on what's specific to your codebase, org, or workflow — the stuff the agent can't figure out on its own.

Note: reinforcing behavior the agent knows but doesn't reliably follow (e.g., "always verify your own output") is valuable, not "obvious." The test is whether the skill changes agent behavior in practice, not whether the agent theoretically already knows it.

- **Pass**: Content is predominantly non-obvious OR reinforces behavior the agent knows but routinely skips without the skill
- **Partial**: Mix of useful specifics and generic advice that the agent already reliably follows
- **Missing**: Mostly restates things the agent would do anyway without any behavioral nudge

### 6. Avoids Railroading
Does the skill give the agent flexibility to adapt, or is it overly rigid?

Skills are reusable across many different prompts. Being too specific in instructions makes the skill brittle. Give the agent information and constraints, but let it adapt to the situation.

- **Pass**: Provides information and goals, lets the agent decide how to execute
- **Partial**: Some sections are too prescriptive but overall has flexibility
- **Missing**: Step-by-step rigid instructions that don't adapt to context. Heavy use of ALWAYS/NEVER/MUST without explaining why

### 7. Includes Useful Scripts or References
Does the skill provide scripts, code, or reference material that save the agent from reinventing the wheel?

Giving the agent pre-built scripts and libraries lets it spend its turns on composition and decision-making rather than reconstructing boilerplate.

- **Pass**: Includes scripts/ or references/ that the agent uses effectively
- **Partial**: Agent consistently reinvents the same helper code each run — that code should be bundled
- **N/A**: Skill is instruction-only by nature (behavioral overlays, simple workflows, philosophy skills) or is short enough that scripts would be overkill. Don't suggest adding scripts/references unless there's clear evidence the agent needs them.

### 8. Has Frontmatter
Does the skill have proper YAML frontmatter with name and description?

- **Pass**: Has name and description in frontmatter
- **Partial**: Has frontmatter but missing description
- **Missing**: No frontmatter at all

---

## Claude-Specific Checks (`.claude/skills/` only)

### C1. On-Demand Hooks
Could this skill benefit from session-scoped hooks?

Claude Code skills can register hooks that activate only when the skill is called. Useful for guardrails (blocking dangerous commands), enforcement (style checks on save), or automation (post-action triggers).

- **Pass**: Uses on-demand hooks appropriately, or clearly doesn't need them
- **Partial**: Could benefit from hooks but doesn't use them
- **N/A**: Hooks wouldn't add value for this skill

### C2. Setup / Config Pattern
If the skill needs user-specific context (which Slack channel, which environment, etc.), does it handle setup gracefully?

A good pattern: store setup info in a config.json in the skill directory. If config is missing, prompt the user.

- **Pass**: Has a config mechanism or clearly doesn't need one
- **Partial**: Hardcodes values that should be configurable
- **N/A**: Skill doesn't need user-specific config

### C3. Data Persistence
If the skill produces or accumulates data across runs, does it store it properly?

Data stored in the skill directory may be deleted on upgrade. Use `${CLAUDE_PLUGIN_DATA}` for persistent storage, or store in a stable project location.

- **Pass**: Uses stable storage for persistent data, or doesn't need persistence
- **Partial**: Stores data in skill directory (fragile)
- **N/A**: Skill doesn't accumulate data across runs
