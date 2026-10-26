#!/bin/bash
# Apply this repo's invocation rule to every pstack skill, including ones upstream adds later.
#
# Usage: plugins/pstack/scripts/normalize-invocation.sh [--check]
#
# Rule:
# - No skill sets disable-model-invocation. In Claude Code it blocks the Skill tool and
#   subagent preloading, so poteto-mode could not load the skills it routes to.
# - Skills outside ENTRY_SKILLS set user-invocable: false, which hides them from the / menu.
# - Skills outside ENTRY_SKILLS have agents/openai.yaml with allow_implicit_invocation: false.
# --check reports violations and exits 1 instead of fixing them.

set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills" && pwd)"
ENTRY_SKILLS="poteto-mode poteto-help setup-pstack make-bot-ui automate-me create-verification-skill maintain-verification-skill teach"

ruby - "$SKILLS_DIR" "${1:-}" "$ENTRY_SKILLS" <<'RUBY'
skills_dir, mode, entry = ARGV
check = mode == "--check"
entry = entry.split
problems = []

Dir.glob(File.join(skills_dir, "*/SKILL.md")).sort.each do |path|
  name = File.basename(File.dirname(path))
  content = File.read(path, encoding: "UTF-8")
  match = content.match(/\A---\n(.*?\n)---\n/m) or abort "#{path}: missing frontmatter"
  lines = match[1].lines.reject { |l| l.start_with?("disable-model-invocation:", "user-invocable:") }
  lines << "user-invocable: false\n" unless entry.include?(name)
  fixed = "---\n#{lines.join}---\n#{match.post_match}"
  if fixed != content
    problems << "#{name}: invocation frontmatter"
    File.write(path, fixed) unless check
  end

  next if entry.include?(name)
  yaml = File.join(File.dirname(path), "agents", "openai.yaml")
  text = File.exist?(yaml) ? File.read(yaml) : ""
  next if text.match?(/^\s+allow_implicit_invocation: false$/)
  problems << "#{name}: agents/openai.yaml lacks allow_implicit_invocation: false"
  next if check
  abort "#{yaml}: has a policy block; set allow_implicit_invocation by hand" if text.match?(/^policy:/)
  Dir.mkdir(File.dirname(yaml)) unless Dir.exist?(File.dirname(yaml))
  File.write(yaml, "#{text}#{"\n" unless text.empty? || text.end_with?("\n")}policy:\n  allow_implicit_invocation: false\n")
end

problems.each { |p| warn "#{check ? "invalid" : "fixed"}: #{p}" }
exit(check && problems.any? ? 1 : 0)
RUBY
