import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.widgets

// Clipboard history from cliphist. Enter copies an entry back; Delete, with an empty search, forgets it.
Scope {
    id: root

    LazyLoader {
        active: Menus.current === "clipboard"

        MenuWindow {
            id: menu

            property var entries: []

            title: "CHRONICLE"
            placeholder: "recall…"
            hint: "↵ recall   del forget   esc close"
            countWord: "ENTRY"
            countWordPlural: "ENTRIES"
            emptyText: "nothing has been kept"
            items: {
                const q = query.trim().toLowerCase();
                return q === "" ? entries : entries.filter(e => e.name.toLowerCase().includes(q));
            }
            onChosen: item => {
                Quickshell.execDetached(["sh", "-c", 'printf "%s\n" "$1" | cliphist decode | wl-copy', "sh", item.line]);
                Menus.close();
            }
            onRemoved: item => {
                entries = entries.filter(e => e.line !== item.line);
                Quickshell.execDetached(["sh", "-c", 'printf "%s\n" "$1" | cliphist delete', "sh", item.line]);
            }

            Process {
                running: true
                command: ["cliphist", "list"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        menu.entries = text.split("\n").filter(l => l !== "").map(line => {
                            const preview = line.slice(line.indexOf("\t") + 1);
                            const binary = preview.startsWith("[[ binary data");
                            return {
                                line: line,
                                name: binary ? "Image" : preview,
                                detail: binary ? preview.replace(/^\[\[ binary data\s*|\s*\]\]$/g, "") : "",
                                glyph: binary ? "▣" : "❡"
                            };
                        });
                    }
                }
            }
        }
    }
}
