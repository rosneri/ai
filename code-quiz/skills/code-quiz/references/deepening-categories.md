# Deepening categories (learning & growth)

Subjects that build the mental model to _participate_ — the purpose, architecture, theory, and
evolution behind the work. Used for the **optional deepen rounds** after the verdict (Step 7). These
are for learning and improving; they **never gate** and never touch the pass-marker.

Choose the handful that fit the specific change, and draw from different categories each round so
each "run again" widens coverage instead of repeating. Merge-blocking subjects live in
[gating-categories.md](gating-categories.md).

Format: `slug — one-line description.`

## Why this work exists

- origin-pain — the real product/user pain that triggered this change.
- cost-of-inaction — what not doing it costs: the incident, stuck money, toil, risk.
- why-now — what changed to make this worth doing at this moment.
- stakeholder — who feels the consequence; which team owns it downstream.
- prior-attempt — what earlier fix/workaround this replaces and why that fell short.
- incident-history — the past incident/outage in this area that shaped how this was built.
- product-metric — the business metric this should move, and how you'd measure that it did.

## Design & architecture

- layer-placement — why the code lives in this module/layer and not another.
- pattern-name — the named pattern this instantiates (adapter/port, producer/consumer, saga, repo).
- rejected-alternative — a plausible design not taken, and the reason.
- seam — what boundary this introduced or removed; where the new cut is.
- coupling — what got coupled or decoupled, and whether that's good here.
- build-vs-reuse — why a new dependency, or why hand-rolled instead of reusing one.
- abstraction-level — is this the right altitude, or over/under-abstracted for the need.
- api-surface — what the public/interface change commits future callers to.
- boundary-ownership — why this concern belongs to this domain/owner and not the caller.
- naming-semantics — what the chosen names promise, and where they could mislead a reader.
- api-ergonomics — how it feels to consume this interface; how misuse-resistant it is.
- cross-cutting — how the change interacts with the cross-cutting layers (logging, auth, retries, middleware, error handling).

## Tradeoffs & judgment

- what-traded — what was given up (perf↔clarity, consistency↔availability, latency↔cost).
- tolerated-failure — the failure mode the design deliberately accepts as acceptable.
- scaling-ceiling — the load/size/edge at which this approach stops working.
- reversibility — how expensive it is to undo this decision later.
- default-choice — why the chosen default (fail-open/closed, sync/async, eager/lazy) fits here.
- consistency-model — strong vs eventual, and what the choice costs the reader.
- security-threat-model — who the attacker is here; which vectors this defends and which it newly opens.
- capacity-cost — the infra/cost implication at projected growth; what gets expensive first.
- testing-strategy — why this test shape (unit/integration/e2e) fits, and what's deliberately left untested.

## Theory & concepts

- cs-concept — the underlying idea: idempotency, index selectivity, isolation level, backpressure.
- domain-concept — the business idea (flow-of-funds, holdback, clawback, double-entry, availability).
- delivery-semantics — at-least-once vs exactly-once; what dedup this needs.
- consistency-property — monotonicity, ordering, convergence the design must preserve.
- correctness-proof — the argument for why this is right, not just that it passes tests.
- math-model — the formula/accounting identity the code encodes and why it holds.
- migration-pattern — expand/contract, dual-write, backfill-then-cutover; which pattern this is and why.
- performance-model — where the time actually goes; the big-O plus the constant factors that dominate.
- caching-theory — invalidation strategy, TTL vs event-driven, cold-start and thundering-herd behavior.

## Systems thinking

- distributed-failure — partial failure across services and how it's recovered.
- generalization — where else this pattern applies in the codebase.
- backpressure-flow — how load propagates through this path; where queues grow when a consumer slows.
- operational-runbook — what on-call does when this misbehaves; the manual remediation and its cost.

## Evolution & maintenance

- next-change — the change this enables, or blocks.
- debt-delta — technical debt added or paid down.
- future-reader — what a maintainer in 6 months needs that isn't obvious from the code.
- requirement-shift — what has to move if load 10×'s or a related feature ships.
- deprecation-path — how the old thing gets retired now that this exists.
- data-model-evolution — what today's schema shape makes easy or hard for the next change to it.
- team-convention — the codebase convention this follows or breaks, and the reason the convention exists.

## People & process

- review-focus — what a reviewer of this diff should scrutinize hardest, and why.
- knowledge-silo — who else understands this area; what the bus factor is after this change.
- communication — who must be told before/after this ships (support, docs, another team) and what they need.

## Product & users

- user-visible — what the end user actually sees change, if anything.
- edge-user — the user segment/workflow this affects most (or breaks first).
- support-impact — the tickets this creates or eliminates; what support needs to know.

## Craft & readability

- readability — what makes this code easy or hard to read cold; the part a newcomer stumbles on.
- error-message-quality — what the errors/logs tell the person debugging at 3am; are they actionable.
- idiom — the language/framework idiom used here, and its known footguns.

## History & context

- code-archaeology — what the git history of this area reveals; why the surrounding code looks the way it does.
- industry-history — how this class of problem was solved before; what shift made this approach viable.

## First principles

- clean-slate — rebuilt from scratch today, what would differ.
- load-bearing-assumption — the assumption that, if false, breaks the whole approach.
- steelman-opposite — the strongest case for the design that was NOT chosen.
- minimal-version — the smallest change that would have solved the core problem.
- organizational-shape — how team/ownership structure shaped this design (Conway's law in this diff).
