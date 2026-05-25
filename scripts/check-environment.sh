#!/usr/bin/env bash
set -euo pipefail

json=false
if [[ "${1:-}" == "--json" ]]; then
  json=true
fi

skill_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home_dir="${HOME:?HOME is not set}"

has_command() {
  command -v "$1" >/dev/null 2>&1
}

command_json() {
  local name="$1"
  if has_command "$name"; then
    local path version
    path="$(command -v "$name")"
    version="$("$name" --version 2>/dev/null | head -n 1 || true)"
    printf '{"name":"%s","available":true,"path":"%s","version":"%s"}' "$name" "$path" "$version"
  else
    printf '{"name":"%s","available":false,"path":null,"version":null}' "$name"
  fi
}

dir_json() {
  local name="$1"
  local path="$2"
  if [[ -d "$path" ]]; then
    printf '{"name":"%s","exists":true,"path":"%s"}' "$name" "$path"
  else
    printf '{"name":"%s","exists":false,"path":"%s"}' "$name" "$path"
  fi
}

superpowers_present=false
if [[ -d "$home_dir/.codex/superpowers/skills" || -d "$home_dir/.codex/skills/using-superpowers" || -d "$home_dir/.agents/skills/using-superpowers" ]]; then
  superpowers_present=true
fi

gstack_present=false
if has_command gstack || [[ -d "$home_dir/.codex/skills/gstack" || -d "$home_dir/.claude/skills/gstack" ]]; then
  gstack_present=true
fi

if [[ "$json" == true ]]; then
  printf '{"skillRoot":"%s","commands":[%s,%s,%s,%s,%s],"directories":[%s,%s,%s,%s,%s,%s,%s],"superpowersPresent":%s,"gstackPresent":%s}\n' \
    "$skill_root" \
    "$(command_json git)" "$(command_json openspec)" "$(command_json gstack)" "$(command_json node)" "$(command_json bun)" \
    "$(dir_json codexSkills "$home_dir/.codex/skills")" \
    "$(dir_json codexSuperpowers "$home_dir/.codex/superpowers/skills")" \
    "$(dir_json agentsSkills "$home_dir/.agents/skills")" \
    "$(dir_json claudeSkills "$home_dir/.claude/skills")" \
    "$(dir_json codexGstack "$home_dir/.codex/skills/gstack")" \
    "$(dir_json claudeGstack "$home_dir/.claude/skills/gstack")" \
    "$(dir_json currentSkill "$skill_root")" \
    "$superpowers_present" "$gstack_present"
  exit 0
fi

echo "AI Delivery Stack environment check"
echo "Skill root: $skill_root"
echo
echo "Commands:"
for cmd in git openspec gstack node bun; do
  if has_command "$cmd"; then
    echo "  [OK] $cmd - $(command -v "$cmd")"
  else
    echo "  [MISSING] $cmd"
  fi
done
echo
echo "Directories:"
for entry in \
  "codexSkills:$home_dir/.codex/skills" \
  "codexSuperpowers:$home_dir/.codex/superpowers/skills" \
  "agentsSkills:$home_dir/.agents/skills" \
  "claudeSkills:$home_dir/.claude/skills" \
  "codexGstack:$home_dir/.codex/skills/gstack" \
  "claudeGstack:$home_dir/.claude/skills/gstack" \
  "currentSkill:$skill_root"; do
  name="${entry%%:*}"
  path="${entry#*:}"
  if [[ -d "$path" ]]; then
    echo "  [OK] $name: $path"
  else
    echo "  [MISSING] $name: $path"
  fi
done
echo
echo "Superpowers skills: $([[ "$superpowers_present" == true ]] && echo present || echo missing)"
echo "gstack skills/command: $([[ "$gstack_present" == true ]] && echo present || echo missing)"
