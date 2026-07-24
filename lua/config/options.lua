-- Editor options. UI-only settings are skipped inside the VSCode-Neovim
-- extension (VS Code owns line numbers, the statusline, folding UI, etc.).
local opt = vim.opt

-- Always-on, environment-agnostic behavior.
opt.clipboard = "unnamedplus" -- use the system clipboard
opt.undofile = true -- persistent undo across sessions
opt.undolevels = 10000
opt.ignorecase = true
opt.smartcase = true -- case-sensitive when the query has capitals
opt.timeoutlen = 300
opt.updatetime = 200
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.confirm = true -- prompt to save instead of failing :q
opt.swapfile = false
opt.virtualedit = "block" -- let visual-block go past EOL

if not vim.g.vscode then
  opt.number = true
  opt.relativenumber = true
  opt.mouse = "a"
  opt.showmode = false -- lualine renders the mode
  opt.cursorline = true
  opt.signcolumn = "yes"
  opt.scrolloff = 8
  opt.sidescrolloff = 8
  opt.breakindent = true
  opt.linebreak = true
  opt.wrap = false
  opt.termguicolors = true
  opt.winminwidth = 5
  opt.pumheight = 12 -- max completion menu height
  opt.pumblend = 0
  opt.inccommand = "split" -- live :substitute preview
  opt.laststatus = 3 -- single global statusline
  opt.list = true
  opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
  opt.fillchars = { eob = " " } -- hide the ~ end-of-buffer markers

  -- Indentation: ship a 2-space default (vim-rails/editorconfig refine per project).
  opt.expandtab = true
  opt.shiftwidth = 2
  opt.tabstop = 2
  opt.softtabstop = 2
  opt.shiftround = true
  opt.smartindent = true

  -- Treesitter-based folding, everything open on load.
  opt.foldlevel = 99
  opt.foldlevelstart = 99
  opt.foldenable = true
  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  opt.foldtext = ""
end

-- Trim a couple of unused providers to cut startup + :checkhealth noise.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
