---
name: evolve
description: >
  Inspect, edit, or curate the evolved instructions of a skill — the per-skill markdown file the
  evolve plugin injects on top of every invocation. With a skill name, reviews the current session
  for lessons about that skill and proposes edits to its file. Without one, lists every evolution
  file and when it last changed. Use when the user says "evolve <skill>", "what has <skill>
  learned", "edit <skill> instructions", "reset <skill> evolution", or "/evolve".
user_invocable: true
arguments:
  - name: skill
    description: "Skill name to evolve (e.g. 'tdd'). Omit to list all evolution files."
    required: false
---

# evolve

The evolve plugin makes skills self-improving. Each skill gets one markdown file:

```
${EVOLVE_DIR:-~/.evolutions}/<skill>.md
```

A hook injects that file before every invocation of the skill (both `Skill` tool calls and a
user-typed `/skill`), followed by a short protocol telling Claude to append durable lessons at the
end of the task. Instructions in the file override the skill's SKILL.md. Plugin prefixes are
stripped: `caveman:caveman` and `/caveman` both read `caveman.md`.

## File format

```markdown
# <skill>

## Instructions

- Rules that amend or override SKILL.md. One line each. Newest last.

## Log

- YYYY-MM-DD — what changed and why (one line)
```

Both sections are hand-editable. The user owns the file; Claude appends to it.

## `/evolve` with no argument

List `${EVOLVE_DIR:-~/.evolutions}/*.md` with last-modified date and instruction count:

```bash
for f in "${EVOLVE_DIR:-$HOME/.evolutions}"/*.md; do
  printf '%s  %s  %s rules\n' "$(date -r "$f" +%F)" "$(basename "$f" .md)" "$(grep -c '^- ' "$f")"
done
```

Report the list. Nothing else.

## `/evolve <skill>`

1. Read `${EVOLVE_DIR:-~/.evolutions}/<skill>.md` if it exists; otherwise start from the format above.
2. Review this session for evidence about how the skill should behave differently: user corrections,
   steps that failed or were skipped, better approaches found. Skip anything task-specific.
3. Propose the edits as a diff (added, changed, removed bullets) and wait for the user to approve,
   edit, or reject each one. Do not write before approval.
4. Write the file, add one dated `## Log` line summarizing the change, and print the final
   `## Instructions` section.

Sub-requests handled the same way: "reset <skill>" empties `## Instructions` (keep the Log, add a
line), "show <skill>" prints the file with no changes.

## Composing into a plugin that is not invoked as a skill

Always-on plugins (hook-injected modes, agents) never pass through the Skill tool, so the hook can't
see them. Add one line to their instructions instead:

```
Read ${EVOLVE_DIR:-~/.evolutions}/<name>.md if it exists and follow it; it overrides this file.
Append durable lessons there under `## Instructions` and a dated line under `## Log`.
```

That is the whole protocol. No dependency on this plugin is required.

## Obsidian

Set `EVOLVE_DIR` to a folder inside the vault, e.g. in `~/.claude/settings.json`:

```json
{ "env": { "EVOLVE_DIR": "/Users/me/vaults/notes/evolutions" } }
```

Files are plain markdown, so the vault indexes, links, and versions them like any other note.
