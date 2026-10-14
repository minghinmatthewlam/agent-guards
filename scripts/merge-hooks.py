#!/usr/bin/env python3
"""Merge the poteto-reminder hook entries into a Claude settings.json or Codex hooks.json.

Usage: merge-hooks.py [--dry-run] <json-file> <hook-command>

Replaces every existing handler whose command runs poteto-reminder.py with one
group per event below, keeps every other key and hook, and leaves the file
untouched when it already matches.
"""
import json, os, shutil, sys

MARKER = "poteto-reminder.py"
EVENTS = {
    "SessionStart": {"matcher": "startup|compact|clear"},
    "UserPromptSubmit": {},
}


def is_ours(handler):
    return MARKER in handler.get("command", "")


def strip_ours(groups):
    kept = []
    for group in groups:
        handlers = [h for h in group.get("hooks", []) if not is_ours(h)]
        if handlers:
            kept.append({**group, "hooks": handlers})
        elif not any(is_ours(h) for h in group.get("hooks", [])):
            kept.append(group)
    return kept


def ours(groups):
    return [g for g in groups if any(is_ours(h) for h in g.get("hooks", []))]


def merged(doc, command):
    hooks = dict(doc.get("hooks", {}))
    for event, extra in EVENTS.items():
        want = {**extra, "hooks": [{"type": "command", "command": command}]}
        groups = hooks.get(event, [])
        if ours(groups) == [want]:
            continue
        hooks[event] = strip_ours(groups) + [want]
    return {**doc, "hooks": hooks}


def main():
    args = sys.argv[1:]
    dry_run = args[:1] == ["--dry-run"]
    if dry_run:
        args = args[1:]
    if len(args) != 2:
        sys.exit(__doc__)
    shown, command = args
    path = os.path.realpath(shown)
    doc = {}
    if os.path.exists(path):
        with open(path) as f:
            doc = json.load(f)
    new = merged(doc, command)
    if new == doc:
        print(f"  Hooks already current in {shown}")
        return
    if dry_run:
        print(f"  [dry-run] merge poteto-reminder hooks into {shown}")
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".agent-guards-tmp"
    with open(tmp, "w") as f:
        json.dump(new, f, indent=2)
        f.write("\n")
    if os.path.exists(path):
        shutil.copymode(path, tmp)
    os.replace(tmp, path)
    print(f"  Merged poteto-reminder hooks into {shown}")


main()
