#!/usr/bin/env bash
set -euo pipefail

host="both"
mode="copy"
apply=false
force=false
skill_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      host="${2:?--host requires codex, claude, or both}"
      shift 2
      ;;
    --mode)
      mode="${2:?--mode requires copy or link}"
      shift 2
      ;;
    --apply)
      apply=true
      shift
      ;;
    --dry-run)
      apply=false
      shift
      ;;
    --force)
      force=true
      shift
      ;;
    --skill-path)
      skill_path="$(cd "${2:?--skill-path requires a path}" && pwd)"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ "$host" != "codex" && "$host" != "claude" && "$host" != "both" ]]; then
  echo "--host must be codex, claude, or both" >&2
  exit 2
fi

if [[ "$mode" != "copy" && "$mode" != "link" ]]; then
  echo "--mode must be copy or link" >&2
  exit 2
fi

install_one() {
  local target_host="$1"
  local root="$2"
  local destination="$root/ai-delivery-stack"
  local prefix="Dry run"
  [[ "$apply" == true ]] && prefix="Applying"

  echo "$prefix for $target_host -> $destination"

  if [[ "$apply" != true ]]; then
    [[ -d "$root" ]] || echo "  Would create directory: $root"
    if [[ -e "$destination" ]]; then
      if [[ "$force" == true ]]; then
        echo "  Would replace existing destination"
      else
        echo "  Destination exists; would skip without --force"
      fi
    fi
    if [[ "$mode" == "link" ]]; then
      echo "  Would link $skill_path"
    else
      echo "  Would copy $skill_path"
    fi
    return
  fi

  mkdir -p "$root"
  if [[ -e "$destination" ]]; then
    if [[ "$force" != true ]]; then
      echo "  Destination exists; skipping. Re-run with --force to replace."
      return
    fi
    case "$(cd "$root" && pwd)/" in
      "$(cd "$(dirname "$destination")" && pwd)/"*) ;;
      *) echo "Refusing to remove destination outside target root: $destination" >&2; exit 3 ;;
    esac
    rm -rf "$destination"
  fi

  if [[ "$mode" == "link" ]]; then
    ln -s "$skill_path" "$destination"
  else
    cp -R "$skill_path" "$destination"
  fi
  echo "  Installed."
}

echo "AI Delivery Stack host setup"
echo "Source: $skill_path"
echo "Mode: $mode"
echo "Operation: $([[ "$apply" == true ]] && echo apply || echo dry-run)"
echo

if [[ "$host" == "codex" || "$host" == "both" ]]; then
  install_one codex "$HOME/.codex/skills"
fi

if [[ "$host" == "claude" || "$host" == "both" ]]; then
  install_one claude "$HOME/.claude/skills"
fi
