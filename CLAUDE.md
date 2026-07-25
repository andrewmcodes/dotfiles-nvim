# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal [lazy.nvim](https://github.com/folke/lazy.nvim) Neovim configuration (not a distro), hand-assembled for a Ruby on Rails / Stimulus / React (JS + JSX) / ERB / Markdown / AI-agent workflow tuned to the Podia app. The defining constraint: **one config runs in two environments** — standalone Neovim and inside the VSCode-Neovim extension.

The `README.md` and `docs/` are the source of truth for user-facing behavior (keymaps, workflows). Read `docs/plugins.md` to find which file configures a given plugin. Don't duplicate those docs here — update them when behavior changes.

## Commands

There is no build or test suite for the config itself. Working on it means editing Lua and reloading Neovim.

- **Format Lua** (required before committing): `stylua .` (installed via mise). Style is enforced by `.stylua.toml` — 2-space indent, 120 column width, double quotes, no collapsed single-line statements.
- **Install / update / inspect plugins**: `:Lazy sync`, `:Lazy`. Plugin versions are pinned in `lazy-lock.json`, which **is tracked on purpose** — commit lockfile changes deliberately.
- **Verify health**: `:checkhealth`.
- **Manage LSP servers / tools**: `:Mason`.

`tr`/`RSpec`/`Jest` keymaps run tests in the *project you're editing* (`bin/rspec`, `yarn jest`), not against this repo.

## Architecture

### Dual-environment gating (the central idea)

`init.lua` sets leader keys, loads `config.options`, bootstraps lazy, then branches on `vim.g.vscode` (set by the VSCode-Neovim extension): standalone loads `config.keymaps` + `config.autocmds`; VS Code loads `config.vscode` instead, which maps the same leader keys to VS Code commands so muscle memory carries over.

Nearly every plugin spec is gated with `cond = function() return not vim.g.vscode end`. Only four load in both environments — `mini.nvim` (ai/surround/pairs), `flash.nvim`, `ts-comments.nvim`, and `vim-repeat` — and `editing.lua` exists to hold exactly those, so specs in it must **not** be gated. Everything else, treesitter included, is gated off: VS Code owns the UI, LSP, files, search, and highlighting. **When adding a plugin, decide which environment it belongs to and gate accordingly.** UI-only editor options in `config/options.lua` are likewise wrapped in `if not vim.g.vscode`.

### Plugin specs

`config/lazy.lua` imports the whole `lua/plugins/` directory (`{ import = "plugins" }`). Each file returns a list of lazy specs grouped by concern (`lsp.lua`, `git.lua`, `ai.lua`, …). `defaults = { lazy = true }` — everything is lazy-loaded, so specs must declare their own `event` / `ft` / `cmd` / `keys` triggers.

**Cross-file merge specs.** lazy.nvim merges multiple specs for the same plugin across files. This config relies on it, so a plugin can appear in more than one file:

- `copilot.lua` is declared once in `ai.lua`; `completion.lua` wires it into blink.cmp via `blink-copilot` without redeclaring it.
- `snacks.nvim` is configured (with `opts`) in `ui.lua`; `ai.lua` and `git.lua` add keys-only specs (no `opts`) so the `ui.lua` config is preserved.

When touching one of these, keep the single `opts`/`config` owner and add only `keys`/`dependencies` elsewhere.

### LSP (native Neovim 0.12+ API)

`lsp.lua` uses `vim.lsp.config(...)` + `vim.lsp.enable(...)` directly — **not** the old `lspconfig.setup{}` framework. Mason (via `mason-tool-installer`) installs servers and CLI tools, but `mason-lspconfig` auto-enable is off; servers are enabled explicitly in the `vim.lsp.enable({...})` list. Per-buffer keymaps and features (inlay hints, code lens, document highlight) attach in a single `LspAttach` autocmd, and goto-style maps prefer Telescope pickers with a `vim.lsp.buf` fallback.

Two Ruby-specific details that are easy to break:

