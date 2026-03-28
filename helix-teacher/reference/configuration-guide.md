# Helix Configuration Guide

Use this reference when helping users configure Helix or migrate from another editor.

## Config file locations

| File                    | Location                         | Purpose                                |
| ----------------------- | -------------------------------- | -------------------------------------- |
| `config.toml`           | `~/.config/helix/config.toml`    | Editor settings, theme, key remaps     |
| `languages.toml`        | `~/.config/helix/languages.toml` | Language servers, formatters, grammars |
| `.helix/config.toml`    | Project root                     | Project-specific editor overrides      |
| `.helix/languages.toml` | Project root                     | Project-specific language config       |

Open config: `:config-open`. Reload config: `:config-reload`.

## Essential config.toml options

```toml
theme = "onedark"  # or any theme from :theme <tab>

[editor]
line-number = "relative"     # "absolute" (default) or "relative"
mouse = false                # disable mouse (default: true)
cursorline = true            # highlight current line
auto-format = true           # format on save (default: true)
idle-timeout = 250           # ms before idle actions trigger
bufferline = "multiple"      # show buffer tabs: "never" (default), "always", "multiple"
color-modes = true           # color the mode indicator
rulers = [80, 120]           # vertical ruler columns
text-width = 100             # max line length for reflow
true-color = true            # force true color
popup-border = "all"         # border around popups: "none" (default), "all", "popup", "menu"

[editor.cursor-shape]
insert = "bar"               # "block" (default), "bar", "underline"
normal = "block"
select = "underline"

[editor.lsp]
display-inlay-hints = true   # show inlay hints (default: false)
display-messages = true      # show LSP messages in status
auto-signature-help = true   # signature help popup

[editor.indent-guides]
render = true                # show indent guides (default: false)
character = "│"

[editor.file-picker]
hidden = false               # show hidden files

[editor.statusline]
left = ["mode", "spinner", "file-name", "file-modification-indicator"]
center = []
right = ["diagnostics", "selections", "register", "position", "file-encoding", "file-type"]

[editor.soft-wrap]
enable = true                # soft wrap long lines (default: false)

[editor.auto-save]
focus-lost = true            # save when editor loses focus

[editor.search]
smart-case = true            # case-insensitive unless uppercase used (default: true)
wrap-around = true           # wrap search at file boundaries (default: true)

[editor.whitespace.render]
tab = "all"                  # show tab characters
space = "none"
newline = "none"

[editor.inline-diagnostics]
cursor-line = "warning"      # show inline diagnostics on cursor line

[editor]
end-of-line-diagnostics = "hint"  # show diagnostics at end of line
```

## Language server configuration (languages.toml)

### Adding a language server

```toml
# Define the server
[language-server.typescript-language-server]
command = "typescript-language-server"
args = ["--stdio"]

# Assign it to a language
[[language]]
name = "typescript"
language-servers = ["typescript-language-server"]
auto-format = true
formatter = { command = "prettier", args = ["--parser", "typescript"] }
```

### Common language server setups

```toml
# TypeScript/JavaScript
[language-server.typescript-language-server]
command = "typescript-language-server"
args = ["--stdio"]

# Rust
[language-server.rust-analyzer]
command = "rust-analyzer"

# Python
[language-server.pyright]
command = "pyright-langserver"
args = ["--stdio"]

# Go
[language-server.gopls]
command = "gopls"

# Lua
[language-server.lua-language-server]
command = "lua-language-server"

# Tailwind CSS
[language-server.tailwindcss-ls]
command = "tailwindcss-language-server"
args = ["--stdio"]
```

### Multiple servers per language

```toml
[[language]]
name = "typescript"
language-servers = [
  { name = "efm-lsp-prettier", only-features = ["format"] },
  "typescript-language-server"
]
```

### Language server with config

```toml
[language-server.rust-analyzer]
command = "rust-analyzer"

[language-server.rust-analyzer.config]
check.command = "clippy"
cargo.features = "all"
inlayHints.closureReturnTypeHints.enable = true
```

### External formatter

