---
name: watch-ci
description: Poll CI checks on a PR until they finish, reporting progress. Use when the user says "watch CI", "monitor CI", "wait for CI", "watch the build", "let me know when CI finishes", or wants to track CI check progress on a PR.
user_invocable: true
arguments:
  - name: pr
    description: PR number to watch. Defaults to the PR for the current branch.
    required: false
  - name: repo
    description: GitHub repo (owner/repo). Defaults to current repo.
    required: false
---

# Watch CI

Monitor CI checks on a PR, polling at regular intervals until all checks complete, then report the final result.

## Workflow

### 1. Resolve the PR number

If no PR number is provided, detect it from the current branch:

```bash
gh pr view --json number --jq '.number'
```

### 2. First poll — determine initial interval

Run the script once manually to get the initial recommended interval:

```bash
bash watch-ci/scripts/watch-ci.sh <pr-number> [repo]
```

The script outputs `RECOMMENDED_INTERVAL=<duration>` (e.g. `2m`, `5m`, `10m`) based on:

- **Historical CI duration** — average of the last 5 completed runs for the repo.
- **Elapsed time** — how long since monitoring started.

Read the `RECOMMENDED_INTERVAL` value from the output.

### 3. Start the loop with the recommended interval

```
/loop <interval> bash watch-ci/scripts/watch-ci.sh <pr-number> [repo]
```

The script exits `0` when all checks finish (pass or fail) and `1` while still pending. The loop handles the repeat automatically.

**Adjust the interval if it changes:** If the script's `RECOMMENDED_INTERVAL` differs from the current loop interval by more than 2 minutes, stop the loop and restart it with the new interval.

### 4. On completion

When the loop reports all checks finished:

- **All passed** — tell the user CI is green.
- **Any failed** — show the failed checks and suggest running `/ci-fix <pr-number>` to investigate.

## Interval heuristics

The script determines the poll interval dynamically:

| Scenario                               | Interval |
| -------------------------------------- | -------- |
| No historical data, elapsed < 5m       | 2m       |
| No historical data, elapsed 5–15m      | 5m       |
| No historical data, elapsed > 15m      | 10m      |
| Historical avg known, > 20m remaining  | 10m      |
| Historical avg known, 10–20m remaining | 5m       |
| Historical avg known, 3–10m remaining  | 3m       |
| Historical avg known, < 3m remaining   | 2m       |

## Rules

- This skill is read-only — do not modify files or make git operations.
- Always show the status table to the user after each poll.
- If the PR has no checks yet, wait and retry — checks may take a moment to appear after pushing.
- Do not poll more frequently than every 60 seconds to avoid API rate limits.
