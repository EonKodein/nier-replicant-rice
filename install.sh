#!/usr/bin/env bash
# NieR Replicant rice installer for Arch-based systems running (or about to run) niri.
#   ./install.sh               show what will change, ask, then install and start
#   ./install.sh --yes         don't ask
#   ./install.sh --no-deps     skip packages (fonts are still fetched)
#   ./install.sh --files-only  deploy files only: no packages, fonts, gsettings or processes
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SRC="$REPO/home"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nier-rice"
FONTS="$HOME/.local/share/fonts/nier-rice"
FONT_BASE=https://raw.githubusercontent.com/google/fonts/main/ofl

PACKAGES=(niri quickshell xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk
  swaybg mako kitty foot swayidle cliphist wl-clipboard brightnessctl playerctl
  pipewire pipewire-pulse wireplumber networkmanager upower qt6ct noto-fonts adw-gtk-theme
  hyprpolkitagent libnotify curl fastfetch python-evdev btop)
FONT_FILES=('cinzel/Cinzel[wght].ttf'
  'cormorantgaramond/CormorantGaramond[wght].ttf' 'cormorantgaramond/CormorantGaramond-Italic[wght].ttf'
  'ebgaramond/EBGaramond[wght].ttf' 'ebgaramond/EBGaramond-Italic[wght].ttf'
  'jetbrainsmono/JetBrainsMono[wght].ttf' 'jetbrainsmono/JetBrainsMono-Italic[wght].ttf')

YES=0 DEPS=1 FILES_ONLY=0
for a in "$@"; do
  case "$a" in
    --yes|-y) YES=1 ;;
    --no-deps) DEPS=0 ;;
    --files-only) FILES_ONLY=1; DEPS=0 ;;
    *) sed -n 2,6p "$0"; exit 2 ;;
  esac
done

say() { printf '\033[33m::\033[0m %s\n' "$*"; }
die() { say "ERROR: $*" >&2; exit 1; }

[ -d "$SRC" ] || die "run this from a full checkout: $SRC is missing"

install_packages() {
  command -v pacman >/dev/null || die "this installer needs pacman (use --no-deps to skip packages)"
  local missing=() p
  for p in "${PACKAGES[@]}"; do pacman -Q "$p" >/dev/null 2>&1 || missing+=("$p"); done
  if [ "${#missing[@]}" -gt 0 ]; then
    say "installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi
  # The lock screen config uses swaylock-effects options, which plain swaylock rejects.
  if ! swaylock --help 2>&1 | grep -q -- '--effect-vignette'; then
    local aur=""
    for p in paru yay; do if command -v "$p" >/dev/null; then aur="$p"; break; fi; done
    [ -n "$aur" ] || die "swaylock-effects (AUR) is required: install paru or yay, or install it by hand"
    say "installing swaylock-effects from the AUR with $aur"
    "$aur" -S --needed --noconfirm swaylock-effects
  fi
}

install_fonts() {
  local f out
  mkdir -p "$FONTS"
  for f in "${FONT_FILES[@]}"; do
    out="$FONTS/${f##*/}"
    [ -s "$out" ] && continue
    say "fetching font ${f##*/}"
    curl -fsSL --max-time 120 -g "$FONT_BASE/$f" -o "$out.part" || die "could not download $f"
    mv -f "$out.part" "$out"
  done
  fc-cache -f "$FONTS" >/dev/null 2>&1 || true
}

if [ "$YES" = 0 ] && [ "$FILES_ONLY" = 0 ]; then
  say "These existing files would be replaced (a backup goes to ~/.config/dotfiles_backup_<time>/):"
  shown=0
  while IFS= read -r rel; do
    if [ -e "$HOME/$rel" ] && ! cmp -s "$SRC/$rel" "$HOME/$rel"; then echo "     ~/$rel"; shown=1; fi
  done < <(cd "$SRC" && find . -type f -printf '%P\n' | sort)
  if [ -e "$HOME/.config/qt6ct/qt6ct.conf" ]; then echo "     ~/.config/qt6ct/qt6ct.conf"; shown=1; fi
  [ "$shown" = 1 ] || echo "     (none)"
  say "It also sets the GTK theme to NieR and stops any running waybar, swaync, dunst or mako."
  if [ -n "${NIRI_SOCKET:-}" ]; then say "The change applies to this session right away."; fi
  read -r -p "Continue? [y/N] " answer
  case "$answer" in y|Y|yes) ;; *) say "Nothing changed."; exit 0 ;; esac
fi

if [ "$DEPS" = 1 ]; then install_packages; fi
if [ "$FILES_ONLY" = 0 ] && ! id -nG | tr ' ' '\n' | grep -qx input; then
  say "Note: tapping Super to open the launcher needs the input group. Mod+Space works without it."
  say "      To enable it: sudo usermod -aG input \$USER, then log in again."
fi
if [ "$FILES_ONLY" = 0 ]; then install_fonts; fi

mkdir -p "$STATE"
printf '%s' "$REPO" > "$STATE/root"
if [ "$FILES_ONLY" = 1 ]; then
  NIER_RICE_ROOT="$REPO" bash "$SRC/.local/bin/nier-rice" on --files-only
else
  NIER_RICE_ROOT="$REPO" bash "$SRC/.local/bin/nier-rice" on
fi
say "Done. Undo with: ~/.local/bin/nier-rice off   Remove entirely with: ~/.local/bin/nier-rice uninstall"
