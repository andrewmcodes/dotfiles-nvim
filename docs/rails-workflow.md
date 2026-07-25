# Ruby on Rails workflow

Everything here is tuned for the Podia app: Ruby 4 / Rails 8, **Standard** for lint+format, `ruby-lsp` (with the Rails and RSpec addons), ERB views, and Stimulus controllers.

## Language server (ruby-lsp)

`ruby-lsp` is launched as `mise x -- ruby-lsp`, so it always runs under the project's pinned Ruby (Podia = 4.0.5) regardless of how you started Neovim. It re-execs itself into the project's composed bundle, which auto-loads:

- **ruby-lsp-rails** — Rails-aware features (model/association info, `pending migrations`, etc.).
- **ruby-lsp-rspec** — RSpec code lenses and test discovery.
- **Standard + RuboCop addons** — diagnostics and formatting via your `.standard.yml`.

Because `init_options.formatter = "auto"`, ruby-lsp detects Standard automatically. On save, **Ruby** buffers are formatted by ruby-lsp (conform intentionally has no Ruby formatter, so there's no double-formatting). ERB is a different story — see [Formatting & linting](#formatting--linting).

> `ruby_lsp`'s `cmd` is deliberately a **function**, not a plain table. lspconfig starts the server with `cwd = root_dir`, and a table override silently drops that — `mise x` would then resolve its Ruby from nvim's working directory instead of the Rails root, which breaks the moment you launch nvim from a parent directory. If you edit that block, keep the function form.

Useful commands: `:LspInfo` (what's attached), `:LspLog` (server output), `:checkhealth vim.lsp`.

Common LSP keys: `gd` definition, `gr` references, `K` hover, `<leader>ca` code action, `<leader>cr` rename, `<leader>cl` run code lens. See [keymaps.md](keymaps.md#code--lsp-active-when-a-server-is-attached).

> If `ruby_lsp` doesn't attach, it's almost always a Ruby-version/bundle issue. See [troubleshooting.md](troubleshooting.md#ruby-lsp-doesnt-attach).

## Formatting & linting

- **Format on save** is on. Ruby → ruby-lsp (Standard). ERB → `herb-format`. Everything else (JS, SCSS, JSON, YAML, Markdown) → Prettier/stylua/shfmt via conform.
- Manual format: `<leader>cf`.
- Toggle autoformat: `:FormatDisable` (global), `:FormatDisable!` (this buffer), `:FormatEnable`.
- Diagnostics come from ruby-lsp (Standard/RuboCop) and, in views, from Herb — inline and in Trouble (`<leader>xx`).
- Long offenses render in full **under the cursor line** (`virtual_lines`), not truncated at the window edge. `<leader>uv` switches back to the compact inline form.

### ERB formatting

ruby-lsp does **not** format ERB — Standard/RuboCop only parse `.rb`, and Shopify closed the ERB-formatting request as not-planned. ERB goes through [Herb](https://herb-tools.dev)'s `herb-format` instead, resolved from the project's `node_modules/.bin` (falling back to a global install). If it isn't installed, saving a view is a silent no-op rather than an error — install instructions are in [setup.md](setup.md#erb-formatting-optional).

> Herb's formatter is an experimental preview upstream and its own docs warn it may mangle edge cases, so the first save of a long-lived view can produce a large diff. Review it before committing; `:FormatDisable!` opts the current buffer out.

## Navigation (vim-rails + projectionist)

[vim-rails](https://github.com/tpope/vim-rails) understands Rails project structure:

| Command / key | Jumps to |
| --- | --- |
| `:A` / `<leader>ra` | The "alternate" file (model ↔ spec, controller ↔ view, etc.) |
| `:R` / `<leader>rr` | The "related" file |
| `:AV` `:AS` `:AT` | Alternate in a vertical split / horizontal split / new tab |
| `:Emodel <name>` | `app/models/<name>.rb` |
| `:Eview <name>` | A view |
| `:Econtroller <name>` | A controller |
| `:Emigration` | The latest migration |
| `gf` | The file under the cursor — partials (`render "shared/x"`), associations, requires |

Podia's `.projections.json` is honored automatically (ViewComponent `.rb` ↔ `.html.erb`, CMS ↔ customer views).

## Fuzzy navigation (per-resource pickers)

For "show me all the X and let me fuzzy-pick one," `lua/plugins/ruby.lua` defines a Telescope picker per resource type:

| Key | Picker | Key | Picker |
| --- | --- | --- | --- |
| `<leader>rm` | Models | `<leader>rj` | Jobs |
| `<leader>rc` | Controllers | `<leader>rn` | Mailers |
| `<leader>rv` | Views | `<leader>ru` | ViewComponents |
| `<leader>rs` | Specs | `<leader>rt` | Stimulus controllers |
| `<leader>ri` | Migrations | `<leader>rd` | `db/schema.rb` |
| `<leader>rl` | Libs | | |

Each resolves the Rails root from **the current buffer** (nearest `Gemfile`), not from nvim's working directory — so they keep working when you launched nvim from a parent directory. `<leader>ra` (alternate) and `<leader>rr` (related) come from vim-rails.

> These replace `sato-s/telescope-rails.nvim`, which was last updated in 2024 and shelled out to `find` against nvim's cwd with six hardcoded paths.

## Running Rails

| Key | Action |
| --- | --- |
| `<leader>rR` | `bin/rails routes` in a picker — select a route to open its controller on `def <action>` |
| `<leader>rC` | `bin/rails console` in a floating terminal |
| `<leader>rM` | `bin/rails db:migrate` |
| `<leader>rG` | `bin/rails generate …` (prompts for the rest) |

`<leader>rR` boots Rails to collect the route table, which takes a few seconds; it runs asynchronously, so the editor stays responsive and the picker opens when it's ready.

## Debugging

Breakpoint debugging via [nvim-dap](https://github.com/mfussenegger/nvim-dap) + `nvim-dap-ruby`, which drives `rdbg` from the `debug` gem. The gem needs to be in the project's Gemfile.

| Key | Action |
| --- | --- |
| `<leader>db` / `<leader>dB` | Toggle breakpoint / conditional breakpoint |
| `<leader>dc` | Start or continue |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| `<leader>du` | Toggle the debug UI |
| `<leader>dK` | Inspect the value under the cursor |
| `<leader>dr` | Toggle the debug REPL |
| `<leader>dt` | Terminate the session |

Two ways in:

1. **Debug a spec** — set a breakpoint, then `<leader>td` (from the test group) runs the nearest spec under the debugger.
2. **Attach to a running server** — start it with the debugger listening, then `<leader>dc` and pick the attach configuration:

   ```sh
   RUBY_DEBUG_OPEN=true RUBY_DEBUG_HOST=127.0.0.1 RUBY_DEBUG_PORT=38698 bin/rails s
   ```

   If attaching gives `ECONNREFUSED`, add `require "debug/open_nonstop"` at the top of `config/environments/development.rb`.

Variable values render inline next to your code as you step, so most of the time you don't need to open the REPL at all.

## Jump to any symbol

`<leader>cs` opens a live workspace-symbol picker (backed by ruby-lsp) — type a class or method name to jump anywhere in the app. `<leader>xs` (Trouble) outlines the current file's symbols.

## Jump to view / route (Code Lens)

ruby-lsp annotates controller actions with Code Lens links ("Jump to view", route info). Put the cursor on an action and press `<leader>cl` to follow them. This works because the config registers a `rubyLsp.openFile` command handler (in `lua/plugins/lsp.lua`) — without it, Neovim would error with `does not support command rubyLsp.openFile`. Code Lens refreshes automatically as you move around.

## ERB views

- `.erb` files (including `.html.erb`, `.json.erb`) are set to the `eruby` filetype so ruby-lsp, Herb, treesitter, and stimulus all behave.
- Treesitter highlights embedded Ruby inside HTML (`embedded_template` + `ruby` + `html` parsers).
- `<` in a tag auto-closes/renames via `nvim-ts-autotag`.
- **Herb** (`herb_ls`) parses the HTML *and* the ERB together, so it catches the structural mistakes ruby-lsp can't see — an unclosed `<div>`, a `<% ... do %>` with no matching `<% end %>`, a stray closing tag. These show up as ordinary diagnostics.

## Stimulus

`stimulus-language-server` attaches to `eruby`, `html`, and `ruby` buffers. In a view, completing `data-controller="…"`, `data-*-target`, and `data-action` offers the controllers/targets/actions defined in your `*_controller.js` files (which live in per-area `controllers/` directories). No extra setup — just start typing a `data-` attribute.

> It does **not** attach to `.js` buffers — that's upstream lspconfig's filetype list, not a config choice here. Editing a `*_controller.js` gets `vtsls` + `eslint`; use `<leader>rt` to find controllers by name.

## Testing (RSpec)

Powered by [neotest](https://github.com/nvim-neotest/neotest) with the `neotest-rspec` adapter, which runs `bin/rspec`.

| Key | Action |
| --- | --- |
| `<leader>tr` | Run the test under the cursor |
| `<leader>tf` | Run the whole file |
| `<leader>tl` | Re-run the last test |
| `<leader>ts` | Toggle the summary tree |
| `<leader>to` / `<leader>tO` | Show output float / toggle output panel |
| `<leader>tw` | Watch mode (re-run on change) |

You can also run a spec via ruby-lsp's code lens: put the cursor on an `it`/`describe` and press `<leader>cl`.

## Ruby motions & textobjects

Beyond the LSP, plain Vim motions are treesitter-accurate in Ruby:

| Key | Does |
| --- | --- |
| `%` | Jump `def`/`if`/`do`/`class` ↔ its `end` (vim-matchup) |
| `am` / `im` | The whole method / just its body — `dam` deletes a `def`…`end` |
| `ac` / `ic` | The whole class / just its body |
| `aa` / `ia` | A parameter |
| `]m` / `[m` | Next / previous method |
| `]]` / `[[` | Next / previous class |

These are set **per buffer** on purpose: Neovim's shipped Ruby ftplugin defines its own `]m`/`[[`/… built on syntax-group matching, and a buffer-local map always beats a global one. Setting ours per buffer overrides those so the treesitter versions actually win.

## Tips

- `end` is inserted automatically after `def`/`do`/`if`/`class` (vim-endwise).
- Symbol occurrences highlight on idle (document highlight) when the LSP supports it.
- Use `<leader>xs` (Trouble symbols) to outline a large model or controller.
- RSpec and Rails snippets are available in `.rb` buffers (`desc`, `it`, `bef`, …) — type a prefix and the completion menu offers them.
