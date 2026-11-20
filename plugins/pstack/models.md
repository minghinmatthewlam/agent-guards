# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model` and spawn `generalPurpose`). Alias entries in a panel list still count toward its fan-out.
# defaults: 3
# budget: medium (high)
feature, refactoring: anthropic/claude-opus-5.5
bug-fix: anthropic/claude-opus-5.5
perf-issue: anthropic/claude-opus-5.5
hillclimb: anthropic/claude-opus-5.5
judgment and prose: anthropic/claude-opus-5.5
arena runners: anthropic/claude-fable-5.2, anthropic/claude-opus-5.5, google/gemini-4-neon
arena cross-judge pool: anthropic/claude-opus-5.5, google/gemini-4-neon
swarm workers: anthropic/claude-opus-5.5
interrogate reviewers: anthropic/claude-fable-5.2, google/gemini-4-neon, openai/gpt-6.1-sol
