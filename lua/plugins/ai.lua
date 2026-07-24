-- AI tooling — subscription based, NO API keys.
-- Owns <leader>a (Copilot / CopilotChat / CLI agent terminals) and
-- <leader>A (Avante, remapped off its default <leader>a prefix).
-- Copilot subscription powers inline suggestions, chat, and Avante.
return {
  -- Inline suggestions. This is the ONLY declaration of copilot.lua in the config;
  -- completion.lua consumes it via blink-copilot as a dependency.
  {
    "zbirenbaum/copilot.lua",
    cond = function()
      return not vim.g.vscode
    end,
    event = "InsertEnter",
    cmd = "Copilot",
    keys = {
      {
        "<leader>at",
        function()
          require("copilot.suggestion").toggle_auto_trigger()
        end,
        desc = "Toggle Copilot suggestions",
      },
    },
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = false,
        gitcommit = true,
        ["*"] = true,
      },
    },
  },

  -- Chat / prompt actions. Visual-mode maps use <cmd> so CopilotChat's selection
  -- function still sees the live visual range (mode is preserved by <cmd>).
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    cmd = { "CopilotChat", "CopilotChatToggle", "CopilotChatReset" },
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
    },
    build = "make tiktoken",
    opts = {
      model = "gpt-4o",
    },
    keys = {
      { "<leader>aa", "<cmd>CopilotChatToggle<cr>", mode = { "n", "v" }, desc = "Toggle chat" },
      { "<leader>ax", "<cmd>CopilotChatReset<cr>", desc = "Reset chat" },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        mode = { "n", "v" },
        desc = "Prompt actions",
      },
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Explain code" },
      { "<leader>af", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Fix code" },
      { "<leader>av", "<cmd>CopilotChatReview<cr>", mode = { "n", "v" }, desc = "Review code" },
      { "<leader>aT", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "Generate tests" },
    },
  },

  -- Avante — full-file agentic edits. Uses the Copilot provider (no API key).
  -- All leader mappings are relocated under <leader>A so Avante does NOT register
  -- its default <leader>a… maps (which would collide with the Copilot group).
  {
    "yetone/avante.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    build = "make",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      provider = "copilot",
      -- Move every leader-prefixed mapping from <leader>a… to <leader>A…
      -- (superset of Avante's known defaults; unknown keys are harmlessly ignored).
      mappings = {
        ask = "<leader>Aa",
        new_ask = "<leader>An",
        edit = "<leader>Ae",
        refresh = "<leader>Ar",
        focus = "<leader>Af",
        stop = "<leader>AS",
        select_model = "<leader>A?",
        toggle = {
          default = "<leader>At",
          debug = "<leader>Ad",
          hint = "<leader>Ah",
          suggestion = "<leader>As",
          repomap = "<leader>AR",
        },
        files = {
          add_current = "<leader>Ac",
          add_all_buffers = "<leader>AB",
        },
      },
    },
    keys = {
      { "<leader>Aa", "<cmd>AvanteAsk<cr>", mode = { "n", "v" }, desc = "Avante ask" },
      { "<leader>At", "<cmd>AvanteToggle<cr>", desc = "Avante toggle" },
      { "<leader>Ae", "<cmd>AvanteEdit<cr>", mode = "v", desc = "Avante edit" },
    },
    -- ── Drive the Claude subscription instead of Copilot (still NO API key) ──
    -- Avante can talk to the authenticated `claude` CLI over ACP. To switch,
    -- replace the `opts` above with something like:
    --
    --   opts = {
    --     provider = "claude-code",
    --     acp_providers = {
    --       ["claude-code"] = {
    --         -- Uses your logged-in Claude Code CLI; no ANTHROPIC_API_KEY needed.
    --         command = "claude",
    --         args = { "--acp" },
    --         env = {},
    --       },
    --     },
    --     -- ...keep the <leader>A mappings block from above...
    --   }
    --
    -- (Left commented so the default provider stays Copilot.)
  },

  -- CLI agent terminals via snacks.nvim (declared/configured in ui.lua).
  -- Keys-only merge spec — no opts, so ui.lua's snacks config is preserved.
  -- Each terminal is keyed by its command string, so it toggles/reuses per agent.
  {
    "folke/snacks.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    keys = {
      {
        "<leader>ac",
        function()
          require("snacks").terminal.toggle("claude", { win = { position = "right" } })
        end,
        desc = "Claude Code",
      },
      {
        "<leader>ao",
        function()
          require("snacks").terminal.toggle("opencode", { win = { position = "right" } })
        end,
        desc = "opencode",
      },
      {
        "<leader>aC",
        function()
          require("snacks").terminal.toggle("codex", { win = { position = "right" } })
        end,
        desc = "Codex",
      },
    },
  },
}
