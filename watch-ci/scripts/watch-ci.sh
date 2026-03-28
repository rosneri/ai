#!/usr/bin/env bash
# Poll CI check statuses for a PR and output a summary table.
# Usage: bash watch-ci.sh <pr-number> [repo]
# Exit codes: 0 = all checks finished, 1 = checks still pending, 2 = error
# Outputs RECOMMENDED_INTERVAL=<duration> for dynamic poll timing.

set -euo pipefail

PR="${1:?Usage: watch-ci.sh <pr-number> [repo]}"
REPO_FLAG=""
if [ -n "${2:-}" ]; then
  REPO_FLAG="--repo $2"
fi

STATE_FILE="/tmp/watch-ci-${PR}.state"

# --- Timing: track when we started watching ---
if [ ! -f "$STATE_FILE" ]; then
  date +%s > "$STATE_FILE"
fi
WATCH_START=$(cat "$STATE_FILE")
NOW_EPOCH=$(date +%s)
ELAPSED_SEC=$(( NOW_EPOCH - WATCH_START ))
ELAPSED_MIN=$(( ELAPSED_SEC / 60 ))

# --- Fetch historical CI run duration (average of last 5 completed runs) ---
AVG_DURATION_MIN=0
HIST_JSON=$(gh run list $REPO_FLAG --limit 5 --status completed \
  --json createdAt,updatedAt 2>/dev/null) || HIST_JSON="[]"
if [ "$HIST_JSON" != "[]" ] && [ "$(echo "$HIST_JSON" | jq 'length')" -gt 0 ]; then
  AVG_DURATION_SEC=$(echo "$HIST_JSON" | jq '
    [ .[] |
      ( (.updatedAt | sub("\\.[0-9]+"; "") | sub("Z$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime) -
        (.createdAt | sub("\\.[0-9]+"; "") | sub("Z$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime) )
    ] | if length > 0 then (add / length | floor) else 0 end
  ' 2>/dev/null) || AVG_DURATION_SEC=0
  AVG_DURATION_MIN=$(( AVG_DURATION_SEC / 60 ))
fi

# --- Recommend poll interval ---
recommend_interval() {
  local elapsed=$1
  local avg_dur=$2

  if [ "$avg_dur" -gt 0 ]; then
    local remaining=$(( avg_dur - elapsed ))
    if [ "$remaining" -le 3 ]; then
      echo "2m"   # almost done
    elif [ "$remaining" -le 10 ]; then
      echo "3m"
    elif [ "$remaining" -le 20 ]; then
      echo "5m"
    else
      echo "10m"  # long way to go
    fi
  else
    # no historical data — use elapsed-based heuristic
    if [ "$elapsed" -lt 5 ]; then
      echo "2m"
    elif [ "$elapsed" -lt 15 ]; then
      echo "5m"
    else
      echo "10m"
    fi
  fi
}

JSON=$(gh pr view "$PR" $REPO_FLAG --json statusCheckRollup,state,title,url \
  --jq '{
    title: .title,
    url: .url,
    state: .state,
    checks: [
      .statusCheckRollup[] | {
        name: (.name // .context // "unknown"),
        status: .status,
        conclusion: .conclusion,
        state: .state,
        detailsUrl: (.detailsUrl // .targetUrl // "")
      }
    ]
  }' 2>/dev/null) || {
  echo "ERROR: Failed to fetch PR #$PR. Is gh authenticated?" >&2
  exit 2
}

TITLE=$(echo "$JSON" | jq -r '.title')
URL=$(echo "$JSON" | jq -r '.url')
TOTAL=$(echo "$JSON" | jq '.checks | length')

if [ "$TOTAL" -eq 0 ]; then
  echo "PR #$PR: $TITLE"
  echo "No CI checks found yet."
  echo ""
  echo "RECOMMENDED_INTERVAL=2m"
  exit 1
fi

# Classify each check
PASSED=$(echo "$JSON" | jq '[.checks[] | select(.conclusion == "SUCCESS" or .conclusion == "NEUTRAL" or .conclusion == "SKIPPED" or .state == "SUCCESS")] | length')
FAILED=$(echo "$JSON" | jq '[.checks[] | select(.conclusion == "FAILURE" or .conclusion == "CANCELLED" or .conclusion == "TIMED_OUT" or .conclusion == "ACTION_REQUIRED" or .state == "FAILURE" or .state == "ERROR")] | length')
PENDING=$(echo "$JSON" | jq '[.checks[] | select(.status == "IN_PROGRESS" or .status == "QUEUED" or .status == "PENDING" or .status == "WAITING" or .state == "PENDING" or (.conclusion == null and .state == null) or .conclusion == "" or .state == "")] | length')

# Timestamp
NOW=$(date '+%H:%M:%S')

INTERVAL=$(recommend_interval "$ELAPSED_MIN" "$AVG_DURATION_MIN")

echo "## CI Status for PR #$PR — $NOW"
echo ""
echo "**$TITLE**"
echo "$URL"
echo ""
echo "| Total | Passed | Failed | Pending |"
echo "|-------|--------|--------|---------|"
echo "| $TOTAL | $PASSED | $FAILED | $PENDING |"
echo ""

if [ "$AVG_DURATION_MIN" -gt 0 ]; then
  echo "_Elapsed: ${ELAPSED_MIN}m — Avg CI duration: ${AVG_DURATION_MIN}m — Next poll: ${INTERVAL}_"
else
  echo "_Elapsed: ${ELAPSED_MIN}m — Next poll: ${INTERVAL}_"
fi
echo ""

# Show failed checks
FAILED_LIST=$(echo "$JSON" | jq -r '.checks[] | select(.conclusion == "FAILURE" or .conclusion == "CANCELLED" or .conclusion == "TIMED_OUT" or .conclusion == "ACTION_REQUIRED" or .state == "FAILURE" or .state == "ERROR") | "- **\(.name)** — \(.conclusion // .state) \(if .detailsUrl != "" then .detailsUrl else "" end)"')
if [ -n "$FAILED_LIST" ]; then
  echo "### Failed"
  echo "$FAILED_LIST"
  echo ""
fi

# Show pending checks
PENDING_LIST=$(echo "$JSON" | jq -r '.checks[] | select(.status == "IN_PROGRESS" or .status == "QUEUED" or .status == "PENDING" or .status == "WAITING" or .state == "PENDING" or (.conclusion == null and .state == null) or .conclusion == "" or .state == "") | "- \(.name) — \(.status // .state // "waiting")"')
if [ -n "$PENDING_LIST" ]; then
  echo "### Pending"
  echo "$PENDING_LIST"
  echo ""
fi

# Determine overall status
if [ "$PENDING" -gt 0 ]; then
  echo "---"
  echo "**Status: IN PROGRESS** ($PASSED/$TOTAL passed, $PENDING pending)"
  echo ""
  echo "RECOMMENDED_INTERVAL=$INTERVAL"
  exit 1
elif [ "$FAILED" -gt 0 ]; then
  echo "---"
  echo "**Status: FAILED** ($FAILED/$TOTAL checks failed)"
  rm -f "$STATE_FILE"
  exit 0
else
  echo "---"
  echo "**Status: ALL PASSED**"
  rm -f "$STATE_FILE"
  exit 0
fi
