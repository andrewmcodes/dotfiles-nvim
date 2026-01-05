# Neovim Configuration Optimization Plan

## Overview
This plan outlines optimizations for the Neovim configuration based on a comprehensive review of the current setup. The configuration is based on Kickstart.nvim with custom plugins and modifications.

## Current State Analysis

### Strengths
- Well-organized plugin structure in `lua/custom/plugins/`
- Good separation of concerns (keymaps, options, plugins)
- Using lazy.nvim for plugin management
- Ruby LSP properly configured with adam12/ruby-lsp.nvim
- Mason for LSP/tool installation
- Format-on-save with conform.nvim
- Basic linting with nvim-lint (markdown only)

### Areas for Improvement
1. **No Lua linting** - Configuration files have no linting
2. **No dependency management documentation** - No guide for installing external tools
3. **Limited linter coverage** - Only markdown linting configured
4. **No .tool-versions or .mise.toml** - No version management for dependencies
5. **Incomplete documentation** - No central reference for keybindings and features

## Implementation Plan

### Phase 1: Dependency Management (Priority: HIGH)

#### 1.1 Add mise Configuration
**Goal:** Use mise (modern asdf replacement) for managing tool versions

**Tasks:**
- [ ] Create `.tool-versions` or `.mise.toml` in nvim config directory
- [ ] Document required tools: lua, stylua, luacheck/selene, ruby, etc.
- [ ] Add installation script or README section
- [ ] Consider adding mise hook to auto-install dependencies

**Files to modify/create:**
- Create: `.mise.toml` or `.tool-versions`
- Create: `scripts/install-dependencies.sh`
- Update: Main documentation

#### 1.2 Homebrew Fallback
**Goal:** Provide Homebrew installation instructions for users not using mise

**Tasks:**
- [ ] Document Homebrew installation commands
- [ ] Create Brewfile (optional)
- [ ] Add to documentation

**Files to create:**
- Create: `Brewfile` (optional)

### Phase 2: Lua Linting (Priority: HIGH)

#### 2.1 Add Lua Linter
**Goal:** Enable linting for Lua configuration files

**Options:**
- **luacheck** - Traditional, widely used
- **selene** - Modern, faster, better diagnostics (RECOMMENDED)

**Tasks:**
- [ ] Install selene via mise/homebrew
- [ ] Add selene to lint.lua configuration
- [ ] Create `.selene.toml` or `selene.toml` configuration
- [ ] Configure to recognize vim globals (vim, require, etc.)
- [ ] Test on existing configuration files

**Files to modify/create:**
- Modify: `lua/custom/plugins/lint.lua`
- Create: `selene.toml` or `.luacheckrc`

### Phase 3: Enhanced Linting & Formatting (Priority: MEDIUM)

#### 3.1 Add More Language Support
**Goal:** Expand linting and formatting for common languages

**Tasks:**
- [ ] Add Ruby linting (handled by ruby-lsp, verify configuration)
- [ ] Add JSON/YAML linting (prettier or specific tools)
- [ ] Add shell script linting (shellcheck)
- [ ] Add Python linting (ruff or pylint)
- [ ] Add JavaScript/TypeScript linting (eslint)

**Files to modify:**
- Modify: `lua/custom/plugins/lint.lua`
- Modify: `lua/custom/plugins/conform.lua`
- Modify: `lua/custom/plugins/lspconfig.lua`

#### 3.2 Optimize Mason Setup
**Goal:** Ensure all required tools are auto-installed

**Tasks:**
- [ ] Add commonly used LSPs to ensure_installed
- [ ] Add formatters to ensure_installed (prettier, black, etc.)
- [ ] Add linters to ensure_installed (shellcheck, etc.)

**Files to modify:**
- Modify: `lua/custom/plugins/lspconfig.lua`

### Phase 4: Plugin Enhancements (Priority: MEDIUM)

#### 4.1 Add Missing Quality-of-Life Plugins
**Goal:** Enhance development experience

**Potential additions:**
- [ ] trouble.nvim - Better diagnostics UI
- [ ] nvim-spectre - Search and replace across project
- [ ] persistence.nvim - Session management
- [ ] flash.nvim or leap.nvim - Enhanced navigation
- [ ] noice.nvim - Enhanced UI for messages, cmdline, popupmenu

**Files to create:**
- Create: Individual plugin files in `lua/custom/plugins/`

#### 4.2 Enhanced Git Integration
**Goal:** Improve Git workflow

**Tasks:**
- [ ] Consider lazygit.nvim integration
- [ ] Add diffview.nvim for better diff viewing
- [ ] Enhance gitsigns configuration

**Files to modify/create:**
- Modify: `lua/custom/plugins/gitsigns.lua`
- Create: Additional git plugin files

### Phase 5: Performance Optimization (Priority: LOW)

#### 5.1 Lazy Loading Optimization
**Goal:** Ensure optimal startup time

**Tasks:**
- [ ] Review lazy.nvim loading strategies
- [ ] Add event-based loading where missing
- [ ] Profile startup time (`:Lazy profile`)
- [ ] Optimize heavy plugins

**Files to modify:**
- Review all plugin files for lazy loading opportunities

#### 5.2 Keybinding Optimization
**Goal:** Improve keybinding organization and discoverability

**Tasks:**
- [ ] Review which-key groups
- [ ] Add missing leader key groups
- [ ] Document custom keybindings
- [ ] Consider adding more mnemonic bindings

**Files to modify:**
- Modify: `lua/custom/plugins/which-key.lua`
- Modify: `lua/keymaps.lua`

### Phase 6: Documentation (Priority: HIGH)

#### 6.1 Create CODEX.md
**Goal:** Comprehensive documentation of entire configuration

**Sections needed:**
- [ ] Table of Contents
- [ ] Quick Start Guide
- [ ] Installation Instructions
- [ ] Plugin Directory
- [ ] LSP Configuration
- [ ] Keybindings Reference
- [ ] Formatting & Linting
- [ ] Customization Guide
- [ ] Troubleshooting
- [ ] FAQ

**Files to create:**
- Create: `CODEX.md`

#### 6.2 Additional Documentation
**Goal:** Support documentation for specific areas

**Tasks:**
- [ ] Create CONTRIBUTING.md for configuration changes
- [ ] Add inline comments where missing
- [ ] Document custom functions

## Implementation Order

### Sprint 1 (Immediate)
1. Add Lua linting (selene)
2. Create mise configuration
3. Create CODEX.md

### Sprint 2 (Short-term)
1. Add dependency installation scripts
2. Enhance linting for other languages
3. Optimize Mason setup

### Sprint 3 (Medium-term)
1. Add quality-of-life plugins
2. Enhanced Git integration
3. Keybinding optimization

### Sprint 4 (Long-term)
1. Performance profiling and optimization
2. Custom snippets and templates
3. Advanced workflow automation

## Success Criteria

- [ ] All Lua files pass linting without errors
- [ ] Dependencies can be installed via single command
- [ ] CODEX.md provides complete reference
- [ ] Startup time < 100ms (measure with `nvim --startuptime`)
- [ ] All common languages have LSP + linting + formatting
- [ ] Zero configuration errors in `:checkhealth`

## Notes

- Prefer mise over asdf (more modern, faster)
- Use selene over luacheck (better defaults, faster)
- Keep configuration modular and well-commented
- Test each change incrementally
- Maintain compatibility with Kickstart.nvim updates

## References

- [mise documentation](https://mise.jdx.dev/)
- [selene documentation](https://kampfkarren.github.io/selene/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason registry](https://mason-registry.dev/)
