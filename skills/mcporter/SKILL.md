---
name: mcporter
description: "CLI access to MCP servers without loading them into agent context (saves tokens). Use when: (1) calling MCP tools on-demand, (2) want to avoid MCP context overhead."
---

# MCPorter

Call MCP server tools via CLI without a persistent connection. Keeps tool schemas out of context.

## Quick Start

```bash
mcporter list                          # available servers
mcporter list <server> --schema        # tools + args (always run before first call)
mcporter call <server>.<tool> key:val  # call a tool
```

## Rules

- Always run `mcporter list <server> --schema` before first call — tool names drift between versions.
- If a server is offline or auth-gated, report it and continue with fallback tools.

## Non-Obvious Workflows

### Chrome live-session debugging

Connects to the user's running Chrome with existing login state and cookies. Requires Chrome remote debugging and user consent prompt approval.

```bash
mcporter list chrome-devtools --schema
mcporter call chrome-devtools.list_pages
mcporter call chrome-devtools.select_page pageIndex:0
mcporter call chrome-devtools.take_screenshot
mcporter call chrome-devtools.evaluate_script function:"() => document.title"
```

### When to use mcporter vs direct MCP

- **mcporter**: One-off or infrequent tool calls. Keeps context clean.
- **Direct MCP**: Frequent use in a session, need streaming, tight integration.
