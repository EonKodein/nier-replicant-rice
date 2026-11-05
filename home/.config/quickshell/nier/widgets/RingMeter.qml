import QtQuick
import qs.theme

// Circular gauge: a faint graduated track, a bronze arc, and a rune at the centre.
Item {
    id: root

    property real value: 0                     // 0..1
    property color arcColor: Theme.bronze
    property string rune: ""
    property color runeColor: Theme.ivory
    property real lineWidth: 1.75
    property int ticks: 12
    property int runeSize: Math.round(width * 0.42)

    property real shown: Math.max(0, Math.min(1, value))
    Behavior on shown {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    implicitWidth: 28
    implicitHeight: 28

    onShownChanged: canvas.requestPaint()
    onArcColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const c = width / 2;
            const r = c - root.lineWidth - 1;
            const start = -Math.PI / 2;

            ctx.strokeStyle = Theme.stone700;
            ctx.lineWidth = root.lineWidth;
            ctx.beginPath();
            ctx.arc(c, c, r, 0, Math.PI * 2);
            ctx.stroke();

            ctx.strokeStyle = root.arcColor;
            ctx.lineCap = "butt";
            ctx.beginPath();
            ctx.arc(c, c, r, start, start + Math.PI * 2 * root.shown);
            ctx.stroke();

            ctx.strokeStyle = Theme.bronzeDim;
            ctx.lineWidth = 1;
            for (let i = 0; i < root.ticks; i++) {
                const a = start + i * Math.PI * 2 / root.ticks;
                ctx.beginPath();
                ctx.moveTo(c + Math.cos(a) * (r + root.lineWidth / 2 + 0.2), c + Math.sin(a) * (r + root.lineWidth / 2 + 0.2));
                ctx.lineTo(c + Math.cos(a) * (r + root.lineWidth / 2 + 1), c + Math.sin(a) * (r + root.lineWidth / 2 + 1));
                ctx.stroke();
            }
        }
    }
    Text {
        anchors.centerIn: parent
        text: root.rune
        color: root.runeColor
        font.family: Theme.rune
        font.pixelSize: root.runeSize
    }
}
