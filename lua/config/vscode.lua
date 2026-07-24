-- Loaded only inside the VSCode-Neovim extension (vim.g.vscode is set).
-- Neovim provides motions/text-objects/surround/flash/comments; everything
-- else (LSP, files, search, folding UI) is delegated to VS Code commands so
-- the leader-key muscle memory carries over to standalone Neovim.
if not vim.g.vscode then
  return
end

local vscode = require("vscode")
local map = vim.keymap.set

-- Move by visual lines.
map({ "n", "x" }, "j", "gj", { desc = "Down (visual line)" })
map({ "n", "x" }, "k", "gk", { desc = "Up (visual line)" })

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Code intelligence → VS Code.
map("n", "gd", function()
  vscode.action("editor.action.revealDefinition")
end, { desc = "Go to definition" })
map("n", "gr", function()
  vscode.action("editor.action.goToReferences")
end, { desc = "References" })
map("n", "gI", function()
  vscode.action("editor.action.goToImplementation")
end, { desc = "Implementations" })
map("n", "gy", function()
  vscode.action("editor.action.goToTypeDefinition")
end, { desc = "Type definition" })
map("n", "K", function()
  vscode.action("editor.action.showHover")
end, { desc = "Hover" })
map({ "n", "x" }, "<leader>ca", function()
  vscode.action("editor.action.quickFix")
end, { desc = "Code action" })
map("n", "<leader>cr", function()
  vscode.action("editor.action.rename")
end, { desc = "Rename symbol" })
map({ "n", "x" }, "<leader>cf", function()
  vscode.action("editor.action.formatDocument")
end, { desc = "Format" })
map("n", "]d", function()
  vscode.action("editor.action.marker.next")
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  vscode.action("editor.action.marker.prev")
end, { desc = "Prev diagnostic" })

-- Files / search / explorer → VS Code.
map("n", "<leader><space>", function()
  vscode.action("workbench.action.quickOpen")
end, { desc = "Find files" })
map("n", "<leader>ff", function()
  vscode.action("workbench.action.quickOpen")
end, { desc = "Find files" })
map("n", "<leader>/", function()
  vscode.action("workbench.action.findInFiles")
end, { desc = "Search in files" })
map("n", "<leader>,", function()
  vscode.action("workbench.action.showAllEditors")
end, { desc = "Buffers" })
map("n", "<leader>e", function()
  vscode.action("workbench.view.explorer")
end, { desc = "Explorer" })

-- Git / tests → VS Code.
map("n", "<leader>gg", function()
  vscode.action("workbench.view.scm")
end, { desc = "Source control" })
map("n", "<leader>tr", function()
  vscode.action("testing.runAtCursor")
end, { desc = "Run test at cursor" })

-- Folding → VS Code.
map("n", "za", function()
  vscode.action("editor.toggleFold")
end, { desc = "Toggle fold" })
map("n", "zR", function()
  vscode.action("editor.unfoldAll")
end, { desc = "Open all folds" })
map("n", "zM", function()
  vscode.action("editor.foldAll")
end, { desc = "Close all folds" })
