-- JavaScript / JSX editing ergonomics (NO TypeScript in this stack).
-- eslint + vtsls live in lsp.lua and prettier in formatting.lua; this file only
-- adds auto close/rename of JSX/HTML/ERB tags via treesitter.
return {
  {
    "windwp/nvim-ts-autotag",
    cond = function()
      return not vim.g.vscode
    end,
    ft = { "html", "javascriptreact", "eruby", "xml" },
    opts = {},
  },
}
