# Neovim Configuration

> Based on Kickstart.nvim with extensive customizations

## Quick Links

- [CODEX.md](./CODEX.md) - Complete reference documentation
- [PLAN.md](./PLAN.md) - Optimization plan and roadmap

## Quick Start

### 1. Install Dependencies

**Option A: Using mise (Recommended)**
```bash
# Install mise
curl https://mise.run | sh

# Install dependencies
cd ~/.config/nvim
mise install
```

**Option B: Using Homebrew**
```bash
brew install lua@5.1 stylua selene node
```

**Option C: Automated Script**
```bash
cd ~/.config/nvim
./scripts/install-dependencies.sh
```

### 2. Install Ruby LSP

The Ruby LSP should be installed **per Ruby version**, not via Mason:

```bash
gem install ruby-lsp
```

Or add to your project's Gemfile:
```ruby
gem 'ruby-lsp', group: :development
```

### 3. Open Neovim

```bash
nvim
```

Plugins will install automatically via lazy.nvim.

### 4. Verify Installation

```vim
:checkhealth
```

## Essential Keybindings

Press `<Space>` (leader key) to see all available commands via which-key.

| Key | Action |
|-----|--------|
| `<Space>sf` | Search files |
| `<Space>sg` | Search by grep |
| `<Space>e` | Toggle file explorer |
| `<Space>f` | Format current buffer |
| `gd` | Go to definition |
| `K` | Hover documentation |

## Project Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── keymaps.lua       # Global keybindings
│   ├── options.lua       # Vim options
│   └── custom/plugins/   # Plugin configurations
├── scripts/
│   └── install-dependencies.sh
├── .mise.toml            # Tool versions
├── selene.toml           # Lua linter config
├── .stylua.toml          # Lua formatter config
├── CODEX.md              # Complete documentation
├── PLAN.md               # Optimization roadmap
└── README.md             # This file
```

## Features

- **LSP Support**: Lua, Ruby (via ruby-lsp), and easy addition of more
- **Autocompletion**: nvim-cmp with LSP, snippets, and path completion
- **Fuzzy Finding**: Telescope for files, grep, symbols, and more
- **Git Integration**: Gitsigns for hunks, blame, and diff
- **Formatting**: Auto-format on save with conform.nvim
- **Linting**: Real-time linting with nvim-lint
- **Debugging**: DAP support for multiple languages
- **GitHub Copilot**: AI-powered code completion

## Configured Languages

### Fully Supported
- **Lua**: LSP (lua_ls), formatter (stylua), linter (selene)
- **Ruby**: LSP (ruby-lsp), auto-formatting, linting

### Formatting & Linting
- **Shell**: formatter (shfmt), linter (shellcheck)
- **JSON**: formatter (prettier), linter (jsonlint)
- **YAML**: formatter (prettier)
- **Markdown**: formatter (prettier), linter (markdownlint)

## Important Notes

### Ruby LSP
**DO NOT** install ruby-lsp via Mason. The `adam12/ruby-lsp.nvim` plugin manages it automatically and handles Ruby version switching correctly.

If you encounter Ruby LSP errors:
1. Remove Mason's ruby-lsp: `rm -rf ~/.local/share/nvim/mason/packages/ruby-lsp`
2. Install globally: `gem install ruby-lsp`
3. Restart Neovim

### Which-Key Warning
The configuration uses the new which-key spec (v3.0+). If you see deprecation warnings, they have been resolved in the latest version.

## Troubleshooting

### Plugins Not Loading
```vim
:Lazy sync
```

### LSP Not Working
```vim
:LspInfo          " Check LSP status
:Mason            " Check installed servers
:checkhealth lsp  " Run health check
```

### Ruby LSP Issues
```bash
# Check if ruby-lsp is installed
gem list ruby-lsp

# Install if missing
gem install ruby-lsp

# Check in Neovim
:LspInfo
```

## Documentation

For complete documentation, see [CODEX.md](./CODEX.md), which includes:
- All keybindings
- Plugin reference
- LSP configuration
- Customization guide
- Troubleshooting
- FAQ

## Customization

This configuration is designed to be customized. See the [Customization Guide](./CODEX.md#customization-guide) in CODEX.md for details on:
- Adding new plugins
- Modifying keybindings
- Changing options
- Adding language support

## Credits

- Based on [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) by TJ DeVries
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) by folke
- All plugin authors (see CODEX.md for complete list)

## Version

**Configuration Version**: 1.0
**Last Updated**: 2026-01-05
**Neovim Version Required**: 0.10+

---

For questions or issues, check [CODEX.md](./CODEX.md) or run `:checkhealth`
