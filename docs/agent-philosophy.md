# Agent Philosophy

## Read the code first

Code is the source of truth for the current implementation. Read and trace it before relying on documentation, history, or assumptions. Ask the user only for product intent that the code cannot answer.

## Define proof before work

Decide what success looks like and how to observe it before implementation. Find the repository's verification path first. If none exists, create one. A change is not done until the affected user-facing surface has been exercised.

Verification is maintained infrastructure. It should explain how to start the product, confirm the right instance is running, drive important features, capture proof, and clean up safely. Keep it current as the product changes.

## Make the correct path easy

Agents copy nearby code and take shortcuts. Use simple structure, one canonical path, strong types, static analysis, tests, and CI so the intended implementation is obvious and important mistakes fail early.

Prefer removing a bad path over documenting why agents should avoid it. Use written instructions only when the decision cannot be enforced mechanically.

## Learn from mistakes

Treat a material agent mistake as feedback about the system. Find what made the wrong action easy. Improve the owning code, repository structure, tooling, verification, or workflow, then prove the same class of mistake is harder to repeat.

Do not add machinery for a harmless one-off judgment error.

## Give goals, tools, and constraints

State the desired result, available tools, important constraints, and observable success. Let the agent choose the implementation details when the code and goal make them clear.

## Keep the human oriented

Report the result, proof, important decisions, blockers, and residual risk in plain language. Put supporting detail in code, diffs, logs, and artifacts so it is available without overwhelming the main report.
