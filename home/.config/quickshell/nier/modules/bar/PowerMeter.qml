import QtQuick
import qs.services
import qs.theme
import qs.widgets

// Battery. ᛋ Sowilo, the sun. The arc turns crimson at 15% and below; "+" marks charging.
Meter {
    value: Power.level
    rune: "ᛋ"
    arcColor: Power.low ? Theme.crimson : Theme.bronze
    runeColor: Power.low ? Theme.crimsonLit : Power.charging ? Theme.bronze : Theme.ivory
    reading: Math.round(Power.level * 100) + (Power.charging ? "+" : "")
    readingColor: Power.low ? Theme.crimsonLit : Theme.ivory
}
