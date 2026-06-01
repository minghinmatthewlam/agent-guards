# Autoreview References

These files are optional `--prompt-file` add-ons for repos where generic diff review misses important local context.

Use the file whose basename matches the reviewed repo when it exists:

```bash
~/.agents/skills/autoreview/scripts/autoreview --mode auto --engine codex --no-web-search --prompt-file ~/.agents/skills/autoreview/references/pi-gui.md
```

Keep these prompts short, review-focused, and free of secrets.
