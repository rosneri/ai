#!/usr/bin/env bash
# Discovers Neovim/Vim configuration and outputs a structured summary.
# Exit codes: 0 = config found, 1 = no config found

set -euo pipefail

found_config=false

# --- Neovim XDG config ---
nvim_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
if [ -d "$nvim_config" ]; then
  found_config=true
  echo "## Neovim Config: $nvim_config"
  echo ""

  # Detect distribution / framework
  for marker in lazyvim.json .lazyvim.json lua/lazyvim; do
    if [ -e "$nvim_config/$marker" ]; then
      echo "**Distribution:** LazyVim"
      break
    fi
  done
  if [ -d "$nvim_config/lua/astronvim" ] || [ -f "$nvim_config/.astro" ]; then
    echo "**Distribution:** AstroNvim"
  fi
  if [ -d "$nvim_config/lua/nvchad" ] || [ -f "$nvim_config/lua/chadrc.lua" ]; then
    echo "**Distribution:** NvChad"
  fi

  # Detect plugin manager
  if [ -f "$nvim_config/lazy-lock.json" ]; then
    echo "**Plugin manager:** lazy.nvim"
  elif grep -rql "packer" "$nvim_config" 2>/dev/null | head -1 >/dev/null 2>&1; then
    echo "**Plugin manager:** packer.nvim"
  elif grep -rql "vim-plug\|call plug#" "$nvim_config" 2>/dev/null | head -1 >/dev/null 2>&1; then
    echo "**Plugin manager:** vim-plug"
  elif [ -d "$nvim_config/pack" ]; then
    echo "**Plugin manager:** native packages (:help packages)"
  fi
  echo ""

  # Init file
  for init in init.lua init.vim; do
    if [ -f "$nvim_config/$init" ]; then
      echo "**Init file:** $init"
      echo '```'
      head -80 "$nvim_config/$init"
      echo '```'
      echo ""
      break
    fi
  done

  # lazy-lock.json → plugin list
  if [ -f "$nvim_config/lazy-lock.json" ]; then
    echo "### Installed plugins (from lazy-lock.json)"
    echo ""
    # Extract plugin names sorted alphabetically
    grep -oE '"[^"]+":' "$nvim_config/lazy-lock.json" | tr -d '":' | sort
    echo ""
  fi

  # Lua plugin specs (lua/plugins/)
  if [ -d "$nvim_config/lua/plugins" ]; then
    echo "### Plugin spec files (lua/plugins/)"
    echo ""
    find "$nvim_config/lua/plugins" -name '*.lua' -type f | sort | while read -r f; do
      echo "- $(basename "$f")"
    done
    echo ""
  fi

  # LSP servers configured
  echo "### LSP configuration hints"
  echo ""
  grep -rh "lspconfig\.\|ensure_installed\|mason" "$nvim_config" --include='*.lua' 2>/dev/null \
    | grep -v "^--" \
    | head -30 || echo "(no LSP config lines found)"
  echo ""

  # Keymaps
  keymap_files=$(find "$nvim_config" -name '*.lua' -type f -exec grep -l "vim.keymap\|map(" {} \; 2>/dev/null | head -5)
  if [ -n "$keymap_files" ]; then
    echo "### Files with custom keymaps"
    echo ""
    echo "$keymap_files" | while read -r f; do
      echo "- $f"
    done
    echo ""
  fi

  # Tree structure (depth 3)
  echo "### Directory structure"
  echo '```'
  find "$nvim_config" -maxdepth 3 -not -path '*/\.*' -not -path '*/pack/*' | head -60 | sed "s|$nvim_config|nvim|"
  echo '```'
fi

# --- Legacy ~/.vimrc / ~/.vim ---
if [ -f "$HOME/.vimrc" ]; then
  found_config=true
  echo ""
  echo "## Legacy Vim Config: ~/.vimrc"
  echo ""
  echo '```vim'
  head -80 "$HOME/.vimrc"
  echo '```'
fi

if [ -d "$HOME/.vim" ]; then
  found_config=true
  echo ""
  echo "## Legacy Vim Directory: ~/.vim"
  echo '```'
  find "$HOME/.vim" -maxdepth 2 -not -path '*/\.*' | head -40
  echo '```'
fi

# --- Neovim version ---
if command -v nvim &>/dev/null; then
  echo ""
  echo "## Neovim version"
  nvim --version | head -3
elif command -v vim &>/dev/null; then
  echo ""
  echo "## Vim version"
  vim --version | head -3
fi

if [ "$found_config" = false ]; then
  echo "NO_CONFIG_FOUND"
  exit 1
fi
