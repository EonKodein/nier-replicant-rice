import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme

// The day's passing, drawn on the track carved into the wallpaper's seal: midnight is at the top
// and the arc closes the circle by the next midnight. It repaints once a minute, so it costs
// nothing in between. It sits on the bottom layer, behind every window.
PanelWindow {
    id: root

    // Where the wallpaper's track lands: a 3840x2160 image scaled to fill, radius 477.6 px there.
    readonly property real scaleToFill: screen ? Math.max(screen.width / 3840, screen.height / 2160) : 0.5
    readonly property real radius: 477.6 * scaleToFill

    WlrLayershell.namespace: "nier-seal"
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.ceil(radius * 2 + 24)
    implicitHeight: Math.ceil(radius * 2 + 24)
    color: "transparent"
    mask: Region {}

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: arc.requestPaint()
    }
    Canvas {
        id: arc
        anchors.fill: parent
        antialiasing: true
        onWidthChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const now = clock.date;
            const day = (now.getHours() * 60 + now.getMinutes()) / 1440;
            const start = -Math.PI / 2;
            const end = start + Math.PI * 2 * day;
            const c = width / 2;

            ctx.strokeStyle = Theme.crimson;
            ctx.lineWidth = Math.max(2, 5 * root.scaleToFill * 2);
            ctx.beginPath();
            ctx.arc(c, c, root.radius, start, end);
            ctx.stroke();

            // A lozenge marks the present moment.
            const size = 4;
            ctx.save();
            ctx.translate(c + Math.cos(end) * root.radius, c + Math.sin(end) * root.radius);
            ctx.fillStyle = Theme.ivory;
            ctx.beginPath();
            ctx.moveTo(0, -size * 1.5);
            ctx.lineTo(size, 0);
            ctx.lineTo(0, size * 1.5);
            ctx.lineTo(-size, 0);
            ctx.closePath();
            ctx.fill();
            ctx.restore();
        }
    }
}
