#!/usr/bin/env bash
set -euo pipefail

# Detect which top-level skill directories were modified in the PR.
# Expects BASE_REF env var (e.g. "main").
# Writes outputs to $GITHUB_OUTPUT.

BASE_REF="${BASE_REF:?BASE_REF is required}"

CHANGED_DIRS=$(git diff --name-only "origin/${BASE_REF}...HEAD" \
  | grep -oP '^[^/]+' | sort -u)

SKILLS=""
SKILLS_JSON="[]"
while IFS= read -r dir; do
  [ -z "$dir" ] && continue
  [[ "$dir" == .* ]] && continue
  [[ "$dir" == "ci" ]] && continue
  [[ "$dir" == "scripts" ]] && continue
  [[ "$dir" == "node_modules" ]] && continue
  [[ "$dir" == *.* ]] && continue  # skip root files like README.md

  if [ -d "$dir" ]; then
    # Plugins nest their skills under <plugin>/skills/<skill>/
    for skill_dir in "$dir"/skills/*/; do
      [ -f "${skill_dir}SKILL.md" ] || continue
      skill_dir="${skill_dir%/}"
      SKILLS="${SKILLS}${skill_dir}"$'\n'
      SKILLS_JSON=$(echo "$SKILLS_JSON" | jq -c --arg d "$skill_dir" '. + [$d]')
    done
  fi
done <<< "$CHANGED_DIRS"

SKILLS=$(echo "$SKILLS" | sed '/^$/d')

if [ -z "$SKILLS" ]; then
  {
    echo "has_changes=false"
    echo "changed_skills="
    echo "changed_skills_list=[]"
  } >> "$GITHUB_OUTPUT"
  echo "No skill directories changed."
else
  {
    echo "has_changes=true"
    echo "changed_skills<<EOF"
    echo "$SKILLS"
    echo "EOF"
    echo "changed_skills_list=$SKILLS_JSON"
  } >> "$GITHUB_OUTPUT"
  echo "Changed skills:"
  echo "$SKILLS"
fi
