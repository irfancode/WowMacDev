#!/usr/bin/env swift
//
//  make-terminal-profiles.swift
//  ─────────────────────────────────────────────────────────────────────
//  Creates the five Apple Terminal colour schemes used by
//  `profile <name>` (see config/zsh/90-prompt.zsh), and points every
//  one of them at a Nerd Font so the Starship and eza icons render
//  as glyphs rather than empty boxes.
//
//  Why a Swift script: Terminal.app stores the font in the profile
//  plist as an NSKeyedArchiver blob. Neither `defaults write` nor
//  PlistBuddy can synthesise that archive, and the ObjC bridge in
//  osascript/JXA cannot reach +[NSFont fontWithName:size:]. Swift
//  links AppKit directly, so the archive is genuine.
//
//  Usage:
//      swift make-terminal-profiles.swift            # create/refresh
//      swift make-terminal-profiles.swift --list     # show available fonts
//      swift make-terminal-profiles.swift --remove   # delete our schemes
//
//  It only ever writes keys under "Window Settings" and
//  "Profile Color Schemes" whose names begin with "Dev:", so any
//  scheme you created by hand is left untouched.
// ─────────────────────────────────────────────────────────────────────

import Foundation
import AppKit

let BUNDLE = "com.apple.Terminal"
let PREFIX = "Dev:"

// ── Mark: the key we own, so --remove knows what to delete ──
struct Scheme {
    let name: String
    let bg: String
    let fg: String
    let cursor: String
    let selection: String
    let ansiBlack: String
    let ansiRed: String
    let ansiGreen: String
    let ansiYellow: String
    let ansiBlue: String
    let ansiMagenta: String
    let ansiCyan: String
    let ansiWhite: String
    let brightBlack: String
    let brightRed: String
    let brightGreen: String
    let brightYellow: String
    let brightBlue: String
    let brightMagenta: String
    let brightCyan: String
    let brightWhite: String
}

// The palette follows the "Chroma spectrum" starship palette so the
// prompt, the terminal background and eza/bat all agree.
let schemes: [Scheme] = [
    // Everyday dark. Calm, high contrast, no neon.
    Scheme(name: "Default",
           bg: "#1c1b1f", fg: "#fcfcfa",
           cursor: "#fc9867", selection: "#3a3540",
           ansiBlack: "#2d2a2e", ansiRed: "#ff6188", ansiGreen: "#a9dc76",
           ansiYellow: "#ffd866", ansiBlue: "#78dce8", ansiMagenta: "#ab9df2",
           ansiCyan: "#78dce8", ansiWhite: "#e8e6e3",
           brightBlack: "#727072", brightRed: "#ff8ba4", brightGreen: "#c4e88a",
           brightYellow: "#ffe28a", brightBlue: "#9ae6ef", brightMagenta: "#c2b5f7",
           brightCyan: "#9ae6ef", brightWhite: "#fcfcfa"),

    // Production. Deliberately uncomfortable: red cursor, red-tinted
    // background, loud red for anything that errors.
    Scheme(name: "Production",
           bg: "#17090d", fg: "#fff4f5",
           cursor: "#ff2d55", selection: "#4d1622",
           ansiBlack: "#3a2027", ansiRed: "#ff4d6d", ansiGreen: "#8fce6a",
           ansiYellow: "#ffc94d", ansiBlue: "#7fd4e6", ansiMagenta: "#c9a0ff",
           ansiCyan: "#7fd4e6", ansiWhite: "#ffe8ea",
           brightBlack: "#8a5a63", brightRed: "#ff6b85", brightGreen: "#a9e07f",
           brightYellow: "#ffd977", brightBlue: "#9ae6f2", brightMagenta: "#d9bcff",
           brightCyan: "#9ae6f2", brightWhite: "#ffffff"),

    // Remote / SSH. Cool blue-grey so a remote session is obvious
    // at a glance and cannot be confused with the local machine.
    Scheme(name: "Remote",
           bg: "#0f1720", fg: "#e2e8f0",
           cursor: "#38bdf8", selection: "#1e3a52",
           ansiBlack: "#24313f", ansiRed: "#f87171", ansiGreen: "#4ade80",
           ansiYellow: "#facc15", ansiBlue: "#60a5fa", ansiMagenta: "#c084fc",
           ansiCyan: "#22d3ee", ansiWhite: "#dbe3ec",
           brightBlack: "#5b6b7d", brightRed: "#fca5a5", brightGreen: "#86efac",
           brightYellow: "#fde047", brightBlue: "#93c5fd", brightMagenta: "#d8b4fe",
           brightCyan: "#67e8f9", brightWhite: "#f1f5f9"),

    // Light. For a bright room. Darkened ANSI values: the standard
    // 16 colours are far too pale to read on white.
    Scheme(name: "Light",
           bg: "#fdfdfd", fg: "#24292f",
           cursor: "#bc4c00", selection: "#cfe3ff",
           ansiBlack: "#57606a", ansiRed: "#cf222e", ansiGreen: "#116329",
           ansiYellow: "#7d4e00", ansiBlue: "#0969da", ansiMagenta: "#8250df",
           ansiCyan: "#1b7c83", ansiWhite: "#24292f",
           brightBlack: "#6e7781", brightRed: "#a40e26", brightGreen: "#1a7f37",
           brightYellow: "#9a6700", brightBlue: "#218bff", brightMagenta: "#a475f9",
           brightCyan: "#3192aa", brightWhite: "#57606a"),

    // Focus. Almost no chroma, so prompts and diffs are the only
    // coloured things on screen. Low visual noise for long sessions.
    Scheme(name: "Focus",
           bg: "#101012", fg: "#d4d4d8",
           cursor: "#a1a1aa", selection: "#2a2a2e",
           ansiBlack: "#27272a", ansiRed: "#b4646e", ansiGreen: "#8ba37a",
           ansiYellow: "#b8a06a", ansiBlue: "#7a99b8", ansiMagenta: "#9a8fb8",
           ansiCyan: "#7fa8a8", ansiWhite: "#c4c4c8",
           brightBlack: "#52525b", brightRed: "#d1838c", brightGreen: "#a3bd90",
           brightYellow: "#d4bb84", brightBlue: "#96b4d1", brightMagenta: "#b5aad1",
           brightCyan: "#99c2c2", brightWhite: "#e4e4e7")
]

