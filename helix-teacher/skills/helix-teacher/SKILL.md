---
name: helix-teacher
description: Teaches Helix editor by analyzing the user's existing configuration, explaining keybindings and LSP setup, and answering questions. Use when the user asks about Helix, their helix config, keybindings, LSP setup, themes, or wants help setting up or learning Helix. Also triggers on "helix keybindings", "explain my helix config", "helix setup", "learn helix", or "hx config".
user_invocable: true
---

# Helix Teacher

Discover and explain the user's Helix setup, or help them get started from scratch.

See these reference files for details:

- [keymap-reference.md](./reference/keymap-reference.md) — complete keymap organized by mode and category
- [configuration-guide.md](./reference/configuration-guide.md) — configuration options, LSP setup, and migration tips

## Step 1: Discover existing configuration

Run the discovery script to find and catalog the user's Helix config:

```bash
bash helix-teacher/scripts/discover-config.sh
```

The script checks `$XDG_CONFIG_HOME/helix` (defaults to `~/.config/helix`), detects `config.toml`, `languages.toml`, custom themes, and runtime queries. It also checks for project-local `.helix/` config.

### If config is found → Step 2a

### If NO config is found (script exits 1) → Step 2b

## Step 2a: Explain the existing setup

Present a concise summary organized as:

1. **Overview** — Helix version, theme, key editor settings (line numbers, mouse, cursor shape)
2. **Key remappings** — Summarize any custom keybindings in `[keys.*]` sections. Highlight deviations from defaults.
3. **LSP & languages** — Which language servers are configured in `languages.toml`, formatters, auto-format settings
4. **Editor preferences** — Notable settings (auto-pairs, soft-wrap, indent guides, statusline customization, etc.)

Keep the summary short. Let the user ask follow-up questions rather than dumping everything at once.

Then be available to answer questions — see Step 3.

## Step 2b: No config found — help the user get started

Helix is batteries-included — no plugin manager or distribution needed. Ask the user:

1. What language(s) do you primarily work with?
2. How comfortable are you with modal editing? (beginner / Vim user / Kakoune user)
3. What editor are you coming from?

Based on answers:

- **Beginner to modal editing** → Suggest running `:tutor` first, explain the selection-first model, recommend starting with minimal config
- **Coming from Vim** → Explain the key differences (selection → action instead of action → motion, `x` selects lines, `w` then `d` instead of `dw`, no plugins needed for surround/comments/LSP). Offer a starter `config.toml` with familiar settings (relative line numbers, cursor shapes).
- **Coming from Kakoune** → Helix will feel natural. Note the differences (TOML config, built-in LSP, tree-sitter integration, slightly different key choices).
- **Coming from VS Code / other GUI editor** → Explain modal editing basics, suggest `:tutor`, highlight that LSP features (go-to-definition, rename, code actions) work out of the box with `Space` menu.

Provide a starter `config.toml` tailored to their background and help them set up language servers for their stack (pointing to `hx --health` to check language support).

## Step 3: Answer questions

When answering Helix questions, follow these guidelines:

- **Read before answering** — If the question is about the user's config, read `config.toml` and/or `languages.toml` first. Do not guess.
- **Be practical** — Show the exact TOML config they need and where to put it (`config.toml` vs `languages.toml` vs `.helix/` project config).
- **Explain keybindings in context** — Use the [keymap-reference.md](./reference/keymap-reference.md) to give accurate default bindings. Always mention the mode (normal, insert, select).
- **Teach the selection-first model** — Helix uses `selection → action` (inspired by Kakoune). When explaining workflows, emphasize selecting first, then acting. For Vim users, explicitly contrast with Vim's `action → motion`.
- **Leverage built-in features** — Helix has built-in support for surround (`m`), LSP (`Space`/`g`), file picker (`Space+f`), comments (`Ctrl-c`), tree-sitter text objects, and multiple selections. No plugins needed.
- **Use `hx --health`** — When debugging LSP or language support issues, always suggest `hx --health <lang>` first to check if the language server is detected.

### Common question patterns

| User asks about           | How to help                                                                                       |
| ------------------------- | ------------------------------------------------------------------------------------------------- |
| Keybindings / how to do X | Look up in keymap-reference.md, show the key sequence and mode, contrast with Vim if relevant     |
| Custom keybindings        | Show TOML syntax for `[keys.normal]`, `[keys.insert]`, `[keys.select]` sections                   |
| LSP not working           | Run `hx --health <lang>`, check `languages.toml` config, verify server is installed               |
| Adding a language server  | Show `[language-server]` and `[[language]]` config in `languages.toml`                            |
| Formatting                | Explain `auto-format`, `formatter` config in `languages.toml`, and `:format` command              |
| Themes                    | Show how to set theme in `config.toml`, create custom themes, and use `:theme` to preview         |
| Multiple selections       | Teach `s` (select regex), `C` (copy selection to next line), `,` (keep primary), `%` (select all) |
| Surround / match          | Explain match mode (`m`) — `ms` to surround, `mr` to replace, `md` to delete, `mm` to match       |
| Tree-sitter text objects  | Explain `]f`/`[f` (functions), `]t`/`[t` (types), `Alt-o`/`Alt-i` (expand/shrink selection)       |
| Coming from Vim           | Map their Vim workflow to Helix equivalents, highlight selection-first differences                |
| Performance / startup     | Helix is fast by default; check `hx --health` for grammar/query issues                            |
