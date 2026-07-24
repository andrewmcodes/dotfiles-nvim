-- UI layer: snacks (QoL), lualine, bufferline, which-key, noice. All gated off under VS Code.
local function not_vscode()
  return not vim.g.vscode
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    cond = not_vscode,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      indent = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true },
      statuscolumn = { enabled = true },
      input = { enabled = true },
      -- terminal + lazygit are on by default and used by git.lua / ai.lua.
      dashboard = {
        enabled = true,
        preset = {
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = function()
                require("telescope.builtin").find_files()
              end,
            },
            {
              icon = " ",
              key = "r",
              desc = "Recent Files",
              action = function()
                require("telescope.builtin").oldfiles()
              end,
            },
            {
              icon = " ",
              key = "g",
              desc = "Grep",
              action = function()
                require("telescope.builtin").live_grep()
              end,
            },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
              end,
            },
            {
              icon = " ",
              key = "?",
              desc = "Cheatsheet",
              action = function()
                require("which-key").show({ global = true })
              end,
            },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = "<cmd>Lazy<cr>" },
            { icon = " ", key = "q", desc = "Quit", action = "<cmd>qa<cr>" },
          },
        },
      },
    },
    config = function(_, opts)
      local snacks = require("snacks")
      snacks.setup(opts)

      -- UI toggles under <leader>u.
      snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>ul")
      snacks.toggle.diagnostics():map("<leader>ud")
      vim.keymap.set("n", "<leader>un", function()
        snacks.notifier.hide()
      end, { desc = "Dismiss Notifications" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    cond = not_vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "onedark",
        icons_enabled = true,
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    cond = not_vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
      {
        "<leader>bo",
        function()
          Snacks.bufdelete.other()
        end,
        desc = "Delete Other Buffers",
      },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    cond = not_vscode,
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- One-key cheatsheet: the live, always-accurate map of every keybinding.
      vim.keymap.set("n", "<leader>?", function()
        wk.show({ global = true })
      end, { desc = "Cheatsheet (all keymaps)" })

      -- Auto-show the cheatsheet on startup when nvim opens with no file (i.e. on
      -- the dashboard). Deferred so which-key has fully registered every mapping.
      if vim.fn.argc() == 0 then
        vim.schedule(function()
          pcall(function()
            wk.show({ global = true })
          end)
        end)
      end

      -- Group labels for every leader prefix used across the config.
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>s", group = "Search" },
        { "<leader>c", group = "Code" },
        { "<leader>g", group = "Git" },
        { "<leader>gh", group = "Hunks" },
        { "<leader>t", group = "Test" },
        { "<leader>a", group = "AI" },
        { "<leader>A", group = "Avante" },
        { "<leader>b", group = "Buffer" },
        { "<leader>r", group = "Rails" },
        { "<leader>u", group = "UI" },
        { "<leader>x", group = "Trouble" },
      })
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    cond = not_vscode,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
      },
      cmdline = { view = "cmdline_popup" },
      -- Let snacks.notifier own notifications; noice handles cmdline/messages/LSP.
      notify = { enabled = false },
      messages = { enabled = true },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },
}
