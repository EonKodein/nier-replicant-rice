import QtQuick
import qs.theme

// Signature panel: matte stone, a bronze hairline, a fainter second line inset 3 px,
// and small diamonds on the left and right edges. Square corners, always.
Rectangle {
    color: Theme.surface
    border.color: Theme.bronze
    border.width: 1

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: "transparent"
        border.color: Theme.frameInner
        border.width: 1
    }
    Diamond {
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: 6
    }
    Diamond {
        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: -6
    }
}
