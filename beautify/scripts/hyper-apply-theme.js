#!/usr/bin/env node
//
// hyper-apply-theme.js — inject a Chroma theme palette into ~/.hyper.js
//
// Used by beautify/install.sh --theme so the palette can be swapped without
// clobbering the rich base config (font/cursor/window/splits) or the user's
// edits. The resulting file stays a plain Hyper config.
//
// Usage:
//   hyper-apply-theme.js <theme-js-path> [hyper-config-path]
//
// If the target config does not exist it is seeded from
// ../config/hyper/hyper.js with the palette applied.

"use strict";

const fs = require("fs");
const path = require("path");
const util = require("util");

const [, , themePathArg, cfgPathArg] = process.argv;
const themePath = path.resolve(themePathArg || "");
const cfgPath = path.resolve(cfgPathArg || path.join(process.env.HOME || "~", ".hyper.js"));
const basePath = path.join(__dirname, "..", "config", "hyper", "hyper.js");

if (!fs.existsSync(themePath)) {
  console.error(`hyper-apply-theme: no theme at ${themePath}`);
  process.exit(1);
}

const palette = require(themePath).config;
const baseCfg = require(basePath);
const userCfg = fs.existsSync(cfgPath) ? require(cfgPath).config : {};

// Merge order: rich base defaults → user edits (font/padding/plugins win) →
// theme palette (colors always come from the theme). This also upgrades old
// palette-only ~/.hyper.js files that the pre-injector installer wrote.
const cfg = Object.assign({}, baseCfg.config, userCfg, {
  backgroundColor: palette.backgroundColor,
  foregroundColor: palette.foregroundColor,
  cursorColor: palette.cursorColor,
  selectionColor: palette.selectionColor,
  borderColor: palette.borderColor,
  colors: palette.colors
});

const out =
  "// Hyper Terminal Configuration — 2026 best-in-class\n" +
  "// Managed by beautify/install.sh. Re-applying a theme only swaps the\n" +
  "// Chroma palette (see scripts/hyper-apply-theme.js); font, cursor, window\n" +
  "// and split settings are preserved.\n" +
  "module.exports = " +
  util.inspect({ config: cfg }, { depth: null, compact: false, breakLength: 60 }) +
  ";\n";

fs.writeFileSync(cfgPath, out);
console.log(`Applied Chroma palette to ${cfgPath}`);