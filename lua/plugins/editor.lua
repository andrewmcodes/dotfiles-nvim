-- Editor tooling: telescope, neo-tree, trouble, todo-comments, flash, matchup,
-- undotree, persistence.
-- Most are gated off under VS Code; flash is NOT (works in both — see build contract).
local function not_vscode()
  return not vim.g.vscode
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    event = "VeryLazy",
    cond = not_vscode,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader><space>",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Recent Files",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").git_files()
        end,
        desc = "Find Git Files",
      },
      {
        "<leader>,",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>/",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Grep (Live)",
      },
      {
        "<leader>sw",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Search Word",
        mode = { "n", "x" },
      },
      {
        "<leader>sg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Search by Grep",
      },
      {
        "<leader>sh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Search Help",
      },
      {
        "<leader>sk",
        function()
          require("telescope.builtin").keymaps()
        end,
        desc = "Search Keymaps",
      },
      {
        "<leader>sd",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "Search Diagnostics",
      },
      {
        "<leader>sr",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume Search",
      },
      {
        "<leader>sc",
        function()
          require("telescope.builtin").commands()
        end,
        desc = "Search Commands",
      },
      {
        "<leader>sn",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Search Nvim Config",
      },
    },
    opts = function()
      return {
        defaults = {
          mappings = {
            i = { ["<c-enter>"] = "to_fuzzy_refine" },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    cond = not_vscode,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    -- `cmd`/`keys` don't fire for `nvim .`, so load neo-tree eagerly when nvim is
    -- launched on a directory. Its netrw hijack then takes over the "." buffer.
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = (vim.uv or vim.loop).fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Explorer (Toggle)" },
      { "<leader>E", "<cmd>Neotree focus reveal<cr>", desc = "Explorer (Reveal File)" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        -- Take over directory buffers (e.g. `nvim .`) in the current window.
        hijack_netrw_behavior = "open_current",
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 32,
      },
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    cond = not_vscode,
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP Definitions / References (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    cond = not_vscode,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo Comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev Todo Comment",
      },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search Todos" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todos (Trouble)" },
    },
  },

  -- Restores `%` on Ruby's def/if/do/class → end, which this config would otherwise
  -- lack entirely: config/lazy.lua disables both `matchit` (the runtime plugin that
  -- consumes Ruby's ftplugin `b:match_words`) and `matchparen`. matchup supersedes
  -- both, is treesitter-aware, and adds `]%`/`[%` motions plus `i%`/`a%` textobjects.
  -- Gated: VS Code has its own bracket matching.
  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    cond = not_vscode,
    init = function()
      -- Offscreen match shown in the statusline area rather than a popup, which
      -- otherwise fights noice/lualine.
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
      vim.g.matchup_matchparen_deferred = 1 -- don't recompute on every cursor move
    end,
  },

  -- Visual undo history. `undofile` is on (config/options.lua), so the history
  -- already persists across sessions — this is the only way to actually see it.
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
    cond = not_vscode,
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
    },
    init = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- Session restore, scoped per directory — reopening a project brings back the
  -- buffers and window layout instead of an empty dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    cond = not_vscode,
    opts = {},
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session (this dir)",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- Flash: NOT gated — jump motions work inside VS Code too.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
}
