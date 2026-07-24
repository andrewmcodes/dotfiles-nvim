-- LSP configuration using the Neovim 0.11+ native API (vim.lsp.config / vim.lsp.enable).
-- Mason installs the servers + CLI tools; ruby-lsp is provided by the project bundle
-- (NOT installed via Mason) and auto-loads its rails/rspec addons.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cond = function()
      return not vim.g.vscode
    end,
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      { "j-hui/fidget.nvim", opts = {} },
      "b0o/schemastore.nvim",
    },
    config = function()
      -- Mason bootstrap ------------------------------------------------------
      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Language servers
          "lua-language-server",
          "vtsls",
          "eslint-lsp",
          "stimulus-language-server",
          "css-lsp",
          "html-lsp",
          "json-lsp",
          "yaml-language-server",
          "marksman",
          "bash-language-server",
          "taplo",
          -- Formatters / linters used by conform.nvim + nvim-lint
          "stylua",
          "shfmt",
          "markdownlint",
          "prettier",
        },
      })
      -- We enable servers ourselves below, so disable auto-enable.
      require("mason-lspconfig").setup({ automatic_enable = false })

      -- Capabilities (prefer blink.cmp; fall back to defaults) ---------------
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end
      vim.lsp.config("*", { capabilities = capabilities })

      -- Per-server configuration --------------------------------------------
      -- Ruby: uses the project's composed bundle (ruby-lsp-rails + ruby-lsp-rspec).
      -- Launch through `mise x` so ruby-lsp always runs under the project's pinned
      -- Ruby (e.g. Podia's 4.0.5) regardless of the ambient PATH nvim inherited.
      -- Falls back to a bare `ruby-lsp` when mise isn't installed.
      local ruby_lsp_cmd = { "ruby-lsp" }
      if vim.fn.executable("mise") == 1 then
        ruby_lsp_cmd = { "mise", "x", "--", "ruby-lsp" }
      end
      vim.lsp.config("ruby_lsp", {
        cmd = ruby_lsp_cmd,
        filetypes = { "ruby", "eruby" },
        init_options = {
          formatter = "auto",
          enabledFeatures = {
            "codeActions",
            "codeLens",
            "completion",
            "definition",
            "diagnostics",
            "documentHighlights",
            "documentLink",
            "documentSymbols",
            "foldingRanges",
            "formatting",
            "hover",
            "inlayHint",
            "onTypeFormatting",
            "selectionRanges",
            "semanticHighlighting",
            "signatureHelp",
            "typeHierarchy",
            "workspaceSymbol",
          },
          featuresConfiguration = {
            inlayHint = { enableAll = true },
          },
        },
      })

      -- JavaScript / JSX (no TypeScript in this project).
      vim.lsp.config("vtsls", {
        filetypes = { "javascript", "javascriptreact" },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            tsserver = {
              globalPlugins = {},
            },
          },
          javascript = {
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = false },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              enumMemberValues = { enabled = false },
            },
          },
        },
      })

      -- ESLint: diagnostics + code actions only; Prettier owns formatting.
      vim.lsp.config("eslint", {
        filetypes = { "javascript", "javascriptreact" },
        settings = {
          workingDirectories = { mode = "auto" },
          format = false,
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- JSON / YAML get schema definitions from SchemaStore.
      local ok_schema, schemastore = pcall(require, "schemastore")
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = ok_schema and schemastore.json.schemas() or nil,
            validate = { enable = true },
          },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = ok_schema and schemastore.yaml.schemas() or nil,
          },
        },
      })

      -- Enable all servers (cssls/html/bashls/taplo/marksman/stimulus_ls use defaults).
      vim.lsp.enable({
        "lua_ls",
        "ruby_lsp",
        "vtsls",
        "eslint",
        "stimulus_ls",
        "cssls",
        "html",
        "jsonls",
        "yamlls",
        "marksman",
        "bashls",
        "taplo",
      })

      -- Diagnostics display --------------------------------------------------
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
        },
      })

      -- Buffer-local keymaps + features on attach ----------------------------
      local attach_group = vim.api.nvim_create_augroup("podia-lsp-attach", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = attach_group,
        callback = function(event)
          local bufnr = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Prefer Telescope pickers for goto-style maps, fall back to vim.lsp.buf.
          local function picker(name, fallback)
            local ok_tel, builtin = pcall(require, "telescope.builtin")
            if ok_tel and builtin[name] then
              return builtin[name]
            end
            return fallback
          end

          map("n", "gd", picker("lsp_definitions", vim.lsp.buf.definition), "Goto Definition")
          map("n", "gr", picker("lsp_references", vim.lsp.buf.references), "Goto References")
          map("n", "gI", picker("lsp_implementations", vim.lsp.buf.implementation), "Goto Implementation")
          map("n", "gy", picker("lsp_type_definitions", vim.lsp.buf.type_definition), "Goto Type Definition")
          map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cl", vim.lsp.codelens.run, "Run Code Lens")

          -- Toggle inlay hints (capability-gated).
          if client and client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, "Toggle Inlay Hints")
          end

          -- Code lens auto-refresh (e.g. ruby-lsp "run test" lenses).
          if client and client:supports_method("textDocument/codeLens") then
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              group = attach_group,
              buffer = bufnr,
              callback = function()
                vim.lsp.codelens.refresh({ bufnr = bufnr })
              end,
            })
          end

          -- Document highlight under cursor when idle.
          if client and client:supports_method("textDocument/documentHighlight") then
            local highlight_group = vim.api.nvim_create_augroup("podia-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = highlight_group,
              buffer = bufnr,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = highlight_group,
              buffer = bufnr,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("podia-lsp-detach", { clear = true }),
              callback = function(detach)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "podia-lsp-highlight", buffer = detach.buf })
              end,
            })
          end
        end,
      })
    end,
  },

  -- Lua development helpers for editing this config itself.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cond = function()
      return not vim.g.vscode
    end,
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        "luvit-meta/library",
      },
    },
  },
}
