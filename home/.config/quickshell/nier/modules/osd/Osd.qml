import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.theme
import qs.widgets

// Brief on-screen meter. Volume is observed from PipeWire, so any app or key change shows it.
// Brightness has no such signal: `nier-ctl` reports it through IPC.
Scope {
    id: root

    property string label: ""
    property string rune: ""
    property real value: 0
    property string reading: ""
    property color accent: Theme.bronze
    property bool shown: false
    property bool armed: false

    function show(l, r, v, text, colour) {
        if (!armed)
            return;
        label = l;
        rune = r;
        value = v;
        reading = text;
        accent = colour;
        shown = true;
        hide.restart();
    }
    function showVolume() {
        show("Volume", Audio.muted ? "ᛁ" : "ᚨ", Audio.muted ? 0 : Audio.volume,
            Audio.muted ? "--" : String(Math.round(Audio.volume * 100)),
            Audio.muted ? Theme.crimson : Theme.bronze);
    }

    // PipeWire reports its initial values shortly after start: those aren't user changes.
    Timer {
        interval: 2500
        running: true
        onTriggered: root.armed = true
    }
    Timer {
        id: hide
        interval: 1400
        onTriggered: root.shown = false
    }
    Connections {
        target: Audio
        function onVolumeChanged() {
            root.showVolume();
        }
        function onMutedChanged() {
            root.showVolume();
        }
    }
    IpcHandler {
        target: "osd"
        function brightness(percent: int): void {
            root.show("Brightness", "ᛋ", percent / 100, String(percent), Theme.bronze);
        }
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            screen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]

            WlrLayershell.namespace: "nier-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            anchors.bottom: true
            margins.bottom: 72
            implicitWidth: 260
            implicitHeight: 86
            color: "transparent"
            mask: Region {}

            DoubleFrame {
                anchors.fill: parent
            }
            Row {
                anchors.centerIn: parent
                spacing: 18
                RingMeter {
                    width: 54
                    height: 54
                    value: root.value
                    arcColor: root.accent
                    rune: root.rune
                    runeColor: root.accent === Theme.crimson ? Theme.crimsonLit : Theme.ivory
                    lineWidth: 2.5
                    ticks: 24
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: root.label.toUpperCase()
                        color: Theme.ivoryDim
                        font.family: Theme.display
                        font.pixelSize: 12
                        font.letterSpacing: 2
                    }
                    Text {
                        text: root.reading
                        color: root.accent === Theme.crimson ? Theme.crimsonLit : Theme.ivory
                        font.family: Theme.display
                        font.pixelSize: 24
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }
}
