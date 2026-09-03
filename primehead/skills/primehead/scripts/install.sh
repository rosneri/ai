#!/usr/bin/env bash
# Install primehead from this plugin: link the wrapper into ~/.local/bin and make
# sure Headroom is present. Safe to re-run. Resolves its own location, so it
# works from a Claude Code plugin, a Prime Agent package, or a plain clone.
set -uo pipefail

NAME="primehead"
CLIENT="prime-agent"
CLIENT_HINT="npm install -g prime-agent"

BIN_DIR="${PRIMEHEAD_BIN_DIR:-$HOME/.local/bin}"

SELF="${BASH_SOURCE[0]}"
while [ -L "$SELF" ]; do
  link="$(readlink "$SELF")"
  case "$link" in
    /*) SELF="$link" ;;
    *)  SELF="$(cd "$(dirname "$SELF")" && pwd)/$link" ;;
  esac
done
SCRIPT_DIR="$(cd "$(dirname "$SELF")" && pwd)"
WRAPPER="$SCRIPT_DIR/$NAME"

if [ -t 1 ]; then
  C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_RED=$'\033[31m'; C_DIM=$'\033[2m'; C_OFF=$'\033[0m'
else
  C_GRN=""; C_YEL=""; C_RED=""; C_DIM=""; C_OFF=""
fi
ok()   { printf '%s\n' "  ${C_GRN}ok${C_OFF}    $*"; }
warn() { printf '%s\n' "  ${C_YEL}warn${C_OFF}  $*"; }
bad()  { printf '%s\n' "  ${C_RED}miss${C_OFF}  $*"; }

[ -f "$WRAPPER" ] || { printf '%s\n' "$NAME: wrapper not found at $WRAPPER" >&2; exit 1; }
chmod +x "$WRAPPER"

printf '\n%s install\n\n' "$NAME"

if command -v headroom >/dev/null 2>&1; then
  ok "headroom $(headroom --version 2>&1 | tr -d '\n')"
else
  printf '%s\n' "  ...   installing headroom-ai[all]"
  if command -v uv >/dev/null 2>&1; then
    uv tool install 'headroom-ai[all]' >/dev/null 2>&1 && ok "headroom installed (uv tool)"
  elif command -v pipx >/dev/null 2>&1; then
    pipx install 'headroom-ai[all]' >/dev/null 2>&1 && ok "headroom installed (pipx)"
  elif command -v pip3 >/dev/null 2>&1; then
    pip3 install --user 'headroom-ai[all]' >/dev/null 2>&1 && ok "headroom installed (pip3 --user)"
  fi
  command -v headroom >/dev/null 2>&1 \
    || bad "headroom install failed — run: uv tool install 'headroom-ai[all]'"
fi

if command -v "$CLIENT" >/dev/null 2>&1; then
  ok "$CLIENT $("$CLIENT" --version 2>&1 | tr -d '\n')"
else
  bad "$CLIENT not found — $CLIENT_HINT"
fi

mkdir -p "$BIN_DIR"
ln -sf "$WRAPPER" "$BIN_DIR/$NAME"
ok "linked $BIN_DIR/$NAME -> $WRAPPER"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) warn "$BIN_DIR is not on PATH — add: export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

printf '\n%s\n\n' "${C_DIM}Run '$NAME --$NAME-status' to see the routing decision.${C_OFF}"
