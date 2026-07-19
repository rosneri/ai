# Gating categories (crucial for merge)

What the user MUST understand to responsibly ship _this_ change. If they can't answer these, the PR
should not merge. The **base round** is built from this file, and the pass-marker / PR gate keys
**only** on these.

Choose the handful that are load-bearing for the specific change — never use all of them. Draw from
different categories each round so coverage widens. Type-2 (learning) subjects live in
[deepening-categories.md](deepening-categories.md) and never gate.

Format: `slug — one-line description.`

## How the change works

- mechanism — how the new code actually produces its effect; trace the path.
- control-flow — which branch runs when; what condition selects each path.
- data-shape — how the payload/schema/record changed and who reads it.
- guard-intent — is a given check real business logic or a type/null appeasement (rubber-stamp trap).
- behavior-delta — under a "refactor/chore" label, what behavior actually changed vs only moved.
- design-tradeoff — why this approach over the obvious alternative; what it ruled out.
- error-propagation — where a thrown/rejected error surfaces; who catches it and what the caller/user sees.
- dependency-behavior — what the called library/API actually does in the case relied on (throws? retries? returns null?).
- state-machine — which state transitions are legal now; which state can get stuck.

## What it touches

- blast-radius — what else this touches; callers, consumers, data downstream.
- downstream-consumer — who consumes this event/output and what breaks if it changes.
- contract-compat — why a field is optional / a change is back-compatible for in-flight data.
- data-lifecycle — migration, backfill, rollout, and how old data is handled.
- config-dependency — the env var/config/secret the change assumes, and what happens in an environment where it's absent.
- feature-flag — what runs with the flag off, on, and mid-rollout; behavior in the mixed state.
- cache-staleness — what's cached, when it's invalidated, and what can serve stale after this change.
- migration-order — deploy sequencing: what breaks if new code runs before the migration (or vice versa); the mixed-version window.

## What must hold

- invariant — what must stay true for this to be correct; what silently breaks it.
- domain-invariant — the business rule the code must preserve (money balances; one payout ↔ one row).
- idempotency-path — what makes a retry safe (or unsafe) end to end.
- concurrency — what if two of these race or run interleaved.
- ordering — what if messages/events arrive out of order.
- transaction-boundary — what's atomic here; which partial write is possible if it fails midway.
- precision-units — rounding, units, float vs integer cents; where conversion happens and what it can lose.
- time-handling — UTC vs local, DST, date boundaries, clock skew; which the new code assumes.

## When and where it runs

- trigger-path — what actually invokes this code (request, cron, queue, webhook, retry) and how often.
- rollout-mechanics — how this reaches production (flag, canary, big-bang) and what the kill switch is.
- environment-difference — what differs between local/staging/prod that changes this code's behavior.
- deploy-window — what happens to in-flight requests/jobs while old and new code coexist during deploy.

## How you'd verify it

- repro-verify — how to reproduce the original behavior by hand and confirm the change fixed it.
- manual-check — the one pre-merge check automation doesn't cover, and why it matters here.
- regression-surface — which existing tests should have caught the original bug, and why they didn't.

## What can go wrong

- failure-mode — what happens on error, retry, race, or bad data.
- edge-case — the input/timing/state it now handles, or newly breaks.
- open-edge — an edge case still untested or unhandled after this change.
- worst-case-bug — the nastiest bug this could introduce and how it'd manifest.
- money-correctness — where cents could be lost, double-counted, or mis-signed.
- security-access — auth, tenant-isolation, or access implications.
- pii-exposure — whether sensitive data is newly logged, returned, or crossed a boundary.
- rollback-safety — what happens if this is reverted after data has been written under it.
- observability — how you'd know in prod this is working or broken; the signal to watch.
- null-empty — what happens on null/undefined/empty-collection input at the new code's entry points.
- silent-failure — where an error is swallowed; what the user/system sees instead of a failure.
- input-validation — what unvalidated input can reach the new code; where the trust boundary sits.
- resource-leak — what's opened/allocated (connections, listeners, handles, subscriptions) and who closes it, including on the error path.
- perf-cost — the loop/query/allocation that got heavier; what this adds to the hot path.
- test-evidence — what the added/changed tests actually prove, and the gap they leave uncovered.
