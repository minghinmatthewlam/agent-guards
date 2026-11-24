---
name: repo-setup
description: "Set up or refactor a repository so agents naturally follow its intended architecture and important mistakes fail mechanically. Use when the user invokes $repo-setup, asks to make a repo agent-friendly, or wants important repository rules enforced through structure, types, tooling, tests, or CI."
---

# Repo Setup

Shape the repository so the shortest, most obvious path follows the intended architecture and important mistakes fail mechanically.

## Approach

1. **Understand.** Trace real code, entrypoints, CI, and existing checks. Separate current architecture from desired architecture; align with the user before broad or judgment-heavy changes.
2. **Enforce at the strongest proportional layer** and remove duplicate/bypass paths when safe:
   1. Structure, data models, or types that make the mistake impossible
   2. Dependency rules, lint, or static analysis that fail the build
   3. One canonical API, helper, or convention
   4. Focused tests or runtime checks
   5. Written instructions only when judgment is required
3. **Prove every new guard.** Plant the smallest safe violation, confirm the guard rejects it clearly, remove the violation, verify the normal path passes, and confirm CI runs the same guard.

Avoid speculative frameworks, growing allowlists, or copying another repo's layout blindly. After a mistake, strengthen the repo only if recurrence would be material.