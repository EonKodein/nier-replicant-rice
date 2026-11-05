pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which full-screen menu is open: at most one at a time. `qs -c nier ipc call menu toggle launcher`
// takes launcher, clipboard or session. Keybinds and nier-tap go through this.
Singleton {
    id: root

    property string current: ""

    function toggle(name) {
        current = current === name ? "" : name;
    }
    function close() {
        current = "";
    }
    // Started through niri, so programs get the session's environment rather than the shell's.
    function spawn(command) {
        Quickshell.execDetached(["niri", "msg", "action", "spawn", "--"].concat(command));
    }

    IpcHandler {
        target: "menu"
        function toggle(name: string): void {
            root.toggle(name);
        }
        function close(): void {
            root.close();
        }
    }
}
