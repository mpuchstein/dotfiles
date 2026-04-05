pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // ─── Apex palettes ───────────────────────
    readonly property var palettes: ({
        neon: {
            // Backgrounds
            base: "#050505", mantle: "#0a0a0a", crust: "#000000",
            surface0: "#141414", surface1: "#1e1e1e", surface2: "#262626",
            overlay0: "#404040", overlay1: "#555555",
            // Text
            text: "#ededed", subtext0: "#b0b0b0", subtext1: "#d0d0d0",
            // Accent colors — apex-neon palette
            lavender: "#9d00ff",  // sacred purple
            mauve:    "#9d00ff",  // sacred purple
            pink:     "#ff0044",  // razor red
            red:      "#ff0044",  // razor red
            peach:    "#ff8899",  // alert salmon
            yellow:   "#ffb700",  // amber warning
            green:    "#00ff99",  // toxic green
            teal:     "#00ff99",  // toxic green
            blue:     "#00eaff",  // tech cyan
            sky:      "#00eaff"   // tech cyan
        },
        aeon: {
            // Backgrounds
            base: "#f5f5f5", mantle: "#e8e8e8", crust: "#d0d0d0",
            surface0: "#e0e0e0", surface1: "#d4d4d4", surface2: "#c8c8c8",
            overlay0: "#737373", overlay1: "#555555",
            // Text
            text: "#0a0a0a", subtext0: "#444444", subtext1: "#333333",
            // Accent colors — apex-aeon palette
            lavender: "#7a3cff",  // indigo purple
            mauve:    "#7a3cff",  // indigo purple
            pink:     "#ff0044",  // razor red
            red:      "#ff0044",  // razor red
            peach:    "#ff4d6d",  // rose error
            yellow:   "#d18f00",  // dark amber
            green:    "#00b377",  // forest green
            teal:     "#00b377",  // forest green
            blue:     "#007a88",  // deep teal
            sky:      "#007a88"   // deep teal
        }
    })

    readonly property var p: palettes[Config.apexFlavor] || palettes.neon

    // ─── Palette colors ──────────────────────
    readonly property color base: p.base
    readonly property color mantle: p.mantle
    readonly property color crust: p.crust
    readonly property color surface0: p.surface0
    readonly property color surface1: p.surface1
    readonly property color surface2: p.surface2
    readonly property color overlay0: p.overlay0
    readonly property color text: p.text
    readonly property color subtext0: p.subtext0
    readonly property color subtext1: p.subtext1
    readonly property color lavender: p.lavender
    readonly property color mauve: p.mauve
    readonly property color pink: p.pink
    readonly property color red: p.red
    readonly property color peach: p.peach
    readonly property color yellow: p.yellow
    readonly property color green: p.green
    readonly property color teal: p.teal
    readonly property color blue: p.blue
    readonly property color sky: p.sky

    // ─── Semantic aliases ────────────────────
    readonly property color accent: blue      // tech cyan / deep teal
    readonly property color success: green    // toxic / forest
    readonly property color warning: yellow   // amber
    readonly property color danger: red       // razor red
    readonly property color info: sky         // cyan / teal
    readonly property color muted: overlay0   // dim grey

    // ─── Opacity tokens ──────────────────────
    readonly property real opacitySubtle: 0.08      // borders, faint dividers
    readonly property real opacityLight: 0.15       // tinted backgrounds
    readonly property real opacityMedium: 0.3       // active borders, overlays
    readonly property real opacityStrong: 0.45      // muted/disabled elements
    readonly property real opacityFill: 0.7         // progress bar fills

    // ─── Border token ────────────────────────
    readonly property bool isDark: Config.apexFlavor === "neon"
    readonly property color borderSubtle: isDark ? Qt.rgba(1, 1, 1, opacitySubtle) : Qt.rgba(0, 0, 0, opacitySubtle)

    // ─── Transparency ────────────────────────
    readonly property bool transparencyEnabled: Config.transparency
    readonly property color barBackground: transparencyEnabled ? Qt.alpha(mantle, 0.75) : mantle
    readonly property color popoutBackground: transparencyEnabled ? Qt.alpha(mantle, 0.82) : mantle

    // ─── Layout ──────────────────────────────
    readonly property int barWidth: 52
    readonly property int barInnerWidth: 40
    readonly property int barPadding: 6
    readonly property int spacing: 10

    // Popouts
    readonly property int popoutWidth: 320
    readonly property int popoutPadding: 16
    readonly property int popoutSpacing: 10

    // Rounding
    readonly property int radiusSmall: 8
    readonly property int radiusNormal: 14
    readonly property int radiusPill: 1000

    // ─── Typography ──────────────────────────
    readonly property int fontSmall: 11
    readonly property int fontSize: 13
    readonly property int fontLarge: 15
    readonly property string fontFamily: "GeistMono Nerd Font"
    readonly property string iconFont: "GeistMono Nerd Font"

    // ─── Animation ───────────────────────────
    readonly property int animFast: 150
    readonly property int animNormal: 300
    readonly property int animSlow: 500
}
