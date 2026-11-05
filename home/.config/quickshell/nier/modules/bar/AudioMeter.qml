import QtQuick
import qs.services
import qs.theme
import qs.widgets

// Volume: click to mute, scroll to adjust. ᚨ Ansuz (voice); ᛁ Isa (stillness) when muted.
Meter {
    value: Audio.muted ? 0 : Audio.volume
    rune: Audio.muted ? "ᛁ" : "ᚨ"
    runeColor: Audio.muted ? Theme.crimsonLit : Theme.ivory
    reading: Audio.available ? (Audio.muted ? "--" : String(Math.round(Audio.volume * 100))) : "··"
    readingColor: Audio.muted ? Theme.crimsonLit : Theme.ivory
    onClicked: Audio.toggleMute()
    onWheel: steps => Audio.nudge(steps * 0.05)
}
