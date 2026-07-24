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

1. ⚡ **Daily Drivers** — find files, grep, save, definition/references, window & buffer nav
2. 🚂 **Rails, Rails, Rails** — alternate/related file, model/controller/view/spec/migration pickers, `gf`, workspace symbols, code lens
3. 🧪 **Test Lab** — run nearest/file/last, summary, output, watch (neotest + RSpec)
4. 🔧 **Code & Fix** — rename, code action, format, diagnostics, Trouble
5. 🌿 **Git Flow** — Lazygit, Diffview, blame, hunks, stage/reset
6. 🤖 **AI Copilot** — accept/cycle suggestions, chat, explain/fix/tests, Claude Code terminal
7. 🥷 **Motion Master** — flash, surround, comment, move lines (these work in VS Code too)
8. 🧠 **Second Brain** — Obsidian: daily note, new/search/quick-switch, backlinks, follow link, toggle checkbox, templates
9. 👑 **Boss: Everything** — a gauntlet drawn from every world (unlocks once the rest are cleared)

Every world is playable immediately — pick any one. Clearing a world still fills its mastery ring and marks it ✓, and the Boss draws from all of them. Progress is saved in your browser's `localStorage` — the `↺ Reset` button wipes it.

## Where the data comes from

`data.js` is the whole dataset, and every entry is a real binding from this config. The source of truth for keymaps is still [`docs/keymaps.md`](../keymaps.md) and [`docs/rails-workflow.md`](../rails-workflow.md) — when a keymap changes there, update `data.js` to match.

## Files

| File         | Role                                                                           |
| ------------ | ------------------------------------------------------------------------------ |
| `index.html` | Screens + layout                                                               |
| `styles.css` | Arcade-neon theme, keycaps, animations                                         |
| `data.js`    | The curated keymap dataset (worlds, cards, mnemonics)                          |
| `game.js`    | Engine: key-notation parser, input matching, scoring, mastery, confetti, sound |
