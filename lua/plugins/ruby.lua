-- Ruby / Rails editing ergonomics and navigation.
-- LSP (ruby_lsp) is configured in lsp.lua; this file adds tpope's
-- Rails/projectionist/bundler/endwise tooling and telescope-rails fuzzy
-- resource pickers, all under the <leader>r group.
--
-- The full Rails navigation story:
--   * ruby-lsp go-to-definition (gd), references (gr), workspace symbols (<leader>cs)
--   * ruby-lsp Code Lens "Jump to view"/route links (<leader>cl) — see lsp.lua
--   * vim-rails :A / :Emodel / :Eview / gf on partials & associations
--   * telescope-rails fuzzy pickers per resource (<leader>rm/rc/rv/rs/ri/rl)
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
  -- Fuzzy pickers scoped to each Rails resource type (ctrlp-rails for telescope).
  {
    "sato-s/telescope-rails.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>rm", "<cmd>Telescope rails models<cr>", desc = "Rails: models" },
      { "<leader>rc", "<cmd>Telescope rails controllers<cr>", desc = "Rails: controllers" },
      { "<leader>rv", "<cmd>Telescope rails views<cr>", desc = "Rails: views" },
      { "<leader>rs", "<cmd>Telescope rails specs<cr>", desc = "Rails: specs" },
      { "<leader>ri", "<cmd>Telescope rails migrations<cr>", desc = "Rails: migrations" },
      { "<leader>rl", "<cmd>Telescope rails libs<cr>", desc = "Rails: libs" },
    },
    config = function()
      require("telescope").load_extension("rails")
    end,
  },
}
