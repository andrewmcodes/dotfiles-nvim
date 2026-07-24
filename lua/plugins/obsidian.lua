-- Obsidian integration for the `digital-brain` vault. Standalone-only: gated
-- off under VS Code, where the Obsidian app (or the VS Code UI) owns notes.
--
-- Deliberate choices for a hand-curated vault with a strict DKS type system:
--   * `disable_frontmatter = true` — never rewrite existing frontmatter (no
--     injected `id`/`aliases`/`tags`), so notes' `type:` metadata stays intact.
--   * `ui.enable = false` — render-markdown.nvim (markdown.lua) owns in-buffer
--     rendering; running both fights over concealment.
--   * Daily notes get a folder + date format but NO template: the vault's
--     `day.tmpl.md` is Templater (`<% … %>`) which obsidian.nvim can't execute,
--     so pointing at it would leave literal tags in the note.
--   * New notes land in `+inbox` to match the vault's `newFileFolderPath`.
return {
  {
    "obsidian-nvim/obsidian.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Load for any markdown buffer (so vault features attach) and for the
    -- `:Obsidian` command / leader maps invoked from anywhere.
    ft = "markdown",
    cmd = "Obsidian",
    keys = {
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes (grep)" },
      { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch note" },
      { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
      { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's daily note" },
      { "<leader>od", "<cmd>Obsidian dailies<cr>", desc = "Pick a daily note" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Links in note" },
      { "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note (update links)" },
      { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
      { "<leader>ox", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
      { "<leader>og", "<cmd>Obsidian follow_link<cr>", desc = "Follow link under cursor" },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "digital-brain",
          path = "~/git/andrewmcodes/digital-brain",
        },
      },

      -- Match the vault's "new file → +inbox" behaviour.
      notes_subdir = "+inbox",
      new_notes_location = "notes_subdir",

      daily_notes = {
        folder = "logs/days",
        date_format = "%Y-%m-%d",
      },

      templates = {
        folder = "util/tmpl",
      },

      completion = {
        blink = true,
        nvim_cmp = false,
        min_chars = 2,
      },

      picker = {
        name = "telescope.nvim",
      },

      -- render-markdown.nvim owns in-buffer rendering.
      ui = { enable = false },

      -- Never touch existing frontmatter — the vault manages `type:` itself.
      disable_frontmatter = true,
    },
  },
}
