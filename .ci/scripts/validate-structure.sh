#!/usr/bin/env bash
set -euo pipefail

# Validate SKILL.md structure for each changed skill directory.
# Reads skill directory names from stdin (one per line).

ERRORS=0

while IFS= read -r skill_dir; do
  [ -z "$skill_dir" ] && continue
  echo "::group::Validating $skill_dir"

  SKILL_FILE="$skill_dir/SKILL.md"

  # Check SKILL.md exists
  if [ ! -f "$SKILL_FILE" ]; then
    echo "::error file=$skill_dir::Missing SKILL.md"
    ERRORS=$((ERRORS + 1))
    echo "::endgroup::"
    continue
  fi

  # Check frontmatter delimiter
  if ! head -1 "$SKILL_FILE" | grep -q '^---$'; then
    echo "::error file=$SKILL_FILE::Missing YAML frontmatter (no opening ---)"
    ERRORS=$((ERRORS + 1))
    echo "::endgroup::"
    continue
  fi

  # Check closing frontmatter delimiter
  CLOSING=$(awk 'NR>1 && /^---$/ { print NR-1; exit }' "$SKILL_FILE")
  if [ -z "$CLOSING" ]; then
    echo "::error file=$SKILL_FILE::Missing closing frontmatter delimiter (---)"
    ERRORS=$((ERRORS + 1))
    echo "::endgroup::"
    continue
  fi

  # Extract frontmatter
  FRONTMATTER=$(sed -n '2,'"$((CLOSING))"'p' "$SKILL_FILE")

  # Check required fields
  for field in name description; do
    VALUE=$(echo "$FRONTMATTER" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -z "$VALUE" ]; then
      echo "::error file=$SKILL_FILE::Missing or empty required field '$field'"
      ERRORS=$((ERRORS + 1))
    fi
  done

  # Check that skill body has content after frontmatter
  BODY_START=$((CLOSING + 2))
  BODY=$(awk -v start="$BODY_START" 'NR>=start && /[^ ]/ { print; exit }' "$SKILL_FILE")
  if [ -z "$BODY" ]; then
    echo "::warning file=$SKILL_FILE::SKILL.md has no content after frontmatter"
  fi

  # Check for at least an H1 heading in the body
  if ! tail -n +"$BODY_START" "$SKILL_FILE" | grep -q '^# '; then
    echo "::warning file=$SKILL_FILE::SKILL.md missing H1 heading in body"
  fi

  # Validate arguments structure if present
  if echo "$FRONTMATTER" | grep -q '^arguments:'; then
    ARG_NAMES=$(echo "$FRONTMATTER" | grep '^\s*- name:' | sed 's/.*name:[[:space:]]*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -z "$ARG_NAMES" ]; then
      echo "::error file=$SKILL_FILE::arguments declared but no argument names found"
      ERRORS=$((ERRORS + 1))
    fi
  fi

  echo "::endgroup::"
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "::error::Found $ERRORS structure validation error(s)"
  exit 1
fi

echo "All skills passed structure validation"
