#!/bin/bash
# Validate all skills under skills/*/SKILL.md.
# Checks:
# - valid YAML frontmatter
# - required fields: name, description
# - unique skill name values

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi

ruby - "$SKILLS_DIR" <<'RUBY'
require "yaml"

skills_dir = ARGV[0]
paths = Dir.glob(File.join(skills_dir, "*/SKILL.md")).sort
errors = []
seen = {}

paths.each do |path|
  content = File.read(path)
  match = content.match(/\A---\n(.*?)\n---\n/m)
  unless match
    errors << "#{path}: missing YAML frontmatter block"
    next
  end

  begin
    data = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
  rescue => e
    errors << "#{path}: invalid YAML: #{e.message}"
    next
  end

  name = data["name"]
  description = data["description"]

  if !name.is_a?(String) || name.strip.empty?
    errors << "#{path}: missing or empty `name`"
  end

  if !description.is_a?(String) || description.strip.empty?
    errors << "#{path}: missing or empty `description`"
  end

  if name.is_a?(String) && !name.strip.empty?
    if seen.key?(name)
      errors << "#{path}: duplicate skill name `#{name}` (already defined in #{seen[name]})"
    else
      seen[name] = path
    end
  end
end

if errors.empty?
  puts "Validated #{paths.length} SKILL.md file(s): OK"
else
  warn "Skill validation failed:"
  errors.each { |err| warn "  - #{err}" }
  exit 1
end
RUBY
