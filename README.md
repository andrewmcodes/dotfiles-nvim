# Neovim

A curated [lazy.nvim](https://github.com/folke/lazy.nvim) config built for a Ruby on Rails, Stimulus, React (JS/JSX), ERB, Markdown, and AI-agent workflow — tuned for the Podia app. Inspired by Omarchy's LazyVim setup, but hand-assembled from individual plugins rather than a distro, so every choice is explicit and easy to change.

One config runs in two places: **standalone Neovim** and **inside the [VSCode-Neovim](https://github.com/vscode-neovim/vscode-neovim) extension**. Heavy UI plugins are gated on `vim.g.vscode`, so VS Code keeps its own UI while Neovim still provides motions, text objects, surround, flash, and comments.

> 🎮 **[Play Keycombat](https://andrewmcodes.github.io/dotfiles-nvim/)** — an interactive, ADHD-friendly game that drills these keymaps into muscle memory (Rails-developer moves first): 11 worlds, 96 bindings, from Daily Drivers through Ruby Surgery and the Debugger. Runs right in the browser. Source in [`docs/game/`](docs/game/).

## Documentation

- [Setup](docs/setup.md) — installing the toolchain (Homebrew + mise) on a fresh machine
- [Getting started](docs/getting-started.md) — requirements, first launch, updating, backups
- [Keymap reference](docs/keymaps.md) — the full cheatsheet
- [Rails workflow](docs/rails-workflow.md) — ruby-lsp, formatting, navigation, RSpec
- [JavaScript / React / Stimulus](docs/javascript.md) — vtsls, ESLint, Prettier, Jest
- [AI workflow](docs/ai.md) — Copilot, Copilot Chat, Avante, CLI agents
- [Using in VS Code](docs/vscode.md) — the VSCode-Neovim extension
- [Troubleshooting](docs/troubleshooting.md) — common issues and fixes
- [Plugin inventory](docs/plugins.md) — every plugin and where it's configured
- [Keycombat game](docs/game/) — [play it live](https://andrewmcodes.github.io/dotfiles-nvim/) to learn the keymaps by doing

## Requirements

- Neovim **0.12+** (uses the native `vim.lsp.config`/`vim.lsp.enable` API).
- A Nerd Font (JetBrainsMono Nerd Font is assumed for icons).
- `git`, `rg` (ripgrep), `fd`, `make`, a C compiler, `lazygit`, `node`, and `ruby`.
- `tree-sitter` (the parser CLI) on `PATH` — nvim-treesitter's `main` branch compiles parsers locally. It's provided here via mise, so launch nvim from a mise-activated shell (the same requirement as ruby-lsp).
- For Ruby: `ruby-lsp` on `PATH` (already provided here via mise). It runs the project's composed bundle, which auto-loads `ruby-lsp-rails` and `ruby-lsp-rspec`.
- For AI: the `claude`, `opencode`, and `codex` CLIs (already installed) plus a GitHub Copilot subscription. No model API keys are needed — everything is subscription-based.

## First launch

On the first time you open a file, [mason.nvim](https://github.com/mason-org/mason.nvim) auto-installs the language servers and tools (`vtsls`, `eslint-lsp`, `stimulus-language-server`, `lua-language-server`, `marksman`, `stylua`, `shfmt`, `markdownlint`, …) with a progress indicator. `ruby-lsp` is **not** installed by Mason — it comes from the project's own bundle. Run `:Lazy sync` to (re)install plugins and `:checkhealth` to verify.

## Layout

```
init.lua                 leader keys, globals, load order (vscode vs terminal split)
lua/config/
  options.lua            editor options (UI-only opts gated behind vim.g.vscode)
  keymaps.lua            core keymaps (standalone Neovim only)
  autocmds.lua           yank highlight, last cursor position, .erb -> eruby, mkdir on save
  lazy.lua               lazy.nvim bootstrap + setup (imports lua/plugins/)
  vscode.lua             delegates LSP/files/search to VS Code commands
lua/plugins/
  colorscheme.lua        onedarkpro (active) + tokyonight/catppuccin (available)
  ui.lua                 snacks, lualine, bufferline, which-key, noice
  editor.lua             telescope, neo-tree, trouble, todo-comments, flash, matchup,
                         undotree, persistence
  treesitter.lua         syntax + indent + textobjects (rewritten `main`; Neovim 0.12+)
  editing.lua            mini.ai/surround/pairs, ts-comments, vim-repeat (both envs)
  lsp.lua                nvim-lspconfig + mason; ruby_lsp, herb_ls, vtsls, eslint, ...
  completion.lua         blink.cmp (+ Copilot source, Rails/RSpec snippets)
  formatting.lua         conform.nvim (prettier / stylua / shfmt / herb-format)
  linting.lua            nvim-lint (markdownlint)
  git.lua                gitsigns, diffview, lazygit (via snacks)
  test.lua               neotest + neotest-rspec (bin/rspec) + neotest-jest (yarn jest)
  dap.lua                nvim-dap + nvim-dap-ruby (rdbg), dap-ui, virtual text
  ruby.lua               vim-rails, projectionist, bundler, endwise, Rails pickers +
                         bin/rails commands
  javascript.lua         nvim-ts-autotag (JSX/HTML/ERB tags)
  stimulus.lua           (empty — Stimulus is covered by stimulus_ls + treesitter)
  markdown.lua           render-markdown, markdown-preview
  obsidian.lua           obsidian.nvim (digital-brain vault)
  ai.lua                 copilot.lua, CopilotChat, avante, CLI-agent terminals
```

## Keymaps

Leader is <kbd>Space</kbd>. Press <kbd>Space</kbd> and wait to see [which-key](https://github.com/folke/which-key.nvim) hints for everything below.

### Find & search (Telescope)

| Key | Action |
| --- | --- |
| `<leader><space>` / `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Git files |
| `<leader>,` | Buffers |
| `<leader>/` | Live grep |
| `<leader>sw` | Grep word under cursor / selection |
| `<leader>sh` `<leader>sk` `<leader>sd` | Help / keymaps / diagnostics |
| `<leader>sr` `<leader>sc` `<leader>sn` `<leader>st` | Resume / commands / nvim config / todos |
| `<leader>e` / `<leader>E` | File explorer toggle / reveal current file |

### Code (LSP)

| Key | Action |
| --- | --- |
| `gd` `gr` `gI` `gy` | Definition / references / implementation / type definition |
| `K` `gK` | Hover / signature help |
| `<leader>cr` `<leader>ca` | Rename / code action |
| `<leader>cf` `<leader>cl` | Format buffer / run code lens |
| `<leader>cd` `]d` `[d` | Line diagnostics / next / prev |
| `<leader>th` | Toggle inlay hints |
| `<leader>xx` `<leader>xX` `<leader>xs` | Trouble: diagnostics / buffer / symbols |
| `<leader>xl` `<leader>xL` `<leader>xQ` `<leader>xt` | Trouble: LSP / loclist / quickfix / todos |

### Git

| Key | Action |
| --- | --- |
| `<leader>gg` `<leader>gl` | Lazygit / lazygit log |
| `<leader>gd` `<leader>gf` `<leader>gF` | Diffview / file history / repo history |
| `<leader>gb` | Toggle line blame |
| `]c` `[c` | Next / prev hunk |
| `<leader>ghs` `<leader>ghr` `<leader>ghp` `<leader>ghb` | Stage / reset / preview hunk, blame line (`<leader>gh` = more) |

### Tests (neotest)

| Key | Action |
| --- | --- |
| `<leader>tr` `<leader>tf` `<leader>tl` | Run nearest / file / last |
| `<leader>ts` `<leader>to` `<leader>tO` | Toggle summary / show output / output panel |
| `<leader>tw` `<leader>tS` `<leader>td` | Toggle watch / stop / debug nearest |

RSpec runs via `bin/rspec`, Jest via `yarn jest` — the adapter is chosen by filetype.

### Rails navigation

Multiple, complementary layers (details in [docs/rails-workflow.md](docs/rails-workflow.md)):

- **vim-rails**: `<leader>ra` alternate, `<leader>rr` related; `:A`, `:Emodel`, `:Eview`, `:Econtroller`, `:Emigration`; `gf` on partials/associations; `.projections.json` honored.
- **Resource pickers**: `<leader>rm` models, `rc` controllers, `rv` views, `rs` specs, `ri` migrations, `rl` libs, `rj` jobs, `rn` mailers, `ru` components, `rt` Stimulus controllers, `rd` schema.
- **Running Rails**: `<leader>rR` routes picker (jumps to the action), `rC` console, `rM` `db:migrate`, `rG` generate.
- **ruby-lsp**: `gd` go-to-definition, `gr` references, `<leader>cs` workspace symbols, and Code Lens "jump to view"/route links via `<leader>cl`.
- **Ruby motions**: `%` jumps `def`↔`end`, `dam` deletes a whole method, `]m`/`[m` step between methods.

### ERB

`herb_ls` parses the HTML and the ERB together, so unclosed tags and a missing `<% end %>` surface as ordinary diagnostics — things ruby-lsp can't see. `herb-format` formats views on save once [installed](docs/setup.md#erb-formatting-optional).

### Debugging

Breakpoint debugging for Ruby via nvim-dap + `rdbg`: `<leader>db` breakpoint, `<leader>dc` start/continue, `<leader>di`/`do`/`dO` step, `<leader>du` toggle UI. `<leader>td` debugs the nearest spec. Variable values render inline as you step.

### AI

Subscription-based; **no API keys**.

| Key | Action |
| --- | --- |
| `<M-l>` / `<M-]>` / `<M-[>` | Copilot inline: accept / next / prev (insert mode) |
| `<leader>at` | Toggle Copilot auto-suggestions |
| `<leader>aa` `<leader>ax` `<leader>ap` | Copilot Chat: toggle / reset / prompt actions |
| `<leader>ae` `<leader>af` `<leader>av` `<leader>aT` | Chat: explain / fix / review / tests (works on a visual selection) |
| `<leader>Aa` `<leader>At` `<leader>Ae` | Avante: ask / toggle / edit (Copilot provider by default) |
| `<leader>ac` `<leader>ao` `<leader>aC` | Toggle a terminal running Claude Code / opencode / Codex |

Run `:Copilot auth` once to sign in. Avante defaults to the Copilot provider; to drive it through the Claude subscription instead, uncomment the ACP/`claude-code` block in `lua/plugins/ai.lua` (still no API key).

### Editing & windows

`s`/`S` flash jump, `sa`/`sd`/`sr` surround add/delete/replace, `gc`/`gcc` comment, `<C-s>` save, `<C-h/j/k/l>` window navigation, `<A-j>`/`<A-k>` move lines, `<leader>uw/us/ul/ud/uv/un` UI toggles, `<leader>uu` undo tree, `<leader>l` Lazy, `<leader>qq` quit all.

Sessions: `<leader>qs` reopens this project exactly as you left it (buffers + window layout), `<leader>ql` restores the last session anywhere.

## VS Code

Open the repo with the VSCode-Neovim extension and this config loads in "vscode" mode: UI plugins are skipped and `lua/config/vscode.lua` maps the same leader keys to VS Code commands (`<leader>ff` quick open, `<leader>/` search, `gd`/`K`/`<leader>ca`/`<leader>cr` code intelligence, `za`/`zR`/`zM` folds). Motions, surround, flash, and comments come from Neovim.

## Backup / restore

The previous kickstart-modular config is preserved on the `backup/kickstart-modular-20260723` git branch and copied to `~/.config/nvim.bak-20260723`. To roll back: `git checkout backup/kickstart-modular-20260723`.
