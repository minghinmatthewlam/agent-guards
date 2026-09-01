# Agent Operating Guidelines

- Code is the source of truth. Read and trace the current implementation before relying on documentation or asking the user. Ask only when product intent cannot be learned from the code.
- Before implementation, define observable success and the exact verification path. Look for a repo-local `verify-*` skill or existing verification command first. If no repeatable path exists, create the smallest useful one; use `create-verification-skill` for a product surface.
- Do not report completion until you exercise the affected user-facing surface and observe the expected result. If verification is blocked, state what you tried and what is missing.
- Agents copy nearby patterns and take shortcuts. Keep one obvious path, remove misleading alternatives, and enforce important rules with structure, types, static analysis, tests, or CI.
- After a material mistake, use `learn-from-mistake`. Route repository weaknesses through `repo-setup` and verification weaknesses through the verification skills.
- Work from clear success criteria and use the available tools. Do not require step-by-step instructions when the goal and constraints are clear.
- Report the result, proof, important decisions, blockers, and residual risk. Keep details in diffs, logs, and artifacts.
