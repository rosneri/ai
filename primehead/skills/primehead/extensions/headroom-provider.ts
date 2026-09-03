import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// primehead — point Prime Agent's model providers at a local Headroom proxy.
//
// Prime Agent has no ANTHROPIC_BASE_URL / OPENAI_BASE_URL override: every
// provider passes the model catalog's own baseUrl to the SDK. The supported
// hooks are ~/.prime/agent/models.json (durable, global) and
// pi.registerProvider() from an extension (per run). primehead uses the
// extension so a dead proxy can never leak into a plain session.
//
// Loaded only by `primehead`, via `prime-agent -e <this file>`. Do not copy it
// into ~/.prime/agent/extensions/ — that directory auto-loads in every session.
//
// PRIMEHEAD_PROXY_URL   proxy origin, e.g. http://127.0.0.1:8787 (required)
// PRIMEHEAD_PROVIDERS   comma-separated provider names (default: anthropic)

export default function (pi: ExtensionAPI) {
  const raw = process.env.PRIMEHEAD_PROXY_URL?.trim();
  if (!raw) return; // no proxy chosen for this run: leave providers untouched

  const origin = raw.replace(/\/+$/, "");
  const providers = (process.env.PRIMEHEAD_PROVIDERS?.trim() || "anthropic")
    .split(",")
    .map((name) => name.trim())
    .filter(Boolean);

  for (const provider of providers) {
    // The Anthropic SDK appends /v1/messages to baseUrl, so it wants the bare
    // origin. OpenAI-compatible SDKs append /chat/completions, so they want /v1.
    const baseUrl = provider === "anthropic" ? origin : `${origin}/v1`;
    pi.registerProvider(provider, { baseUrl });
  }
}
