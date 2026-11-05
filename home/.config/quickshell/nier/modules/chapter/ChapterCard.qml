import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme
import qs.widgets

// A brief "VERSE III" plate on workspace change, like a chapter title. It sits on the top layer,
// so fullscreen games and video cover it, and it never takes input.
Scope {
    id: root

    property string numeral: ""
    property bool open: false
    property bool armed: false
    property real fade: 0

    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }
    Connections {
        target: Niri
        function onFocusedIdxChanged() {
            if (!root.armed || Niri.focusedIdx < 1)
                return;
            root.numeral = Niri.roman(Niri.focusedIdx);
            root.open = true;
            card.restart();
        }
    }
    SequentialAnimation {
        id: card
        NumberAnimation {
            target: root
            property: "fade"
            to: 1
            duration: 110
            easing.type: Easing.OutCubic
        }
        PauseAnimation {
            duration: 420
        }
        NumberAnimation {
            target: root
            property: "fade"
            to: 0
            duration: 280
            easing.type: Easing.InCubic
        }
        ScriptAction {
            script: root.open = false
        }
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            screen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]

            WlrLayershell.namespace: "nier-chapter"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: Math.max(190, numeralText.implicitWidth + 80)
            implicitHeight: 118
            color: "transparent"
            mask: Region {}

            Item {
                anchors.fill: parent
                opacity: root.fade

                DoubleFrame {
                    anchors.fill: parent
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "VERSE"
                        color: Theme.bronze
                        font.family: Theme.display
                        font.pixelSize: 12
                        font.letterSpacing: 4
                    }
                    Text {
                        id: numeralText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.numeral
                        color: Theme.ivory
                        font.family: Theme.display
                        font.pixelSize: 44
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }
}
