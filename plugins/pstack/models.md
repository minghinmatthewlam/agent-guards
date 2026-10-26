# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`). Alias entries in a panel list still count toward its fan-out.
# budget: large (xhigh)
feature, refactoring: anthropic/claude-opus-5.5
bug-fix: anthropic/claude-opus-5.5
perf-issue: anthropic/claude-opus-5.5
hillclimb: anthropic/claude-opus-5.5
judgment and prose: anthropic/claude-opus-5.5
hardest tasks: anthropic/claude-opus-5.5
how explorer: anthropic/claude-opus-5.5
how explainer: anthropic/claude-opus-5.5
why investigators: anthropic/claude-opus-5.5
why synthesizer: anthropic/claude-opus-5.5
reflect tooling: anthropic/claude-opus-5.5
reflect judgment, divergent, synthesizer: anthropic/claude-opus-5.5
arena runners: anthropic/claude-opus-5.5, openai/gpt-6.1-sol
arena cross-judge pool: openai/gpt-6.1-sol
swarm workers: anthropic/claude-opus-5.5
architect runners: anthropic/claude-opus-5.5, openai/gpt-6.1-sol
interrogate reviewers: anthropic/claude-opus-5.5, openai/gpt-6.1-sol
