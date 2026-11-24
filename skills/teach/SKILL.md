---
name: teach
description: "Build a working mental model of code: the components and how they interact, then the interfaces, schemas, and function signatures. Use when asked to teach or explain how code works, walk through an architecture, deep-dive a subsystem, or understand a change, including code outside the current repo. For a concept with no code, use pstack:teach."
---

# Teach

Load and follow `pstack:teach`; this skill wins on conflicts.

Trace real code before explaining and note anything unverified. Clone external repos under `~/dev/<repo>` so the user can open the same files. Introduce unfamiliar components, tools, domain terms, and synthetic inputs in plain words first, with skimmable prerequisite background in its own section.

## Views

- **System map (start here):** components, responsibilities, who calls whom, data crossing boundaries, state ownership, and one real end-to-end request + key failure path.
- **Contract walk (when going deeper or asked about data/interfaces):** interfaces and data, never function bodies.
  - Types/schemas: purpose, key fields, one real filled-in example, storage/durability, and writer.
  - Call flow: full-width, full-text-size top-down Mermaid flowchart of numbered steps with labeled call arrows. Clicking a box opens its contract card in a side panel with a draggable divider; clicking again or `Esc` closes it. Don't repeat the steps as a list.
- **Proposed designs:** use both views on traced existing code. Mark existing (gray, thin), changed (orange, dashed), and new (blue, thick solid)—never red vs. green. Show before/after call flow; point new `path:line` at the design sketch or "not written yet"; label new examples illustrative.

## Output

- **Chat:** link code as a Markdown link targeting the absolute path plus `:line` (opens the file pane); at most one-line signatures; explain code with pseudocode. (Claude desktop renders Mermaid and `<details>` as raw source.)
- **Visuals:** one self-contained HTML page under `/tmp/teach/<slug>.html` via `SendUserFile` (`display: "render"`), updated in place as the explanation grows (or `show_widget` when inline fits better). Include Mermaid CDN diagrams, an end-to-end state stepper with failure-path toggle, collapsible vertical-layout cards (no brace noise, no one-line types) with copyable `abs_path:line`, and cross-linked mentions with a floating Back button plus built-in Back/Forward (`Ctrl+-` / `Ctrl+Shift+-`).

Teaching alone does not authorize code changes.
