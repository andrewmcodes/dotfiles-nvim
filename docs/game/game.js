/*
 * game.js — the trainer engine. Vanilla JS on purpose: zero build step, works
 * offline, just open index.html. (React was allowed but not needed here.)
 *
 * The core loop: show a task ("Go to definition") and capture the real keys you
 * press on your keyboard, matching them against the actual Neovim binding. Get it
 * right first try → points, combo, confetti. Get it wrong → see the answer and
 * retype it to lock the muscle memory in.
 */
(function () {
  "use strict";

  const { WORLDS, CARDS } = window.NVIM_TRAINER;
  const CARD_BY_ID = Object.fromEntries(CARDS.map((c) => [c.id, c]));
  const WORLD_BY_ID = Object.fromEntries(WORLDS.map((w) => [w.id, w]));

  const SESSION_LEN = 12; // rounds per world session — short by design
  const STORE_KEY = "nvim-trainer-v1";
  const SEQ_TIMEOUT = 2000; // ms of stalling before a partial sequence resets

  // ── Persistent state ──────────────────────────────────────────────────────
  const defaultState = () => ({
    xp: 0,
    mastery: {}, // id -> { box, seen, correct }
    completed: {}, // worldId -> true
    settings: { sound: true, motion: true },
  });

  let store = load();

  function load() {
    try {
      const raw = localStorage.getItem(STORE_KEY);
      if (!raw) return defaultState();
      const parsed = JSON.parse(raw);
      return Object.assign(defaultState(), parsed, {
        settings: Object.assign(defaultState().settings, parsed.settings || {}),
      });
    } catch (e) {
      return defaultState();
    }
  }

  function save() {
    try {
      localStorage.setItem(STORE_KEY, JSON.stringify(store));
    } catch (e) {
      /* private mode / quota — the game still works, just won't remember */
    }
  }

  function boxOf(id) {
    return (store.mastery[id] && store.mastery[id].box) || 0;
  }
  function isMastered(id) {
    return boxOf(id) >= 3;
  }
  function bumpMastery(id, correct) {
    const m = store.mastery[id] || { box: 0, seen: 0, correct: 0 };
    m.seen += 1;
    if (correct) {
      m.correct += 1;
      m.box = Math.min(5, m.box + 1);
    } else {
      m.box = Math.max(0, m.box - 1); // gentle: don't fully reset
    }
    store.mastery[id] = m;
  }

  // ── Key notation parsing ────────────────────────────────────────────────
  // Turn a Neovim key string ("<leader>ca", "<C-s>", "gd", "K") into a list of
  // chord tokens: { base, ctrl, alt, shift }.
  function parseKeys(spec) {
    const tokens = [];
    let i = 0;
    while (i < spec.length) {
      if (spec[i] === "<") {
        const end = spec.indexOf(">", i);
        tokens.push(parseSpecial(spec.slice(i + 1, end)));
        i = end + 1;
      } else {
        tokens.push(parseChar(spec[i]));
        i += 1;
      }
    }
    return tokens;
  }

  function parseSpecial(inner) {
    if (inner === "leader") return chord(" ");
    if (inner === "Space") return chord(" ");
    if (inner === "CR") return chord("enter");
    if (inner === "Tab") return chord("tab");
    if (inner === "Esc") return chord("escape");
    const m = inner.match(/^([CSAM])-(.+)$/);
    if (m) {
      const mod = m[1];
      const rest = m[2] === "Space" ? " " : m[2];
      const c = chord(rest.length === 1 ? rest.toLowerCase() : rest.toLowerCase());
      if (mod === "C") c.ctrl = true;
      else if (mod === "S") c.shift = true;
      else c.alt = true; // A or M both mean Alt/Meta here
      return c;
    }
    return chord(inner.toLowerCase());
  }

  function parseChar(ch) {
    if (/[A-Z]/.test(ch)) return chord(ch.toLowerCase(), { shift: true });
    return chord(ch);
  }

  function chord(base, opts) {
    return Object.assign({ base, ctrl: false, alt: false, shift: false }, opts || {});
  }

  // Canonical string for comparing two chords.
  function canon(c) {
    const parts = [];
    if (c.ctrl) parts.push("ctrl");
    if (c.alt) parts.push("alt");
    if (c.shift && /^[a-z]$/.test(c.base)) parts.push("shift");
    parts.push(c.base === " " ? "space" : c.base);
    return parts.join("+");
  }

  // Read a real keydown event into a chord (using e.code so Alt on macOS,
  // which mangles e.key, still resolves to the physical letter).
  const CODE_MAP = {
    Space: " ",
    BracketLeft: "[",
    BracketRight: "]",
    Comma: ",",
    Period: ".",
    Slash: "/",
    Semicolon: ";",
    Backslash: "\\",
    Minus: "-",
    Equal: "=",
    Quote: "'",
    Backquote: "`",
    Enter: "enter",
    Tab: "tab",
    Escape: "escape",
  };
  function chordFromEvent(e) {
    let base;
    if (/^Key[A-Z]$/.test(e.code)) base = e.code.slice(3).toLowerCase();
    else if (/^Digit\d$/.test(e.code)) base = e.code.slice(5);
    else if (CODE_MAP[e.code] !== undefined) base = CODE_MAP[e.code];
    else base = (e.key || "").toLowerCase();
    return { base, ctrl: e.ctrlKey, alt: e.altKey, shift: e.shiftKey };
  }

  // Human-friendly keycaps for a token: ["Ctrl","S"], ["⇧","K"], ["Space"], ["]"]
  const CAP_LABEL = { " ": "Space", enter: "⏎", tab: "⇥", escape: "Esc" };
  function tokenCaps(c) {
    const caps = [];
    if (c.ctrl) caps.push("Ctrl");
    if (c.alt) caps.push("⌥");
    if (c.shift) caps.push("⇧");
    let main = CAP_LABEL[c.base] || c.base;
    if (/^[a-z]$/.test(c.base)) main = c.base.toUpperCase();
    caps.push(main);
    return caps;
  }

  // Pre-parse every card's accepted variants once.
  CARDS.forEach((c) => {
    c.variants = c.keys.map(parseKeys);
    c.canonAnswer = c.variants[0].map(canon).join(" ");
  });

  // ── Sound (WebAudio, no assets) ──────────────────────────────────────────
  let audioCtx = null;
  function actx() {
    if (!store.settings.sound) return null;
    if (!audioCtx) {
      try {
        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      } catch (e) {
        return null;
      }
    }
    return audioCtx;
  }
  function beep(freq, dur, type, gain, when) {
    const ctx = actx();
    if (!ctx) return;
    const t = ctx.currentTime + (when || 0);
    const osc = ctx.createOscillator();
    const g = ctx.createGain();
    osc.type = type || "sine";
    osc.frequency.value = freq;
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(gain || 0.15, t + 0.01);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    osc.connect(g).connect(ctx.destination);
    osc.start(t);
    osc.stop(t + dur + 0.02);
  }
  const sfx = {
    click: () => beep(420, 0.05, "square", 0.05),
    step: () => beep(660, 0.06, "sine", 0.08),
    correct: () => {
      beep(523, 0.12, "sine", 0.14, 0);
      beep(659, 0.12, "sine", 0.14, 0.09);
      beep(784, 0.18, "sine", 0.16, 0.18);
    },
    combo: (n) => beep(600 + n * 60, 0.14, "triangle", 0.14),
    wrong: () => {
      beep(180, 0.18, "sawtooth", 0.12, 0);
      beep(120, 0.22, "sawtooth", 0.12, 0.05);
    },
    win: () => {
      [523, 659, 784, 1046].forEach((f, i) => beep(f, 0.2, "triangle", 0.16, i * 0.12));
    },
  };

  // ── Confetti (canvas particles) ──────────────────────────────────────────
  const canvas = document.getElementById("fx");
  const ctx2d = canvas.getContext("2d");
  let particles = [];
  function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  window.addEventListener("resize", resizeCanvas);
  resizeCanvas();

  const CONFETTI_COLORS = ["#7dd3fc", "#fca5a5", "#86efac", "#fcd34d", "#c4b5fd", "#f9a8d4"];
  function burst(x, y, amount) {
    if (!store.settings.motion) return;
    for (let i = 0; i < amount; i++) {
      const a = Math.random() * Math.PI * 2;
      const speed = 3 + Math.random() * 7;
      particles.push({
        x,
        y,
        vx: Math.cos(a) * speed,
        vy: Math.sin(a) * speed - 4,
        life: 1,
        size: 4 + Math.random() * 6,
        color: CONFETTI_COLORS[(Math.random() * CONFETTI_COLORS.length) | 0],
        rot: Math.random() * Math.PI,
        vr: (Math.random() - 0.5) * 0.3,
      });
    }
    if (!rafId) tick();
  }
  let rafId = null;
  function tick() {
    ctx2d.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach((p) => {
      p.vy += 0.25;
      p.x += p.vx;
      p.y += p.vy;
      p.rot += p.vr;
      p.life -= 0.014;
      ctx2d.save();
      ctx2d.globalAlpha = Math.max(0, p.life);
      ctx2d.translate(p.x, p.y);
      ctx2d.rotate(p.rot);
      ctx2d.fillStyle = p.color;
      ctx2d.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 0.6);
      ctx2d.restore();
    });
    particles = particles.filter((p) => p.life > 0 && p.y < canvas.height + 40);
    if (particles.length) rafId = requestAnimationFrame(tick);
    else {
      ctx2d.clearRect(0, 0, canvas.width, canvas.height);
      rafId = null;
    }
  }

  // ── Leveling ─────────────────────────────────────────────────────────────
  const RANKS = [
    { xp: 0, title: "Fresh Install" },
    { xp: 300, title: "Config Curious" },
    { xp: 800, title: "Buffer Wrangler" },
    { xp: 1600, title: "Rails Rider" },
    { xp: 2800, title: "Motion Apprentice" },
    { xp: 4500, title: "LSP Whisperer" },
    { xp: 7000, title: "Telescope Sniper" },
    { xp: 10000, title: "Vim Sensei" },
    { xp: 14000, title: "Neovim Ninja" },
  ];
  function rankInfo() {
    let idx = 0;
    for (let i = 0; i < RANKS.length; i++) if (store.xp >= RANKS[i].xp) idx = i;
    const cur = RANKS[idx];
    const next = RANKS[idx + 1];
    const level = idx + 1;
    const into = store.xp - cur.xp;
    const span = next ? next.xp - cur.xp : 1;
    return { level, title: cur.title, into, span, pct: next ? into / span : 1, next };
  }

  // ── World unlocking ──────────────────────────────────────────────────────
  function worldCards(worldId) {
    if (worldId === "boss") return CARDS.slice();
    return CARDS.filter((c) => c.world === worldId);
  }
  function isUnlocked(worldId) {
    const idx = WORLDS.findIndex((w) => w.id === worldId);
    if (idx === 0) return true;
    if (worldId === "boss") return WORLDS.filter((w) => w.id !== "boss").every((w) => store.completed[w.id]);
    return !!store.completed[WORLDS[idx - 1].id];
  }
  function worldProgress(worldId) {
    const cards = worldCards(worldId);
    const mastered = cards.filter((c) => isMastered(c.id)).length;
    return { mastered, total: cards.length, pct: mastered / cards.length };
  }

  // ── DOM helpers ──────────────────────────────────────────────────────────
  const $ = (sel) => document.querySelector(sel);
  const el = (tag, cls, txt) => {
    const n = document.createElement(tag);
    if (cls) n.className = cls;
    if (txt != null) n.textContent = txt;
    return n;
  };
  function showScreen(name) {
    document.querySelectorAll(".screen").forEach((s) => s.classList.remove("active"));
    $("#" + name).classList.add("active");
    game.screen = name;
  }

  // Render a sequence of chord tokens as keycap groups into a container.
  function renderKeys(container, tokens, opts) {
    container.innerHTML = "";
    const upto = opts && opts.upto != null ? opts.upto : tokens.length;
    tokens.forEach((tok, i) => {
      const group = el("span", "kc-group" + (i < upto ? " lit" : ""));
      tokenCaps(tok).forEach((cap, j) => {
        if (j > 0) group.appendChild(el("span", "kc-plus", "+"));
        const keycap = el("span", "kc", cap);
        if (cap === "Space") keycap.classList.add("kc-wide");
        if (tok.base === " " && i === 0) keycap.classList.add("kc-leader");
        group.appendChild(keycap);
      });
      container.appendChild(group);
    });
  }

  // ── Game runtime state ────────────────────────────────────────────────────
  const game = {
    screen: "home",
    worldId: null,
    queue: [],
    index: 0,
    current: null,
    phase: "answer", // 'answer' | 'retype'
    buffer: [],
    locked: false,
    usedHint: false,
    startTime: 0,
    seqTimer: null,
    // session tally
    firstTryCorrect: 0,
    misses: 0,
    xpGained: 0,
    maxCombo: 0,
    combo: 0,
    newMasteries: 0,
  };

  // Build a weighted, spaced session queue for a world.
  function buildQueue(worldId) {
    const pool = worldCards(worldId);
    const weightFor = (c) => [6, 5, 4, 3, 2, 1][boxOf(c.id)];
    const pick = () => {
      const total = pool.reduce((s, c) => s + weightFor(c), 0);
      let r = Math.random() * total;
      for (const c of pool) {
        r -= weightFor(c);
        if (r <= 0) return c;
      }
      return pool[pool.length - 1];
    };
    const queue = [];
    const len = pool.length >= SESSION_LEN ? SESSION_LEN : Math.max(pool.length, Math.min(SESSION_LEN, pool.length * 2));
    let guard = 0;
    while (queue.length < len && guard++ < 500) {
      const c = pick();
      // avoid back-to-back repeats when we can
      if (queue.length && queue[queue.length - 1] === c && pool.length > 1) continue;
      queue.push(c);
    }
    return queue;
  }

  function startWorld(worldId) {
    if (!isUnlocked(worldId)) return;
    game.worldId = worldId;
    game.queue = buildQueue(worldId);
    game.index = 0;
    game.firstTryCorrect = 0;
    game.misses = 0;
    game.xpGained = 0;
    game.maxCombo = 0;
    game.combo = 0;
    game.newMasteries = 0;
    // resume audio context on the user gesture that started the world
    if (audioCtx && audioCtx.state === "suspended") audioCtx.resume();
    showScreen("play");
    const w = WORLD_BY_ID[worldId];
    $("#play-world").textContent = w.icon + "  " + w.title;
    $("#play").style.setProperty("--accent", w.accent);
    summonKeyboard(); // raise the soft keyboard on touch (we're in a tap gesture)
    nextRound();
  }

  function nextRound() {
    if (game.index >= game.queue.length) return finishSession();
    game.current = game.queue[game.index];
    game.phase = "answer";
    game.buffer = [];
    game.usedHint = false;
    game.locked = false;
    game.startTime = performance.now();
    clearTimeout(game.seqTimer);
    renderRound();
  }

  function renderRound() {
    const c = game.current;
    const w = WORLD_BY_ID[c.world];
    $("#round-count").textContent = "Round " + (game.index + 1) + " / " + game.queue.length;
    $("#progress-fill").style.width = (game.index / game.queue.length) * 100 + "%";
    $("#hud-score").textContent = game.xpGained.toLocaleString();
    renderCombo();

    $("#card-chip").textContent = w.icon + " " + w.title;
    $("#card-chip").style.background = w.accent + "22";
    $("#card-chip").style.color = w.accent;
    $("#card-label").textContent = c.label;
    $("#card-prompt").textContent = c.prompt;

    const banner = $("#feedback");
    banner.className = "feedback";
    banner.textContent = "";
    $("#answer-reveal").classList.add("hidden");
    $("#answer-reveal").innerHTML = "";
    $("#pressed").innerHTML = "";
    $("#prompt-instr").textContent = "Type the keys…";
    $("#mastery-dots").innerHTML = "";
    const box = boxOf(c.id);
    for (let i = 0; i < 5; i++) {
      const dot = el("span", "dot" + (i < box ? " on" : ""));
      $("#mastery-dots").appendChild(dot);
    }
  }

  function renderCombo() {
    const badge = $("#hud-combo");
    if (game.combo >= 2) {
      badge.textContent = "🔥 " + game.combo + "× combo";
      badge.classList.add("show");
    } else {
      badge.classList.remove("show");
    }
  }

  // ── Input handling ─────────────────────────────────────────────────────────
  function onKeyDown(e) {
    if (game.screen !== "play") return;
    if (e.metaKey) return; // let Cmd-based OS/browser shortcuts through (macOS)
    if (["Shift", "Control", "Alt", "Meta"].includes(e.key)) return; // ignore lone modifiers
    if (e.key === "Escape") {
      e.preventDefault();
      quitToHome();
      return;
    }
    // Soft keyboards (notably Android/GBoard) fire keydown with no usable key
    // — keyCode 229, e.key "Unidentified", or mid-composition. Let those fall
    // through to the hidden field's `input` event instead of a false miss, and
    // don't preventDefault (so the character actually reaches the field).
    if (e.isComposing || e.keyCode === 229 || e.key === "Unidentified") return;
    e.preventDefault(); // capture everything else so the browser doesn't hijack it
    if (e.repeat || game.locked) return;
    feedChord(chordFromEvent(e));
  }

  // Feed one parsed chord into the current round — shared by the physical
  // keyboard (onKeyDown) and the mobile soft-keyboard path (onSoftInput).
  function feedChord(c) {
    if (game.screen !== "play" || game.locked || !game.current) return;
    game.buffer.push(c);
    const bufCanon = game.buffer.map(canon);
    renderKeys($("#pressed"), game.buffer);

    // Compare against every accepted variant of the target.
    let anyPrefix = false;
    let matched = false;
    for (const v of game.current.variants) {
      const vCanon = v.map(canon);
      if (bufCanon.length > vCanon.length) continue;
      let ok = true;
      for (let i = 0; i < bufCanon.length; i++) {
        if (bufCanon[i] !== vCanon[i]) {
          ok = false;
          break;
        }
      }
      if (ok) {
        anyPrefix = true;
        if (bufCanon.length === vCanon.length) matched = true;
      }
    }

    clearTimeout(game.seqTimer);
    if (matched) return game.phase === "answer" ? onCorrect() : onRetypeDone();
    if (anyPrefix) {
      sfx.step();
      game.seqTimer = setTimeout(() => {
        game.buffer = [];
        $("#pressed").innerHTML = "";
      }, SEQ_TIMEOUT);
      return;
    }
    // Wrong key.
    if (game.phase === "answer") return onWrong();
    return onRetypeMiss();
  }

  // Turn a single typed character into a chord (mobile soft-keyboard path).
  function chordFromChar(ch) {
    if (ch === " ") return chord(" ");
    if (/[A-Z]/.test(ch)) return chord(ch.toLowerCase(), { shift: true });
    return chord(ch);
  }

  // The hidden field only exists to open the on-screen keyboard; we read the
  // characters it receives, feed them to the engine, then wipe it clean.
  function onSoftInput(e) {
    const field = $("#mobile-input");
    if (field) field.value = "";
    if (game.screen !== "play" || game.locked) return;
    const type = e.inputType || "";
    if (type.indexOf("delete") === 0) return; // backspace etc. — ignore
    if (type === "insertLineBreak" || type === "insertParagraph") {
      feedChord(chord("enter"));
      return;
    }
    const data = e.data || "";
    for (const ch of data) {
      if (game.locked) break;
      feedChord(chordFromChar(ch));
    }
  }

  // Is this a touch-first device? (Governs the soft-keyboard affordances.)
  const IS_TOUCH =
    (window.matchMedia && window.matchMedia("(hover: none) and (pointer: coarse)").matches) ||
    "ontouchstart" in window ||
    navigator.maxTouchPoints > 0;

  // Focus the hidden field to raise the soft keyboard. Must run inside a user
  // gesture (tap) on mobile, or the browser refuses to show the keyboard.
  function summonKeyboard() {
    if (!IS_TOUCH || game.screen !== "play") return;
    const field = $("#mobile-input");
    if (!field) return;
    try {
      field.focus({ preventScroll: true });
    } catch (e) {
      field.focus();
    }
  }

  function onCorrect() {
    game.locked = true;
    const elapsed = (performance.now() - game.startTime) / 1000;
    const speedBonus = elapsed < 1.5 ? 1.5 : elapsed < 3 ? 1.2 : 1;
    game.combo += 1;
    game.maxCombo = Math.max(game.maxCombo, game.combo);
    const comboMult = Math.min(3, 1 + (game.combo - 1) * 0.2);
    const base = game.usedHint ? 40 : 100;
    const pts = Math.round(base * comboMult * speedBonus);

    const wasMastered = isMastered(game.current.id);
    if (!game.usedHint) bumpMastery(game.current.id, true);
    if (!wasMastered && isMastered(game.current.id)) game.newMasteries += 1;

    game.xpGained += pts;
    store.xp += pts;
    game.firstTryCorrect += game.usedHint ? 0 : 1;
    save();

    renderCombo();
    sfx.correct();
    if (game.combo >= 3) sfx.combo(game.combo);

    const banner = $("#feedback");
    banner.className = "feedback good show";
    const bonus = [];
    if (speedBonus > 1) bonus.push("⚡ fast");
    if (comboMult > 1) bonus.push(comboMult.toFixed(1) + "× combo");
    banner.textContent = pickPraise() + "  +" + pts + (bonus.length ? "  (" + bonus.join(", ") + ")" : "");

    const rect = $("#card").getBoundingClientRect();
    burst(rect.left + rect.width / 2, rect.top + rect.height / 2, game.combo >= 5 ? 90 : 45);

    game.index += 1;
    setTimeout(nextRound, 750);
  }

  function onWrong() {
    game.locked = true;
    game.combo = 0;
    renderCombo();
    game.misses += 1;
    bumpMastery(game.current.id, false);
    save();
    sfx.wrong();
    shake($("#card"));

    // Re-queue this card once, a few rounds later, for a second attempt.
    if (!game.current._requeued) {
      const clone = Object.create(game.current);
      clone._requeued = true;
      const at = Math.min(game.queue.length, game.index + 3);
      game.queue.splice(at, 0, clone);
    }

    const banner = $("#feedback");
    banner.className = "feedback bad show";
    banner.textContent = "Not quite — here's the move. Type it to lock it in.";
    revealAnswer();
    game.phase = "retype";
    game.buffer = [];
    game.locked = false;
    $("#pressed").innerHTML = "";
    $("#prompt-instr").textContent = "Now type it yourself →";
  }

  function onRetypeMiss() {
    game.buffer = [];
    $("#pressed").innerHTML = "";
    shake($("#answer-reveal"));
    sfx.click();
  }

  function onRetypeDone() {
    game.locked = true;
    sfx.step();
    const banner = $("#feedback");
    banner.className = "feedback good show";
    banner.textContent = "That's the one. 💪";
    const rect = $("#card").getBoundingClientRect();
    burst(rect.left + rect.width / 2, rect.top + rect.height / 2, 20);
    game.index += 1;
    setTimeout(nextRound, 550);
  }

  function revealAnswer() {
    const reveal = $("#answer-reveal");
    reveal.classList.remove("hidden");
    reveal.innerHTML = "";
    const keysRow = el("div", "reveal-keys");
    renderKeys(keysRow, game.current.variants[0]);
    reveal.appendChild(keysRow);
    if (game.current.keys.length > 1) {
      const alt = el("div", "reveal-alt", "also: " + game.current.keys.slice(1).join("  ·  "));
      reveal.appendChild(alt);
    }
    reveal.appendChild(el("div", "reveal-mnemonic", "💡 " + game.current.mnemonic));
  }

  const PRAISE = ["Nice!", "Clean!", "Boom!", "Muscle memory!", "Snappy!", "Yes!", "Locked in!", "Smooth!"];
  function pickPraise() {
    return PRAISE[(Math.random() * PRAISE.length) | 0];
  }

  function shake(node) {
    if (!store.settings.motion) return;
    node.classList.remove("shake");
    void node.offsetWidth; // reflow to restart the animation
    node.classList.add("shake");
  }

  // ── Buttons in play ────────────────────────────────────────────────────────
  function useHint() {
    if (game.phase !== "answer" || game.locked) return;
    game.usedHint = true;
    revealAnswer();
    $("#feedback").className = "feedback hint show";
    $("#feedback").textContent = "Half points with a hint — still counts as practice.";
  }
  function showAnswer() {
    if (game.locked) return;
    if (game.phase === "answer") {
      // treat as a miss and drop into retype
      onWrong();
    }
  }

  function finishSession() {
    store.completed[game.worldId] = true;
    save();
    sfx.win();
    burst(canvas.width / 2, canvas.height * 0.35, 160);
    renderResults();
    showScreen("results");
  }

  function quitToHome() {
    clearTimeout(game.seqTimer);
    renderHome();
    showScreen("home");
  }

  // ── Results screen ─────────────────────────────────────────────────────────
  function renderResults() {
    const total = game.firstTryCorrect + game.misses;
    const acc = total ? Math.round((game.firstTryCorrect / total) * 100) : 100;
    $("#results-world").textContent = WORLD_BY_ID[game.worldId].title + " complete!";
    $("#stat-xp").textContent = "+" + game.xpGained.toLocaleString();
    $("#stat-acc").textContent = acc + "%";
    $("#stat-combo").textContent = game.maxCombo + "×";
    $("#stat-mastered").textContent = game.newMasteries;

    const r = rankInfo();
    $("#results-rank").textContent = "Level " + r.level + " · " + r.title;

    // Grade line
    let grade = "Keep drilling — you'll have these cold soon.";
    if (acc >= 95) grade = "Flawless. Absolute wizardry. 🧙";
    else if (acc >= 80) grade = "Sharp. Your fingers know the way. ✨";
    else if (acc >= 60) grade = "Solid progress — run it again to lock it in.";
    $("#results-grade").textContent = grade;

    // Next world button
    const idx = WORLDS.findIndex((w) => w.id === game.worldId);
    const next = WORLDS[idx + 1];
    const nextBtn = $("#btn-next-world");
    if (next && isUnlocked(next.id)) {
      nextBtn.classList.remove("hidden");
      nextBtn.textContent = "Next: " + next.icon + " " + next.title;
      nextBtn.onclick = () => startWorld(next.id);
    } else {
      nextBtn.classList.add("hidden");
    }
    $("#btn-replay").onclick = () => startWorld(game.worldId);
  }

  // ── Home screen ─────────────────────────────────────────────────────────────
  function renderHome() {
    const r = rankInfo();
    $("#rank-level").textContent = "LV " + r.level;
    $("#rank-title").textContent = r.title;
    $("#rank-xp").textContent = store.xp.toLocaleString() + " XP";
    $("#rank-fill").style.width = Math.round(r.pct * 100) + "%";
    $("#rank-next").textContent = r.next ? r.next.xp - store.xp + " XP to " + r.next.title : "Max rank reached 👑";

    const masteredTotal = CARDS.filter((c) => isMastered(c.id)).length;
    $("#stat-mastered-total").textContent = masteredTotal + " / " + CARDS.length;

    const grid = $("#world-grid");
    grid.innerHTML = "";
    WORLDS.forEach((w) => {
      const unlocked = isUnlocked(w.id);
      const prog = worldProgress(w.id);
      const tile = el("button", "world-tile" + (unlocked ? "" : " locked"));
      tile.style.setProperty("--accent", w.accent);
      tile.disabled = !unlocked;

      const top = el("div", "world-top");
      top.appendChild(el("span", "world-icon", w.icon));
      const ring = makeRing(prog.pct, w.accent);
      top.appendChild(ring);
      tile.appendChild(top);

      tile.appendChild(el("div", "world-title", w.title));
      tile.appendChild(el("div", "world-blurb", w.blurb));

      const foot = el("div", "world-foot");
      if (unlocked) {
        foot.appendChild(el("span", "world-count", prog.mastered + "/" + prog.total + " mastered"));
        if (store.completed[w.id]) foot.appendChild(el("span", "world-badge", "✓ cleared"));
      } else {
        foot.appendChild(el("span", "world-lock", "🔒 clear the previous world"));
      }
      tile.appendChild(foot);

      if (unlocked) tile.onclick = () => startWorld(w.id);
      grid.appendChild(tile);
    });

    // toggles reflect stored settings
    $("#toggle-sound").setAttribute("aria-pressed", String(store.settings.sound));
    $("#toggle-sound").textContent = store.settings.sound ? "🔊 Sound" : "🔇 Muted";
    $("#toggle-motion").setAttribute("aria-pressed", String(store.settings.motion));
    $("#toggle-motion").textContent = store.settings.motion ? "✨ Motion" : "🚫 Reduced";
  }

  function makeRing(pct, color) {
    const size = 40;
    const r = 16;
    const circ = 2 * Math.PI * r;
    const svgNS = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(svgNS, "svg");
    svg.setAttribute("width", size);
    svg.setAttribute("height", size);
    svg.setAttribute("class", "ring");
    const bg = document.createElementNS(svgNS, "circle");
    bg.setAttribute("cx", size / 2);
    bg.setAttribute("cy", size / 2);
    bg.setAttribute("r", r);
    bg.setAttribute("class", "ring-bg");
    const fg = document.createElementNS(svgNS, "circle");
    fg.setAttribute("cx", size / 2);
    fg.setAttribute("cy", size / 2);
    fg.setAttribute("r", r);
    fg.setAttribute("class", "ring-fg");
    fg.setAttribute("stroke", color);
    fg.setAttribute("stroke-dasharray", circ);
    fg.setAttribute("stroke-dashoffset", circ * (1 - pct));
    svg.appendChild(bg);
    svg.appendChild(fg);
    const label = document.createElementNS(svgNS, "text");
    label.setAttribute("x", size / 2);
    label.setAttribute("y", size / 2 + 4);
    label.setAttribute("text-anchor", "middle");
    label.setAttribute("class", "ring-label");
    label.textContent = Math.round(pct * 100) + "%";
    svg.appendChild(label);
    return svg;
  }

  // ── Cheat sheet ─────────────────────────────────────────────────────────────
  function renderCheatsheet() {
    const container = $("#cheat-list");
    container.innerHTML = "";
    WORLDS.filter((w) => w.id !== "boss").forEach((w) => {
      const section = el("div", "cheat-section");
      const h = el("h3", "cheat-h");
      h.style.color = w.accent;
      h.textContent = w.icon + " " + w.title;
      section.appendChild(h);
      worldCards(w.id).forEach((c) => {
        const row = el("div", "cheat-row");
        const keys = el("div", "cheat-keys");
        renderKeys(keys, c.variants[0]);
        row.appendChild(keys);
        const info = el("div", "cheat-info");
        info.appendChild(el("span", "cheat-label", c.label));
        info.appendChild(el("span", "cheat-prompt", c.prompt));
        row.appendChild(info);
        if (isMastered(c.id)) row.appendChild(el("span", "cheat-mastered", "★"));
        section.appendChild(row);
      });
      container.appendChild(section);
    });
  }

  // ── Wiring ───────────────────────────────────────────────────────────────────
  function quickPlay() {
    // pick the first unlocked world that isn't fully mastered, else the boss/daily
    const candidate =
      WORLDS.find((w) => isUnlocked(w.id) && worldProgress(w.id).pct < 1) ||
      WORLDS.filter((w) => isUnlocked(w.id)).pop() ||
      WORLDS[0];
    startWorld(candidate.id);
  }

  function bind() {
    window.addEventListener("keydown", onKeyDown, true);

    // Mobile: raise/keep the soft keyboard and read what it types.
    if (IS_TOUCH) document.body.classList.add("touch");
    const mobileInput = $("#mobile-input");
    if (mobileInput) mobileInput.addEventListener("input", onSoftInput);
    // Tapping the card (or the explicit button) re-summons the keyboard if the
    // field ever loses focus mid-session.
    $("#card").addEventListener("click", summonKeyboard);
    $("#btn-keyboard").onclick = function () {
      this.blur();
      summonKeyboard();
    };

    $("#btn-start").onclick = quickPlay;
    $("#btn-cheat").onclick = () => {
      renderCheatsheet();
      showScreen("cheatsheet");
    };
    $("#cheat-back").onclick = quitToHome;
    $("#play-back").onclick = quitToHome;
    $("#results-home").onclick = quitToHome;
    // Blur after click so a following Space/Enter goes to the game, not the button.
    $("#btn-hint").onclick = function () {
      this.blur();
      useHint();
      summonKeyboard();
    };
    $("#btn-show").onclick = function () {
      this.blur();
      showAnswer();
      summonKeyboard();
    };

    $("#toggle-sound").onclick = () => {
      store.settings.sound = !store.settings.sound;
      save();
      renderHome();
    };
    $("#toggle-motion").onclick = () => {
      store.settings.motion = !store.settings.motion;
      save();
      renderHome();
    };
    $("#btn-reset").onclick = () => {
      if (confirm("Reset all progress, XP and mastery? This can't be undone.")) {
        store = defaultState();
        save();
        renderHome();
      }
    };

    renderHome();
    showScreen("home");
  }

  document.addEventListener("DOMContentLoaded", bind);
})();
