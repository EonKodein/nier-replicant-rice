import QtQuick
import qs.theme

// One menu line: icon or glyph, name, and a quiet description on the right.
// modelData is { name, detail, icon, glyph }.
Item {
    id: row

    required property var modelData
    required property int index
    readonly property bool selected: ListView.isCurrentItem

    signal hovered(int index, real x, real y)
    signal chosen(var item)

    width: ListView.view ? ListView.view.width : 0
    height: ListView.view ? ListView.view.rowHeight : 46

    AppGlyph {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        iconName: row.modelData.icon ?? ""
        glyph: row.modelData.glyph ?? row.modelData.name.charAt(0).toUpperCase()
        lit: row.selected
    }
    Text {
        id: name
        anchors.left: icon.right
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        // The description column only needs room when there is a description.
        width: Math.min(implicitWidth, parent.width * (row.modelData.detail ? 0.52 : 0.82))
        text: row.modelData.name
        elide: Text.ElideRight
        color: row.selected ? Theme.ivory : Theme.ivoryDim
        font.family: Theme.book
        font.pixelSize: 18
    }
    Text {
        anchors.left: name.right
        anchors.leftMargin: 18
        anchors.right: parent.right
        anchors.rightMargin: 26
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        text: row.modelData.detail ?? ""
        elide: Text.ElideRight
        color: Theme.ivoryFaint
        font.family: Theme.serif
        font.italic: true
        font.pixelSize: 14
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: ev => {
            const at = mapToGlobal(ev.x, ev.y);
            row.hovered(row.index, at.x, at.y);
        }
        onClicked: row.chosen(row.modelData)
    }
}
