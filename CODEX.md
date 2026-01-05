# Neovim Configuration CODEX

**Complete reference for your Neovim configuration**

> Based on Kickstart.nvim with custom plugins and enhancements

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Project Structure](#project-structure)
4. [Core Configuration](#core-configuration)
5. [Plugins Directory](#plugins-directory)
6. [LSP Configuration](#lsp-configuration)
7. [Keybindings Reference](#keybindings-reference)
8. [Formatting & Linting](#formatting--linting)
9. [Git Integration](#git-integration)
10. [Debugging](#debugging)
11. [Customization Guide](#customization-guide)
12. [Troubleshooting](#troubleshooting)
13. [FAQ](#faq)

---

## Quick Start

### First Time Setup

```bash
# 1. Install dependencies
./scripts/install-dependencies.sh

# 2. Open Neovim
nvim

# 3. Check health
:checkhealth

# 4. View keybindings
<Space> (press space to see all leader keybindings via which-key)
```

### Essential Keybindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key - shows all available commands |
| `<Space>sf` | Search files |
| `<Space>sg` | Search by grep |
| `<Space>e` | Toggle file explorer (Neo-tree) |
| `<Space>f` | Format current buffer |
| `K` | Hover documentation |
| `gd` | Go to definition |

---

## Installation

### Prerequisites

**Option 1: Using mise (Recommended)**
```bash
# Install mise
curl https://mise.run | sh

# Install dependencies
cd ~/.config/nvim
mise install
```

**Option 2: Using Homebrew**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install lua@5.1 stylua selene node
```

### Automatic Installation

Run the provided installation script:
```bash
cd ~/.config/nvim
./scripts/install-dependencies.sh
```

This will:
- Install all required tools via mise or Homebrew
- Install Neovim plugins via lazy.nvim
- Install LSP servers via Mason
- Verify installation with `:checkhealth`

### Manual Installation

1. **Install Neovim** (0.10+)
   ```bash
   # macOS
   brew install neovim

   # Or download from https://neovim.io/
   ```

2. **Install dependencies**
   ```bash
   mise install  # or use homebrew commands above
   ```

3. **Open Neovim**
   ```bash
   nvim
   ```
   - Plugins will install automatically via lazy.nvim
   - LSP servers will install automatically via Mason

---

## Project Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── lazy-bootstrap.lua      # lazy.nvim plugin manager setup
│   ├── lazy-plugins.lua        # Plugin loader
│   ├── keymaps.lua             # Global keybindings
│   ├── options.lua             # Vim options
│   ├── vscode_options.lua      # VSCode-specific options
│   └── custom/
│       └── plugins/            # Custom plugin configurations
│           ├── lspconfig.lua   # LSP configuration
│           ├── ruby-lsp.lua    # Ruby LSP setup
│           ├── telescope.lua   # Fuzzy finder
│           ├── treesitter.lua  # Syntax highlighting
│           ├── cmp.lua         # Autocompletion
│           ├── conform.lua     # Formatting
│           ├── lint.lua        # Linting
│           ├── gitsigns.lua    # Git integration
│           ├── neo-tree.lua    # File explorer
│           ├── which-key.lua   # Keybinding hints
│           ├── copilot.lua     # GitHub Copilot
│           ├── debug.lua       # DAP debugging
│           ├── mini.lua        # Mini.nvim utilities
│           ├── autopairs.lua   # Auto-pairing brackets
│           ├── comment.lua     # Commenting
│           ├── indent_line.lua # Indent guides
│           ├── todo-comments.lua # TODO highlighting
│           ├── onedark.lua     # Color scheme
│           └── vim-sleuth.lua  # Auto-detect indentation
├── scripts/
│   └── install-dependencies.sh # Dependency installer
├── .mise.toml                  # mise tool versions
├── selene.toml                 # Lua linter config
├── .stylua.toml                # Lua formatter config
├── PLAN.md                     # Optimization plan
└── CODEX.md                    # This file
```

---

## Core Configuration

### Options (`lua/options.lua`)

#### Display
- **Line numbers**: Enabled
- **Relative numbers**: Disabled (uncomment to enable)
- **Cursor line**: Highlighted
- **Sign column**: Always visible
- **Scroll offset**: 10 lines minimum above/below cursor

#### Editing
- **Clipboard**: Synced with system clipboard
- **Undo file**: Persistent undo history
- **Break indent**: Enabled
- **Case sensitivity**: Smart (case-insensitive unless capital letters used)

#### UI
- **Mouse**: Enabled
- **Show mode**: Disabled (shown in statusline)
- **Timeout**: 300ms for which-key popup
- **Update time**: 250ms for CursorHold events
- **Split behavior**: Opens right and below

#### Whitespace
- **Tab character**: `» `
- **Trailing spaces**: `·`
- **Non-breaking space**: `␣`

### Global Keybindings (`lua/keymaps.lua`)

#### Essential
| Key | Mode | Action |
|-----|------|--------|
| `<Space>` | Normal | Leader key |
| `<Esc>` | Normal | Clear search highlight |
| `<Esc><Esc>` | Terminal | Exit terminal mode |

#### Window Navigation
| Key | Mode | Action |
|-----|------|--------|
| `<C-h>` | Normal | Move to left window |
| `<C-l>` | Normal | Move to right window |
| `<C-j>` | Normal | Move to lower window |
| `<C-k>` | Normal | Move to upper window |

#### Diagnostics
| Key | Mode | Action |
|-----|------|--------|
| `[d` | Normal | Previous diagnostic |
| `]d` | Normal | Next diagnostic |
| `<leader>e` | Normal | Show diagnostic error |
| `<leader>q` | Normal | Open quickfix list |

---

## Plugins Directory

### Plugin Manager: lazy.nvim

**Location**: Auto-bootstrapped in `lua/lazy-bootstrap.lua`

**Commands**:
- `:Lazy` - Open plugin manager UI
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Install missing and update plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy profile` - Profile startup time

### Core Plugins

#### 1. **Telescope** (Fuzzy Finder)
**File**: `lua/custom/plugins/telescope.lua`
**Plugin**: [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

**Features**:
- Fuzzy file finding
- Live grep search
- LSP integration
- Buffer navigation
- Help tag search

**Keybindings**:
| Key | Action |
|-----|--------|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep (live) |
| `<leader>sw` | Search current word |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Search resume (last search) |
| `<leader>s.` | Search recent files |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>ss` | Search telescope builtins |
| `<leader>sn` | Search Neovim config files |
| `<leader>s/` | Search in open files |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader><leader>` | Find existing buffers |

**Extensions**:
- `telescope-fzf-native` - Native FZF sorter for performance
- `telescope-ui-select` - Use Telescope for `vim.ui.select`

#### 2. **LSP Configuration** (Language Server Protocol)
**File**: `lua/custom/plugins/lspconfig.lua`
**Plugin**: [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

**Features**:
- Automatic LSP server installation via Mason
- Go to definition, references, implementations
- Hover documentation
- Code actions
- Rename symbols
- Workspace symbols
- Inlay hints

**Keybindings** (Active when LSP attached):
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>th` | Toggle inlay hints |
| `K` | Hover documentation |

**Configured LSP Servers**:
- **lua_ls** - Lua (Neovim config, plugins)
- **ruby_lsp** - Ruby (via adam12/ruby-lsp.nvim)

**Mason Tools** (Auto-installed):
- stylua, selene (Lua)
- shellcheck, shfmt (Shell)
- markdownlint (Markdown)
- prettier (JSON, YAML, Markdown)
- jsonlint (JSON)

#### 3. **Ruby LSP**
**File**: `lua/custom/plugins/ruby-lsp.lua`
**Plugin**: [adam12/ruby-lsp.nvim](https://github.com/adam12/ruby-lsp.nvim)

**Features**:
- Automatic ruby-lsp gem installation
- Smart detection of global vs bundled gems
- Works with all Ruby version managers (rbenv, asdf, chruby)
- Rails-specific code lens features
- Jump between controllers and views
- Run tests from editor

**Installation**:
```bash
# Global installation (recommended)
gem install ruby-lsp

# Per-project (optional)
# Add to Gemfile: gem 'ruby-lsp', group: :development
bundle install
```

#### 4. **Treesitter** (Syntax Highlighting)
**File**: `lua/custom/plugins/treesitter.lua`
**Plugin**: [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

**Features**:
- Advanced syntax highlighting
- Incremental selection
- Code folding
- Indentation

**Commands**:
- `:TSInstall <language>` - Install parser for language
- `:TSUpdate` - Update all parsers
- `:TSBufEnable` - Enable feature for buffer

#### 5. **nvim-cmp** (Autocompletion)
**File**: `lua/custom/plugins/cmp.lua`
**Plugin**: [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

**Features**:
- LSP completion
- Snippet completion (LuaSnip)
- Path completion
- Buffer completion

**Keybindings** (In completion menu):
| Key | Action |
|-----|--------|
| `<C-n>` | Next item |
| `<C-p>` | Previous item |
| `<C-b>` | Scroll docs up |
| `<C-f>` | Scroll docs down |
| `<C-y>` | Confirm selection |
| `<C-Space>` | Trigger completion |
| `<Tab>` | Next snippet placeholder / select next |
| `<S-Tab>` | Previous snippet placeholder / select previous |

**Snippet Keybindings**:
| Key | Action |
|-----|--------|
| `<C-l>` | Jump to next snippet placeholder |
| `<C-h>` | Jump to previous snippet placeholder |

#### 6. **Conform** (Formatting)
**File**: `lua/custom/plugins/conform.lua`
**Plugin**: [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)

**Features**:
- Format on save
- Multiple formatter support
- LSP fallback
- Async formatting

**Keybindings**:
| Key | Action |
|-----|--------|
| `<leader>f` | Format buffer |

**Configured Formatters**:
- **Lua**: stylua
- **JSON**: prettier
- **YAML**: prettier
- **Markdown**: prettier
- **Shell**: shfmt

#### 7. **nvim-lint** (Linting)
**File**: `lua/custom/plugins/lint.lua`
**Plugin**: [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)

**Features**:
- Automatic linting on save and text changes
- Multiple linter support per filetype
- Diagnostic integration

**Configured Linters**:
- **Lua**: selene
- **Markdown**: markdownlint
- **JSON**: jsonlint
- **Shell**: shellcheck (sh, bash, zsh)

**Linting Triggers**:
- Buffer enter
- After save
- After leaving insert mode

#### 8. **Neo-tree** (File Explorer)
**File**: `lua/custom/plugins/neo-tree.lua`
**Plugin**: [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)

**Features**:
- File system tree
- Git status integration
- Buffer navigation
- Floating window support

**Keybindings**:
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Neo-tree |
| `<C-n>` | Alternative toggle |

**Neo-tree Commands** (Inside tree):
- `?` - Show help
- `a` - Add file/directory
- `d` - Delete
- `r` - Rename
- `x` - Cut
- `c` - Copy
- `p` - Paste
- `y` - Copy filename
- `Y` - Copy relative path

#### 9. **Gitsigns** (Git Integration)
**File**: `lua/custom/plugins/gitsigns.lua`
**Plugin**: [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)

**Features**:
- Git diff signs in sign column
- Hunk navigation
- Stage/unstage hunks
- Blame line
- Preview changes

**Keybindings**:
| Key | Mode | Action |
|-----|------|--------|
| `]h` | Normal | Next hunk |
| `[h` | Normal | Previous hunk |
| `<leader>hs` | Normal/Visual | Stage hunk |
| `<leader>hr` | Normal/Visual | Reset hunk |
| `<leader>hS` | Normal | Stage buffer |
| `<leader>hu` | Normal | Undo stage hunk |
| `<leader>hR` | Normal | Reset buffer |
| `<leader>hp` | Normal | Preview hunk |
| `<leader>hb` | Normal | Blame line |
| `<leader>hd` | Normal | Diff this |
| `<leader>hD` | Normal | Diff this ~ |
| `<leader>tb` | Normal | Toggle blame line |
| `<leader>td` | Normal | Toggle deleted |

**Text Objects**:
| Key | Mode | Action |
|-----|------|--------|
| `ih` | Operator/Visual | Inside hunk |
| `ah` | Operator/Visual | Around hunk |

#### 10. **Which-Key** (Keybinding Helper)
**File**: `lua/custom/plugins/which-key.lua`
**Plugin**: [folke/which-key.nvim](https://github.com/folke/which-key.nvim)

**Features**:
- Shows pending keybindings
- Organized by prefix
- Searchable

**Usage**:
- Press `<Space>` and wait - shows all leader keybindings
- Press any prefix (e.g., `<leader>s`) - shows all search commands

**Registered Groups**:
- `<leader>c` - Code actions
- `<leader>d` - Document/Diagnostics
- `<leader>r` - Rename
- `<leader>s` - Search
- `<leader>w` - Workspace
- `<leader>t` - Toggle
- `<leader>h` - Git Hunk

#### 11. **GitHub Copilot**
**File**: `lua/custom/plugins/copilot.lua`
**Plugin**: [github/copilot.vim](https://github.com/github/copilot.vim)

**Features**:
- AI-powered code completion
- Context-aware suggestions

**Setup**:
1. First use: `:Copilot setup`
2. Authenticate with GitHub

**Keybindings** (Default Copilot):
| Key | Mode | Action |
|-----|------|--------|
| `<Tab>` | Insert | Accept suggestion |
| `<C-]>` | Insert | Dismiss suggestion |
| `<M-]>` | Insert | Next suggestion |
| `<M-[>` | Insert | Previous suggestion |

#### 12. **DAP** (Debug Adapter Protocol)
**File**: `lua/custom/plugins/debug.lua`
**Plugins**:
- [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)

**Features**:
- Breakpoint management
- Step debugging
- Variable inspection
- REPL console

**Keybindings**:
| Key | Action |
|-----|--------|
| `<F5>` | Start/Continue debugging |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle breakpoint |
| `<leader>B` | Set conditional breakpoint |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last debug session |

#### 13. **Additional Plugins**

**mini.nvim** (`lua/custom/plugins/mini.lua`)
- Collection of minimal but powerful plugins
- mini.ai - Extended text objects
- mini.surround - Surround actions

**autopairs** (`lua/custom/plugins/autopairs.lua`)
- Automatic bracket/quote pairing

**Comment.nvim** (`lua/custom/plugins/comment.lua`)
- Easy commenting
- `gcc` - Comment line
- `gc` - Comment motion
- `gcap` - Comment paragraph

**indent-blankline** (`lua/custom/plugins/indent_line.lua`)
- Show indentation guides
- Scope highlighting

**todo-comments** (`lua/custom/plugins/todo-comments.lua`)
- Highlight TODO, FIXME, NOTE, etc.
- `]t` / `[t` - Next/previous todo
- `<leader>st` - Search todos with Telescope

**vim-sleuth** (`lua/custom/plugins/vim-sleuth.lua`)
- Automatic indentation detection

**onedark** (`lua/custom/plugins/onedark.lua`)
- Color scheme

---

## LSP Configuration

### Available Language Servers

#### Lua LSP (`lua_ls`)
**Auto-configured for**:
- Neovim configuration files
- Plugin development
- Lua scripting

**Features**:
- Completion with call snippets
- Diagnostics
- Hover documentation
- Go to definition

#### Ruby LSP (`ruby_lsp`)
**Managed by**: adam12/ruby-lsp.nvim

**Features**:
- Ruby 3.x support
- Rails support
- RSpec support
- Code formatting (via rubocop/standard)
- Go to definition
- Find references
- Hover documentation
- Code lens (controller/view navigation)
- Run tests

**Configuration**:
- Formatter: `auto` (can be 'rubocop', 'standard', or 'syntax_tree')
- Auto-install: Enabled
- Works with bundled gems

### Adding New Language Servers

1. **Add to servers table** in `lua/custom/plugins/lspconfig.lua`:
   ```lua
   servers = {
     -- Add your server here
     pyright = {},  -- Python
     tsserver = {}, -- TypeScript
   }
   ```

2. **Mason will auto-install** the server on next Neovim start

3. **Or manually install**:
   ```vim
   :Mason
   ```
   Then search and install your LSP server

### LSP Commands

| Command | Description |
|---------|-------------|
| `:LspInfo` | Show attached LSP servers |
| `:LspStart` | Start LSP server |
| `:LspStop` | Stop LSP server |
| `:LspRestart` | Restart LSP server |
| `:Mason` | Open Mason UI |
| `:MasonUpdate` | Update Mason registry |
| `:MasonInstall <tool>` | Install tool |

---

## Keybindings Reference

### Legend
- `<leader>` = `<Space>` (Space key)
- `<C-x>` = Control + x
- `<M-x>` = Alt/Option + x
- `<S-x>` = Shift + x

### Global Keybindings

#### Essential
| Key | Mode | Action |
|-----|------|--------|
| `<Space>` | N | Leader key (shows which-key popup) |
| `<Esc>` | N | Clear search highlight |
| `<Esc><Esc>` | T | Exit terminal mode |
| `:` | N | Command mode |
| `/` | N | Search forward |
| `?` | N | Search backward |

#### Navigation
| Key | Mode | Action |
|-----|------|--------|
| `h/j/k/l` | N | Left/Down/Up/Right |
| `w/b` | N | Next/Previous word |
| `0/$` | N | Start/End of line |
| `gg/G` | N | First/Last line |
| `<C-u>/<C-d>` | N | Page up/down |
| `<C-h/j/k/l>` | N | Move between windows |
| `[d / ]d` | N | Previous/Next diagnostic |
| `[h / ]h` | N | Previous/Next git hunk |
| `[t / ]t` | N | Previous/Next todo comment |

#### File Operations
| Key | Mode | Action |
|-----|------|--------|
| `:w` | N | Save file |
| `:q` | N | Quit |
| `:wq` | N | Save and quit |
| `:q!` | N | Quit without saving |
| `<leader>e` | N | Toggle file explorer |
| `<leader>sf` | N | Search files |
| `<leader>sn` | N | Search Neovim config |

### Leader Key Mappings

#### Search (`<leader>s`)
| Key | Action |
|-----|--------|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep |
| `<leader>sw` | Search current word |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Search resume |
| `<leader>s.` | Search recent files |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>ss` | Search select telescope |
| `<leader>sn` | Search Neovim files |
| `<leader>s/` | Search in open files |
| `<leader>st` | Search TODO comments |

#### Code (`<leader>c`)
| Key | Action |
|-----|--------|
| `<leader>ca` | Code action |

#### Document/Diagnostics (`<leader>d`)
| Key | Action |
|-----|--------|
| `<leader>ds` | Document symbols |
| `<leader>dr` | Debug REPL |
| `<leader>dl` | Debug last |

#### Rename (`<leader>r`)
| Key | Action |
|-----|--------|
| `<leader>rn` | Rename symbol |

#### Workspace (`<leader>w`)
| Key | Action |
|-----|--------|
| `<leader>ws` | Workspace symbols |

#### Toggle (`<leader>t`)
| Key | Action |
|-----|--------|
| `<leader>th` | Toggle inlay hints |
| `<leader>tb` | Toggle git blame |
| `<leader>td` | Toggle git deleted |

#### Git Hunks (`<leader>h`)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>hs` | N/V | Stage hunk |
| `<leader>hr` | N/V | Reset hunk |
| `<leader>hS` | N | Stage buffer |
| `<leader>hu` | N | Undo stage hunk |
| `<leader>hR` | N | Reset buffer |
| `<leader>hp` | N | Preview hunk |
| `<leader>hb` | N | Blame line |
| `<leader>hd` | N | Diff this |
| `<leader>hD` | N | Diff this ~ |

#### Other Leader Keys
| Key | Action |
|-----|--------|
| `<leader>f` | Format buffer |
| `<leader>e` | Show diagnostic error |
| `<leader>q` | Open quickfix list |
| `<leader>/` | Fuzzy search in buffer |
| `<leader><leader>` | Find buffers |
| `<leader>D` | Type definition |
| `<leader>B` | Conditional breakpoint |

### LSP Keybindings
(Active only when LSP is attached)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `K` | Hover documentation |

### Debug Keybindings
| Key | Action |
|-----|--------|
| `<F5>` | Continue/Start |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle breakpoint |

### Completion Keybindings
(In insert mode, when completion menu is open)

| Key | Action |
|-----|--------|
| `<C-n>` | Next item |
| `<C-p>` | Previous item |
| `<C-y>` | Confirm |
| `<C-Space>` | Trigger completion |
| `<Tab>` | Next/Accept snippet |
| `<S-Tab>` | Previous snippet |
| `<C-l>` | Next snippet placeholder |
| `<C-h>` | Previous snippet placeholder |

### Comment Keybindings
| Key | Mode | Action |
|-----|------|--------|
| `gcc` | N | Comment line |
| `gc` | N/V | Comment motion/selection |
| `gcap` | N | Comment paragraph |

---

## Formatting & Linting

### Formatting

**Plugin**: conform.nvim
**Configuration**: `lua/custom/plugins/conform.lua`

#### Supported Languages
| Language | Formatter | Config File |
|----------|-----------|-------------|
| Lua | stylua | `.stylua.toml` |
| JSON | prettier | Built-in |
| YAML | prettier | Built-in |
| Markdown | prettier | Built-in |
| Shell | shfmt | Built-in |
| Ruby | ruby-lsp | Via LSP |

#### Format Commands
- `<leader>f` - Format current buffer
- `:Format` - Format current buffer (command)
- Auto-format on save (enabled by default)

#### Disable Auto-format
Add to file-specific format_on_save in `conform.lua`:
```lua
local disable_filetypes = { c = true, cpp = true, your_filetype = true }
```

#### Adding New Formatters
1. Install formatter via Mason or mise
2. Add to `formatters_by_ft` in `conform.lua`:
   ```lua
   formatters_by_ft = {
     python = { "black" },
   }
   ```

### Linting

**Plugin**: nvim-lint
**Configuration**: `lua/custom/plugins/lint.lua`

#### Supported Languages
| Language | Linter | Auto-installed |
|----------|--------|----------------|
| Lua | selene | Yes (Mason) |
| Markdown | markdownlint | Yes (Mason) |
| JSON | jsonlint | Yes (Mason) |
| Shell (sh/bash/zsh) | shellcheck | Yes (Mason) |
| Ruby | ruby-lsp | Via LSP |

#### Linting Triggers
- On buffer enter
- On save
- After leaving insert mode

#### Adding New Linters
1. Install linter via Mason or mise
2. Add to `linters_by_ft` in `lint.lua`:
   ```lua
   lint.linters_by_ft = {
     python = { 'pylint' },
   }
   ```

### Configuration Files

#### Stylua (`.stylua.toml`)
```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
```

#### Selene (`selene.toml`)
```toml
std = "vim"

[config]
globals = ["vim", "require", ...]
```

---

## Git Integration

### Gitsigns Features

**Plugin**: gitsigns.nvim
**Configuration**: `lua/custom/plugins/gitsigns.lua`

#### Git Signs in Sign Column
- `┃` - Modified lines
- `▎` - Added lines
- `▁` - Removed lines (top line indicator)
- `▔` - Changed lines (bottom line indicator)

#### Hunk Operations
- Stage hunks interactively
- Reset hunks
- Preview changes
- Navigate between hunks

#### Blame Integration
- View blame for current line
- Toggle blame display
- Show commit details

### Git Commands

While gitsigns handles in-editor git operations, you can use standard git commands:

```bash
# Status
:!git status

# Common operations (use gitsigns keybindings instead)
# But if you need terminal:
:terminal git add .
:terminal git commit -m "message"
:terminal git push
```

### Recommended Git Workflow

1. **View changes**: `<leader>hp` (preview hunk)
2. **Stage changes**: `<leader>hs` (stage hunk) or `<leader>hS` (stage buffer)
3. **Commit**: Use terminal or git client
4. **Push**: Use terminal or git client

---

## Debugging

### DAP (Debug Adapter Protocol)

**Plugins**: nvim-dap, nvim-dap-ui
**Configuration**: `lua/custom/plugins/debug.lua`

#### Supported Languages
- Requires language-specific debug adapters
- Install via Mason: `:Mason` then search for debuggers

#### Debug Workflow

1. **Set breakpoints**: `<F7>` on line
2. **Start debugging**: `<F5>`
3. **Step through**:
   - `<F1>` - Step into
   - `<F2>` - Step over
   - `<F3>` - Step out
4. **Inspect variables**: Hover or use debug UI
5. **Continue**: `<F5>`

#### Debug UI
- Opens automatically when debugging starts
- Shows:
  - Variables
  - Call stack
  - Breakpoints
  - Console/REPL

#### Debug Commands
| Command | Description |
|---------|-------------|
| `:DapContinue` | Start/continue debugging |
| `:DapStepInto` | Step into function |
| `:DapStepOver` | Step over line |
| `:DapStepOut` | Step out of function |
| `:DapToggleBreakpoint` | Toggle breakpoint |
| `:DapTerminate` | Stop debugging |

---

## Customization Guide

### Adding New Plugins

1. **Create plugin file** in `lua/custom/plugins/`:
   ```lua
   -- lua/custom/plugins/my-plugin.lua
   return {
     'author/plugin-name',
     config = function()
       require('plugin-name').setup({
         -- configuration here
       })
     end,
   }
   ```

2. **Restart Neovim** - lazy.nvim will auto-install

### Modifying Keybindings

#### Global Keybindings
Edit `lua/keymaps.lua`:
```lua
vim.keymap.set('n', '<leader>x', '<cmd>MyCommand<CR>', { desc = 'Description' })
```

#### Plugin-specific Keybindings
Edit the plugin's file in `lua/custom/plugins/`:
```lua
vim.keymap.set('n', '<leader>x', function()
  require('plugin').action()
end, { desc = 'Description' })
```

### Changing Options

Edit `lua/options.lua`:
```lua
vim.opt.option_name = value

-- Examples:
vim.opt.relativenumber = true
vim.opt.tabstop = 4
```

### Changing Color Scheme

Edit `lua/custom/plugins/onedark.lua` or create new theme file:
```lua
return {
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    require('onedark').setup {
      style = 'darker', -- 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer'
    }
    vim.cmd.colorscheme 'onedark'
  end,
}
```

### Adding Language Support

1. **LSP Server**: Add to `servers` table in `lspconfig.lua`
2. **Treesitter**: `:TSInstall <language>`
3. **Formatter**: Add to `conform.lua`
4. **Linter**: Add to `lint.lua`

Example for Python:
```lua
-- In lspconfig.lua servers table
servers = {
  pyright = {},
}

-- In conform.lua
formatters_by_ft = {
  python = { "black" },
}

-- In lint.lua
linters_by_ft = {
  python = { 'pylint' },
}

-- Then install tools
-- :Mason -> search and install: pyright, black, pylint
```

---

## Troubleshooting

### Common Issues

#### Plugins Not Loading
```vim
:Lazy sync
```
Then restart Neovim.

#### LSP Not Working
1. Check LSP status:
   ```vim
   :LspInfo
   ```
2. Check Mason:
   ```vim
   :Mason
   ```
3. Check health:
   ```vim
   :checkhealth lsp
   ```

#### Formatter Not Working
1. Check Mason installation:
   ```vim
   :Mason
   ```
2. Check conform status:
   ```vim
   :ConformInfo
   ```

#### Ruby LSP Issues
1. Check ruby-lsp gem is installed:
   ```bash
   gem list ruby-lsp
   ```
2. Install if missing:
   ```bash
   gem install ruby-lsp
   ```
3. Check LSP is running:
   ```vim
   :LspInfo
   ```

#### Slow Startup
1. Profile startup:
   ```vim
   :Lazy profile
   ```
2. Check startup time:
   ```bash
   nvim --startuptime startup.log
   ```

### Health Checks

Run health checks for various components:
```vim
:checkhealth
:checkhealth lazy
:checkhealth lsp
:checkhealth mason
:checkhealth treesitter
```

### Logs

View logs for debugging:
```vim
:messages                  " Neovim messages
:Lazy log                  " Plugin manager logs
:lua vim.print(vim.lsp.get_log_path())  " LSP log path
```

---

## FAQ

### Q: How do I update plugins?
**A**: `:Lazy update` or just `:Lazy` then press `U`

### Q: How do I add a new LSP server?
**A**:
1. Add to `servers` table in `lua/custom/plugins/lspconfig.lua`
2. Restart Neovim (Mason will auto-install)
3. Or manually: `:Mason` and install

### Q: How do I disable format on save?
**A**: In `lua/custom/plugins/conform.lua`, add your filetype to `disable_filetypes`

### Q: How do I change the leader key?
**A**: Edit `init.lua` line 70: `vim.g.mapleader = " "`

### Q: Where are plugins installed?
**A**: `~/.local/share/nvim/lazy/` (on macOS/Linux)

### Q: How do I see all keybindings?
**A**: Press `<Space>` (leader) and wait for which-key popup, or `:Telescope keymaps`

### Q: Ruby LSP not working with my project's Ruby version?
**A**: The ruby-lsp.nvim plugin should auto-detect your Ruby version manager. Ensure:
1. ruby-lsp gem is installed for that Ruby version
2. Your version manager shim is in PATH
3. Try `:LspRestart` after changing Ruby versions

### Q: How do I disable Copilot?
**A**: Delete or comment out `lua/custom/plugins/copilot.lua` and restart

### Q: How do I use Neovim with VSCode?
**A**: The config already supports VSCode mode. Install the Neovim VSCode extension.

### Q: Can I use this config as a starting point?
**A**: Yes! That's the purpose of Kickstart.nvim. Fork it and customize.

### Q: How do I add custom snippets?
**A**: Edit LuaSnip configuration in `lua/custom/plugins/cmp.lua` or create snippet files

### Q: What's the difference between mise and asdf?
**A**: mise is a modern, faster rewrite of asdf with better UX. Both manage tool versions.

### Q: How do I install mise?
**A**: `curl https://mise.run | sh` or see https://mise.jdx.dev/

---

## Additional Resources

### Documentation
- [Neovim Documentation](https://neovim.io/doc/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason Registry](https://mason-registry.dev/)
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

### Learning Resources
- [Learn Lua in Y Minutes](https://learnxinyminutes.com/docs/lua/)
- `:help lua-guide` (in Neovim)
- `:Tutor` (in Neovim)

### Tools
- [mise](https://mise.jdx.dev/) - Version manager
- [stylua](https://github.com/JohnnyMorganz/StyLua) - Lua formatter
- [selene](https://kampfkarren.github.io/selene/) - Lua linter

---

## Version History

- **v1.0** (2025-01-05) - Initial CODEX creation
  - Complete plugin documentation
  - Keybinding reference
  - Installation guide
  - Troubleshooting section

---

## Credits

- Based on [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) by TJ DeVries
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) by folke
- All plugin authors (see individual plugin sections)

---

**Last Updated**: 2025-01-05
**Configuration Version**: 1.0
**Neovim Version Required**: 0.10+

---

## Quick Reference Card

### Most Used Keybindings

```
ESSENTIAL
  Space        Leader key / which-key
  <leader>sf   Search files
  <leader>sg   Search by grep
  <leader>e    Toggle file tree

LSP
  gd           Go to definition
  gr           Go to references
  K            Hover docs
  <leader>ca   Code action
  <leader>rn   Rename

GIT
  <leader>hs   Stage hunk
  <leader>hp   Preview hunk
  ]h / [h      Next/prev hunk

EDITING
  <leader>f    Format buffer
  gcc          Comment line
  gc           Comment motion

NAVIGATION
  <C-hjkl>     Switch windows
  ]d / [d      Next/prev diagnostic
  <leader><leader>  Switch buffers
```

Save this reference card for quick access!

---

*For questions or issues, check the Troubleshooting section or run `:checkhealth`*
