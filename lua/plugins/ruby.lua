-- Ruby / Rails editing ergonomics and navigation.
-- LSP (ruby_lsp) is configured in lsp.lua; this file only adds tpope's
-- Rails/projectionist/bundler/endwise tooling plus a small <leader>r group.
return {
  {
    "tpope/vim-projectionist",
    cond = function()
      return not vim.g.vscode
    end,
    event = "VeryLazy",
  },
  {
    "tpope/vim-rails",
    cond = function()
      return not vim.g.vscode
    end,
    dependencies = { "tpope/vim-projectionist" },
    ft = { "ruby", "eruby" },
    cmd = {
      "Rails",
      "A",
      "AV",
      "AS",
      "AT",
      "R",
      "Emodel",
      "Eview",
      "Econtroller",
      "Emigration",
    },
    keys = {
      { "<leader>ra", "<cmd>A<cr>", desc = "Rails: alternate file" },
      { "<leader>rr", "<cmd>R<cr>", desc = "Rails: related file" },
    },
  },
  {
    "tpope/vim-bundler",
    cond = function()
      return not vim.g.vscode
    end,
    ft = { "ruby", "eruby" },
  },
  {
    "tpope/vim-endwise",
    cond = function()
      return not vim.g.vscode
    end,
    ft = { "ruby", "eruby", "lua", "sh", "vim" },
  },
}
