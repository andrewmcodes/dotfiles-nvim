# Keymap reference

Leader is <kbd>Space</kbd>. Press <kbd>Space</kbd> and pause to let [which-key](https://github.com/folke/which-key.nvim) show every option. This page is the full reference; most maps also carry a `desc` visible in `:Telescope keymaps` (`<leader>sk`).

## General & editing

| Key | Mode | Action |
| --- | --- | --- |
| `<C-s>` | n/i/v | Save file |
| `<Esc>` | n | Clear search highlight |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Move to left/down/up/right window |
| `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` | n | Resize window |
| `<A-j>` `<A-k>` | n/i/v | Move line/selection down/up |
| `<C-d>` `<C-u>` | n | Half-page down/up (cursor centered) |
| `n` `N` | n | Next/prev search result (centered) |
| `<` `>` | v | Indent left/right (keeps selection) |
| `gc` `gcc` | n/v | Toggle comment (treesitter-aware) |
| `<leader>l` | n | Open Lazy |
| `<leader>qq` | n | Quit all |

## Motions & text objects (work in VS Code too)

| Key | Mode | Action |
| --- | --- | --- |
| `s` | n/x/o | Flash jump |
| `S` | n/x/o | Flash treesitter select |
| `r` | o | Remote flash |
| `R` | o/x | Treesitter search |
| `sa{motion}{char}` | n/v | Surround add |
| `sd{char}` | n | Surround delete |
| `sr{old}{new}` | n | Surround replace |
| `a`/`i` + `w b q ( [ { t …` | o/x | mini.ai text objects (word, function call, quotes, tags, …) |

## Files & search (Telescope)

| Key | Action |
| --- | --- |
| `<leader><space>` / `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Git-tracked files |
| `<leader>,` | Open buffers |
| `<leader>/` | Live grep (project-wide) |
| `<leader>sw` | Grep word under cursor / selection |
| `<leader>sg` | Grep (same as `<leader>/`) |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sd` | Diagnostics |
| `<leader>sr` | Resume last picker |
| `<leader>sc` | Vim commands |
| `<leader>sn` | Find files in the nvim config |
| `<leader>st` | Todo comments |

## File explorer (neo-tree)

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle explorer, revealing current file |
| `<leader>E` | Focus explorer on current file |

## Buffers (bufferline)

| Key | Action |
| --- | --- |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `[b` / `]b` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bo` | Delete other buffers |
| `<leader>bp` | Toggle pin |

## Code / LSP (active when a server is attached)

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | n | Go to definition |
| `gr` | n | References |
| `gI` | n | Implementations |
| `gy` | n | Type definition |
| `K` | n | Hover documentation |
| `gK` | n | Signature help |
| `<leader>cr` | n | Rename symbol |
| `<leader>ca` | n/x | Code action |
| `<leader>cl` | n | Run code lens (ruby-lsp "run test" / "jump to view") |
| `<leader>cs` | n | Workspace symbols (jump to any class/method) |
| `<leader>cf` | n/v | Format buffer (conform) |
| `<leader>cd` | n | Line diagnostics (float) |
| `<leader>th` | n | Toggle inlay hints |
| `<leader>cp` | n (markdown) | Toggle markdown preview |

## Diagnostics & Trouble

| Key | Action |
| --- | --- |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>xx` | Diagnostics (Trouble) |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Document symbols |
| `<leader>xl` | LSP definitions/references |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |
| `<leader>xt` | Todo comments (Trouble) |

## Git

| Key | Action |
| --- | --- |
| `<leader>gg` | Lazygit |
| `<leader>gl` | Lazygit log |
| `<leader>gd` | Diffview (open) |
| `<leader>gD` | Diffview (close) |
| `<leader>gf` | File history (current file) |
| `<leader>gF` | File history (repo) |
| `<leader>gb` | Toggle inline line blame |
| `]c` / `[c` | Next / previous hunk |
| `<leader>ghs` `<leader>ghr` | Stage / reset hunk (works on a visual range) |
| `<leader>ghS` `<leader>ghR` | Stage / reset buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` `<leader>ghb` `<leader>ghd` | Preview hunk / blame line / diff this |

## Tests (neotest — RSpec + Jest)

| Key | Action |
| --- | --- |
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>tl` | Run last test |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Show output (float) |
| `<leader>tO` | Toggle output panel |
| `<leader>tw` | Toggle watch mode |
| `<leader>tS` | Stop |
| `<leader>td` | Debug nearest test |

## AI

| Key | Mode | Action |
| --- | --- | --- |
| `<M-l>` | i | Accept Copilot suggestion |
| `<M-]>` / `<M-[>` | i | Next / previous suggestion |
| `<C-]>` | i | Dismiss suggestion |
| `<leader>at` | n | Toggle Copilot auto-suggestions |
| `<leader>aa` | n/v | Toggle Copilot Chat |
| `<leader>ax` | n | Reset chat |
| `<leader>ap` | n/v | Prompt actions menu |
| `<leader>ae` `<leader>af` `<leader>av` `<leader>aT` | n/v | Explain / fix / review / generate tests |
| `<leader>Aa` | n/v | Avante ask |
| `<leader>At` | n | Avante toggle sidebar |
| `<leader>Ae` | v | Avante edit selection |
| `<leader>ac` `<leader>ao` `<leader>aC` | n | Toggle Claude Code / opencode / Codex terminal |

## Rails (vim-rails)

`<leader>ra` alternate file, `<leader>rr` related file (vim-rails). Fuzzy resource pickers (telescope-rails): `<leader>rm` models, `<leader>rc` controllers, `<leader>rv` views, `<leader>rs` specs, `<leader>ri` migrations, `<leader>rl` libs. Commands: `:A`, `:AV`, `:AS`, `:R`, `:Emodel`, `:Eview`, `:Econtroller`, `:Emigration`, `:Rails`. `gf` jumps to partials, associations, and requires. See [rails-workflow.md](rails-workflow.md).

## UI toggles

| Key | Action |
| --- | --- |
| `<leader>uw` | Toggle wrap |
| `<leader>us` | Toggle spelling |
| `<leader>ul` | Toggle relative number |
| `<leader>ud` | Toggle diagnostics |
| `<leader>un` | Dismiss notifications |

## Completion menu (blink.cmp — insert mode)

| Key | Action |
| --- | --- |
| `<CR>` | Accept |
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump snippet placeholder |
| `<C-Space>` | Open menu / toggle docs |
| `<C-y>` | Select and accept |
| `<C-e>` | Hide menu |
