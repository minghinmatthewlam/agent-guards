#!/usr/bin/env python3
"""Remind T3 agents in scoped repos to work in pstack's poteto-mode.

Usage: poteto-reminder.py claude|codex, with the hook event JSON on stdin.
Prints nothing unless T3 launched the agent (T3CODE_CLI_PATH is set) and the
event's cwd is under a folder listed in poteto-reminder.scopes beside this file.
"""
import glob, json, os, sys

HERE = os.path.dirname(os.path.realpath(__file__))
FOLLOW = "Make sure you are working in pstack's poteto-mode and following it. "
MISSING = "If the poteto-mode SKILL.md body (its Non-negotiables, Principles and Playbooks) is not in your context, "


def load_scopes():
    with open(os.path.join(HERE, "poteto-reminder.scopes")) as f:
        lines = (line.strip() for line in f)
        return [os.path.realpath(os.path.expanduser(line)) for line in lines if line and not line.startswith("#")]


def in_scope(cwd):
    real = os.path.realpath(cwd)
    return any(real == s or real.startswith(s + "/") for s in load_scopes())


def codex_skill_path():
    codex_home = os.environ.get("CODEX_HOME") or os.path.expanduser("~/.codex")
    found = glob.glob(os.path.join(codex_home, "plugins/cache/*/pstack/*/skills/poteto-mode/SKILL.md"))
    return max(found, key=os.path.getmtime) if found else None


def reminder(tool):
    if tool == "claude":
        return FOLLOW + MISSING + "invoke the Skill tool with pstack:poteto-mode before anything else this turn."
    path = codex_skill_path()
    where = f"`{path}`" if path else "the pstack:poteto-mode skill's SKILL.md (the pstack plugin's skills root)"
    return FOLLOW + MISSING + f"read {where} in full before anything else this turn. It is the pstack:poteto-mode skill."


def main():
    tool = sys.argv[1] if len(sys.argv) > 1 else ""
    if tool not in ("claude", "codex"):
        sys.exit(f"usage: {sys.argv[0]} claude|codex")
    event = json.load(sys.stdin)
    if not os.environ.get("T3CODE_CLI_PATH") or not in_scope(event.get("cwd", "")):
        return
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": event["hook_event_name"],
        "additionalContext": reminder(tool),
    }}))


main()
