import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme
import qs.widgets

// Fuller load readings in the corner of the desk, shown only while no window is open on this
// workspace. Behind every window, and it never takes input.
PanelWindow {
    id: desk

    readonly property bool empty: Niri.isEmptyOn(screen ? screen.name : "")

    WlrLayershell.namespace: "nier-vitals"
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore
    anchors {
        bottom: true
        left: true
    }
    margins {
        bottom: 36
        left: 36
    }
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    color: "transparent"
    mask: Region {}

    Row {
        id: row
        spacing: 22
        opacity: desk.empty ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Repeater {
            model: [
                { rune: "ᛊ", label: "MIND", value: () => System.cpu, text: () => Math.round(System.cpu * 100) + "%" },
                { rune: "ᛒ", label: "MEMORY", value: () => System.memory, text: () => Math.round(System.memory * 100) + "%" },
                { rune: "ᚲ", label: "HEAT", value: () => Math.max(0, System.temperature) / 100, text: () => System.temperature < 0 ? "--" : Math.round(System.temperature) + "°" }
            ]
            Column {
                required property var modelData
                spacing: 6
                RingMeter {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 54
                    height: 54
                    value: parent.modelData.value()
                    rune: parent.modelData.rune
                    lineWidth: 2.5
                    ticks: 24
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: parent.modelData.text()
                    color: Theme.ivory
                    font.family: Theme.mono
                    font.pixelSize: 12
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: parent.modelData.label
                    color: Theme.bronzeDim
                    font.family: Theme.display
                    font.pixelSize: 9
                    font.letterSpacing: 2
                }
            }
        }
        Column {
            anchors.bottom: parent.bottom
            spacing: 4
            Text {
                text: "↓ " + System.human(System.down)
                color: Theme.ivoryDim
                font.family: Theme.mono
                font.pixelSize: 12
            }
            Text {
                text: "↑ " + System.human(System.up)
                color: Theme.ivoryDim
                font.family: Theme.mono
                font.pixelSize: 12
            }
            Text {
                text: "FLOW"
                color: Theme.bronzeDim
                font.family: Theme.display
                font.pixelSize: 9
                font.letterSpacing: 2
            }
        }
    }
}
