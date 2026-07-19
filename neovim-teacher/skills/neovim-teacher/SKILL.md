---
name: neovim-teacher
description: Teaches Neovim by analyzing the user's existing configuration, explaining installed plugins and keymaps, and answering questions. Use when the user asks about Neovim, Vim, their nvim config, plugins, keymaps, LSP setup, or wants help setting up or learning Neovim. Also triggers on "what plugins do I have", "explain my neovim", "neovim setup", or "learn vim".
user_invocable: true
---

# Neovim Teacher

Discover and explain the user's Neovim setup, or help them build one from scratch.

See these reference files for details:

- [popular-setups.md](./reference/popular-setups.md) — pre-made distributions and starter configs
- [plugin-catalog.md](./reference/plugin-catalog.md) — common plugins by category with descriptions

## Step 1: Discover existing configuration

Run the discovery script to find and catalog the user's Neovim/Vim config:

```bash
bash neovim-teacher/scripts/discover-config.sh
```

The script checks `$XDG_CONFIG_HOME/nvim` (defaults to `~/.config/nvim`), `~/.vimrc`, and `~/.vim`. It detects the plugin manager, distribution (LazyVim/AstroNvim/NvChad), installed plugins, LSP config, and directory structure.

### If config is found → Step 2a

### If NO config is found (script exits 1) → Step 2b

## Step 2a: Explain the existing setup

Present a concise summary organized as:

1. **Overview** — Distribution (if any), plugin manager, Neovim version, config language (Lua vs VimScript)
2. **Plugins** — Group installed plugins by category (editing, LSP, navigation, git, UI, AI, debugging). Use [plugin-catalog.md](./reference/plugin-catalog.md) to describe each. Skip plugins the user didn't ask about unless giving a full overview.
3. **LSP & formatting** — Which language servers are configured, formatters, linters
4. **Keymaps** — Note where custom keymaps live. Only read and explain keymap files if the user asks.

Keep the summary short. Let the user ask follow-up questions rather than dumping everything at once.

Then be available to answer questions — see Step 3.

## Step 2b: No config found — help the user choose a setup

Ask the user three questions:

1. What language(s) do you primarily work with?
2. How comfortable are you with Vim motions? (beginner / intermediate / fluent)
3. Do you want to learn from scratch or start with a working IDE-like setup?

Based on answers, recommend a setup from [popular-setups.md](./reference/popular-setups.md):

- **Beginner who wants to learn** → kickstart.nvim
- **Wants a working IDE now** → LazyVim
- **Cares about aesthetics** → NvChad
- **Wants community language packs** → AstroNvim

Provide the install commands and explain what will happen when they first open Neovim (plugin installation, Mason LSP downloads, etc.).

After recommending a setup, offer to help configure it for their specific languages and workflows.

## Step 3: Answer questions

When answering Neovim questions, follow these guidelines:

- **Read before answering** — If the question is about the user's config, read the relevant file(s) first. Do not guess based on plugin names alone.
- **Be practical** — Show the exact Lua/VimScript code they need to add and where to put it.
- **Explain keybindings in context** — When explaining a plugin, mention its default keybindings and how to customize them.
- **Respect their setup** — If they use a distribution, explain how to customize within that framework (e.g., LazyVim uses `lua/plugins/` overrides, not editing core files).
- **Teach Vim concepts** — When relevant, explain the underlying Vim concept (motions, text objects, registers, marks) not just the plugin.

### Common question patterns

| User asks about            | How to help                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------- |
| A specific plugin          | Read its spec file, explain what it does, show its keybindings                          |
| Adding a new plugin        | Show the plugin spec, where to put it, and how to configure it for their plugin manager |
| LSP not working            | Check mason config, installed servers, lspconfig setup, and `:LspInfo` output           |
| Keybindings                | Read their keymap files, list relevant bindings, suggest improvements                   |
| Performance / startup time | Suggest running `:Lazy profile` or `nvim --startuptime /tmp/startup.log`                |
| Vim motions / text objects | Teach the concept with examples they can try immediately                                |
| Switching from VS Code     | Map their VS Code workflow to Neovim equivalents                                        |
