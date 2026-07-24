# AI workflow

Everything is **subscription-based — no model API keys**. GitHub Copilot (your subscription) powers inline completion, chat, and Avante; Claude and Codex are used through their already-authenticated CLIs.

## Copilot inline completion

`copilot.lua` shows ghost-text suggestions as you type.

| Key | Mode | Action |
| --- | --- | --- |
| `<M-l>` | i | Accept the suggestion |
| `<M-]>` / `<M-[>` | i | Cycle to next / previous suggestion |
| `<C-]>` | i | Dismiss |
| `<leader>at` | n | Toggle auto-suggestions on/off |

First-time setup: `:Copilot auth` (then `:Copilot status` to confirm). Copilot also appears as a source in the completion menu, boosted to the top.

## Copilot Chat

`CopilotChat.nvim` is an in-editor chat panel with buffer/selection context.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>aa` | n/v | Toggle the chat window |
| `<leader>ax` | n | Reset the conversation |
| `<leader>ap` | n/v | Prompt-actions menu (pick a canned prompt) |
| `<leader>ae` | n/v | Explain the code / selection |
| `<leader>af` | n/v | Fix the code / selection |
| `<leader>av` | n/v | Review the code / selection |
| `<leader>aT` | n/v | Generate tests |

Select code in visual mode first, then use `<leader>ae`/`af`/`av`/`aT` to act on the selection.

## Avante (Cursor-style panel)

`avante.nvim` is a sidebar that can read and apply edits to your buffers agentically. It defaults to the **Copilot provider**, so it runs on your Copilot subscription with no API key.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>Aa` | n/v | Ask Avante about the file / selection |
| `<leader>At` | n | Toggle the Avante sidebar |
| `<leader>Ae` | v | Edit the selection with Avante |

Avante's default mappings live under `<leader>a`, which would collide with the Copilot group — so this config relocates all of them to `<leader>A`.

### Drive Avante with your Claude subscription (optional)

To route Avante through the authenticated `claude` CLI (still no API key), uncomment the ACP/`claude-code` provider block in `lua/plugins/ai.lua`. It sets `provider = "claude-code"` and points at the `claude` command over the Agent Client Protocol.

## CLI agents in a split

The primary way to use your Claude and Codex subscriptions is their CLIs, popped into a terminal split via `snacks.terminal`:

| Key | Opens |
| --- | --- |
| `<leader>ac` | Claude Code (`claude`) |
| `<leader>ao` | opencode |
| `<leader>aC` | Codex (`codex`) |

Each terminal is keyed by its command, so pressing the key again toggles the same session (it persists in the background). They open in a right split scoped to the current working directory. Use `<Esc><Esc>` to leave terminal-insert mode, and the key again to hide.

## Which tool when?

- **Inline Copilot** — line-by-line autocomplete while typing.
- **Copilot Chat** — quick "explain/fix/review this" without leaving the buffer.
- **Avante** — multi-file, apply-the-diff style edits inside Neovim.
- **Claude Code / Codex / opencode terminals** — full agentic sessions using your subscriptions, with the repo's existing agent config (`.claude`, `opencode.json`, `AGENTS.md`).
