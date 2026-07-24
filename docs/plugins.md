# Plugin inventory

Every plugin, where it's configured, and what it does. Each `lua/plugins/*.lua` file returns a list of specs; UI-heavy ones are gated with `cond = not vim.g.vscode`.

## Core / UI — `colorscheme.lua`, `ui.lua`

| Plugin | Purpose |
| --- | --- |
| `folke/tokyonight.nvim` | Active colorscheme (`tokyonight-night`) |
| `catppuccin/nvim` | Alternative colorscheme (`:colorscheme catppuccin`) |
| `folke/snacks.nvim` | Dashboard, notifier, indent guides, scroll, big-file handling, terminal, lazygit |
| `nvim-lualine/lualine.nvim` | Statusline |
| `akinsho/bufferline.nvim` | Buffer tabs |
| `folke/which-key.nvim` | Leader-key hints + group labels |
| `folke/noice.nvim` (+ `nui.nvim`) | Cmdline popup, LSP hover/signature UI, messages |

## Editor — `editor.lua`, `treesitter.lua`, `editing.lua`

| Plugin | Purpose |
| --- | --- |
| `nvim-telescope/telescope.nvim` (+ fzf-native, ui-select) | Fuzzy finder for files, grep, symbols, etc. |
| `nvim-neo-tree/neo-tree.nvim` | File explorer (`<leader>e`) |
| `folke/trouble.nvim` | Diagnostics / symbols / quickfix list (`<leader>x`) |
| `folke/todo-comments.nvim` | Highlight + navigate TODO/FIXME/etc. |
| `folke/flash.nvim` | Jump-to-anywhere motions (`s`/`S`) — loads in VS Code too |
| `nvim-treesitter/nvim-treesitter` (`main` branch) | Syntax highlighting + indentation (not lazy-loaded; parsers compiled via the `tree-sitter` CLI) |
| `echasnovski/mini.nvim` | `mini.ai` text objects, `mini.surround`, `mini.pairs` — loads in VS Code too |
| `folke/ts-comments.nvim` | Treesitter-aware `gc`/`gcc` commenting — loads in VS Code too |
| `tpope/vim-repeat` | `.` repeat for plugin maps — loads in VS Code too |

## LSP / completion / format / lint — `lsp.lua`, `completion.lua`, `formatting.lua`, `linting.lua`

| Plugin | Purpose |
| --- | --- |
| `neovim/nvim-lspconfig` | LSP server configs (native 0.11+ API) |
| `mason-org/mason.nvim` (+ mason-lspconfig, mason-tool-installer) | Install/manage servers + tools |
| `folke/lazydev.nvim` | Lua LS tuning for editing this config |
| `j-hui/fidget.nvim` | LSP progress UI |
| `b0o/schemastore.nvim` | JSON/YAML schemas |
| `saghen/blink.cmp` (+ friendly-snippets, blink-copilot) | Completion menu with Copilot source |
| `stevearc/conform.nvim` | Formatting (Prettier / stylua / shfmt); Ruby via ruby-lsp |
| `mfussenegger/nvim-lint` | Markdown linting (markdownlint) |

Servers enabled: `ruby_lsp` (via `mise x`), `vtsls`, `eslint`, `stimulus_ls`, `lua_ls`, `jsonls`, `yamlls`, `cssls`, `html`, `marksman`, `bashls`, `taplo`.

## Languages — `ruby.lua`, `javascript.lua`, `stimulus.lua`, `markdown.lua`

| Plugin | Purpose |
| --- | --- |
| `tpope/vim-rails` (+ `vim-projectionist`, `vim-bundler`) | Rails navigation: `:A`, `:E*`, `gf`, `.projections.json` |
| `tpope/vim-endwise` | Auto-insert `end` in Ruby/Lua/sh |
| `sato-s/telescope-rails.nvim` | Fuzzy pickers per Rails resource (`<leader>rm/rc/rv/rs/ri/rl`) |
| `windwp/nvim-ts-autotag` | Auto close/rename JSX/HTML/ERB tags |
| `MeanderingProgrammer/render-markdown.nvim` | In-buffer Markdown rendering |
| `iamcco/markdown-preview.nvim` | Browser Markdown preview (`<leader>cp`) |

(`stimulus.lua` is intentionally empty — Stimulus is covered by `stimulus_ls` + treesitter.)

## Git / tests / AI — `git.lua`, `test.lua`, `ai.lua`

| Plugin | Purpose |
| --- | --- |
| `lewis6991/gitsigns.nvim` | Signs, hunk stage/reset/preview/blame (`<leader>gh`, `]c`/`[c`) |
| `sindrets/diffview.nvim` | Rich diffs + file history (`<leader>gd/gf/gF`) |
| `nvim-neotest/neotest` (+ neotest-rspec, neotest-jest) | Run RSpec (`bin/rspec`) and Jest (`yarn jest`) (`<leader>t`) |
| `zbirenbaum/copilot.lua` | Inline Copilot suggestions |
| `CopilotC-Nvim/CopilotChat.nvim` | Copilot chat panel (`<leader>a`) |
| `yetone/avante.nvim` | Cursor-style AI sidebar on the Copilot provider (`<leader>A`) |
| `folke/snacks.nvim` (keys only) | Terminals for `claude` / `opencode` / `codex` (`<leader>ac/ao/aC`) |

## Adding or removing a plugin

Add a spec to the relevant file (or create a new `lua/plugins/<name>.lua`), then `:Lazy sync`. To remove one, delete its spec and `:Lazy clean`. Gate any UI plugin with `cond = function() return not vim.g.vscode end` so it stays out of the VS Code environment.
