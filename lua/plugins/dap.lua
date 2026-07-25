-- Debugging. Owns the <leader>d namespace.
--
-- Ruby is driven by nvim-dap-ruby, which talks to the `debug` gem's `rdbg` over
-- TCP (ruby/debug does not speak DAP over stdio, so an "executable" adapter can't
-- work). The gem must be in the project's Gemfile.
--
-- Two ways in:
--   1. Debug a spec — <leader>db to set a breakpoint, then <leader>td (test.lua),
--      which runs neotest with `strategy = "dap"`. That keymap has existed all
--      along but errored until this file was added.
--   2. Attach to a running server — start it with the debugger open:
--        RUBY_DEBUG_OPEN=true RUBY_DEBUG_HOST=127.0.0.1 RUBY_DEBUG_PORT=38698 bin/rails s
--      then <leader>dc and pick the "attach" configuration.
return {
  {
    "mfussenegger/nvim-dap",
    cond = function()
      return not vim.g.vscode
    end,
    dependencies = {
      { "suketa/nvim-dap-ruby", config = true },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {},
      },
      -- Renders variable values inline next to the code as you step. The most
      -- legible part of DAP if you've never used a debugger UI before.
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
            if cond and cond ~= "" then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue / Start",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>dK",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Inspect Value (hover)",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle Debug UI",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
          require("dapui").close()
        end,
        desc = "Terminate Session",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Open the UI when a session starts, close it when it ends, so <leader>td
      -- (debug nearest spec) needs no extra step.
      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      -- Breakpoint signs (Nerd Font, matching the diagnostic signs in lsp.lua).
      vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = " ", texthl = "DiagnosticInfo", linehl = "Visual" })
    end,
  },
}
