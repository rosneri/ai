# Plugin Catalog by Category

Use this reference when recommending plugins or explaining what installed plugins do.

## Core editing

| Plugin                            | Purpose                                                                      |
| --------------------------------- | ---------------------------------------------------------------------------- |
| nvim-treesitter                   | Syntax highlighting, text objects, and code folding via incremental parsing  |
| nvim-cmp                          | Autocompletion engine with extensible sources                                |
| LuaSnip / nvim-snippets           | Snippet engine (LuaSnip is Lua-based; nvim-snippets uses native vim.snippet) |
| mini.pairs / autopairs            | Auto-close brackets, quotes, and tags                                        |
| mini.surround / nvim-surround     | Add, change, delete surrounding delimiters                                   |
| flash.nvim / leap.nvim / hop.nvim | Motion plugins for jumping to any visible location                           |
| which-key.nvim                    | Displays available keybindings in a popup                                    |
| comment.nvim / mini.comment       | Toggle comments with `gc`                                                    |

## LSP & diagnostics

| Plugin                   | Purpose                                             |
| ------------------------ | --------------------------------------------------- |
| nvim-lspconfig           | Quick setup for built-in LSP client                 |
| mason.nvim               | Install and manage LSP servers, formatters, linters |
| mason-lspconfig.nvim     | Bridge between mason and lspconfig                  |
| none-ls.nvim / nvim-lint | Run external linters/formatters as LSP sources      |
| conform.nvim             | Formatter runner (replaces null-ls for formatting)  |
| trouble.nvim             | Pretty diagnostics list, references, quickfix       |
| fidget.nvim              | LSP progress indicator                              |

## Navigation & search

| Plugin                                   | Purpose                                                     |
| ---------------------------------------- | ----------------------------------------------------------- |
| telescope.nvim                           | Fuzzy finder for files, grep, buffers, LSP symbols          |
| fzf-lua                                  | Alternative fuzzy finder using fzf (faster on large repos)  |
| neo-tree.nvim / nvim-tree.lua / oil.nvim | File explorer (neo-tree: feature-rich, oil: edit-as-buffer) |
| harpoon                                  | Bookmark and quick-switch between a small set of files      |
| grapple.nvim                             | Tag-based file navigation (harpoon alternative)             |

## Git integration

| Plugin        | Purpose                                                              |
| ------------- | -------------------------------------------------------------------- |
| gitsigns.nvim | Git change indicators in the sign column, inline blame, hunk actions |
| fugitive.vim  | Full Git wrapper (`:Git` commands)                                   |
| neogit        | Magit-like Git interface for Neovim                                  |
| diffview.nvim | Side-by-side diff and merge conflict viewer                          |

## UI & appearance

| Plugin                      | Purpose                                   |
| --------------------------- | ----------------------------------------- |
| lualine.nvim                | Statusline                                |
| bufferline.nvim             | Tab-like buffer bar                       |
| indent-blankline.nvim       | Indentation guides                        |
| noice.nvim                  | Replaces cmdline, messages, popupmenu UI  |
| dressing.nvim               | Better `vim.ui.select` and `vim.ui.input` |
| nvim-notify                 | Notification manager                      |
| dashboard-nvim / alpha-nvim | Start screen                              |

## AI & copilot

| Plugin                    | Purpose                                    |
| ------------------------- | ------------------------------------------ |
| copilot.lua / copilot.vim | GitHub Copilot integration                 |
| CopilotChat.nvim          | Chat interface for Copilot                 |
| codecompanion.nvim        | Multi-provider AI chat (Claude, GPT, etc.) |
| avante.nvim               | Cursor-like AI editing experience          |

## Debugging

| Plugin      | Purpose                                          |
| ----------- | ------------------------------------------------ |
| nvim-dap    | Debug Adapter Protocol client                    |
| nvim-dap-ui | UI for nvim-dap (watches, breakpoints, console)  |
| neotest     | Test runner framework with per-language adapters |

## Language-specific

| Ecosystem     | Key plugins                                                                 |
| ------------- | --------------------------------------------------------------------------- |
| TypeScript/JS | typescript-tools.nvim or ts_ls via lspconfig, neotest-jest / neotest-vitest |
| Python        | pyright/basedpyright via lspconfig, neotest-python, venv-selector.nvim      |
| Rust          | rustaceanvim (replaces rust-tools.nvim), crates.nvim                        |
| Go            | go.nvim, neotest-go                                                         |
| Lua (Neovim)  | lazydev.nvim (replaces neodev.nvim) — workspace library for Neovim API      |
