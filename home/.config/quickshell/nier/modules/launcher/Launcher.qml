import QtQuick
import Quickshell
import qs.services
import qs.widgets

// The application menu. Beyond searching: "2+2*3" calculates, "> command" runs a command and
// "web something" searches the web.
Scope {
    function build(text) {
        const q = text.trim();
        if (q.startsWith(">")) {
            const command = q.slice(1).trim();
            return command === "" ? [] : [{ kind: "run", command: command, name: command, detail: "run in a shell", glyph: "›" }];
        }
        const web = /^(?:web|цуи)\s+(.+)$/i.exec(q);
        if (web)
            return [{ kind: "web", query: web[1], name: web[1], detail: "search the web", glyph: "?" }];

        const items = [];
        const value = Calc.evaluate(q);
        if (value !== null)
            items.push({ kind: "calc", value: String(value), name: "= " + value, detail: "copy the result", glyph: "=" });
        return items.concat(Apps.search(q).map(entry => ({
            kind: "app",
            entry: entry,
            name: entry.name,
            detail: entry.comment || entry.genericName,
            icon: entry.icon
        })));
    }

    LazyLoader {
        active: Menus.current === "launcher"

        MenuWindow {
            title: "GRIMOIRE"
            placeholder: "seek a verse…"
            emptyText: "no such verse is written"
            items: build(query)
            onChosen: item => {
                if (item.kind === "app")
                    Apps.launch(item.entry);
                else if (item.kind === "run")
                    Menus.spawn(["sh", "-c", item.command]);
                else if (item.kind === "web")
                    Menus.spawn(["xdg-open", "https://duckduckgo.com/?q=" + encodeURIComponent(item.query)]);
                else if (item.kind === "calc")
                    Quickshell.execDetached(["wl-copy", item.value]);
                Menus.close();
            }
        }
    }
}
