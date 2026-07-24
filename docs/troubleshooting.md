# Troubleshooting

Start with `:checkhealth` and `:Lazy` (press `L` for the log). Most issues fall into the buckets below.

## ruby_lsp doesn't attach

Symptom: no `ruby_lsp` in `:LspInfo`; `:LspLog` shows `Bundler::RubyVersionMismatch` or `bundler: failed to load command: ruby-lsp`.

Cause: ruby-lsp ran under the wrong Ruby. This config launches it as `mise x -- ruby-lsp` to use the project's pinned Ruby, so:

1. Make sure the project's Ruby is installed: `mise install` in the repo.
2. Confirm resolution: `mise x -- ruby -v` should print the Gemfile's version, and `mise x -- ruby-lsp --version` should succeed.
3. Open Neovim from inside the project directory so `mise` resolves the right config.
4. If the composed bundle is stale, delete `.ruby-lsp/` in the project and reopen — ruby-lsp regenerates it.

## Language servers / formatters missing

Mason installs them on first file open. If something's absent:

- `:Mason` — check install state; press `i` to install a highlighted package.
- `:MasonToolsInstall` — (re)install everything in the ensure_installed list.
- Confirm the tool exists: `:echo exepath('vtsls')`.

## Treesitter errors or missing highlights

- `:TSUpdate` to build/update parsers (needs the `tree-sitter` CLI — provided via mise — plus a C compiler like `cc`).
- `:checkhealth vim.treesitter`.
- nvim-treesitter runs the rewritten `main` branch (required on Neovim 0.12+; the old `master` `.configs` API is 0.11-only). It is **not** lazy-loaded, and highlighting/indentation are enabled per-buffer from a `FileType` autocmd in `treesitter.lua` rather than via `ensure_installed`. If a file opens unhighlighted on the very first launch, the parser is still compiling in the background — reopen it once install finishes. Confirm the CLI is reachable with `:echo exepath('tree-sitter')` (launch nvim from a mise-activated shell if it's empty).

## Completion has no fuzzy matching / "no rust binary"

`blink.cmp` downloads a prebuilt Rust fuzzy binary on first insert. If offline, it falls back to a Lua matcher automatically (slower, still works). To force Lua and silence it, set `fuzzy = { implementation = "lua" }` in `lua/plugins/completion.lua`.

## Avante won't build or load

- `:Lazy build avante.nvim` re-runs `make` (downloads the prebuilt native lib; needs `make`, no cargo).
- Verify: `:lua require("avante_lib").load()` should not error.
- Avante uses the Copilot provider, so make sure `:Copilot status` is signed in.

## Copilot not suggesting

- `:Copilot auth` then `:Copilot status`.
- Suggestions are auto-triggered; toggle with `<leader>at`. Accept with `<M-l>` (Option-l on macOS — ensure your terminal sends Alt/Option as Meta).

## Icons look like boxes

Your terminal isn't using a Nerd Font. Set the terminal font to JetBrainsMono Nerd Font (or any Nerd Font).

## Alt/Option keymaps don't work (macOS)

`<A-j>`/`<A-k>` (move lines) and `<M-l>` (accept Copilot) need the terminal to send Option as Meta. In most terminals: enable "Use Option as Meta key" (Terminal.app: Profiles → Keyboard; iTerm2: Profiles → Keys; Ghostty: `macos-option-as-alt = true`).

## Slow startup

- `:Lazy profile` shows per-plugin load time.
- Everything is lazy-loaded by event/ft/cmd/keys; if startup is slow, the culprit is usually a `lazy = false` plugin (colorscheme, snacks) or treesitter on a huge file (snacks `bigfile` should disable features automatically).

## Full reset

```
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

Then reopen Neovim — plugins and tools reinstall from `lazy-lock.json`.
