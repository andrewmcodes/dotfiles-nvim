-- Andrew's Neovim — a curated lazy.nvim config for Ruby on Rails, Stimulus,
-- React (JS/JSX), ERB, Markdown, and AI agents.
--
-- One config, two homes: it runs as standalone Neovim AND inside the
-- VSCode-Neovim extension. Heavy UI plugins are gated on `vim.g.vscode`
-- (set by the extension) so VS Code keeps its own UI while Neovim still
-- provides motions, text objects, surround, flash, and comments.

-- Leader keys must be set before lazy.nvim and before any plugin loads.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Feature flags read by plugin specs.
vim.g.have_nerd_font = true

-- Options are safe in both environments (UI-only ones self-gate).
require("config.options")

-- Bootstrap lazy.nvim and load every spec in lua/plugins/.
require("config.lazy")

if vim.g.vscode then
  -- Inside VS Code: delegate LSP/files/search to VS Code commands.
  require("config.vscode")
else
  -- Standalone Neovim: core keymaps + autocommands (plugins add the rest).
  require("config.keymaps")
  require("config.autocmds")
end
