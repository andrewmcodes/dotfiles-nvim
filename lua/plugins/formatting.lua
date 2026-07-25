-- Formatting via conform.nvim. Prettier is auto-detected from the project's
-- node_modules/.bin (printWidth 120 from package.json).
--
-- Ruby is deliberately absent — it formats through ruby-lsp (Standard/RuboCop).
-- ERB is NOT: ruby-lsp has no ERB formatter (Shopify closed that as not-planned),
-- so eruby goes through Herb's `herb-format` below.
return {
  {
    "stevearc/conform.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format Buffer",
      },
    },
    opts = {
      -- Not in conform's registry, so define it here. `herb-format` comes from the
      -- npm package @herb-tools/formatter and reads .herb.yml from the project root
      -- for indentWidth / maxLineLength.
      --
      -- Resolved from the project's own node_modules/.bin first (same mechanism as
      -- prettier above), falling back to a global install — so adding
      -- @herb-tools/formatter to package.json is enough, and the whole team gets the
      -- same version. See docs/setup.md.
      formatters = {
        herb_format = {
          -- Wrapped in a closure so the `conform.util` require happens at format
          -- time; at spec-definition time conform is not yet on the runtimepath.
          command = function(self, ctx)
            return require("conform.util").from_node_modules("herb-format")(self, ctx)
          end,
          stdin = true,
        },
      },
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        sh = { "shfmt" },
        -- Claiming eruby here also stops `lsp_format = "fallback"` from asking
        -- herb_ls/ruby_lsp to format it, so there's no double-format ambiguity.
        -- Resolved lazily: until @herb-tools/formatter is installed this returns {},
        -- so saving a view is a silent no-op instead of an error on every write.
        eruby = function(bufnr)
          if require("conform").get_formatter_info("herb_format", bufnr).available then
            return { "herb_format" }
          end
          return {}
        end,
      },
      format_on_save = function(bufnr)
        -- Respect the global / buffer-local disable toggles.
        -- Herb's formatter is still an experimental preview upstream, so the first
        -- save of a long-lived .erb view can produce a large reformat diff. Use
        -- `:FormatDisable!` (this buffer) or `:FormatDisable` (global) to opt out.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
    init = function()
      -- :FormatDisable        -> disable autoformat globally
      -- :FormatDisable!       -> disable autoformat for this buffer only
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save (! = current buffer only)",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
  },
}
