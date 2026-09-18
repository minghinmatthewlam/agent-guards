---
name: architect
description: "Design features, subsystems, and substantial refactors through component boundaries, caller usage, data models, and interfaces before implementation. Use when asked to architect a change, choose a design, or decide where code and responsibilities should live."
---

# Architect

Design a system the user can understand and agents can implement without inventing its architecture along the way. Keep the design focused on the current goal. Favor simple structures that make the correct path obvious over layers, fallbacks, or abstractions for hypothetical needs.

## Ground The Design

Code is the source of truth for existing behavior. Trace the affected implementation, call paths, state ownership, and verification commands. Do not infer behavior from names or familiar patterns. Separate verified constraints from assumptions and proposed changes. Use `new-task` when product intent needs alignment.

## Sketch Before Filling In Bodies

Start from a concrete caller or user example and work backwards to the design. Show:

- The components involved, their responsibilities, and where their code belongs in the actual repository.
- The end-to-end steps: who calls whom, what data crosses each boundary, and where state changes.
- The important data types, states, interfaces, and public function signatures. Leave routine function internals to implementation.

Choose the smallest useful sketch, such as a usage example, type definitions, or a short diagram. Distinguish existing, changed, and new components. Label arrows as dependencies, calls, or data flow rather than mixing meanings.

## Make Boundaries Explicit

Group code around cohesive responsibilities and domain knowledge, not just execution phases. For each meaningful boundary, state what it owns, the interface others use, allowed dependency directions, and important bypasses that must not be allowed. Give persistent state a clear mutation owner.

Keep external systems and untrusted input behind explicit interfaces. Keep shared code genuinely shared rather than turning utilities or root modules into catch-all dependencies. Show where the next similar feature would go.

Use boundaries that fit this repository. Do not copy a fixed UI/service/repository layer stack or create one module per function. A boundary should clarify ownership, isolate change, or enforce a real rule.

Read and use `repo-setup` when designing component boundaries and repository structure. Apply it to the affected area: identify how the correct path stays obvious and how important constraints will be enforced through structure, types, lint, tests, or CI. Include necessary guard changes in the design; do not turn this into a whole-repo audit or implement changes without authorization.

## Let Data Models Remove Bad Cases

Model meaningful states and their required data directly rather than using independent booleans or optional fields that permit contradictory combinations. Parse external input into trusted domain values at boundaries and preserve the checked facts in their types. Do not substitute casts for runtime checks or repeat input checks throughout internal code.

Strengthen types where they prevent a meaningful mistake or simplify callers. Reuse authoritative schemas and make important variant handling exhaustive. Do not pursue type precision that adds complexity without removing a real problem. Types do not prove changing external facts such as current permissions or resource availability.

## Test The Design Against Reality

Compare alternatives when the trade-off matters. Use focused prototypes to resolve uncertain behavior, ergonomics, or performance rather than repeatedly reviewing an abstract plan.

For broad or consequential designs, use independent subagent review focused on the highest-impact decisions and failure cases. Reviewers should challenge unnecessary complexity, not expand scope. Resolve material concerns, then present the simple recommended design, key trade-offs, and remaining uncertainty to the user. Stop when further review adds no decision-relevant value; small designs do not require this ceremony.

Define observable success and how to verify the main path and important failure cases. A compiling interface sketch is not proof of runtime behavior. During authorized implementation, revisit the design if callers need repeated workarounds, unexpected state, or unsafe escapes instead of hiding the mismatch behind fallbacks.

Use `teach` to explain the components, boundaries, and end-to-end flow, and `concisely` for presentation. Surface material decisions while the user can still adjust the design. An architecture request alone does not authorize implementation, broad refactoring, or external changes.
