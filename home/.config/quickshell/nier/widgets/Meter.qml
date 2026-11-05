import QtQuick
import qs.theme

// A labelled ring: rune gauge plus a compact reading such as "62".
Item {
    id: root

    property alias value: ring.value
    property alias rune: ring.rune
    property alias arcColor: ring.arcColor
    property alias runeColor: ring.runeColor
    property string reading: ""
    property color readingColor: Theme.ivory

    signal clicked()
    signal wheel(int steps)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 6
        RingMeter {
            id: ring
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(implicitWidth, 22)
            text: root.reading
            color: root.readingColor
            font.family: Theme.mono
            font.pixelSize: 12
        }
    }
    MouseArea {
        anchors.fill: parent
        property int accumulated: 0
        onClicked: root.clicked()
        onWheel: ev => {
            accumulated += ev.angleDelta.y;
            const steps = Math.trunc(accumulated / 120);
            if (steps !== 0) {
                accumulated -= steps * 120;
                root.wheel(steps);
            }
        }
    }
}
