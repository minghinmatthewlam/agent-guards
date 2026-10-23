#!/usr/bin/env python3
"""Remind Claude Code and Codex agents in scoped repos to follow pstack's poteto-mode.

Reads the hook event JSON on stdin and prints nothing unless the event's cwd is
under a folder listed in poteto-reminder.scopes beside this file. The claude|codex
argument in the registered commands is ignored; it stays so those commands, and
Codex's trust of them, do not change.
"""
import json, os, sys

HERE = os.path.dirname(os.path.realpath(__file__))
REMINDER = "Follow pstack's /poteto-mode"


def load_scopes():
    with open(os.path.join(HERE, "poteto-reminder.scopes")) as f:
        lines = (line.strip() for line in f)
        return [os.path.realpath(os.path.expanduser(line)) for line in lines if line and not line.startswith("#")]


def in_scope(cwd):
    real = os.path.realpath(cwd)
    return any(real == s or real.startswith(s + "/") for s in load_scopes())


def main():
    event = json.load(sys.stdin)
    if not in_scope(event.get("cwd", "")):
        return
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": event["hook_event_name"],
        "additionalContext": REMINDER,
    }}))


main()
