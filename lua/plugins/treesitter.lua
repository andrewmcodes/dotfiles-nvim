-- Treesitter: highlighting + indentation. Gated off under VS Code (uses its own highlighter).
--
-- This targets the rewritten `main` branch (required on Neovim 0.12+). It is a
-- different plugin from the classic `master` API:
--   * No lazy-loading — it loads at startup (`lazy = false`).
--   * No `ensure_installed`/`auto_install` and no `nvim-treesitter.configs` module.
--     Parsers are installed via `install()`; highlighting and indentation are enabled
--     per-buffer through the core `vim.treesitter` API in a FileType autocmd.
--   * Parsers are compiled locally, which needs the `tree-sitter` CLI (installed via
--     mise) plus a C compiler. As with ruby-lsp, launch nvim from a mise-activated
--     shell so the CLI is on PATH. First launch compiles parsers in the background;
--     reopen a file if it isn't highlighted yet.
local function not_vscode()
  return not vim.g.vscode
end

-- Parsers to keep installed. `install()` skips any already present, so re-running
-- this on every startup is cheap.
local ensure_installed = {
  "ruby",
  "embedded_template", -- ERB (filetype `eruby`)
  "html",
  "javascript", -- also parses JSX; the `javascriptreact` filetype maps here
  "css",
  "scss",
  "json", -- also highlights the `jsonc` filetype; there is no separate jsonc parser on `main`
  "yaml",
  "markdown",
  "markdown_inline",
  "lua",
  "luadoc",
  "bash",
  "vim",
  "vimdoc",
  "gitcommit",
  "git_rebase",
  "diff",
  "regex",
  "printf",
  "query",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- the rewrite; requires Neovim 0.12+ (the frozen `master` API is 0.11-only)
    lazy = false, -- the main branch does not support lazy-loading
    build = ":TSUpdate",
    cond = not_vscode,
    config = function()
      local ts = require("nvim-treesitter")

      -- Install any missing parsers (async; already-installed ones are skipped).
      local installed = ts.get_installed("parsers")
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end

      -- Filetype → parser mappings that are not 1:1, so `vim.treesitter.start` can
      -- resolve the language from a buffer's filetype.
      vim.treesitter.language.register("embedded_template", { "eruby" })
      vim.treesitter.language.register("javascript", { "javascriptreact" })

      -- The main branch auto-enables nothing: turn on treesitter highlighting +
      -- indentation per buffer, once a parser for its language is available.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local ft = vim.bo[buf].filetype
          -- pcall bails when no parser is installed for this filetype yet.
          if not pcall(vim.treesitter.start, buf) then
            return
          end
          -- Treesitter indentation, except where its indenter is unreliable (Ruby).
          if ft ~= "ruby" and ft ~= "eruby" then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
          -- Ruby: keep Vim's regex highlighting alongside treesitter (parity with the
          -- old `additional_vim_regex_highlighting = { "ruby" }`).
          if ft == "ruby" then
            vim.bo[buf].syntax = "on"
          end
        end,
      })
    end,
  },
}
