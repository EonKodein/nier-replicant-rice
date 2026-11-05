pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The player worth showing: whatever is playing, otherwise a paused one that has a track.
// MPRIS doesn't push position updates, so they are requested once a second during playback.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: {
        const titled = players.filter(p => !!p.trackTitle);
        return titled.find(p => p.isPlaying) ?? titled[0] ?? null;
    }
    readonly property bool active: player !== null
    readonly property bool playing: active && player.isPlaying
    readonly property string label: {
        if (!active)
            return "";
        return player.trackArtist ? player.trackArtist + " — " + player.trackTitle : player.trackTitle;
    }
    readonly property real progress: active && player.lengthSupported && player.length > 0
        ? Math.min(1, player.position / player.length) : 0

    function toggle() {
        if (active && player.canTogglePlaying)
            player.togglePlaying();
    }
    function step(steps) {
        if (!active)
            return;
        if (steps < 0 && player.canGoNext)
            player.next();
        else if (steps > 0 && player.canGoPrevious)
            player.previous();
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.playing
        onTriggered: root.player.positionChanged()
    }
}
