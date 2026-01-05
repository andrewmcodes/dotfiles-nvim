-- Ruby LSP Plugin
-- This plugin provides enhanced Ruby language server support with automatic installation
-- and smart detection of both global and bundled ruby-lsp gems.
--
-- Installation:
--   For global installation (recommended):
--     gem install ruby-lsp
--
--   For per-project installation (optional):
--     Add to Gemfile: gem 'ruby-lsp', group: :development
--     Run: bundle install

return {
  'adam12/ruby-lsp.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
  },
  ft = 'ruby', -- Load only for Ruby files
  opts = {
    -- Automatically install ruby-lsp gem if not found
    auto_install = true,

    -- LSP configuration options
    lspconfig = {
      -- Command: uses 'ruby-lsp' by default, which works with version managers
      -- The plugin will automatically find the correct ruby-lsp for your Ruby version

      init_options = {
        -- Formatter options: 'auto', 'rubocop', 'standard', or 'syntax_tree'
        formatter = 'auto',

        -- Linters: e.g., { 'rubocop' }, { 'standard' }
        linters = {},

        -- All features enabled by default
        enabledFeatures = {
          'codeActions',
          'codeLens',
          'completion',
          'definition',
          'diagnostics',
          'documentHighlights',
          'documentLink',
          'documentSymbols',
          'foldingRanges',
          'formatting',
          'hover',
          'inlayHint',
          'onTypeFormatting',
          'selectionRanges',
          'semanticHighlighting',
          'signatureHelp',
          'typeHierarchy',
          'workspaceSymbol',
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
