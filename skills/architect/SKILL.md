---
name: architect
description: "Design features, subsystems, and substantial refactors through component boundaries, caller usage, data models, and interfaces before implementation. Use when asked to architect a change, choose a design, or decide where code and responsibilities should live."
---

# Architect

Resolve material design decisions before implementation. Favor simple structures where the right path is obvious over speculative abstractions.

## Design

- **Ground in code.** Trace the real implementation, call paths, state ownership, and verification commands. Use `new-task` when product intent is unclear.
- **Optimize for the resulting system, not the smallest diff.** Treat existing code as changeable—redesign affected parts if that yields a simpler, clearer solution.
- **Work backwards from callers.** Start from a concrete caller/user example and sketch components, ownership, end-to-end flow, key data types, and public interfaces. Leave routine internals to implementation.
- **Make boundaries explicit.** Group around cohesive responsibilities with clear mutation ownership and dependency direction. Apply `repo-setup` to the affected area so key constraints are enforced mechanically (structure, types, lint, tests, CI).
- **Let data models rule out bad states.** Model valid states directly instead of independent booleans/optionals; parse untrusted input at boundaries once and keep checked facts in types.
- **Test against reality.** Prototype uncertain behavior/ergonomics. For broad or consequential designs, run an independent subagent review focused on high-impact decisions and unnecessary complexity. Define observable success and verification.

