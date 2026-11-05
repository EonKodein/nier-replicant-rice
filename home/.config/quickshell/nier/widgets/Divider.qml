import QtQuick
import qs.theme

// Vertical ornamental rule with a lozenge at its centre.
Item {
    implicitWidth: 5
    implicitHeight: 20

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1
        height: parent.height
        color: Theme.bronzeDim
    }
    Diamond {
        anchors.centerIn: parent
        size: 4
    }
}
