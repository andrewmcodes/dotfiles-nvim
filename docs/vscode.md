# Using this config inside VS Code

This config also runs under the [VSCode-Neovim](https://github.com/vscode-neovim/vscode-neovim) extension, which embeds a real Neovim process for editing while VS Code keeps its own UI, LSP, search, and file tree. That makes for a smooth transition: the same leader-key muscle memory works in both places.

## Setup

1. Install the **VSCode Neovim** extension (`asvetliakov.vscode-neovim`).
2. Point it at your Neovim binary in VS Code settings: `"vscode-neovim.neovimExecutablePaths.darwin": "/opt/homebrew/bin/nvim"` (adjust for your install).
3. The extension sets `vim.g.vscode`, and this config detects it automatically — no separate config needed.

## What loads

- **Skipped** (VS Code owns these): colorscheme, statusline, bufferline, dashboard, file tree, Telescope, LSP, completion, git UI, tests, AI, treesitter highlighting, noice.
- **Active** (Neovim owns these): motions and text objects (mini.ai), surround (mini.surround), autopairs (mini.pairs), flash jumps, `gc` comments, and `.` repeat.

This split is enforced by `cond = not vim.g.vscode` on the UI specs; the editing plugins in `lua/plugins/editing.lua` deliberately have no such guard.

## Keymaps in VS Code

`lua/config/vscode.lua` maps the same leader keys to VS Code commands so navigation feels identical:

| Key | VS Code action |
| --- | --- |
| `gd` `gr` `gI` `gy` `K` | Definition / references / implementations / type def / hover |
| `<leader>ca` `<leader>cr` `<leader>cf` | Quick fix / rename / format document |
| `]d` `[d` | Next / previous problem |
| `<leader><space>` / `<leader>ff` | Quick open |
| `<leader>/` | Find in files |
| `<leader>,` | Show all editors |
| `<leader>e` | Explorer |
| `<leader>gg` | Source control |
| `<leader>tr` | Run test at cursor |
| `za` `zR` `zM` | Toggle / open all / close all folds |
| `j` `k` | Move by visual line (`gj`/`gk`) |

Plus all the Neovim-native motions: `s`/`S` flash, `sa`/`sd`/`sr` surround, `a`/`i` text objects, `gcc` comment.

## Caveats

- Anything backed by a skipped plugin (Telescope, neotest, Avante, etc.) is unavailable in VS Code by design — use the VS Code equivalent.
- If a mapping feels unresponsive, it may be intercepted by VS Code; check the extension's keybinding passthrough settings.
