#!/bin/bash
# Validate all skills under skills/*/SKILL.md.
# Checks:
# - valid YAML frontmatter
# - required fields: name, description
# - unique skill name values
# - name matches its directory
# - relative Markdown links resolve
# - README mentions every skill

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
  content = File.read(path, encoding: "UTF-8")
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

  dir_name = File.basename(File.dirname(path))
  if name.is_a?(String) && name != dir_name
    errors << "#{path}: name `#{name}` does not match directory `#{dir_name}`"
  end

  if name.is_a?(String) && !name.strip.empty?
    if seen.key?(name)
      errors << "#{path}: duplicate skill name `#{name}` (already defined in #{seen[name]})"
    else
      seen[name] = path
    end
  end
end

Dir.glob(File.join(skills_dir, "**/*.md")).sort.each do |md|
  File.read(md, encoding: "UTF-8").scan(/\]\(([^)\s]+)\)/).flatten.each do |target|
    next if target.match?(%r{\A[a-z]+:|\A#})
    resolved = File.expand_path(target.sub(/#.*/, ""), File.dirname(md))
    errors << "#{md}: broken link `#{target}`" unless File.exist?(resolved)
  end
end

readme_path = File.join(File.dirname(skills_dir), "README.md")
readme = File.exist?(readme_path) ? File.read(readme_path, encoding: "UTF-8") : ""
seen.each_key do |name|
  errors << "README.md: skill `#{name}` is not listed" unless readme.include?("`#{name}`")
end

if errors.empty?
  puts "Validated #{paths.length} SKILL.md file(s): OK"
else
  warn "Skill validation failed:"
  errors.each { |err| warn "  - #{err}" }
  exit 1
end
RUBY
