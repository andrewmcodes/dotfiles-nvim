# JavaScript, React & Stimulus workflow

Podia's frontend is **JavaScript + JSX (React 18)** — there is no TypeScript. Tooling reflects that: `vtsls` for intellisense, the ESLint LSP for diagnostics, Prettier for formatting, and Jest via neotest.

## Language servers

- **vtsls** attaches to `javascript` and `javascriptreact` buffers and provides completion, go-to-definition, references, rename, and inlay hints. It reads the project `jsconfig.json`, so path aliases (`@app`, `@components`, `@shared`, `@view_components`, `@spec`) resolve for go-to-definition and completion.
- **ESLint LSP** provides diagnostics and code actions using the project's flat config (`eslint.config.mjs`, ESLint 9). Formatting is turned off in ESLint (`format = false`) so it doesn't fight Prettier — ESLint just reports and fixes lint issues via `<leader>ca`.

LSP keys are the same everywhere: `gd`, `gr`, `gI`, `K`, `<leader>cr`, `<leader>ca`. See [keymaps.md](keymaps.md#code--lsp-active-when-a-server-is-attached).

## Formatting

Prettier runs on save (and via `<leader>cf`) for `.js`, `.jsx`, `.json`, `.css`, `.scss`, `.html`, `.yaml`, and `.md`. conform auto-detects the project-local `node_modules/.bin/prettier`, so the printWidth 120 from `package.json` is respected. To pause it: `:FormatDisable` / `:FormatDisable!` / `:FormatEnable`.

## JSX / HTML / ERB tags

`nvim-ts-autotag` auto-closes and auto-renames tags in `.jsx`, `.html`, and `.erb`. Change an opening tag name and the closing tag follows.

## Stimulus

`stimulus-language-server` provides completion for `data-controller`, `data-*-target`, and `data-action` inside `.erb`/`.html` views and in your `*_controller.js` files. Controllers live in per-area `controllers/` directories (e.g. `app/javascript/storefront/controllers/`) plus `app/components/**`. No configuration needed — start typing a `data-` attribute in a view.

## Testing (Jest)

[neotest](https://github.com/nvim-neotest/neotest) with the `neotest-jest` adapter runs `yarn jest`. The adapter is chosen by filetype, so the same keys work for both Jest and RSpec:

| Key | Action |
| --- | --- |
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>tl` | Re-run last |
| `<leader>ts` | Toggle summary |
| `<leader>to` / `<leader>tO` | Output float / panel |
| `<leader>tw` | Watch mode |

Specs live under `spec/javascript`.

## Tips

- `<leader>cs` (workspace symbols) and `gd` make cross-module navigation quick even with the alias imports.
- Completion is Copilot + LSP + snippets + buffer, in that priority — Copilot suggestions float to the top of the menu, and ghost text shows the inline suggestion (accept with `<M-l>`).
