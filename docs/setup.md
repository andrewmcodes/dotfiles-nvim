# Setup

Provisioning a fresh macOS machine so this config works end to end. Once the toolchain is in place, [getting-started.md](getting-started.md) covers first launch and day-to-day use.

Two managers own the toolchain:

- **[Homebrew](https://brew.sh)** — the editor and system CLIs (Neovim, ripgrep, fd, lazygit, git) plus the AI-agent CLIs.
- **[mise](https://mise.jdx.dev)** — language runtimes and per-language tooling (Ruby, Node, the `tree-sitter` parser CLI). Ruby/Node versions resolve per project, so nvim always talks to the right one.

The dividing line matters: anything mise manages is only on `PATH` when mise is active, which is why nvim must be launched from a mise-activated shell (see [Launch nvim from a mise shell](#launch-nvim-from-a-mise-shell)).

## 1. System tools (Homebrew)

Install the [Command Line Tools](https://developer.apple.com/xcode/) for `make` and a C compiler (`cc`), which treesitter and fzf-native need to build:

```sh
xcode-select --install
```

Then Homebrew and the editor + system CLIs:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install neovim ripgrep fd lazygit git
```

Neovim must be **0.12+** (this config uses the native `vim.lsp.config`/`vim.lsp.enable` API); Homebrew's `neovim` is current. Confirm with `nvim --version`.

### Nerd Font

Icons in the statusline, file tree, and completion menu assume a Nerd Font. This config is tuned for JetBrainsMono:

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

Set your terminal (Ghostty/iTerm/WezTerm/…) to use "JetBrainsMono Nerd Font".

## 2. Runtimes & parser CLI (mise)

Install mise and activate it in your shell — this is the step that puts mise-managed tools on `PATH`:

```sh
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc   # then restart the shell
```

Install the runtimes and the treesitter parser CLI globally:

```sh
mise use -g ruby@4.0.5 node@24.13.0 tree-sitter@latest
```

- **`ruby`** backs `ruby-lsp`, which is launched via `mise x -- ruby-lsp` so it always runs under the project's pinned Ruby (a global fallback here is fine; real projects override it via their own `.mise.toml`/`.ruby-version`).
- **`node`** backs the JavaScript LSP/formatter tooling and Copilot.
- **`tree-sitter`** compiles nvim-treesitter parsers locally — the `main` branch requires it. Without it, `:TSUpdate` and parser installs fail.

Verify all three resolve: `mise ls`, then `tree-sitter --version`.

> Ruby linters/formatters (`ruby-lsp`, `standardrb`, `rubocop`) come from each project's own bundle, not from a global install — nothing extra to set up here.

### ERB formatting (optional)

The ERB **language server** (`herb-language-server`) is installed automatically by Mason. The matching ERB **formatter** is a separate package and is not, because it's best pinned per project:

```sh
# preferred — add it to the Rails app's package.json so the team shares a version
yarn add --dev @herb-tools/formatter

# or globally, if you'd rather not touch the project
npm install -g @herb-tools/formatter
```

conform resolves `herb-format` from the project's `node_modules/.bin` first and falls back to a global install (the same mechanism as Prettier). Until it's installed, saving an `.erb` file is simply a no-op rather than an error — so this step is safe to skip.

> Herb's formatter is still an experimental preview upstream, so the first save of a long-lived view can produce a large reformat diff. `:FormatDisable!` turns autoformat off for the current buffer, `:FormatDisable` globally. See [rails-workflow.md](rails-workflow.md#formatting--linting).

## 3. AI CLIs (subscription-based, no API keys)

The `<leader>a` agent terminals and Copilot are all subscription-based. Install each per its official instructions:

- **[Claude Code](https://docs.claude.com/en/docs/claude-code)** — the `claude` CLI.
- **[opencode](https://opencode.ai)** — the `opencode` CLI.
- **[Codex](https://github.com/openai/codex)** — the `codex` CLI.

Copilot (inline suggestions, chat, and the default Avante provider) needs a GitHub Copilot subscription; you sign in from inside Neovim with `:Copilot auth` on first launch.

## 4. Clone the config

```sh
git clone git@github.com:andrewmcodes/dotfiles-nvim.git ~/.config/nvim
```

If `~/.config/nvim` already exists, move it aside first (`mv ~/.config/nvim ~/.config/nvim.bak`).

## 5. First launch

Open `nvim` and let it bootstrap — lazy.nvim installs plugins, Mason installs the language servers/formatters, treesitter compiles its parsers, and blink.cmp fetches its fuzzy-matcher binary. Then `:Copilot auth` and `:checkhealth`. The full walkthrough is in [getting-started.md](getting-started.md#first-launch).

## Launch nvim from a mise shell

`ruby-lsp` and the `tree-sitter` CLI live under mise, so they are only on `PATH` when mise is active. Launching nvim from a shell where `eval "$(mise activate zsh)"` has run (any normal interactive terminal, once step 2 is done) is all that's required. If you launch nvim some other way (a GUI launcher, a bare login shell) and Ruby highlighting/LSP or parser installs silently fail, that missing activation is almost always why.

Quick checks from inside nvim:

- `:echo exepath('tree-sitter')` — should print a mise path, not empty.
- `:checkhealth vim.treesitter` — parsers listed and OK.
- `:LspInfo` on a `.rb` file — `ruby_lsp` attached.

See [troubleshooting.md](troubleshooting.md) if any of these come up empty.
