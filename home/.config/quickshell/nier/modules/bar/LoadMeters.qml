import QtQuick
import qs.services
import qs.theme
import qs.widgets

// System load, always in view: ᛊ CPU and ᛒ memory, turning crimson at 90%. Click opens btop.
Row {
    spacing: 12

    Repeater {
        model: [
            { rune: "ᛊ", value: () => System.cpu },
            { rune: "ᛒ", value: () => System.memory }
        ]
        Meter {
            required property var modelData
            readonly property real level: modelData.value()
            readonly property bool high: level >= 0.9

            anchors.verticalCenter: parent.verticalCenter
            value: level
            rune: modelData.rune
            arcColor: high ? Theme.crimson : Theme.bronze
            runeColor: high ? Theme.crimsonLit : Theme.ivory
            reading: String(Math.round(level * 100))
            readingColor: high ? Theme.crimsonLit : Theme.ivory
            onClicked: Menus.spawn(["kitty", "btop"])
        }
    }
}
