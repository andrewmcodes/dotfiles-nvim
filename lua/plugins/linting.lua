-- Standalone linting via nvim-lint. Only Markdown needs it here: JS is linted by
-- the eslint LSP and Ruby by ruby-lsp, both of which emit their own diagnostics.
return {
  {
    "mfussenegger/nvim-lint",
    cond = function()
      return not vim.g.vscode
    end,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        markdown = { "markdownlint" },
      }

      local lint_group = vim.api.nvim_create_augroup("podia-nvim-lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = lint_group,
        callback = function()
          -- Skip non-modifiable buffers (e.g. read-only previews).
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
