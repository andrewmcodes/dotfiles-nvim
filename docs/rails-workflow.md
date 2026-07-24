# Ruby on Rails workflow

Everything here is tuned for the Podia app: Ruby 4 / Rails 8, **Standard** for lint+format, `ruby-lsp` (with the Rails and RSpec addons), ERB views, and Stimulus controllers.

## Language server (ruby-lsp)

`ruby-lsp` is launched as `mise x -- ruby-lsp`, so it always runs under the project's pinned Ruby (Podia = 4.0.5) regardless of how you started Neovim. It re-execs itself into the project's composed bundle, which auto-loads:

- **ruby-lsp-rails** — Rails-aware features (model/association info, `pending migrations`, etc.).
- **ruby-lsp-rspec** — RSpec code lenses and test discovery.
- **Standard + RuboCop addons** — diagnostics and formatting via your `.standard.yml`.

Because `init_options.formatter = "auto"`, ruby-lsp detects Standard automatically. On save, Ruby and ERB buffers are formatted by ruby-lsp (conform intentionally has no Ruby formatter, so there's no double-formatting).

Useful commands: `:LspInfo` (what's attached), `:LspLog` (server output), `:checkhealth vim.lsp`.

Common LSP keys: `gd` definition, `gr` references, `K` hover, `<leader>ca` code action, `<leader>cr` rename, `<leader>cl` run code lens. See [keymaps.md](keymaps.md#code--lsp-active-when-a-server-is-attached).

> If `ruby_lsp` doesn't attach, it's almost always a Ruby-version/bundle issue. See [troubleshooting.md](troubleshooting.md#ruby-lsp-doesnt-attach).

## Formatting & linting

- **Format on save** is on. Ruby/ERB → ruby-lsp (Standard). Everything else (JS, SCSS, JSON, YAML, Markdown) → Prettier/stylua/shfmt via conform.
- Manual format: `<leader>cf`.
- Toggle autoformat: `:FormatDisable` (global), `:FormatDisable!` (this buffer), `:FormatEnable`.
- Diagnostics come from ruby-lsp (Standard/RuboCop) inline and in Trouble (`<leader>xx`).

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

## Fuzzy navigation (telescope-rails)

For "show me all the X and let me fuzzy-pick one," [telescope-rails.nvim](https://github.com/sato-s/telescope-rails.nvim) gives a picker per resource type:

| Key | Picker |
| --- | --- |
| `<leader>rm` | Models |
| `<leader>rc` | Controllers |
| `<leader>rv` | Views |
| `<leader>rs` | Specs |
| `<leader>ri` | Migrations |
| `<leader>rl` | Libs |

(Equivalent to `:Telescope rails models`, etc.) `<leader>ra` (alternate) and `<leader>rr` (related) come from vim-rails, so the whole `<leader>r` group is Rails navigation.

## Jump to any symbol

`<leader>cs` opens a live workspace-symbol picker (backed by ruby-lsp) — type a class or method name to jump anywhere in the app. `<leader>xs` (Trouble) outlines the current file's symbols.

## Jump to view / route (Code Lens)

ruby-lsp annotates controller actions with Code Lens links ("Jump to view", route info). Put the cursor on an action and press `<leader>cl` to follow them. This works because the config registers a `rubyLsp.openFile` command handler (in `lua/plugins/lsp.lua`) — without it, Neovim would error with `does not support command rubyLsp.openFile`. Code Lens refreshes automatically as you move around.

## ERB views

- `.erb` files (including `.html.erb`, `.json.erb`) are set to the `eruby` filetype so ruby-lsp, treesitter, and stimulus complete correctly.
- Treesitter highlights embedded Ruby inside HTML (`embedded_template` + `ruby` + `html` parsers).
- `<` in a tag auto-closes/renames via `nvim-ts-autotag`.

## Stimulus

`stimulus-language-server` attaches to `.erb`, `.html`, `.rb`, and `.js` buffers. In a view, completing `data-controller="…"`, `data-*-target`, and `data-action` offers the controllers/targets/actions defined in your `*_controller.js` files (which live in per-area `controllers/` directories). No extra setup — just start typing a `data-` attribute.

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

## Tips

- `end` is inserted automatically after `def`/`do`/`if`/`class` (vim-endwise).
- Symbol occurrences highlight on idle (document highlight) when the LSP supports it.
- Use `<leader>xs` (Trouble symbols) to outline a large model or controller.