```toml
[[language]]
name = "javascript"
formatter = { command = "prettier", args = ["--parser", "javascript"] }
auto-format = true

[[language]]
name = "python"
formatter = { command = "black", args = ["-", "--quiet"] }
auto-format = true
```

## Themes

Set theme in `config.toml`:

```toml
theme = "catppuccin_mocha"
```

Preview at runtime: `:theme <tab>` to cycle through available themes.

Create custom themes in `~/.config/helix/themes/<name>.toml`:

```toml
inherits = "catppuccin_mocha"

[palette]
accent = "#f5c2e7"

"ui.cursor" = { fg = "accent" }
```

Popular built-in themes: `onedark`, `gruvbox`, `catppuccin_mocha`, `catppuccin_latte`, `tokyonight`, `rose_pine`, `dracula`, `nord`, `solarized_dark`, `solarized_light`, `base16_default_dark`.

## Common typable commands

| Command                 | Alias   | Description                  |
| ----------------------- | ------- | ---------------------------- |
| `:write`                | `:w`    | Save file                    |
| `:quit`                 | `:q`    | Close view                   |
| `:write-quit`           | `:wq`   | Save and close               |
| `:quit!`                | `:q!`   | Close without saving         |
| `:open <path>`          | `:o`    | Open file                    |
| `:buffer-close`         | `:bc`   | Close buffer                 |
| `:buffer-next`          | `:bn`   | Next buffer                  |
| `:buffer-previous`      | `:bp`   | Previous buffer              |
| `:format`               | `:fmt`  | Format file                  |
| `:reload`               | `:rl`   | Reload file from disk        |
| `:theme <name>`         |         | Change theme                 |
| `:set <option> <value>` |         | Set config option at runtime |
| `:toggle <option>`      |         | Toggle boolean option        |
| `:config-open`          |         | Open config.toml             |
| `:config-reload`        |         | Reload config                |
| `:lsp-restart`          |         | Restart language servers     |
| `:set-language <lang>`  | `:lang` | Set buffer language          |
| `:vsplit`               | `:vs`   | Vertical split               |
| `:hsplit`               | `:hs`   | Horizontal split             |
| `:tutor`                |         | Open the built-in tutorial   |
| `:tree-sitter-scopes`   |         | Show TS scopes under cursor  |
| `:run-shell-command`    | `:sh`   | Run shell command            |
| `:pipe`                 |         | Pipe selections to command   |
| `:sort`                 |         | Sort selection               |
| `:reflow`               |         | Hard-wrap to text-width      |
| `:log-open`             |         | Open helix log file          |

## Starter configs by background

### For Vim users

```toml
theme = "onedark"

[editor]
line-number = "relative"
cursorline = true
color-modes = true
bufferline = "multiple"
popup-border = "all"

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.indent-guides]
render = true

[editor.lsp]
display-inlay-hints = true

[editor.soft-wrap]
enable = true
```

### For VS Code users

```toml
theme = "catppuccin_mocha"

[editor]
line-number = "relative"
mouse = true
cursorline = true
auto-format = true
bufferline = "always"
color-modes = true
popup-border = "all"

[editor.cursor-shape]
insert = "bar"
normal = "block"

[editor.indent-guides]
render = true

[editor.lsp]
display-inlay-hints = true
display-messages = true

[editor.file-picker]
hidden = false

[editor.soft-wrap]
enable = true

[editor.auto-save]
focus-lost = true
```

### Minimal (learn defaults first)

```toml
theme = "gruvbox"

[editor]
line-number = "relative"
cursorline = true

[editor.cursor-shape]
insert = "bar"
```

## Debugging language support

Run `hx --health` for an overview of all languages, or `hx --health <lang>` for a specific language. This shows:

- Whether the language is configured
- Tree-sitter grammar status (highlight, textobject, indent queries)
- Language server detected and its path
- Debug adapter status

Common fixes:

- **LSP not found**: Install the language server and ensure it's on `$PATH`
- **No highlighting**: Run `hx --grammar fetch && hx --grammar build`
- **Wrong formatter**: Check `[[language]]` formatter config in `languages.toml`
