import QtQuick
import Quickshell
import qs.theme
import qs.widgets

// THURSDAY ◆ 14:32 ◆ 5 NOVEMBER. English on purpose: Cinzel has no Polish or Cyrillic forms
// for the system's LC_TIME, and a locale-less layout keeps the shell's width stable.
Row {
    id: root

    readonly property var enLocale: Qt.locale("en_GB")

    spacing: 10

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: clock.date.toLocaleDateString(root.enLocale, "dddd").toUpperCase()
        color: Theme.ivoryDim
        font.family: Theme.display
        font.pixelSize: 11
        font.letterSpacing: 1.5
    }
    Diamond {
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatTime(clock.date, "HH:mm")
        color: Theme.ivory
        font.family: Theme.display
        font.pixelSize: 18
        font.weight: Font.Medium
    }
    Diamond {
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: clock.date.toLocaleDateString(root.enLocale, "d MMMM").toUpperCase()
        color: Theme.ivoryDim
        font.family: Theme.display
        font.pixelSize: 11
        font.letterSpacing: 1.5
    }
}
