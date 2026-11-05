import QtQuick
import qs.services
import qs.theme

// Workspaces as Roman numerals. The active one is bracketed: [ III ].
Row {
    id: root

    property string output: ""

    spacing: 2

    Repeater {
        model: Niri.workspacesOn(root.output)

        Item {
            id: cell

            required property var modelData
            readonly property bool active: modelData.is_active
            readonly property bool occupied: Niri.windowCount(modelData.id) > 0

            implicitWidth: label.implicitWidth + 12
            implicitHeight: 24

            Text {
                id: label
                anchors.centerIn: parent
                text: cell.active ? "[ " + Niri.roman(cell.modelData.idx) + " ]" : Niri.roman(cell.modelData.idx)
                font.family: Theme.display
                font.pixelSize: 14
                font.weight: cell.active ? Font.DemiBold : Font.Normal
                color: cell.modelData.is_urgent ? Theme.crimsonLit
                    : cell.active ? Theme.bronze
                    : area.containsMouse ? Theme.ivory
                    : cell.occupied ? Theme.ivoryDim
                    : Theme.ivoryFaint
                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }
            }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Niri.focusWorkspace(root.output, cell.modelData.idx)
            }
        }
    }

    // Scrolling over the numerals walks through workspaces.
    WheelHandler {
        property int accumulated: 0
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: ev => {
            accumulated += ev.angleDelta.y;
            if (Math.abs(accumulated) >= 120) {
                Niri.action(accumulated > 0 ? "focus-workspace-up" : "focus-workspace-down");
                accumulated = 0;
            }
        }
    }
}
