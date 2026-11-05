pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default PipeWire sink: live volume and mute state.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: !!(sink && sink.audio)
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available ? sink.audio.muted : false

    function toggleMute() {
        if (available)
            sink.audio.muted = !sink.audio.muted;
    }
    function nudge(delta) {
        if (available)
            sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta));
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
}
