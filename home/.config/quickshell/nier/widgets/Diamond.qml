import QtQuick
import qs.theme

// Small ornamental lozenge.
Rectangle {
    property int size: 5
    width: size
    height: size
    rotation: 45
    antialiasing: true
    color: Theme.bronze
}
