---
name: claudehead
description: >
  Installs, explains, or diagnoses claudehead: a launcher that runs Claude Code through the Headroom
  compression proxy only when that proxy passes a real health check, and through plain claude when it
  does not. Use when the user says "install claudehead", "run claude through headroom", "why is my
  session not using headroom", "the proxy is down", or asks about headroom routing, the /readyz gate,
  or claudehead's flags and environment variables.
user_invocable: true
---

# claudehead

`scripts/claudehead` launches Claude Code through a local [Headroom](https://github.com/headroomlabs-ai/headroom)
proxy when the proxy is **provably healthy**, and through plain `claude` when it is not. Headroom
compresses tool output, logs, and file contents before they reach the model. It also sits in the
request path, so an unhealthy proxy would break the session — the gate exists to make that impossible.

Upstream: [rosneri/claudehead](https://github.com/rosneri/claudehead).

## Install

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/claudehead/scripts/install.sh"
```

Outside Claude Code, run `scripts/install.sh` from this skill's directory. It installs
`headroom-ai[all]` if missing (`uv tool install`, then `pipx`, then `pip3 --user`) and links
`claudehead` into `~/.local/bin`. Then use `claudehead` anywhere you would use `claude`.

## The gate

Headroom exposes three probes, and the difference between them is the whole point:

| Endpoint  | Behaviour                                                     |
| --------- | ------------------------------------------------------------- |
| `/livez`  | Process liveness only                                         |
| `/readyz` | **503 until every subsystem is up**, 200 when ready           |
| `/health` | Always 200 — readiness lives in the body, not the status code |

`claudehead` probes `/readyz`, then `/health`. Healthy means HTTP 200 **and** a body reporting
`"service": "headroom-proxy"` **and** `"ready": true`. Four states, four actions:

| State      | Meaning                          | Action                                    |
| ---------- | -------------------------------- | ----------------------------------------- |
| `healthy`  | Ready proxy answering            | `headroom wrap claude --no-proxy`         |
| `starting` | Answering but `ready: false`     | Wait `CLAUDEHEAD_READY_TIMEOUT`, re-probe |
| `foreign`  | Port answers but is not headroom | **Never bind over it** — plain `claude`   |
| `closed`   | Nothing listening                | Start a detached proxy, wait, re-probe    |

`foreign` matters more than it looks: without it the wrapper would try to bind an occupied port,
burn the whole timeout, and bury `address already in use` in a log file.

The proxy is started detached, so it outlives the session — cold start ~20s, warm reuse ~0.2s.

## Commands

```bash
claudehead --claudehead-status        # install + proxy health + the routing decision
claudehead --claudehead-stop          # stop the proxy claudehead started
claudehead --claudehead-logs          # tail -f the proxy log
claudehead --claudehead-plain [args]  # force plain claude, skip the probe
claudehead --claudehead-headroom [..] # require headroom: fail instead of falling back
claudehead --claudehead-port N [args] # use a different proxy port for this run
claudehead --claudehead-unwrap        # undo headroom's durable setup (MCP servers, hooks)
```

Every other argument passes through to Claude Code untouched.

## Diagnosing

Start with `claudehead --claudehead-status`: it prints the probe URL, the resolved `headroom` and
`claude` binaries, the proxy state, and the decision. Then:

- **"using plain claude — port N answers ... but is not a headroom proxy"** — something else owns the
  port. Find it (`lsof -nP -iTCP:8787 -sTCP:LISTEN`) or pick another port with `CLAUDEHEAD_PORT`.
- **"proxy never became ready"** — read `~/.local/state/claudehead/proxy-<port>.log`, or
  `claudehead --claudehead-logs`.
- **`/rc` or `/remote-control` missing** — Claude Code disables it whenever `ANTHROPIC_BASE_URL` is
  custom. Client-side gate; use `--claudehead-plain` for those sessions.

## Configuration

| Variable                   | Default     | Purpose                                              |
| -------------------------- | ----------- | ---------------------------------------------------- |
| `CLAUDEHEAD_PORT`          | `8787`      | Proxy port                                           |
| `CLAUDEHEAD_HOST`          | `127.0.0.1` | Proxy host                                           |
| `CLAUDEHEAD_MODE`          | `auto`      | `auto` \| `headroom` \| `plain`                      |
| `CLAUDEHEAD_READY_TIMEOUT` | `45`        | Seconds to wait for a cold proxy                     |
| `CLAUDEHEAD_PROBE_TIMEOUT` | `2`         | Seconds per health request                           |
| `CLAUDEHEAD_TOOL_SEARCH`   | `true`      | Preserve tool deferral (`true\|auto\|auto:N\|false`) |
| `CLAUDEHEAD_1M`            | `0`         | `1` keeps the 1M context window                      |
| `CLAUDEHEAD_NO_START`      | `0`         | `1` only reuses a running proxy                      |
| `CLAUDEHEAD_QUIET`         | `0`         | `1` suppresses the routing line                      |
| `CLAUDEHEAD_WRAP_ARGS`     | —           | Extra args for `headroom wrap claude`                |

A custom `ANTHROPIC_BASE_URL` costs two things by default: tool deferral turns off (claudehead passes
`--tool-search true` to keep it) and the 1M context window caps to 200k (opt back in with
`CLAUDEHEAD_1M=1`, which pins `ANTHROPIC_MODEL` on the launched process).

## Headroom writes durable global config

Headroom's behaviour, not claudehead's, but it surprises people: the first `headroom wrap claude`
registers the `headroom` and `serena` MCP servers into `~/.claude.json` at **user scope**, so they
load in every later session including plain ones. It also installs a `SessionStart` selfheal hook
into the launch directory's `.claude/settings.local.json`.

```bash
CLAUDEHEAD_WRAP_ARGS=--no-mcp claudehead   # never register them
claudehead --claudehead-unwrap             # remove registrations and hooks
```

`--no-mcp` costs the retrieve tool, which makes Headroom's compression markers unactionable.
