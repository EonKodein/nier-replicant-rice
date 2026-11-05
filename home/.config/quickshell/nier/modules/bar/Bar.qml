import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme
import qs.widgets

// Floating HUD. The surface is exactly the visible frame: gaps come from layer-shell margins,
// so niri's blur (see niri/nier/theme.kdl) never paints outside the panel.
PanelWindow {
    id: bar

    WlrLayershell.namespace: "nier-bar"
    WlrLayershell.layer: WlrLayer.Top

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: Theme.barMargin
        left: Theme.barMargin
        right: Theme.barMargin
    }
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    DoubleFrame {
        anchors.fill: parent
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: clock.x - 20
            spacing: 12

            Workspaces {
                output: bar.screen ? bar.screen.name : ""
            }
            Divider {
                visible: title.text !== ""
            }
            Text {
                id: title
                Layout.fillWidth: true
                text: Niri.activeTitleOn(bar.screen ? bar.screen.name : "")
                color: Theme.ivoryDim
                font.family: Theme.serif
                font.italic: true
                font.pixelSize: 16
                elide: Text.ElideRight
            }
        }

        Clock {
            id: clock
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Tray {
                id: tray
                anchors.verticalCenter: parent.verticalCenter
                window: bar
            }
            Divider {
                anchors.verticalCenter: parent.verticalCenter
                visible: tray.hasItems
            }
            LayoutIndicator {
                anchors.verticalCenter: parent.verticalCenter
            }
            Divider {
                anchors.verticalCenter: parent.verticalCenter
            }
            AudioMeter {
                anchors.verticalCenter: parent.verticalCenter
            }
            NetworkMeter {
                anchors.verticalCenter: parent.verticalCenter
            }
            PowerMeter {
                anchors.verticalCenter: parent.verticalCenter
                visible: Power.present
            }
        }
    }
}
