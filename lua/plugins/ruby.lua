-- Ruby / Rails editing ergonomics and navigation. Owns the <leader>r group.
-- LSP (ruby_lsp, herb_ls) is configured in lsp.lua; this file adds tpope's
-- Rails/projectionist/bundler/endwise tooling, per-resource fuzzy pickers, and a
-- small `bin/rails` command surface.
--
-- The full Rails navigation story:
--   * ruby-lsp go-to-definition (gd), references (gr), workspace symbols (<leader>cs)
--   * ruby-lsp Code Lens "Jump to view"/route links (<leader>cl) — see lsp.lua
--   * vim-rails :A / :Emodel / :Eview / gf on partials & associations
--   * fuzzy pickers per resource (<leader>rm/rc/rv/rs/ri/rl/rj/rn/ru/rt)
--   * a routes picker that jumps straight to the action (<leader>rR)

local function not_vscode()
  return not vim.g.vscode
end

-- Resolve the Rails root from the current buffer upward, NOT from nvim's cwd —
-- the pickers must keep working when nvim was launched from a parent directory.
local function rails_root()
  return vim.fs.root(0, { "Gemfile", ".git" }) or vim.uv.cwd()
end

-- Fuzzy-find inside one Rails directory. Reuses telescope.builtin.find_files, the
-- same picker every other <leader>f map in this config uses.
local function pick_in(subdir, title)
  return function()
    local root = rails_root()
    local dir = root .. "/" .. subdir
    if vim.fn.isdirectory(dir) == 0 then
      vim.notify(("No %s in this project"):format(subdir), vim.log.levels.WARN)
      return
    end
    require("telescope.builtin").find_files({ cwd = dir, prompt_title = title })
  end
end

-- Open db/schema.rb (or structure.sql) from the Rails root.
local function open_schema()
  local root = rails_root()
  for _, rel in ipairs({ "db/schema.rb", "db/structure.sql" }) do
    local path = root .. "/" .. rel
    if vim.fn.filereadable(path) == 1 then
      vim.cmd.edit(path)
      return
    end
  end
  vim.notify("No db/schema.rb or db/structure.sql found", vim.log.levels.WARN)
end

-- Run a bin/rails command in a floating terminal, from the Rails root.
local function rails_term(subcmd, opts)
  return function()
    Snacks.terminal(
      "bin/rails " .. subcmd,
      vim.tbl_extend("force", { cwd = rails_root(), interactive = true }, opts or {})
    )
  end
end

-- Open a controller at `def <action>`, given a parsed route.
local function open_route(root, route)
  local path = ("%s/app/controllers/%s_controller.rb"):format(root, route.controller)
  if vim.fn.filereadable(path) == 0 then
    vim.notify("No controller at " .. path, vim.log.levels.WARN)
    return
  end
  vim.cmd.edit(path)
  -- Harmless no-op when the action is inherited rather than defined here.
  -- \v is very-magic, so `<`/`>` are the word boundaries — NOT `\<`/`\>`, which
  -- would match literal angle brackets. The action is [%w_]+ so it needs no escaping.
  vim.fn.search("\\v<def>\\s+" .. route.action .. ">", "cw")
end

local function show_routes(root, routes)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "Rails Routes",
      finder = finders.new_table({
        results = routes,
        entry_maker = function(route)
          return { value = route, display = route.line, ordinal = route.line }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(bufnr)
        actions.select_default:replace(function()
          actions.close(bufnr)
          open_route(root, action_state.get_selected_entry().value)
        end)
        return true
      end,
    })
    :find()
end

-- `bin/rails routes` picker. Booting Rails takes several seconds, so this runs
-- async and opens the picker on completion rather than freezing the editor.
local function routes_picker()
  local root = rails_root()
  vim.notify("Running bin/rails routes…", vim.log.levels.INFO)

  vim.system({ "bin/rails", "routes" }, { cwd = root, text = true }, function(out)
    vim.schedule(function()
      if out.code ~= 0 then
        vim.notify("bin/rails routes failed:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
        return
      end

      local routes = {}
      for line in vim.gsplit(out.stdout or "", "\n", { trimempty = true }) do
        -- Trailing column is `posts#show`; mounted engines (`Sidekiq::Web`) don't match.
        local controller, action = line:match("([%w_/]+)#([%w_]+)%s*$")
        if controller then
          table.insert(routes, { line = vim.trim(line), controller = controller, action = action })
        end
      end

      if #routes == 0 then
        vim.notify("No routes parsed from bin/rails routes", vim.log.levels.WARN)
        return
      end
      show_routes(root, routes)
    end)
  end)
end

return {
  {
    "tpope/vim-projectionist",
    cond = not_vscode,
    event = "VeryLazy",
  },
  {
    "tpope/vim-rails",
    cond = not_vscode,
    dependencies = { "tpope/vim-projectionist" },
    ft = { "ruby", "eruby" },
    cmd = {
      "Rails",
      "A",
      "AV",
      "AS",
      "AT",
      "R",
      "Emodel",
      "Eview",
      "Econtroller",
      "Emigration",
    },
    keys = {
      { "<leader>ra", "<cmd>A<cr>", desc = "Rails: alternate file" },
      { "<leader>rr", "<cmd>R<cr>", desc = "Rails: related file" },
    },
  },
  {
    "tpope/vim-bundler",
    cond = not_vscode,
    ft = { "ruby", "eruby" },
  },
  {
    "tpope/vim-endwise",
    cond = not_vscode,
    ft = { "ruby", "eruby", "lua", "sh", "vim" },
  },

  -- Fuzzy pickers scoped to each Rails resource type, plus the bin/rails commands.
  -- This replaces sato-s/telescope-rails.nvim, which was last updated in 2024 and
  -- ran `find` against *nvim's cwd* with six hardcoded paths — it broke outside a
  -- spec/ app and had no jobs/mailers/components/Stimulus pickers.
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    keys = {
      { "<leader>rm", pick_in("app/models", "Rails Models"), desc = "Rails: models" },
      { "<leader>rc", pick_in("app/controllers", "Rails Controllers"), desc = "Rails: controllers" },
      { "<leader>rv", pick_in("app/views", "Rails Views"), desc = "Rails: views" },
      { "<leader>rs", pick_in("spec", "Rails Specs"), desc = "Rails: specs" },
      { "<leader>ri", pick_in("db/migrate", "Rails Migrations"), desc = "Rails: migrations" },
      { "<leader>rl", pick_in("lib", "Rails Libs"), desc = "Rails: libs" },
      { "<leader>rj", pick_in("app/jobs", "Rails Jobs"), desc = "Rails: jobs" },
      { "<leader>rn", pick_in("app/mailers", "Rails Mailers"), desc = "Rails: mailers" },
      { "<leader>ru", pick_in("app/components", "ViewComponents"), desc = "Rails: components" },
      { "<leader>rt", pick_in("app/javascript", "Stimulus Controllers"), desc = "Rails: Stimulus controllers" },
      { "<leader>rd", open_schema, desc = "Rails: db/schema.rb" },
      { "<leader>rR", routes_picker, desc = "Rails: routes (jump to action)" },
      { "<leader>rC", rails_term("console"), desc = "Rails: console" },
      { "<leader>rM", rails_term("db:migrate", { interactive = false }), desc = "Rails: db:migrate" },
      {
        "<leader>rG",
        function()
          vim.ui.input({ prompt = "bin/rails generate " }, function(input)
            if input and input ~= "" then
              rails_term("generate " .. input, { interactive = false })()
            end
          end)
        end,
        desc = "Rails: generate…",
      },
    },
  },
}
