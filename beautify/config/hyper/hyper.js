// ═══════════════════════════════════════════════════════════
// Hyper Terminal Configuration — 2026 best-in-class
// Hyper 3.4/3.5 · macOS · Chroma themes
// ═══════════════════════════════════════════════════════════

// The Chroma palette block is injected by beautify/install.sh --theme
// (see scripts/hyper-apply-theme.js). Re-applying a theme only swaps the
// palette — font, cursor, window and split settings below survive.

module.exports = {
  config: {
    // ── Font & Typography ────────────────────────────────────
    // MONOSPACED Nerd Font variant (NFM): Hyper has its own Nerd Font
    // handling, so the mono build keeps every icon exactly one cell wide
    // (lazygit/btop/starship borders stay on-grid) — same reasoning as the
    // Ghostty config. Symbols Nerd Font covers any glyph the primary lacks.
    fontSize: 14,
    fontFamily:
      '"JetBrainsMono Nerd Font Mono", "Symbols Nerd Font", Menlo, monospace',
    fontWeight: "normal",
    fontWeightBold: "bold",
    lineHeight: 1.2,
    letterSpacing: 0.4,
    fontSmoothing: "antialiased",

    // ── Window & Padding ─────────────────────────────────────
    padding: "12px 12px",
    windowSize: [120, 34],
    showWindowControls: true,
    webLinksActivationKey: "ctrl",

    // ── Cursor ───────────────────────────────────────────────
    cursorShape: "bar",
    cursorBlink: true,

    // ── Palette ═════════════════╗
    // ╚══ THIS BLOCK IS THEME-MANAGED ════════════════════════
    backgroundColor: "#2d2a2e",
    foregroundColor: "#fcfcfa",
    cursorColor: "#c1c0c0",
    selectionColor: "#fcfcfa",
    borderColor: "#2d2a2e",
    colors: {
      black: "#2d2a2e",
      red: "#ff6188",
      green: "#a9dc76",
      yellow: "#ffd866",
      blue: "#fc9867",
      magenta: "#ab9df2",
      cyan: "#78dce8",
      white: "#fcfcfa",
      lightBlack: "#727072",
      lightRed: "#ff6188",
      lightGreen: "#a9dc76",
      lightYellow: "#ffd866",
      lightBlue: "#fc9867",
      lightMagenta: "#ab9df2",
      lightCyan: "#78dce8",
      lightWhite: "#fcfcfa"
    },
    // ── Palette end ──────────────────────────────────────────

    // ── Behavior ─────────────────────────────────────────────
    copyOnSelect: true,
    scrollbackLines: 10000,
    shell: "/bin/zsh",

    // ── Plugins ──────────────────────────────────────────────
    plugins: [],
    localPlugins: [],

    // ── Keybindings (macOS) ─────────────────────────────────
    keymaps: {
      "tab:new": "meta+t",
      "tab:next": "meta+shift+]",
      "tab:prev": "meta+shift+[",
      "pane:splitVertical": "meta+d",
      "pane:splitHorizontal": "meta+shift+d",
      "pane:zoom": "meta+shift+z",
      "pane:close": "meta+w",
      "editor:copy": "meta+c",
      "editor:paste": "meta+v",
      "editor:search": "meta+f",
      "window:reloadFull": "meta+shift+r"
    }
  }
};