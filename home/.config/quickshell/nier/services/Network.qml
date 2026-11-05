pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// NetworkManager summary. `nmcli monitor` wakes a refresh on change; a slow timer keeps
// the Wi-Fi signal current. Uses --rescan no, so this never triggers a radio scan.
Singleton {
    id: root

    property string kind: "none"   // "wifi" | "ethernet" | "none"
    property real signal: 0

    function refresh() {
        if (!query.running)
            query.running = true;
    }

    Process {
        id: query
        command: ["sh", "-c",
            "nmcli -t -f TYPE,STATE dev; echo ---; nmcli -t -f ACTIVE,SIGNAL dev wifi list --rescan no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("---");
                const devs = parts[0].trim().split("\n");
                const up = t => devs.some(l => l === t + ":connected");
                root.kind = up("ethernet") ? "ethernet" : up("wifi") ? "wifi" : "none";
                const active = (parts[1] ?? "").trim().split("\n").find(l => l.startsWith("yes:"));
                root.signal = root.kind === "ethernet" ? 1
                    : active ? Number(active.split(":")[1]) / 100 : 0;
            }
        }
    }
    Process {
        id: monitor
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: debounce.restart()
        }
        onExited: retry.restart()
    }
    Timer {
        id: debounce
        interval: 400
        onTriggered: root.refresh()
    }
    Timer {
        id: retry
        interval: 5000
        onTriggered: monitor.running = true
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
