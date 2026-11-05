pragma Singleton

import QtQuick
import Quickshell

// One source of truth for the palette, type and metrics.
Singleton {
    // Stone
    readonly property color stone900: "#1a1917"
    readonly property color stone800: "#252320"
    readonly property color stone700: "#322f2b"
    // Ink and metal
    readonly property color ivory: "#e6e2d8"
    readonly property color ivoryDim: "#a39e91"
    readonly property color ivoryFaint: "#6d685e"
    readonly property color bronze: "#b89f74"
    readonly property color bronzeDim: "#6f6047"
    // Sealed verse. #962d2d is for fills and arcs; thin text needs the lit variant to stay legible.
    readonly property color crimson: "#962d2d"
    readonly property color crimsonLit: "#d4615b"

    // Translucent surfaces
    readonly property color surface: Qt.rgba(0x1a / 255, 0x19 / 255, 0x17 / 255, 0.88)
    readonly property color frameInner: Qt.rgba(0xb8 / 255, 0x9f / 255, 0x74 / 255, 0.28)

    // Type. Cinzel has no Cyrillic: use `serif` for anything an application supplies.
    readonly property string display: "Cinzel"
    readonly property string serif: "Cormorant Garamond"
    readonly property string book: "EB Garamond"     // sturdier than Cormorant, for reading lists
    readonly property string mono: "JetBrains Mono"
    readonly property string rune: "Noto Sans Runic"

    // Bar metrics
    readonly property int barHeight: 42
    readonly property int barMargin: 6
}
