---
name: teach
description: "Build a working mental model of code: the components and how they interact, then the interfaces, schemas, and function signatures. Use when asked to teach or explain how code works, walk through an architecture, deep-dive a subsystem, or understand a change, including code outside the current repo. For a concept with no code, use pstack:teach."
---

# Teach

Load the `pstack:teach` skill and follow it. This skill adds what teaching code needs. Where the two conflict, this skill wins.

Code is the source of truth. Trace the implementation and call paths before explaining, and say what you could not verify. For code outside the current repo, clone it under `~/dev/<repo>` so the user can open the same files.

Assume the user knows none of the components, tools, or domain terms involved. Introduce each one in plain words the first time it appears, before using its name. Put prerequisite background in its own short section the user can skim past. Never collapse it. When an example comes from an input you made up or ran, such as a test file, introduce that input first.

## Views

Start with the system map. Move to the contract walk when the user asks to go deeper or the question is about data or interfaces.

**System map.** The components, what each is responsible for, who calls whom, what data crosses each boundary, and where state lives. Walk one real request end to end, including the failure path that matters most.

**Contract walk.** Interfaces and data, never function bodies.

- Each type or schema: what it represents, its key fields, one filled-in instance with real values, where it is stored and how durable that is (memory, file, which database; does it survive a restart or crash), and who writes it.
- The call flow: a top-down Mermaid flowchart from the entry point. Each box is a numbered function or step with one line on what it does, and each arrow is a call labeled with when it happens, such as "blocked" or "the tool waits". Give the call-flow section the full window width and draw the diagram at full text size. Clicking a box opens its full contract card in a panel beside the diagram, separated by a draggable divider, and clicking the same box again or pressing Esc closes the panel so the diagram takes the full width. Do not repeat the steps as a separate list.

**Proposed designs.** Teach a design the same way, with both views. Trace the existing code it touches so the starting point is real. Mark each component, type, and function as existing, changed, or new, in prose and in the diagrams. Use color-blind-safe styles that also differ without color: new is blue with a thick solid border, changed is orange with a dashed border, existing is gray with a thin border. Never use red against green. For a change, show the call flow before and after. Point a new piece's `path:line` at the design sketch file when one exists, and otherwise say "not written yet". Label example values for new pieces as illustrative.

## Output

The Claude desktop chat shows Mermaid and `<details>` as raw source, so draw chat visuals with the imagine tool (`show_widget`, after its `read_me`). Start there: small diagrams of about five boxes or fewer, built up across several widgets with a sentence between each, with boxes that open a short contract when clicked and close when clicked again. Add the HTML page when the contract walk begins, a diagram needs more than about five boxes, or the user wants something to keep, and keep a small overview widget in chat so the reply stands alone. Without the imagine tool, put every visual in the page.

- In chat, link code as a Markdown link whose target is the absolute path plus `:line`. It opens the file pane at that line. Show at most one-line signatures.
- When you show code, explain it with pseudocode.
- Write the page as one self-contained HTML file under `/tmp/teach/<slug>.html` and send it with `SendUserFile` and `display: "render"`. Draw diagrams with Mermaid from a CDN, built up as `pstack:teach` describes. Make the end-to-end walkthrough a stepper that shows what state changes at each step, with a toggle for the failure path. Give each type and function a collapsible card with its summary, signature, fields, filled-in example, storage, and absolute `path:line` as copyable text, since links in the page do not open the file pane.
- Lay out signatures, fields, and examples vertically: the name on one line, then one indented line per field or parameter with its type and a few words on what it means. Drop braces and syntax noise. Never squeeze a type or an example onto one line.
- Link every mention of a type or function that has a card to that card, in prose, fields, and the call flow. A click opens the card and scrolls to it, and a floating Back button returns to where the user was, like go-to-definition. The page viewer has no browser controls, so build Back and Forward into the page, bound to Ctrl+- and Ctrl+Shift+-. A link to a call-flow step opens it in the diagram's panel.
- Keep one page per topic. Update it and send it again as the explanation grows.

Teaching alone does not authorize code changes.
