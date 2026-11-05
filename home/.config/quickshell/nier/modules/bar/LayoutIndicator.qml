import QtQuick
import qs.services
import qs.theme

// Current keyboard layout. Click cycles it.
Text {
    text: Niri.layoutShort === "" ? "" : "[ " + Niri.layoutShort + " ]"
    color: area.containsMouse ? Theme.ivory : Theme.bronze
    font.family: Theme.mono
    font.pixelSize: 12

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Niri.action("switch-layout", "next")
    }
}