- **ruby-lsp is NOT installed by Mason.** It comes from the project's own composed bundle (auto-loading `ruby-lsp-rails` + `ruby-lsp-rspec`). It's launched via `mise x -- ruby-lsp` so it runs under the project's pinned Ruby regardless of nvim's ambient `PATH` (bare `ruby-lsp` fallback when mise is absent).
- A custom `vim.lsp.commands["rubyLsp.openFile"]` handler is registered so Code Lens "Jump to view" / route links work (ruby-lsp sends `file://…#Lnn` URIs).
- **`ruby_lsp.cmd` must stay a function.** lspconfig's own spec starts the server with `cwd = config.cmd_cwd or config.root_dir`; replacing `cmd` with a plain table silently drops that, and `mise x` then resolves its Ruby from *nvim's* cwd instead of the Rails root — defeating the entire point of the wrapper. Don't override `reuse_client` either; it's what populates `cmd_cwd`.
- **`herb_ls` is pinned to `eruby`.** Upstream defaults to `{ html, eruby }`, but the `html` server already owns HTML. Same split-ownership rule as `cssls`/`somesass_ls`.
- Deliberately not enabled: `rubocop`/`standardrb` (ruby-lsp already runs Standard — would double-report), `sorbet`/`tailwindcss` (not in the stack).

### Formatting split (deliberate)

`conform.nvim` (`formatting.lua`) formats JS/JSX/JSON/CSS/HTML/YAML/Markdown via Prettier, Lua via stylua, sh via shfmt — with `format_on_save` (respecting `:FormatDisable`/`:FormatEnable` toggles and `vim.g/b.disable_autoformat`).

- **Ruby is intentionally absent from conform** — it formats through ruby-lsp (Standard/RuboCop). Don't add `ruby` to `formatters_by_ft`.
- **ERB is NOT** — ruby-lsp has no ERB formatter, so `eruby` maps to `herb_format` (Herb's `herb-format`, defined inline since it isn't in conform's registry). That entry is a *function* that checks availability first, so a missing `herb-format` is a no-op rather than an error on every save.

### Filetypes & tests

- `autocmds.lua` maps `*.erb` → `eruby` (so ruby-lsp, herb_ls, treesitter, and stimulus_ls behave). ERB filetype flows from that.
- `test.lua` (neotest) picks the adapter by filetype: RSpec via `bin/rspec`, Jest via `yarn jest`. `<leader>td` uses `strategy = "dap"` and therefore depends on `dap.lua`.

### Debugging

`dap.lua` owns `<leader>d`: nvim-dap + nvim-dap-ruby (`rdbg` over TCP — ruby/debug does not speak DAP over stdio) + dap-ui + dap-virtual-text. dap-ui auto-opens on `event_initialized` and closes on terminate.

### Leader-key namespaces (which-key)

`<space>` is leader. Groups: `f` find, `s` search, `c` code/LSP, `g` git, `t` test, `r` Rails, `x` Trouble/diagnostics, `u` UI toggles, `a` AI (Copilot + CLI-agent terminals), `A` Avante (relocated off its default `<leader>a` to avoid collision). Keep new maps within the matching namespace.

## Conventions & gotchas

- **Markdown**: do not hard-wrap prose — one physical line per paragraph/list item, soft-wrap in the editor.
- **nvim-treesitter runs the rewritten `main` branch** (required on Neovim 0.12+; the old `master` `.configs` API is 0.11-only and frozen). Consequences that differ from most configs: the plugin is **not lazy-loaded** (`lazy = false`), there is no `ensure_installed`/`auto_install`/`.configs` module, and highlighting + indentation are enabled per-buffer via the core `vim.treesitter` API in a `FileType` autocmd (see `treesitter.lua`). Parsers compile locally, so it needs the **`tree-sitter` CLI** (installed via mise) plus a C compiler — launch nvim from a mise-activated shell (same requirement as ruby-lsp). `require('nvim-treesitter').install()` is idempotent (skips installed parsers). Non-1:1 filetype→parser mappings (`eruby`→`embedded_template`, `javascriptreact`→`javascript`) are registered explicitly; `jsonc` has no parser and highlights via `json`.
- **Treesitter textobject/motion maps are set per buffer, not globally** (`treesitter.lua`). Neovim's shipped ftplugins — Ruby's in particular — define buffer-local `]m`/`[m`/`]M`/`[M`/`]]`/`[[` built on `searchsyn()` + syntax groups, and a buffer-local map always beats a global one. Global versions would be silently dead in exactly the filetype they matter most for. A `FileType` autocmd (deferred via `vim.schedule` so it lands after the ftplugin) applies them, plus a pass over already-loaded buffers since `FileType` has already fired for whatever triggered the plugin load.
- **`matchit`/`matchparen` stay in `disabled_plugins`** because `vim-matchup` replaces both. Don't re-enable them; do keep matchup, or Ruby loses `%` on `def`…`end` entirely.
- **AI is subscription-based; no model API keys.** Copilot powers inline suggestions, chat, and (by default) Avante. `ai.lua` documents a commented ACP block to drive Avante through the Claude CLI instead.
- **Requires Neovim 0.12+** for the native `vim.lsp.config`/`vim.lsp.enable` API.
