-- Colorschemes. onedarkpro is active; tokyonight and catppuccin are installed as alternatives.
local function not_vscode()
  return not vim.g.vscode
end

return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,
    cond = not_vscode,
    opts = {
      options = {
        cursorline = true,
      },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts)
      vim.cmd.colorscheme("onedark")
    end,
  },

  -- Available alternative (not active). Switch with `:colorscheme tokyonight-night`.
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    cond = not_vscode,
    opts = {
      style = "night",
    },
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
