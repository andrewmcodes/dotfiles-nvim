-- Treesitter: highlighting + indentation. Gated off under VS Code (uses its own highlighter).
local function not_vscode()
  return not vim.g.vscode
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- classic .configs API (the `main` rewrite has a different setup)
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cond = not_vscode,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    -- Use the classic config module API (stable on the default branch).
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "ruby",
        "embedded_template",
        "html",
        "javascript", -- also parses JSX; there is no separate "jsx" parser
        "css",
        "scss",
        "json",
        "jsonc",
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
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- Ruby's indent/embedded highlighting is happier with Vim's regex engine alongside.
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = {
        enable = true,
        -- Treesitter's Ruby indenter is unreliable; let Vim handle it.
        disable = { "ruby" },
      },
    },
  },
}
