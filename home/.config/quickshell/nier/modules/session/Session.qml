import QtQuick
import Quickshell
import qs.services
import qs.widgets

// End of the session. Lock is first, so a stray Enter costs nothing.
Scope {
    LazyLoader {
        active: Menus.current === "session"

        MenuWindow {
            readonly property var all: [
                { name: "Lock", detail: "seal the screen", glyph: "ᛁ", command: ["swaylock", "-f"] },
                { name: "Suspend", detail: "sleep until woken", glyph: "ᛇ", command: ["systemctl", "suspend"] },
                { name: "Log out", detail: "leave this session", glyph: "ᚱ", command: ["niri", "msg", "action", "quit", "--skip-confirmation"] },
                { name: "Reboot", detail: "begin again", glyph: "ᛃ", command: ["systemctl", "reboot"] },
                { name: "Shut down", detail: "the end of the verse", glyph: "ᛞ", command: ["systemctl", "poweroff"] }
            ]

            title: "THE LAST VERSE"
            placeholder: "choose…"
            hint: "↵ invoke   ↑↓ choose   esc close"
            countWord: "PATH"
            visibleRows: 5
            items: {
                const q = query.trim().toLowerCase();
                return all.filter(x => x.name.toLowerCase().includes(q));
            }
            onChosen: item => {
                Menus.close();
                Menus.spawn(item.command);
            }
        }
    }
}
