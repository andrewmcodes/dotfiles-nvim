# Plugin inventory

Every plugin, where it's configured, and what it does. Each `lua/plugins/*.lua` file returns a list of specs; UI-heavy ones are gated with `cond = not vim.g.vscode`.

## Core / UI — `colorscheme.lua`, `ui.lua`

| Plugin | Purpose |
| --- | --- |
| `olimorris/onedarkpro.nvim` | Active colorscheme (`onedark`) |
| `folke/tokyonight.nvim` | Alternative colorscheme (`:colorscheme tokyonight-night`) |
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
| `andymass/vim-matchup` | `%` on Ruby `def`/`if`/`do` → `end`, `]%`/`[%`, `i%`/`a%` (replaces the disabled `matchit`/`matchparen`) |
| `mbbill/undotree` | Visual undo history browser (`<leader>uu`) |
| `folke/persistence.nvim` | Per-directory session restore (`<leader>qs`/`ql`) |
| `nvim-treesitter/nvim-treesitter` (`main` branch) | Syntax highlighting + indentation (not lazy-loaded; parsers compiled via the `tree-sitter` CLI) |
| `nvim-treesitter/nvim-treesitter-textobjects` (`main` branch) | Method/class/parameter textobjects + motions (`am`/`ic`, `]m`/`[[`) |
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
| `stevearc/conform.nvim` | Formatting (Prettier / stylua / shfmt / herb-format); Ruby via ruby-lsp |
| `mfussenegger/nvim-lint` | Markdown linting (markdownlint) |

Servers enabled: `ruby_lsp` (via `mise x`), `herb_ls` (ERB), `vtsls`, `eslint`, `stimulus_ls`, `lua_ls`, `jsonls`, `yamlls`, `cssls` (css/less), `somesass_ls` (scss/sass), `html`, `marksman`, `bashls`, `dockerls`, `taplo`.

Two filetypes have deliberately split server ownership, to avoid duplicate diagnostics and completions:

- **Stylesheets** — `cssls` handles plain `css`/`less`; `somesass_ls` owns `scss` and indented `sass` (cross-partial variable/mixin intelligence). Enabling both on `scss` would double up.
- **ERB** — `herb_ls` defaults to `{ html, eruby }` upstream, but is pinned to `eruby` only here because the `html` server already owns plain HTML. An `.erb` buffer therefore runs three servers with distinct jobs: `ruby_lsp` (the embedded Ruby), `herb_ls` (HTML+ERB structure), `stimulus_ls` (`data-*` attributes).

Not enabled, on purpose: `rubocop`/`standardrb` (ruby-lsp already runs Standard via its RuboCop addon — adding these double-reports every offense), and `sorbet`/`tailwindcss` (not part of the Podia stack).

## Languages — `ruby.lua`, `javascript.lua`, `stimulus.lua`, `markdown.lua`, `obsidian.lua`

| Plugin | Purpose |
| --- | --- |
| `tpope/vim-rails` (+ `vim-projectionist`, `vim-bundler`) | Rails navigation: `:A`, `:E*`, `gf`, `.projections.json` |
| `tpope/vim-endwise` | Auto-insert `end` in Ruby/Lua/sh |
| _(local, in `ruby.lua`)_ | Fuzzy pickers per Rails resource + a `bin/rails` command surface (`<leader>r`) |
| `windwp/nvim-ts-autotag` | Auto close/rename JSX/HTML/ERB tags |
| `MeanderingProgrammer/render-markdown.nvim` | In-buffer Markdown rendering |
| `iamcco/markdown-preview.nvim` | Browser Markdown preview (`<leader>cp`) |
| `obsidian-nvim/obsidian.nvim` | Obsidian `digital-brain` vault: daily notes, search, wikilink completion/nav (`<leader>o`) |

(`stimulus.lua` is intentionally empty — Stimulus is covered by `stimulus_ls` + treesitter.)

## Git / tests / debug / AI — `git.lua`, `test.lua`, `dap.lua`, `ai.lua`

| Plugin | Purpose |
| --- | --- |
| `lewis6991/gitsigns.nvim` | Signs, hunk stage/reset/preview/blame (`<leader>gh`, `]c`/`[c`) |
| `sindrets/diffview.nvim` | Rich diffs + file history (`<leader>gd/gf/gF`) |
| `nvim-neotest/neotest` (+ neotest-rspec, neotest-jest) | Run RSpec (`bin/rspec`) and Jest (`yarn jest`) (`<leader>t`) |
| `mfussenegger/nvim-dap` (+ nvim-dap-ruby, dap-ui, dap-virtual-text) | Breakpoint debugging for Ruby via `rdbg` / the `debug` gem (`<leader>d`) |
| `zbirenbaum/copilot.lua` | Inline Copilot suggestions |
| `CopilotC-Nvim/CopilotChat.nvim` | Copilot chat panel (`<leader>a`) |
| `yetone/avante.nvim` | Cursor-style AI sidebar on the Copilot provider (`<leader>A`) |
| `folke/snacks.nvim` (keys only) | Terminals for `claude` / `opencode` / `codex` (`<leader>ac/ao/aC`) |

## Adding or removing a plugin

Add a spec to the relevant file (or create a new `lua/plugins/<name>.lua`), then `:Lazy sync`. To remove one, delete its spec and `:Lazy clean`. Gate any UI plugin with `cond = function() return not vim.g.vscode end` so it stays out of the VS Code environment.
