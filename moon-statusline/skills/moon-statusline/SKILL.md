---
name: moon-statusline
description: >
  Installs or explains the moon-statusline: a two-line Claude Code status line for moon monorepos
  showing model, moon project and deploy target, worktree, git state, PR, context bar, cost, lines
  changed, rate limits, and prompt cache. Use when the user says "install the moon statusline",
  "set up statusline", "status bar", or asks what a segment of the status line means.
user_invocable: true
---

# moon-statusline

`statusline.py` reads the status line JSON payload on stdin and prints two lines:

1. **Identity**: `model·effort ⚡ · project:target · ⑂ worktree · on branch +staged ~dirty · #pr`
2. **Budget**: `████░░░░ 42%/200k │ $1.23 12m04s │ +120/-8 │ 5h 30% 7d 12% │ cache warm 85%`

The moon project is the nearest `moon.pkl` walking up from the cwd (honouring a declared `id`);
the target badge comes from its tags (`modal`, `cloud-run` → `run`, `cloud-functions` → `fn`,
`firebase-hosting` → `hosting`). Git state is cached 5s per session.

## Install

Point `statusLine` in `~/.claude/settings.json` at the script:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ${CLAUDE_PLUGIN_ROOT}/skills/moon-statusline/statusline.py",
    "padding": 1
  }
}
```

If the user already has a wrapper script as `statusLine.command`, keep it and make the wrapper pipe
the payload into `statusline.py` instead (e.g. via `STATUSLINE_IMPL`). Do not replace a wrapper
that feeds other hooks.

## Options (env vars)

| Var                        | Effect                                                           |
| -------------------------- | ---------------------------------------------------------------- |
| `STATUSLINE_BAR_WIDTH`     | context bar width in characters (default 12)                     |
| `STATUSLINE_GUARD_FILE`    | file relative to project root, checked only in worktree sessions |
| `STATUSLINE_GUARD_PATTERN` | regex the guard file must match                                  |
| `STATUSLINE_GUARD_LABEL`   | label shown when the guard is unsatisfied (default `unguarded`)  |

The guard flags a worktree missing its local override (e.g. `.botika.local.pkl` without an
isolated inngest port), so the user notices before backing services collide.
