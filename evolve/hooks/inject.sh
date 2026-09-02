#!/usr/bin/env bash
# Injects the evolved instructions for the skill being invoked, plus the write-back protocol.
#
# Fires on two paths: the Skill tool (PreToolUse) and a user-typed `/skill` (UserPromptSubmit).
# The evolution file is `$EVOLVE_DIR/<skill>.md` (default ~/.evolutions), plugin prefix stripped,
# so `caveman:caveman` and `/caveman` both resolve to `caveman.md`. Point EVOLVE_DIR at a folder
# inside an Obsidian vault to browse and edit the files there.
#
# Fail-open: any parse problem exits 0 with no output.

input=$(cat)
command -v jq >/dev/null || exit 0

event=$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null)
case "$event" in
  PreToolUse)       skill=$(jq -r '.tool_input.skill // empty' <<<"$input") ;;
  UserPromptSubmit) skill=$(jq -r '.prompt // empty' <<<"$input" | sed -nE 's#^/([A-Za-z0-9:_-]+).*#\1#p') ;;
  *) exit 0 ;;
esac

skill=${skill##*:}
[ -n "$skill" ] || exit 0
case "$skill" in evolve|help|clear|compact|config|plugin|model|init) exit 0 ;; esac

root=${EVOLVE_DIR:-$HOME/.evolutions}
file="$root/$skill.md"

if [ -f "$file" ]; then
  body="## Evolved instructions for \`$skill\` (from $file)
Where these conflict with the skill's own SKILL.md, these win — they are the user's and your accumulated corrections.

$(cat "$file")"
else
  body="No evolution file yet for \`$skill\` (would be $file)."
fi

ctx="$body

## Evolve protocol
When this task ends, if the user corrected how the skill behaved, a step in the skill was wrong or outdated, or you found a clearly better approach that applies to every future use of this skill: append one bullet under \`## Instructions\` and one dated line under \`## Log\` in $file (create it with those two headings if missing), then tell the user in one line what you recorded. Record durable rules only — never task state, project facts, or things the user said apply just this once. Never rewrite or delete existing bullets unless the user asks; they may have written them."

jq -n --arg e "$event" --arg c "$ctx" \
  '{hookSpecificOutput:{hookEventName:$e,additionalContext:$c}}'
