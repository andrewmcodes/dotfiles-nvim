-- Markdown authoring. marksman LSP is configured in lsp.lua; this file adds
-- in-buffer rendering and a browser preview. Both are gated off under VS Code.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    ft = { "markdown" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = { enabled = true },
      code = { enabled = true },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview" },
    },
  },
}
