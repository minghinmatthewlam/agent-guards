# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`). Alias entries in a panel list still count toward its fan-out.
# budget: medium (high)
feature, refactoring: anthropic/claude-opus-5.5
bug-fix: anthropic/claude-opus-5.5
perf-issue: anthropic/claude-opus-5.5
hillclimb: anthropic/claude-opus-5.5
judgment and prose: anthropic/claude-opus-5.5
hardest tasks: anthropic/claude-fable-5.2
reflect tooling: anthropic/claude-opus-5.5
reflect judgment, divergent, synthesizer: anthropic/claude-opus-5.5
arena runners: anthropic/claude-fable-5.2, anthropic/claude-opus-5.5, google/gemini-4-carbon
arena cross-judge pool: anthropic/claude-fable-5.2, anthropic/claude-opus-5.5, google/gemini-4-carbon
swarm workers: anthropic/claude-opus-5.5
architect runners: anthropic/claude-fable-5.2, google/gemini-4-carbon, openai/gpt-6.1-sol
interrogate reviewers: anthropic/claude-fable-5.2, google/gemini-4-carbon, openai/gpt-6.1-sol
