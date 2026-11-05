//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import qs.modules.bar
import qs.modules.clipboard
import qs.modules.desktop
import qs.modules.session
import qs.modules.chapter
import qs.modules.launcher
import qs.modules.osd
import qs.modules.seal

// NieR Replicant shell for niri. Entry point only: see modules/ for the widgets.
ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {
            required property var modelData
            screen: modelData
        }
    }
    Variants {
        model: Quickshell.screens
        LivingSeal {
            required property var modelData
            screen: modelData
        }
    }
    Osd {}
    ChapterCard {}
    Launcher {}
    Clipboard {}
    Session {}
    Variants {
        model: Quickshell.screens
        Vitals {
            required property var modelData
            screen: modelData
        }
    }
}
