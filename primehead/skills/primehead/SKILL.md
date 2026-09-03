---
name: primehead
description: >
  Installs, explains, or diagnoses primehead: a launcher that runs Prime Agent through the Headroom
  compression proxy only when that proxy passes a real health check, and through plain prime-agent
  when it does not. Use when the user says "install primehead", "run prime-agent through headroom",
  "why is my prime session not compressed", or asks about headroom routing for Prime Agent, the
  /readyz gate, provider base URLs, or primehead's flags and environment variables.
user_invocable: true
---

# primehead

`scripts/primehead` launches Prime Agent through a local [Headroom](https://github.com/headroomlabs-ai/headroom)
proxy when the proxy is **provably healthy**, and through plain `prime-agent` when it is not. Same
health gate as the `claudehead` plugin, different plumbing — Prime Agent forces two changes.

## Why this is not `headroom wrap`

1. **`headroom wrap` has no prime-agent target.** Its subcommands are one hardcoded command per tool
   (aider, claude, cline, codex … zcode) with no generic mode. Headroom's own help says to use
   `headroom proxy` plus your own env for anything else, so primehead drives the proxy directly.
2. **Prime Agent ignores `ANTHROPIC_BASE_URL`.** Every provider passes the model catalog's `baseUrl`
   to the SDK, so the env var the vendored Anthropic SDK would read is dead code. There are exactly
   two supported hooks: `~/.prime/agent/models.json` → `providers.<name>.baseUrl` (durable, global),
   or `pi.registerProvider(name, { baseUrl })` from an extension (per run).

primehead uses the **extension** hook (`extensions/headroom-provider.ts`, loaded with
`prime-agent -e`). Routing then lives in one process for one run: a dead proxy can never leak into a
plain session, and a killed wrapper leaves nothing to clean up. The `models.json` route would mean
rewriting global config on every launch and restoring it on exit — one crash and every future
session points at a dead port.

Keep the extension where it is. Anything in `~/.prime/agent/extensions/` auto-loads in **every**
session, which is exactly what this design avoids.

## Install

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/primehead/scripts/install.sh"
```

Outside Claude Code, run `scripts/install.sh` from this skill's directory. It installs
`headroom-ai[all]` if missing and links `primehead` into `~/.local/bin`. Then use `primehead`
anywhere you would use `prime-agent`.

## The gate

Healthy means HTTP 200 on `/readyz` (or `/health`) **and** a body reporting
`"service": "headroom-proxy"` **and** `"ready": true`. `/readyz` 503s until every subsystem is up;
`/health` always returns 200, so there the body is the only signal.

| State      | Meaning                          | Action                                       |
| ---------- | -------------------------------- | -------------------------------------------- |
| `healthy`  | Ready proxy answering            | `prime-agent -e headroom-provider.ts`        |
| `starting` | Answering but `ready: false`     | Wait `PRIMEHEAD_READY_TIMEOUT`, re-probe     |
| `foreign`  | Port answers but is not headroom | **Never bind over it** — plain `prime-agent` |
| `closed`   | Nothing listening                | Start a detached proxy, wait, re-probe       |

Port `8787` is also `claudehead`'s default, so a healthy proxy started by either wrapper is reused
by the other.

## Commands

```bash
primehead --primehead-status        # install + proxy health + the routing decision
primehead --primehead-stop          # stop the proxy primehead started
primehead --primehead-logs          # tail -f the proxy log
primehead --primehead-plain [args]  # force plain prime-agent, skip the probe
primehead --primehead-headroom [..] # require headroom: fail instead of falling back
primehead --primehead-port N [args] # use a different proxy port for this run
```

Everything else passes through to Prime Agent untouched. Management subcommands (`model`, `session`,
`mcp`, `package`, `status`, `doctor`, `agents`, …) always run plain: no model traffic, nothing to
compress.

## Diagnosing

`primehead --primehead-status` prints the probe URL, the extension path, the resolved binaries, the
proxy state, and the decision.

- **"port N answers … but is not a headroom proxy"** — something else owns the port. Find it with
  `lsof -nP -iTCP:8787 -sTCP:LISTEN`, or set `PRIMEHEAD_PORT`.
- **"proxy never became ready"** — read the log with `primehead --primehead-logs`.
- **Routing silently not applied** — confirm requests reach the proxy:
  `curl -s 127.0.0.1:8787/stats | jq .summary.api_requests` before and after a prompt.

## Configuration

| Variable                  | Default     | Purpose                                |
| ------------------------- | ----------- | -------------------------------------- |
| `PRIMEHEAD_PORT`          | `8787`      | Proxy port (shared with claudehead)    |
| `PRIMEHEAD_HOST`          | `127.0.0.1` | Proxy host                             |
| `PRIMEHEAD_MODE`          | `auto`      | `auto` \| `headroom` \| `plain`        |
| `PRIMEHEAD_PROVIDERS`     | `anthropic` | Providers to re-point, comma-separated |
| `PRIMEHEAD_READY_TIMEOUT` | `45`        | Seconds to wait for a cold proxy       |
| `PRIMEHEAD_PROBE_TIMEOUT` | `2`         | Seconds per health request             |
| `PRIMEHEAD_NO_START`      | `0`         | `1` only reuses a running proxy        |
| `PRIMEHEAD_QUIET`         | `0`         | `1` suppresses the routing line        |
| `PRIMEHEAD_EXTENSION`     | —           | Override the provider extension path   |

`baseUrl` shape differs per provider: the Anthropic SDK appends `/v1/messages` to a bare origin,
OpenAI-compatible SDKs append `/chat/completions` to a `/v1` base. The extension handles both
(`anthropic` → origin, everything else → origin + `/v1`). Gemini and Vertex shapes are not wired up.

## Worth knowing

- **OAuth works.** Prime Agent's Anthropic OAuth path also honours the overridden `baseUrl` and sends
  `Authorization: Bearer`; Headroom forwards the client's own credentials upstream.
- **Headroom labels the traffic `claude-code`**, because Prime Agent sends the `claude-cli`
  user-agent and `claude-code-*` beta headers on the OAuth path. Cosmetic, and it means the requests
  get Headroom's tuned coding profile instead of an unknown-agent default.
- **Nothing durable is written**: no `models.json`, no global extension, no MCP registration.
