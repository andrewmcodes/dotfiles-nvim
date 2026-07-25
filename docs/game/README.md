# Keycombat — learn this config by playing

An interactive, ADHD-friendly game for burning this Neovim config's keymaps into muscle memory. It shows you a task ("Go to definition", "Jump to the model's spec") and you press the **real keys on your keyboard** — the game matches them against the actual binding from this config.

It plays two ways: **keyboard-driven on desktop** (press the real keys), and **Duolingo-style on mobile** — touch devices get an on-screen keypad with its own **Ctrl / Alt / Shift** keys (tap a modifier to arm it, then tap the next key), since phones have no Ctrl. Every world is unlocked from the start, so you can jump straight to any lesson (e.g. Git Flow), and **⏭ Skip** moves past a card you don't want right now.

## Play it

Open `docs/game/index.html` in any browser. No build, no install, no internet — it's plain HTML/CSS/JS (no framework needed).

```sh
open docs/game/index.html          # macOS
# or serve it, if your browser blocks file:// for whatever reason:
python3 -m http.server -d docs/game 8000   # then visit http://localhost:8000
```

## Why it's built this way (for ADHD focus)

- **Do, don't read.** You practice the actual key presses, not flashcards. Active recall + motor memory is what makes a keymap stick.
- **Tiny sessions.** A "world" is ~12 quick rounds — a 60-second hit, not a course.
- **Instant, loud feedback.** Correct → points, combo multiplier, confetti, a satisfying chord. Wrong → you see the answer and _retype it_ to lock it in before moving on.
- **Visible progress.** XP, levels, per-world mastery rings, and a rank that climbs from _Fresh Install_ to _Neovim Ninja_.
- **One thing on screen at a time.** No walls of text; the current task is the whole screen.
- **Escape hatches.** `💡 Hint` (half points) and `👀 Show me` mean you're never stuck and anxious.
- **Accessibility.** Toggles for **sound** and **motion**, and it honors your OS `prefers-reduced-motion`.

## Worlds (ordered by how often a Rails dev reaches for them)

1. ⚡ **Daily Drivers** — find files, grep, save, definition/references, window & buffer nav, undo tree, session restore
2. 🚂 **Rails, Rails, Rails** — alternate/related file, resource pickers (models → jobs → Stimulus), routes picker, console, migrate, `gf`, workspace symbols, code lens
3. 🔪 **Ruby Surgery** — `%` between `def`/`end`, whole-method and whole-class textobjects, method/class motions (treesitter-accurate; standalone Neovim only)
4. 🧪 **Test Lab** — run nearest/file/last, summary, output, watch (neotest + RSpec)
5. 🐞 **Debugger** — breakpoints, continue, step over/into, inspect a value, debug the nearest spec (nvim-dap + `rdbg`)
6. 🔧 **Code & Fix** — rename, code action, format, diagnostics, Trouble
7. 🌿 **Git Flow** — Lazygit, Diffview, blame, hunks, stage/reset
8. 🤖 **AI Copilot** — accept/cycle suggestions, chat, explain/fix/tests, Claude Code terminal
9. 🥷 **Motion Master** — flash, surround, comment, move lines (these work in VS Code too)
10. 🧠 **Second Brain** — Obsidian: daily note, new/search/quick-switch, backlinks, follow link, toggle checkbox, templates
11. 👑 **Boss: Everything** — a gauntlet drawn from every world (unlocks once the rest are cleared)

> **Ruby Surgery** and **Debugger** are standalone-Neovim only — treesitter textobjects, vim-matchup and nvim-dap are all gated off inside VS Code. **Motion Master** is the world whose moves carry over.

Every world is playable immediately — pick any one. Clearing a world still fills its mastery ring and marks it ✓, and the Boss draws from all of them. Progress is saved in your browser's `localStorage` — the `↺ Reset` button wipes it.

## Where the data comes from

`data.js` is the whole dataset, and every entry is a real binding from this config. The source of truth for keymaps is still [`docs/keymaps.md`](../keymaps.md) and [`docs/rails-workflow.md`](../rails-workflow.md) — when a keymap changes there, update `data.js` to match.

Two traps when adding a card, both of which have bitten this file before:

- **The answer has to be typeable.** `keys[0]` is parsed into chords and compared against real keydown events. A token whose base no keypress can produce (e.g. writing `<Space>` in a way the parser resolves to the literal string `"space"`) makes the card unanswerable. Shifted punctuation like `%` and `?` is handled by the `SHIFTED` map in `game.js` — if you add a card needing a glyph that isn't in it, extend it.
- **Mind the mobile keypad.** Touch users can only press what `KEYPAD_ROWS` offers, so a card needing a new punctuation key also needs that key added there.

## Files

| File         | Role                                                                           |
| ------------ | ------------------------------------------------------------------------------ |
| `index.html` | Screens + layout                                                               |
| `styles.css` | Arcade-neon theme, keycaps, animations                                         |
| `data.js`    | The curated keymap dataset (worlds, cards, mnemonics)                          |
| `game.js`    | Engine: key-notation parser, input matching, scoring, mastery, confetti, sound |
