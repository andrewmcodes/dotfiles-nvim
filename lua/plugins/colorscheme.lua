-- Colorschemes. Tokyonight is active; catppuccin is installed as an alternative.
local function not_vscode()
  return not vim.g.vscode
end

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    cond = not_vscode,
    opts = {
      style = "night",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- Available alternative (not active). Switch with `:colorscheme catppuccin`.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    cond = not_vscode,
    opts = {
      flavour = "mocha",
    },
  },
}
