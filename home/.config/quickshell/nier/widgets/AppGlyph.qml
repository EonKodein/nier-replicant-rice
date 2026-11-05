import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.theme

// An application's icon, muted to sit in the palette, gaining colour when `lit`. With no usable
// icon it draws `glyph` (usually a first letter) on a lozenge, in the shell's own hand.
Item {
    id: root

    property string iconName: ""
    property string glyph: ""
    property bool lit: false
    property int size: 26

    // Absolute paths can't be checked up front, so a failed load also falls back to the glyph.
    readonly property string source: {
        if (!iconName)
            return "";
        return iconName.startsWith("/") ? "file://" + iconName : Quickshell.iconPath(iconName, true);
    }
    readonly property bool hasIcon: source !== "" && image.status !== Image.Error

    implicitWidth: size
    implicitHeight: size

    IconImage {
        id: image
        anchors.fill: parent
        asynchronous: true
        source: root.source
        visible: root.hasIcon
        opacity: root.lit ? 1 : 0.72
        layer.enabled: true
        layer.effect: MultiEffect {
            saturation: root.lit ? -0.25 : -0.8
        }
    }
    Item {
        anchors.fill: parent
        visible: !root.hasIcon
        Rectangle {
            anchors.centerIn: parent
            width: root.size * 0.69
            height: width
            rotation: 45
            antialiasing: true
            color: "transparent"
            border.width: 1
            border.color: root.lit ? Theme.bronze : Theme.bronzeDim
        }
        Text {
            anchors.centerIn: parent
            text: root.glyph
            color: root.lit ? Theme.ivory : Theme.ivoryDim
            font.family: Theme.book
            font.pixelSize: Math.round(root.size / 2)
        }
    }
}