// ── Helpers ────────────────────────────────────────────────

func colour(_ hex: String) -> NSColor {
    var s = hex.trimmingCharacters(in: .whitespaces)
    if s.hasPrefix("#") { s.removeFirst() }
    var value: UInt64 = 0
    Scanner(string: s).scanHexInt64(&value)
    let r = Double((value >> 16) & 0xFF) / 255.0
    let g = Double((value >> 8) & 0xFF) / 255.0
    let b = Double(value & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
}

/// Terminal stores every colour as an archived NSColor, not as a
/// plain string. Archiving it here is the whole reason this script
/// exists.
func archive(_ object: Any) -> Data {
    return try! NSKeyedArchiver.archivedData(
        withRootObject: object, requiringSecureCoding: false)
}

/// The 20 colour keys Terminal understands, in the plist key names
/// it expects. Built as its own function because the colour scheme
/// and the window profile need the identical set — writing them out
/// twice is how the two drift apart.
func colorEntries(_ s: Scheme) -> [String: Any] {
    var out: [String: Any] = [:]
    out["BackgroundColor"] = archive(colour(s.bg))
    out["TextColor"] = archive(colour(s.fg))
    out["CursorColor"] = archive(colour(s.cursor))
    out["SelectionColor"] = archive(colour(s.selection))
    out["TextBoldColor"] = archive(colour(s.fg))

    let plain: [(String, String)] = [
        ("ANSIBlackColor", s.ansiBlack),
        ("ANSIRedColor", s.ansiRed),
        ("ANSIGreenColor", s.ansiGreen),
        ("ANSIYellowColor", s.ansiYellow),
        ("ANSIBlueColor", s.ansiBlue),
        ("ANSIMagentaColor", s.ansiMagenta),
        ("ANSICyanColor", s.ansiCyan),
        ("ANSIWhiteColor", s.ansiWhite),
        ("ANSIBrightBlackColor", s.brightBlack),
        ("ANSIBrightRedColor", s.brightRed),
        ("ANSIBrightGreenColor", s.brightGreen),
        ("ANSIBrightYellowColor", s.brightYellow),
        ("ANSIBrightBlueColor", s.brightBlue),
        ("ANSIBrightMagentaColor", s.brightMagenta),
        ("ANSIBrightCyanColor", s.brightCyan),
        ("ANSIBrightWhiteColor", s.brightWhite),
    ]
    for (k, v) in plain { out[k] = archive(colour(v)) }
    return out
}

/// Pick the best available Nerd Font.
///
/// Two traps here, both verified on this machine:
///
///  1. Only the *Mono* variants of these families are fixed-pitch.
///     "FiraCode Nerd Font" and "JetBrainsMono Nerd Font" report
///     isFixedPitch == false because they ship a proportional and a
///     variable-width cut alongside the monospaced one. A terminal
///     grid needs the Mono cut, so we ask for the exact PostScript
///     name rather than the family name.
///
///  2. +[NSFontManager font(withFamily:traits:weight:size:)] resolves
///     weight 0 to "Thin" for these variable fonts, so it cannot be
///     used to pick a regular weight. NSFont(name:) with a full
///     PostScript name is exact.
func chooseFont() -> (family: String, psName: String)? {
    let families = NSFontManager.shared.availableFontFamilies
    // PostScript name, family it belongs to, and the family name we
    // need to see installed before trusting it.
    let candidates: [(ps: String, family: String, familyName: String)] = [
        ("JetBrainsMonoNFM-Regular",  "JetBrainsMono Nerd Font Mono",  "JetBrainsMono Nerd Font Mono"),
        ("JetBrainsMonoNLNFM-Regular","JetBrainsMonoNL Nerd Font Mono","JetBrainsMonoNL Nerd Font Mono"),
        ("FiraCodeNFM-Reg",           "FiraCode Nerd Font Mono",       "FiraCode Nerd Font Mono"),
        ("MesloLGS-NF-Regular",       "MesloLGS NF",                   "MesloLGS NF"),
        ("HackNerdFont-Regular",      "Hack Nerd Font",                "Hack Nerd Font"),
    ]

    for c in candidates where families.contains(c.familyName) {
        if let f = NSFont(name: c.ps, size: 13), f.isFixedPitch {
            return (c.family, c.ps)
        }
    }

    // Fallback: any Nerd Font family that yields a fixed-pitch font.
    let all: [String] = NSFontManager.shared.availableFonts
    for ps in all.sorted() where ps.hasSuffix("-Regular")
        && (ps.contains("NF") || ps.contains("NerdFont")) {
        if let f = NSFont(name: ps, size: 13), f.isFixedPitch {
            return (ps, ps)
        }
    }
    return nil
}

let args = CommandLine.arguments

// ── --list ─────────────────────────────────────────────────
if args.contains("--list") {
    let fams = NSFontManager.shared.availableFontFamilies
        .filter { $0.contains("Nerd Font") || $0.hasSuffix(" NF") }
        .sorted()
    print("Nerd Font families available to Terminal:")
    for f in fams { print("  \(f)") }
    if let f = chooseFont() {
        print("\nWould use: \(f.psName)  (family \(f.family))")
    } else {
        print("\nNo Nerd Font found. Install one:")
        print("  brew install --cask font-jetbrains-mono-nerd-font")
    }
    exit(0)
}

// ── --remove ───────────────────────────────────────────────
if args.contains("--remove") {
    let d = UserDefaults(suiteName: BUNDLE)!
    for key in ["Window Settings", "Profile Color Schemes"] {
        var dict = d.dictionary(forKey: key) ?? [:]
        for name in dict.keys where (name as String).hasPrefix(PREFIX) {
            dict.removeValue(forKey: name)
            print("removed \(key) → \(name)")
        }
        d.set(dict, forKey: key)
    }
    d.synchronize()
    print("\nDone. Terminal may need a restart to forget the schemes.")
    exit(0)
}

// ── Create / refresh ───────────────────────────────────────

guard let font = chooseFont() else {
    FileHandle.standardError.write(Data("""
    No Nerd Font found. Install one first:
        brew install --cask font-jetbrains-mono-nerd-font
    Then re-run this script.

    """.utf8))
    exit(1)
}

let d = UserDefaults(suiteName: BUNDLE)!
var windowSettings = d.dictionary(forKey: "Window Settings") ?? [:]
var colorSchemes = d.dictionary(forKey: "Profile Color Schemes") ?? [:]

// Font metrics tuned for a terminal grid: 13pt regular, 1.15 line
// spacing, small width adjustment for even cell alignment.
let nsFont = NSFont(name: font.psName, size: 13)!

print("Font: \(font.psName) (\(font.family)) at 13pt\n")

for s in schemes {
    let full = PREFIX + s.name

    // ── Colour scheme ──
    colorSchemes[full] = colorEntries(s)

    // ── Window settings (the "profile") ──
    var ws: [String: Any] = colorEntries(s)

    // Typography + behaviour. Kept as separate assignments rather
    // than one large literal: a 20-key dictionary of Any defeats
    // Swift's type inference and takes an unreasonable time.
    ws["Font"] = archive(nsFont)
    ws["FontHeightSpacing"] = 1.15
    ws["FontWidthSpacing"] = 1.0
    ws["FontAntialias"] = true
    ws["UseBoldFonts"] = true
    ws["UseBrightBold"] = true
    ws["type"] = "Window Settings"
    ws["ProfileCurrentVersion"] = 2.09
    ws["name"] = full

    // 120 columns x 40 rows suits a 14" and a 16" display alike.
    ws["columnCount"] = 120
    ws["rowCount"] = 40
    ws["DrawGrid"] = false
    ws["showGrid"] = false
    ws["ScrollWheelBlock"] = 1

    windowSettings[full] = ws
    print("  ✓ \(full)")
}

d.set(windowSettings, forKey: "Window Settings")
d.set(colorSchemes, forKey: "Profile Color Schemes")
d.synchronize()

// Make the dark default the startup profile, without clobbering the
// user's existing choice of "Clear Dark" — we only switch if it is
// still the stock Basic/Clear default.
let current = d.string(forKey: "Default Window Settings") ?? ""
if current.isEmpty || current == "Basic" || current.hasPrefix("Clear") {
    d.set(PREFIX + "Default", forKey: "Default Window Settings")
    d.set(PREFIX + "Default", forKey: "Startup Window Settings")
    d.synchronize()
    print("\nDefault/startup profile set to \(PREFIX)Default")
} else {
    print("\nLeft your default profile ('\(current)') alone.")
}

print("""

Done. Next steps:
  1. Quit and reopen Terminal (schemes are read at launch).
  2. In the new window, verify the font took: Shell ▸ New Tab,
     then the profile's Text tab.
  3. Switch profiles from the shell:   profile prod | light | remote | focus
  4. Or pick one manually:            Shell ▸ Settings ▸ Profiles

If the icons show as empty boxes, the font did not apply — run with
--list to see which families Terminal can actually see.
""")
