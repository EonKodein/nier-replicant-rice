<div align="center">

# NieR Replicant rice for niri

**Weathered stone, faded bronze and one drop of sealed-verse crimson.**

A complete desktop on [niri](https://github.com/YaLTeR/niri) and [Quickshell](https://quickshell.org), themed after *NieR Replicant ver.1.22474487139...*

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-b89f74?style=flat-square&labelColor=1a1917)](LICENSE)
[![Compositor: niri](https://img.shields.io/badge/compositor-niri-b89f74?style=flat-square&labelColor=1a1917)](https://github.com/YaLTeR/niri)
[![Shell: Quickshell](https://img.shields.io/badge/shell-Quickshell-b89f74?style=flat-square&labelColor=1a1917)](https://quickshell.org)
[![Arch-based](https://img.shields.io/badge/for-Arch--based-962d2d?style=flat-square&labelColor=1a1917)](#install)

**English** · [Русский](README.ru.md)

![The desktop](docs/desktop.jpg)

</div>

## Gallery

| | |
| :-: | :-: |
| ![Application menu with search](docs/launcher.jpg) | ![Session menu](docs/session.jpg) |
| **Grimoire**, the application menu | **The Last Verse**, the session menu |
| ![Chapter card on workspace change](docs/chapter.jpg) | ![Fastfetch status screen](docs/fastfetch.jpg) |
| **Chapter card** on workspace change | **Status screen** in fastfetch |

![The bar](docs/bar.png)

## Features

**The bar.** Roman numeral workspaces, a serif clock, the focused window's title, a tray, the keyboard layout, and runic ring meters for CPU, memory, volume, network and battery. Click a load ring to open `btop`.

**The menus.** One design for all three, replacing a separate launcher:

- **Grimoire** (`Mod` tap or `Mod+Space`): fuzzy search that learns what you open. A query typed in the Russian layout still finds Latin names. It also handles `2+2*3`, `> command` and `web query`.
- **Chronicle** (`Mod+V`): clipboard history with search. `Enter` recalls an entry, `Del` forgets it.
- **The Last Verse** (`Mod+Shift+Q`): lock, suspend, log out, reboot, shut down.

**Small things.**

- **Living seal:** the crimson arc on the wallpaper tracks how much of the day has passed.
- **Chapter card:** a brief `VERSE III` plate when you change workspace.
- **Now playing:** a ring in the bar shows track progress. Click to pause, scroll to change track.
- **Vitals:** heat and network join the load readings in the corner of an empty workspace.
- **Parchment notifications:** pale banners with a thin bronze rule, crimson for critical ones.

<img src="docs/notification.png" alt="A parchment notification" width="420">

**Everything else follows the palette:** kitty, foot, swaylock-effects, mako, and GTK and Qt applications.

The wallpaper is original procedural art (`scripts/gen-wallpaper.py`). No game assets are included.

## Install

For Arch-based systems:

```bash
git clone https://github.com/EonKodein/nier-replicant-rice.git ~/nier-replicant-rice
cd ~/nier-replicant-rice
./install.sh
```

The installer lists the files it will replace and asks first. Each one is backed up to `~/.config/dotfiles_backup_<time>/`, and if the new niri config fails validation, nothing changes. Keep the clone: `nier-rice on` deploys from it.

| Flag | Effect |
| --- | --- |
| `--yes` | Don't ask |
| `--no-deps` | Skip packages |
| `--files-only` | Deploy files only: no packages, fonts, gsettings or process changes |

> [!IMPORTANT]
> **Your niri config is replaced, not merged.** Move `output { }` blocks to `~/.config/niri/monitor.kdl`. Put everything else of your own, such as keyboard layouts and extra binds, in `~/.config/niri/local.kdl`. It is read last, and neither file is ever overwritten.

Opening the menu with a tap of `Mod` needs the `input` group: `sudo usermod -aG input $USER`, then log in again. `Mod+Space` works without it.

**Status:** developed on CachyOS with niri 26.04 and Quickshell 0.3.2. The installer has been tested with `--files-only`, but a full install on a clean system hasn't been run yet, so issue reports are welcome.

## Undo

```bash
nier-rice off         # restore your previous files
nier-rice uninstall   # the same, and delete everything the rice added
nier-rice status      # show what is running
```

Log out and back in afterwards to get your previous session daemons back. `nier-rice` lives in `~/.local/bin`.

## Keys

`Mod` is Super. `Mod+Shift+Esc` lists every bind on screen.

| Keys | Action |
| --- | --- |
| `Mod` tap, `Mod+Space` | Application menu |
| `Mod+T` / `Mod+E` | Terminal / files |
| `Mod+V` | Clipboard history |
| `Mod+Shift+Q` / `Mod+Alt+L` | Session menu / lock |
| `Mod+N` / `Mod+Shift+N` | Dismiss / restore notification |
| `Mod+Shift+S` | Screenshot |
| `Mod+Tab` | Overview |
| `Mod+1…9` / `Mod+Ctrl+1…9` | Go to workspace / move column there |
| `Mod+H`, `Mod+L`, arrows | Focus columns |
| `Mod+R` / `Mod+F` | Column width / fullscreen |

## Fonts

Fetched from [google/fonts](https://github.com/google/fonts) into `~/.local/share/fonts/nier-rice` under the SIL OFL: Cinzel, Cormorant Garamond, EB Garamond and JetBrains Mono. The runes use Noto Sans Runic.

## Repository layout

`home/` mirrors `$HOME`. Edit it, then run `nier-rice on`.

```text
home/.config/quickshell/nier/
├── theme/      palette, type and metrics
├── services/   niri, audio, power, network, system and media state
├── widgets/    frames, ring meters, the menu page
└── modules/    bar, launcher, clipboard, session, OSD, chapter card, seal, vitals
```

## Credits

Several features follow ideas from [angelOS](https://github.com/MixaDoDs/AngelOS-Dotfiles) (MIT), reimplemented here.

A fan project, unaffiliated with Square Enix. Licensed under [GPL-3.0](LICENSE).
