#!/usr/bin/env bash
# PreToolUse gate: block opening a PR until the code-quiz has been passed for the current HEAD.
#
# Fires for both PR-open paths:
#   - CLI:  a Bash call running `gh pr create` / `gh pr ready`
#   - MCP:  any tool named `*create_pull_request*` (e.g. GitHub MCP)
#
# The code-quiz skill writes `<git-dir>/code-quiz-passed-<HEAD-sha>` when the user passes. This gate
# allows the PR only when that marker exists for the exact commit being shipped — new commits after
# passing re-lock the gate (understanding must match the code being shipped).
#
# Fail-open by design: any uncertainty (bad input, non-git dir, git failure) allows the tool. This
# hook runs on every Bash call, and it only guards laziness — so blocking legit work on an error
# costs more than a rare let-through. Never exits non-zero.

input=$(cat)

allow() { exit 0; }

deny() {
  # $1 must be JSON-safe (no double quotes, backslashes, or newlines).
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

tool=$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

is_pr_open=false
case "$tool" in
  *create_pull_request*)
    is_pr_open=true
    ;;
  Bash)
    # Greps the whole JSON payload, not just tool_input.command — extracting one JSON field in
    # bash is fragile. Known false positive: any Bash payload merely containing the phrase (e.g.
    # a commit message) gets denied. Accepted: rare, and consistent with guarding laziness.
    if printf '%s' "$input" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+(create|ready)'; then
      is_pr_open=true
    fi
    ;;
esac

$is_pr_open || allow

sha=$(git rev-parse HEAD 2>/dev/null) || allow
git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null) || allow
[ -n "$sha" ] && [ -n "$git_dir" ] || allow
[ -f "$git_dir/code-quiz-passed-$sha" ] && allow

deny "Opening a PR is gated by code-quiz: you haven't proven you understand this change yet. Invoke the code-quiz skill on this branch's diff (HEAD ${sha:0:8}), administer the comprehension questions to the user, and grade them. The gate opens only after the user passes (the skill writes the pass-marker for this exact commit). Do not retry the PR command until then; do not write the marker yourself."
