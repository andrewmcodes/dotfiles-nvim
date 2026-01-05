if vim.g.vscode then -- VSCode extension
  -- Remap folding keys
  vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = false, silent = true })
  vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = false, silent = true })

  local vscode = require('vscode')

  local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, function() vscode.call(rhs) end, { silent = true, noremap = true })
  end

  -- Remap folding keys
  map('n', 'zM', 'editor.foldAll')
  map('n', 'zR', 'editor.unfoldAll')
  map('n', 'zc', 'editor.fold')
  map('n', 'zC', 'editor.foldRecursively')
  map('n', 'zo', 'editor.unfold')
  map('n', 'zO', 'editor.unfoldRecursively')
  map('n', 'za', 'editor.toggleFold')

  vim.keymap.set({ "n", "x" }, "<leader>r", function()
    vscode.with_insert(function()
      vscode.action("editor.action.refactor")
    end)
  end)
end
