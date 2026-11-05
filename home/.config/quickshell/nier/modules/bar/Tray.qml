import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.theme

// System tray. Icons are desaturated so third-party colours sit quietly in the palette.
Row {
    id: root

    required property var window
    readonly property bool hasItems: repeater.count > 0

    spacing: 8

    Repeater {
        id: repeater
        model: SystemTray.items

        Item {
            id: entry

            required property var modelData

            implicitWidth: 18
            implicitHeight: 18

            IconImage {
                anchors.fill: parent
                source: entry.modelData.icon
                layer.enabled: true
                layer.effect: MultiEffect {
                    saturation: area.containsMouse ? 0 : -0.75
                }
            }
            QsMenuAnchor {
                id: menu
                menu: entry.modelData.menu
                anchor.item: entry
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: ev => {
                    if (ev.button === Qt.MiddleButton)
                        entry.modelData.secondaryActivate();
                    else if (ev.button === Qt.RightButton || entry.modelData.onlyMenu)
                        menu.open();
                    else
                        entry.modelData.activate();
                }
                onWheel: ev => entry.modelData.scroll(ev.angleDelta.y, false)
            }
        }
    }
}
