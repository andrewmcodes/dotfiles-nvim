# Getting started

## What this is

A hand-assembled [lazy.nvim](https://github.com/folke/lazy.nvim) configuration for a Ruby on Rails + Stimulus + React (JS/JSX) + ERB + Markdown + AI workflow, tuned for the Podia app. It is not a distribution (no LazyVim/AstroNvim); every plugin is chosen and configured explicitly, so nothing is hidden behind a framework.

The same files run in two environments:

- **Standalone Neovim** — the full IDE experience (LSP, completion, file tree, fuzzy finder, git, tests, AI).
- **The [VSCode-Neovim](https://github.com/vscode-neovim/vscode-neovim) extension** — Neovim provides motions/text-objects/surround/flash/comments while VS Code keeps its own UI. See [vscode.md](vscode.md).

The switch is automatic: `init.lua` checks `vim.g.vscode` (set by the extension) and loads only what belongs in each environment.

## Requirements

| Tool | Why |
| --- | --- |
| Neovim **0.12+** | Uses the native `vim.lsp.config`/`vim.lsp.enable` API |
| A Nerd Font | Icons in the statusline, tree, completion menu (JetBrainsMono Nerd Font assumed) |
| `git`, `rg`, `fd`, `make`, C compiler | Fuzzy finding, grep, treesitter/fzf-native builds |
| `tree-sitter` CLI (via mise) | nvim-treesitter's `main` branch compiles parsers locally |
| `lazygit` | `<leader>gg` git UI |
| `node`, `mise` | JS tooling; `mise` resolves the per-project Ruby/Node |
| GitHub Copilot subscription | Inline completion, chat, and Avante (no API keys needed) |
| `claude`, `opencode`, `codex` CLIs | AI-agent terminals |

Ruby tooling (`ruby-lsp`, `standardrb`, `rubocop`) comes from the project's own bundle via `mise` — nothing to install through the editor.

## First launch

1. Open Neovim. lazy.nvim bootstraps itself and installs all plugins (progress in a floating window). If you ever need to redo this: `:Lazy sync`.
2. Open any source file. [mason.nvim](https://github.com/mason-org/mason.nvim) auto-installs the language servers and CLI tools (`vtsls`, `eslint-lsp`, `stimulus-language-server`, `lua-language-server`, `marksman`, `stylua`, `shfmt`, `markdownlint`, …) with a progress indicator. This happens once.
3. Sign in to Copilot: `:Copilot auth`.
4. `blink.cmp` downloads its fuzzy-matching binary on the first insert (one-time, automatic).
5. Verify: `:checkhealth`.

`ruby-lsp` is **not** installed by Mason — it is launched via `mise x -- ruby-lsp` so it always runs under the project's pinned Ruby and loads its Rails/RSpec/Standard addons from the project bundle.

## How the config loads

```
init.lua
├─ set leader = Space, vim.g.have_nerd_font
├─ require("config.options")        -- always (UI-only opts skipped under VS Code)
├─ require("config.lazy")           -- bootstrap + import lua/plugins/
└─ if vim.g.vscode
     └─ require("config.vscode")    -- delegate to VS Code commands
   else
     ├─ require("config.keymaps")   -- core keymaps
     └─ require("config.autocmds")  -- yank highlight, .erb→eruby, etc.
```

Each file in `lua/plugins/` returns a list of plugin specs. UI-heavy specs carry `cond = function() return not vim.g.vscode end`; editing enhancements in `editing.lua` (surround, text-objects, flash, comments) load in both environments.

## Updating & maintenance

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager UI (install/update/clean/profile) |
| `:Lazy sync` | Install missing + update to lockfile |
| `:Lazy update` | Update plugins and refresh `lazy-lock.json` |
| `:Lazy restore` | Roll every plugin back to `lazy-lock.json` |
| `:Mason` | Manage LSP servers / tools |
| `:TSUpdate` | Update treesitter parsers |
| `:checkhealth` | Diagnose problems |

`lazy-lock.json` is committed, so `:Lazy restore` gives you a known-good state.

## Backup / restore

The previous kickstart-modular config is preserved:

- git branch `backup/kickstart-modular-20260723`
- directory copy `~/.config/nvim.bak-20260723`

Roll back with `git checkout backup/kickstart-modular-20260723` (from `~/.config/nvim`).
