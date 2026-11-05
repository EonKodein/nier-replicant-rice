import QtQuick
import qs.services
import qs.theme
import qs.widgets

// Now playing. ᛚ Laguz, the flowing water. The ring is track progress and the title dims on pause.
// Click to play or pause, scroll to change track.
Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 8
        RingMeter {
            anchors.verticalCenter: parent.verticalCenter
            value: Media.progress
            rune: "ᛚ"
            runeColor: Media.playing ? Theme.ivory : Theme.ivoryDim
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 210)
            text: Media.label
            elide: Text.ElideRight
            color: Media.playing ? Theme.ivoryDim : Theme.ivoryFaint
            font.family: Theme.serif
            font.italic: true
            font.pixelSize: 15
        }
    }
    MouseArea {
        anchors.fill: parent
        property int accumulated: 0
        onClicked: Media.toggle()
        onWheel: ev => {
            accumulated += ev.angleDelta.y;
            const steps = Math.trunc(accumulated / 120);
            if (steps !== 0) {
                accumulated -= steps * 120;
                Media.step(steps);
            }
        }
    }
}
