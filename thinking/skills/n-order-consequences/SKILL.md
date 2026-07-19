---
name: n-order-consequences
description: >
  Trace the second-, third-, and nth-order consequences of a decision, change, or plan — the
  effects of the effects — so thinking doesn't stop at the obvious first-order outcome. Use when
  the user asks "what are the consequences of X", "think this through", "second-order effects",
  "n order consequences", "what could this cause downstream", or before committing to a
  significant decision (technical, product, organizational, personal).
user_invocable: true
arguments:
  - name: description
    description: >
      What to apply the thinking to — a decision, change, plan, or situation, in the user's words.
      Optionally suffixed with a depth like "to 4 orders". If omitted, ask what decision or change
      to analyze.
    required: true
---

# N-Order Consequences

First-order thinking answers "what happens if I do X?" and stops. This skill forces the next
question, repeatedly: **"and then what?"** Each order's consequences become the inputs to the
next, until the chain stops producing insight. Most bad decisions look good at order 1; most of
their cost lives at orders 2 and 3.

## Step 1 — Explore the problem space first

Consequences of a half-understood action are fiction. Before tracing anything, actually
understand the subject:

- **Investigate what you can yourself.** If the decision touches something inspectable — a
  codebase, a repo, a config, a document, data — go read it. Map the real system: who calls
  what, where the money/data/users actually flow, what constraints already exist. Don't trace
  consequences through an imagined system when the real one is available.
- **Reconstruct the context**: what problem is this action solving, what has been tried before,
  what alternatives were on the table, and what does "success" mean to the person deciding?
- **Ask when you can't infer.** If load-bearing facts are missing — scale, who's affected,
  reversibility, timeline, what constraint is binding — ask **2–3 targeted questions** (via
  `AskUserQuestion` when options are enumerable, free-form otherwise). Ask only what changes the
  analysis; don't interrogate for completeness.

Then pin the frame and say it back:

- **The action** — what is actually being done (not the hoped-for outcome).
- **The system it lands in** — who and what it touches: people, code, money, incentives, time.
- **Depth** — default to **5 orders**; honor an explicit "to N orders" in the argument. If the
  chains genuinely dry up earlier, say so and stop rather than padding orders with restatements —
  a forced 5th order is worse than an honest 3rd.

## Step 2 — Trace the orders

Build the chain order by order. For each order:

1. Take every consequence from the previous order (order 0 = the action itself).
2. For each, ask **"and then what?"** across these lenses — use the ones that fit, don't force all:
   - **Behavior** — how do people/systems *adapt* to the new state? Adaptation, not the state
     itself, is where second-order effects come from (incentives, workarounds, Goodhart effects).
   - **Time** — what compounds, decays, or only shows up later? (Tech debt interest, trust
     erosion, network effects.)
   - **Second parties** — competitors, teammates, users, dependents reacting to the change.
   - **Feedback loops** — does a consequence loop back and amplify or dampen the original action?
     Name loops explicitly; they dominate at higher orders.
   - **Irreversibility** — which consequences are one-way doors?
3. Prune honestly: keep a branch only if it's **plausible and load-bearing**. N-order thinking
   dies by combinatorial explosion; three sharp chains beat thirty speculative ones. Say what you
   pruned and why.

Mark each consequence with a rough **likelihood** (likely / plausible / speculative) and
**valence** (good / bad / mixed). Don't only hunt downsides — second-order *benefits* (learning
effects, optionality, trust built) are equally invisible to first-order thinking.

## Step 3 — Present the map

Output, in order:

1. **The action** (one line).
2. **The chains** — each significant chain as an indented cascade, e.g.:
   ```
   1st: Ship the feature behind a manual toggle
     2nd: Support becomes the toggle's gatekeeper → ticket queue grows
       3rd: Support hires scale with feature adoption — cost scales linearly with success
     2nd: Engineers stop building self-serve config ("support handles it")
       3rd: Product develops a structural dependency on human ops
   ```
3. **What first-order thinking would have missed** — 2–4 bullets naming the non-obvious effects
   the analysis surfaced; this is the payoff, lead the summary with it.
4. **Dominant loop or risk** — the single feedback loop or irreversible consequence that should
   most influence the decision.
5. **Cheap mitigations** — if a bad higher-order chain has an inexpensive early counter (a
   reversible variant, a tripwire metric, a sunset clause), name it. Don't redesign the plan —
   that's the user's call.

Be concrete and falsifiable: "support queue grows because every toggle flip is a ticket" — not
"there may be operational implications". If a chain depends on an assumption, state the
assumption inline so the user can reject the chain by rejecting the assumption.
