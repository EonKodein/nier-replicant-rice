# NieR Replicant rice for niri

A desktop themed after *NieR Replicant ver.1.22474487139...*: weathered stone, faded bronze and
one drop of sealed-verse crimson, on [niri](https://github.com/YaLTeR/niri) and
[Quickshell](https://quickshell.org).

![The bar](docs/bar.png)
![The wallpaper](home/.local/share/nier-rice/wallpaper.png)

A fan project, unaffiliated with Square Enix. The wallpaper is original procedural art
(`scripts/gen-wallpaper.py`) and no game assets are included.

## Install

For Arch-based systems:

    git clone <this repo> ~/nier-replicant-rice
    cd ~/nier-replicant-rice
    ./install.sh

The installer lists the files it will replace and asks first. Each one is backed up to
`~/.config/dotfiles_backup_<time>/`. Keep the clone: `nier-rice on` deploys from it.

| Flag | Effect |
|---|---|
| `--yes` | Don't ask |
| `--no-deps` | Skip packages |
| `--files-only` | Deploy files only: no packages, fonts, gsettings or process changes |

**Your niri config is replaced, not merged.** Move `output { }` blocks to
`~/.config/niri/monitor.kdl`, which is never overwritten. Set keyboard layouts in
`~/.config/niri/nier/input.kdl`.

## Undo

    nier-rice off         # restore your previous files
    nier-rice uninstall   # the same, and delete everything the rice added
    nier-rice status

Log out and back in afterwards to get your previous session daemons back.

## What's included

| Part | Tool |
|---|---|
| Compositor | niri: 6px gaps, thin bronze borders, square corners |
| Bar and OSD | Quickshell: Roman numeral workspaces, serif clock, runic ring meters, tray, keyboard layout |
| Launcher, session and clipboard menus | fuzzel, cliphist |
| Notifications | mako: parchment banners |
| Terminals | kitty, foot |
| Lock and wallpaper | swaylock-effects, swaybg, swayidle (locks before sleep) |
| Apps | GTK (over adw-gtk3-dark) and Qt (qt6ct) palettes |

Fonts are fetched from [google/fonts](https://github.com/google/fonts) under the SIL OFL into
`~/.local/share/fonts/nier-rice`: Cinzel, Cormorant Garamond, EB Garamond and JetBrains Mono.

## Keys

`Mod+Space` launcher · `Mod+T` terminal · `Mod+E` files · `Mod+V` clipboard · `Mod+Alt+L` lock ·
`Mod+Shift+Q` session menu · `Mod+N` dismiss notification · `Mod+Shift+S` screenshot ·
`Mod+Tab` overview · `Mod+Shift+Escape` all keys

## Layout

`home/` mirrors `$HOME`. Edit it, then run `nier-rice on`. In `home/.config/quickshell/nier/`:
`theme/` holds the palette and type, `services/` the system state, `widgets/` the frames and
meters, and `modules/` the bar and OSD.

---

## По-русски

Установка: `git clone`, затем `./install.sh`. Установщик покажет, какие файлы заменит, и спросит
подтверждение. Откат: `nier-rice off`. Полное удаление: `nier-rice uninstall`. Конфиг niri
заменяется целиком: блоки `output` перенеси в `~/.config/niri/monitor.kdl`, раскладки укажи в
`~/.config/niri/nier/input.kdl`.
