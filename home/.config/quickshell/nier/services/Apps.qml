pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Installed applications: search, launch and a usage count that puts your regulars first.
Singleton {
    id: root

    property var usage: ({})

    readonly property var all: DesktopEntries.applications.values.filter(e => !e.noDisplay)

    // A query typed with the Russian layout still finds Latin names: "ыеуфь" finds Steam.
    readonly property string ruKeys: "йцукенгшщзхъфывапролджэячсмитьбю"
    readonly property string enKeys: "qwertyuiop[]asdfghjkl;'zxcvbnm,."

    function swapLayout(text) {
        return Array.from(text).map(c => {
            const i = ruKeys.indexOf(c);
            return i < 0 ? c : enKeys[i];
        }).join("");
    }
    function isSubsequence(q, text) {
        let at = 0;
        for (const c of text) {
            if (c === q[at])
                at++;
            if (at === q.length)
                return true;
        }
        return false;
    }
    function score(entry, q) {
        const name = entry.name.toLowerCase();
        if (name === q)
            return 1000;
        if (name.startsWith(q))
            return 800;
        if (name.split(/[\s\-_:.]+/).some(w => w.startsWith(q)))
            return 600;
        if (name.includes(q))
            return 450;
        // One or two letters would match nearly every description: names only until there are three.
        if (q.length < 3)
            return -1;
        const extra = [entry.genericName, entry.comment].concat(entry.keywords).join(" ").toLowerCase();
        if (extra.includes(q))
            return 250;
        return isSubsequence(q, name) ? 120 : -1;
    }
    function uses(entry) {
        return usage[entry.id] ?? 0;
    }
    function byUseThenName(a, b) {
        return uses(b) - uses(a) || a.name.localeCompare(b.name);
    }
    function search(text) {
        const q = text.trim().toLowerCase();
        if (q === "")
            return all.slice().sort(byUseThenName);
        const swapped = swapLayout(q);
        return all.map(entry => ({
            entry: entry,
            rank: Math.max(score(entry, q), swapped === q ? -1 : score(entry, swapped))
        })).filter(x => x.rank >= 0)
            .sort((a, b) => (b.rank + Math.min(uses(b.entry), 50)) - (a.rank + Math.min(uses(a.entry), 50))
                || a.entry.name.localeCompare(b.entry.name))
            .map(x => x.entry);
    }
    // Started through niri, so apps get the session's environment rather than the shell's.
    function launch(entry) {
        const next = Object.assign({}, usage);
        next[entry.id] = (next[entry.id] ?? 0) + 1;
        usage = next;
        store.setText(JSON.stringify(usage));

        if (!entry.command || entry.command.length === 0) {
            entry.execute();
            return;
        }
        const command = entry.runInTerminal ? ["kitty", "--"].concat(entry.command) : entry.command;
        const prefix = ["niri", "msg", "action", "spawn", "--"];
        if (entry.workingDirectory)
            Quickshell.execDetached(prefix.concat(["sh", "-c", 'cd "$1" && shift && exec "$@"', "sh", entry.workingDirectory], command));
        else
            Quickshell.execDetached(prefix.concat(command));
    }

    FileView {
        id: store
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/nier-rice/launcher-usage.json"
        printErrors: false
        onLoaded: {
            try {
                root.usage = JSON.parse(text());
            } catch (e) {
                root.usage = {};
            }
        }
    }
}
