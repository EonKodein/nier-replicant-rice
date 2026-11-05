pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Mirrors niri's state from `niri msg --json event-stream`. The stream starts with a full
// snapshot and is restarted if it ever drops, so the state heals itself after a niri reload.
Singleton {
    id: root

    property var workspaces: []
    property var windows: []
    property var layoutNames: []
    property int layoutIndex: 0

    readonly property string focusedOutput: {
        const w = workspaces.find(x => x.is_focused);
        return w ? (w.output ?? "") : "";
    }
    readonly property string layoutShort: {
        const n = layoutNames[layoutIndex] ?? "";
        return n.slice(0, 2).toUpperCase();
    }

    function workspacesOn(output) {
        return workspaces.filter(w => w.output === output).sort((a, b) => a.idx - b.idx);
    }
    function windowCount(workspaceId) {
        return windows.filter(w => w.workspace_id === workspaceId).length;
    }
    function activeTitleOn(output) {
        const ws = workspaces.find(w => w.output === output && w.is_active);
        if (!ws || ws.active_window_id === null)
            return "";
        const win = windows.find(w => w.id === ws.active_window_id);
        return win ? (win.title ?? "") : "";
    }

    function action(...args) {
        Quickshell.execDetached(["niri", "msg", "action", ...args]);
    }
    function focusWorkspace(output, idx) {
        Quickshell.execDetached(["sh", "-c",
            'niri msg action focus-monitor "$1" && niri msg action focus-workspace "$2"',
            "sh", output, String(idx)]);
    }

    function handle(ev) {
        if (ev.WorkspacesChanged) {
            workspaces = ev.WorkspacesChanged.workspaces;
        } else if (ev.WorkspaceActivated) {
            const e = ev.WorkspaceActivated;
            const target = workspaces.find(w => w.id === e.id);
            if (!target)
                return;
            workspaces = workspaces.map(w => Object.assign({}, w, {
                is_active: w.output === target.output ? w.id === e.id : w.is_active,
                is_focused: e.focused ? w.id === e.id : w.is_focused
            }));
        } else if (ev.WorkspaceActiveWindowChanged) {
            const e = ev.WorkspaceActiveWindowChanged;
            workspaces = workspaces.map(w => w.id === e.workspace_id
                ? Object.assign({}, w, { active_window_id: e.active_window_id }) : w);
        } else if (ev.WorkspaceUrgencyChanged) {
            const e = ev.WorkspaceUrgencyChanged;
            workspaces = workspaces.map(w => w.id === e.id
                ? Object.assign({}, w, { is_urgent: e.urgent }) : w);
        } else if (ev.WindowsChanged) {
            windows = ev.WindowsChanged.windows;
        } else if (ev.WindowOpenedOrChanged) {
            const win = ev.WindowOpenedOrChanged.window;
            const known = windows.some(w => w.id === win.id);
            windows = known ? windows.map(w => w.id === win.id ? win : w) : windows.concat([win]);
        } else if (ev.WindowClosed) {
            windows = windows.filter(w => w.id !== ev.WindowClosed.id);
        } else if (ev.KeyboardLayoutsChanged) {
            layoutNames = ev.KeyboardLayoutsChanged.keyboard_layouts.names;
            layoutIndex = ev.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
        } else if (ev.KeyboardLayoutSwitched) {
            layoutIndex = ev.KeyboardLayoutSwitched.idx;
        }
    }

    Process {
        id: stream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.handle(JSON.parse(line));
                } catch (e) {
                    console.warn("niri event ignored:", e);
                }
            }
        }
        onExited: retry.restart()
    }
    Timer {
        id: retry
        interval: 2000
        onTriggered: stream.running = true
    }
}
