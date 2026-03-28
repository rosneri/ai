# Popular Pre-made Neovim Setups

Use this reference when the user has no existing config and wants a recommendation.

## Distributions (full IDE-like experience)

| Distribution  | Best for                                                                    | Plugin manager | Customization                        | Link                           |
| ------------- | --------------------------------------------------------------------------- | -------------- | ------------------------------------ | ------------------------------ |
| **LazyVim**   | Developers who want a modern, fast, opinionated IDE                         | lazy.nvim      | Override via `lua/plugins/`          | github.com/LazyVim/LazyVim     |
| **AstroNvim** | Users who want a polished UI with a community plugin marketplace            | lazy.nvim      | `lua/community.lua` + `lua/plugins/` | github.com/AstroNvim/AstroNvim |
| **NvChad**    | Minimalists who want a fast base with a clean theme system                  | lazy.nvim      | `lua/chadrc.lua` + `lua/plugins/`    | github.com/NvChad/NvChad       |
| **LunarVim**  | Users from VS Code wanting a familiar experience (less actively maintained) | lazy.nvim      | `config.lua`                         | github.com/LunarVim/LunarVim   |

## Starter configs (learn by reading)

| Config             | Best for                                    | Notes                                                      |
| ------------------ | ------------------------------------------- | ---------------------------------------------------------- |
| **kickstart.nvim** | Beginners who want to understand every line | Single `init.lua` with heavy comments — best learning tool |
| **nvim-basic-ide** | Intermediate users building from scratch    | Modular structure, fewer plugins than distributions        |

## How to recommend

1. Ask what language(s) they primarily work with
2. Ask their experience level with Vim motions
3. Ask if they prefer learning from scratch or a working setup first

**New to Vim/Neovim → kickstart.nvim** (read it, understand it, then grow)
**Want a working IDE now → LazyVim** (most popular, best docs, easiest to extend)
**Care about aesthetics and themes → NvChad** (beautiful defaults, fast startup)
**Want community plugin packs → AstroNvim** (AstroCommunity has pre-configured language packs)

## Quick install (any distribution)

```bash
# Back up existing config first
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# Clone the distribution starter
git clone https://github.com/<org>/<starter> ~/.config/nvim

# Open Neovim — plugins install automatically
nvim
```
