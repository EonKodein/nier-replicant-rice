pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU, memory, temperature and network from /proc and /sys, sampled every 3 seconds. It never asks
// the discrete GPU for anything, which would wake it and drain the battery.
Singleton {
    id: root

    property real cpu: 0
    property real memory: 0
    property real temperature: -1          // degrees C; -1 when no sensor was found
    property real down: 0                  // bytes per second
    property real up: 0
    property string thermalPath: ""

    property var lastCpu: null
    property var lastNet: null
    property real lastNetAt: 0

    function human(bytes) {
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " M";
        return Math.round(bytes / 1024) + " K";
    }
    function parse(text) {
        const lines = text.split("\n");

        const c = lines[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = c[3] + (c[4] || 0);
        const total = c.reduce((a, b) => a + b, 0);
        if (lastCpu && total > lastCpu.total)
            cpu = 1 - (idle - lastCpu.idle) / (total - lastCpu.total);
        lastCpu = { idle: idle, total: total };

        const mem = key => {
            const m = new RegExp("^" + key + ":\\s+(\\d+)", "m").exec(text);
            return m ? Number(m[1]) : 0;
        };
        const memTotal = mem("MemTotal");
        memory = memTotal > 0 ? 1 - mem("MemAvailable") / memTotal : 0;

        // Interface lines: "  wlan0: <rx bytes> ... <tx bytes in field 9> ..."
        let rx = 0, tx = 0;
        for (const line of lines) {
            const m = /^\s*([^\s:]+):\s+(\d+)(?:\s+\d+){7}\s+(\d+)/.exec(line);
            if (m && m[1] !== "lo") {
                rx += Number(m[2]);
                tx += Number(m[3]);
            }
        }
        const now = Date.now();
        if (lastNet && now > lastNetAt) {
            const seconds = (now - lastNetAt) / 1000;
            down = Math.max(0, rx - lastNet.rx) / seconds;
            up = Math.max(0, tx - lastNet.tx) / seconds;
        }
        lastNet = { rx: rx, tx: tx };
        lastNetAt = now;

        // The sensor file comes last in the output: its only line is a bare number.
        const t = root.thermalPath === "" ? NaN : Number(lines.filter(l => l !== "").pop());
        temperature = isNaN(t) ? -1 : t / 1000;
    }

    Process {
        running: true
        command: ["sh", "-c", "for z in /sys/class/thermal/thermal_zone*; do case \"$(cat \"$z/type\")\" in x86_pkg_temp|k10temp|cpu*|soc*) echo \"$z/temp\"; exit;; esac; done; ls /sys/class/thermal/thermal_zone0/temp 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.thermalPath = text.trim().split("\n")[0]
        }
    }
    Process {
        id: sample
        command: ["cat", "/proc/stat", "/proc/meminfo", "/proc/net/dev"].concat(root.thermalPath === "" ? [] : [root.thermalPath])
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }
    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!sample.running)
                sample.running = true;
        }
    }
}
