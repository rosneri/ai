#!/usr/bin/env bash
set -euo pipefail

# Verify that every changed skill directory has an entry in README.md.
# Reads skill directory names from stdin (one per line).

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
README="$ROOT/README.md"
errors=0

while IFS= read -r skill; do
  [ -z "$skill" ] && continue

  if ! grep -q "(./${skill})" "$README"; then
    echo "  ✗ Skill '${skill}' is not listed in README.md"
    errors=$((errors + 1))
  fi
done

if [ "$errors" -gt 0 ]; then
  echo ""
  echo "${errors} skill(s) missing from README.md — add them to the Skills table."
  exit 1
else
  echo "All changed skills are listed in README.md"
fi
