#!/usr/bin/env bash
# Discovers Helix editor configuration and outputs a structured summary.
# Exit codes: 0 = config found, 1 = no config found

set -euo pipefail

found_config=false

# --- Helix XDG config ---
helix_config="${XDG_CONFIG_HOME:-$HOME/.config}/helix"
if [ -d "$helix_config" ]; then
  found_config=true
  echo "## Helix Config: $helix_config"
  echo ""

  # config.toml
  if [ -f "$helix_config/config.toml" ]; then
    echo "### config.toml"
    echo '```toml'
    cat "$helix_config/config.toml"
    echo '```'
    echo ""
  else
    echo "**config.toml:** not found (using defaults)"
    echo ""
  fi

  # languages.toml
  if [ -f "$helix_config/languages.toml" ]; then
    echo "### languages.toml"
    echo '```toml'
    cat "$helix_config/languages.toml"
    echo '```'
    echo ""
  fi

  # Custom themes
  if [ -d "$helix_config/themes" ]; then
    theme_files=$(find "$helix_config/themes" -name '*.toml' -type f 2>/dev/null | sort)
    if [ -n "$theme_files" ]; then
      echo "### Custom themes"
      echo ""
      echo "$theme_files" | while read -r f; do
        echo "- $(basename "$f" .toml)"
      done
      echo ""
    fi
  fi

  # Runtime queries (custom tree-sitter queries)
  if [ -d "$helix_config/runtime/queries" ]; then
    echo "### Custom runtime queries"
    echo ""
    find "$helix_config/runtime/queries" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | while read -r d; do
      lang=$(basename "$d")
      queries=$(find "$d" -name '*.scm' -type f 2>/dev/null | while read -r q; do basename "$q"; done | tr '\n' ', ' | sed 's/,$//')
      echo "- **$lang**: $queries"
    done
    echo ""
  fi

  # Directory structure
  echo "### Directory structure"
  echo '```'
  find "$helix_config" -maxdepth 3 -not -path '*/\.*' | head -40 | sed "s|$helix_config|helix|"
  echo '```'
fi

# --- Project-local .helix config ---
if [ -d ".helix" ]; then
  found_config=true
  echo ""
  echo "## Project-local config: .helix/"
  echo ""

  if [ -f ".helix/config.toml" ]; then
    echo "### .helix/config.toml"
    echo '```toml'
    cat ".helix/config.toml"
    echo '```'
    echo ""
  fi

  if [ -f ".helix/languages.toml" ]; then
    echo "### .helix/languages.toml"
    echo '```toml'
    cat ".helix/languages.toml"
    echo '```'
    echo ""
  fi
fi

# --- Helix version and health ---
if command -v hx &>/dev/null; then
  echo ""
  echo "## Helix version"
  hx --version
  echo ""
  echo "## Health check (summary)"
  echo '```'
  hx --health 2>&1 | head -30
  echo '```'
fi

if [ "$found_config" = false ]; then
  echo "NO_CONFIG_FOUND"
  exit 1
fi
