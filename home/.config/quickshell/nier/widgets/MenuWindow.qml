import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

// A full-screen menu page, laid out like the game's: title, search in brackets, list, footer.
// Used by the launcher, clipboard and session menu. Give it `items` and handle `chosen`.
PanelWindow {
    id: window

    property string title: ""
    property string placeholder: ""
    property string hint: "↵ invoke   ↑↓ choose   esc close"
    property string countWord: "VERSE"
    property string countWordPlural: countWord + "S"
    property string emptyText: "nothing is written here"
    property var items: []
    property alias query: input.text
    property int visibleRows: 9
    property point pointer: Qt.point(-1, -1)

    signal chosen(var item)
    signal removed(var item)

    // A list scrolling under a resting pointer also reports motion, so only a change in screen
    // position counts. The first report just records where the pointer already is.
    function pointerAt(index, x, y) {
        const known = pointer.x >= 0;
        const moved = x !== pointer.x || y !== pointer.y;
        pointer = Qt.point(x, y);
        if (known && moved)
            list.currentIndex = index;
    }
    function chooseCurrent() {
        const item = items[list.currentIndex];
        if (item)
            chosen(item);
    }
    function move(delta) {
        if (items.length > 0)
            list.currentIndex = (list.currentIndex + delta + items.length) % items.length;
    }

    screen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]

    WlrLayershell.namespace: "nier-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    // Dims the desktop; a click outside the panel closes the menu.
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0x12 / 255, 0x11 / 255, 0x0f / 255, 0.6)
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 130
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Menus.close()
        }
    }

    Item {
        id: panel

        property real rise: 10

        anchors.centerIn: parent
        anchors.verticalCenterOffset: rise
        width: 680
        height: 162 + window.visibleRows * list.rowHeight     // the frame, plus exactly whole rows

        NumberAnimation on rise {
            from: 10
            to: 0
            duration: 170
            easing.type: Easing.OutCubic
        }
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 130
        }
        MouseArea {
            anchors.fill: parent     // clicks on the panel itself don't close it
        }
        DoubleFrame {
            anchors.fill: parent
            color: Qt.rgba(0x1a / 255, 0x19 / 255, 0x17 / 255, 0.97)
        }

        // Title with an ornamental rule on each side.
        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 22
            height: 18

            Text {
                id: titleText
                anchors.centerIn: parent
                text: window.title
                color: Theme.bronze
                font.family: Theme.display
                font.pixelSize: 13
                font.letterSpacing: 6
            }
            Repeater {
                model: [-1, 1]
                Item {
                    required property int modelData
                    anchors.verticalCenter: parent.verticalCenter
                    x: modelData < 0 ? 40 : titleText.x + titleText.width + 16
                    width: titleText.x - 16 - 40
                    height: 5
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 1
                        color: Theme.bronzeDim
                    }
                    Diamond {
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.modelData < 0 ? parent.width - width : 0
                        size: 4
                    }
                }
            }
        }

        // Search field in the rice's angular brackets.
        Item {
            id: search
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 14
            anchors.leftMargin: 34
            anchors.rightMargin: 34
            height: 44

            Text {
                id: bracketOpen
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "["
                color: Theme.bronze
                font.family: Theme.display
                font.pixelSize: 24
            }
            Text {
                id: bracketShut
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "]"
                color: Theme.bronze
                font.family: Theme.display
                font.pixelSize: 24
            }
            TextInput {
                id: input
                anchors.left: bracketOpen.right
                anchors.right: bracketShut.left
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                focus: true
                clip: true
                color: Theme.ivory
                selectionColor: Theme.bronzeDim
                selectedTextColor: Theme.ivory
                font.family: Theme.book
                font.pixelSize: 21
                cursorDelegate: Rectangle {
                    width: 1
                    color: Theme.bronze
                }
                Component.onCompleted: forceActiveFocus()
                onTextChanged: list.currentIndex = 0
                Keys.onPressed: ev => {
                    const ctrl = ev.modifiers & Qt.ControlModifier;
                    if (ev.key === Qt.Key_Escape)
                        Menus.close();
                    else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter)
                        window.chooseCurrent();
                    else if (ev.key === Qt.Key_Down || ev.key === Qt.Key_Tab || (ctrl && (ev.key === Qt.Key_J || ev.key === Qt.Key_N)))
                        window.move(1);
                    else if (ev.key === Qt.Key_Up || ev.key === Qt.Key_Backtab || (ctrl && (ev.key === Qt.Key_K || ev.key === Qt.Key_P)))
                        window.move(-1);
                    else if (ev.key === Qt.Key_PageDown)
                        list.currentIndex = Math.min(list.currentIndex + window.visibleRows, window.items.length - 1);
                    else if (ev.key === Qt.Key_PageUp)
                        list.currentIndex = Math.max(list.currentIndex - window.visibleRows, 0);
                    else if (ev.key === Qt.Key_Delete && input.text === "" && window.items[list.currentIndex])
                        window.removed(window.items[list.currentIndex]);
                    else
                        return;
                    ev.accepted = true;
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: window.placeholder
                    color: Theme.ivoryFaint
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 20
                }
            }
        }

        Rectangle {
            id: ruleTop
            anchors.top: search.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 34
            anchors.rightMargin: 34
            height: 1
            color: Theme.bronzeDim
        }

        ListView {
            id: list

            readonly property int rowHeight: 46

            anchors.top: ruleTop.bottom
            anchors.bottom: ruleBottom.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 6
            anchors.bottomMargin: 6
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            clip: true
            model: window.items
            boundsBehavior: Flickable.StopAtBounds
            snapMode: ListView.SnapToItem
            highlightMoveDuration: 90
            highlightResizeDuration: 0
            highlight: Item {
                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    color: Qt.rgba(0xb8 / 255, 0x9f / 255, 0x74 / 255, 0.10)
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.bronzeDim
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Theme.bronzeDim
                    }
                }
                Diamond {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 20
                    size: 7
                }
            }
            delegate: MenuRow {
                onHovered: (i, x, y) => window.pointerAt(i, x, y)
                onChosen: item => window.chosen(item)
            }
        }
        Text {
            anchors.centerIn: list
            visible: window.items.length === 0
            text: window.emptyText
            color: Theme.ivoryFaint
            font.family: Theme.serif
            font.italic: true
            font.pixelSize: 19
        }

        Rectangle {
            id: ruleBottom
            anchors.bottom: footer.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 8
            anchors.leftMargin: 34
            anchors.rightMargin: 34
            height: 1
            color: Theme.bronzeDim
        }
        Item {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 16
            anchors.leftMargin: 36
            anchors.rightMargin: 36
            height: 16

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: window.hint
                color: Theme.ivoryFaint
                font.family: Theme.mono
                font.pixelSize: 11
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Niri.roman(window.items.length) + " " + (window.items.length === 1 ? window.countWord : window.countWordPlural)
                visible: window.items.length > 0
                color: Theme.bronzeDim
                font.family: Theme.display
                font.pixelSize: 10
                font.letterSpacing: 2
            }
        }
    }
}
