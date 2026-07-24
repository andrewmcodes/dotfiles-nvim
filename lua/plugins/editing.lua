-- Editing enhancements that work in BOTH standalone Neovim and VS Code.
-- IMPORTANT: these must NOT be gated with `cond` (see build contract).
return {
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      -- Better around/inside textobjects. Built-in specs only (NO treesitter),
      -- so it keeps working when treesitter is gated off under VS Code.
      require("mini.ai").setup({ n_lines = 500 })

      -- Surround: default mappings (sa add, sd delete, sr replace, sf/sF find, sh highlight, sn update).
      require("mini.surround").setup()

      -- Autopairs.
      require("mini.pairs").setup()
    end,
  },

  -- Enhances the native (Neovim 0.10+) `gc`/`gcc` commenting with treesitter-aware contexts.
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Lets `.` repeat supported plugin maps (e.g. mini.surround).
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },
}
