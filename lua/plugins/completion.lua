-- Completion via blink.cmp. version = "1.*" fetches a prebuilt Rust binary
-- (no cargo needed). copilot.lua itself is owned by ai.lua; here we only wire
-- the blink source through blink-copilot.
return {
  {
    "saghen/blink.cmp",
    cond = function()
      return not vim.g.vscode
    end,
    event = "InsertEnter",
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "fang2hou/blink-copilot",
    },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        menu = {
          border = "rounded",
        },
        -- Copilot provides its own ghost text via copilot.lua.
        ghost_text = {
          enabled = false,
        },
      },
      snippets = {
        preset = "default",
      },
      sources = {
        default = { "copilot", "lsp", "path", "snippets", "buffer" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
          -- friendly-snippets files them under languages that no Neovim buffer ever
          -- has: frameworks/rails.json -> "rails", ruby/rspec.json -> "rspec". Without
          -- this mapping every Rails and RSpec snippet (~350) is silently unreachable.
          snippets = {
            opts = {
              extended_filetypes = {
                ruby = { "rails", "rspec" },
                eruby = { "rails" },
              },
            },
          },
        },
      },
      signature = {
        enabled = true,
      },
      -- Falls back to the Lua implementation if no prebuilt binary is present.
      fuzzy = {
        implementation = "prefer_rust",
      },
    },
  },
}
