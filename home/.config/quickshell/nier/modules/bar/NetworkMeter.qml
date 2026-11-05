import QtQuick
import qs.services
import qs.theme
import qs.widgets

// Link quality. ᛉ Algiz, the antenna-shaped rune. The network name stays out of the bar so it
// never shows up in a screen recording.
Meter {
    readonly property bool online: Network.kind !== "none"

    value: Network.signal
    rune: "ᛉ"
    runeColor: online ? Theme.ivory : Theme.crimsonLit
    reading: !online ? "--" : Network.kind === "ethernet" ? "ETH" : String(Math.round(Network.signal * 100))
    readingColor: online ? Theme.ivory : Theme.crimsonLit
    onClicked: Network.refresh()
}
