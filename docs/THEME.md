# Theme

**Everforest Dark, medium contrast.** A green-based, warm, low-contrast palette
designed for long sessions. See the upstream palette:
<https://github.com/sainnhe/everforest/blob/master/palette.md>.

The setup has three layers: literal palettes in the app configs, a vendored
Everforest GTK theme, and Papirus icons with green folders.

## Palette

| Role | Hex | Used for |
|---|---|---|
| `bg_dim` | `#232A2E` | deepest background, view backgrounds |
| `bg0` | `#2D353B` | default background |
| `bg1` | `#343F44` | raised surfaces, hover |
| `bg2` | `#3D484D` | popups, floating |
| `bg3` | `#475258` | borders, selection |
| `bg4` | `#4F585E` | separators |
| `bg5` | `#56635F` | muted surface |
| `fg` | `#D3C6AA` | default text |
| `grey0` | `#7A8478` | comments, disabled |
| `grey1` | `#859289` | secondary text |
| `grey2` | `#9DA9A0` | tertiary text |
| `red` | `#E67E80` | errors, urgent, critical battery |
| `orange` | `#E69875` | operators, accents |
| `yellow` | `#DBBC7F` | directories, warnings |
| `green` | `#A7C080` | primary accent, focus, success |
| `aqua` | `#83C092` | constants, secondary accent |
| `blue` | `#7FBBB3` | info, links |
| `purple` | `#D699B6` | numbers, special |
| `bg_red` | `#514045` | error backgrounds |
| `bg_yellow` | `#4D4C43` | warning backgrounds |
| `bg_green` | `#425047` | success backgrounds |
| `bg_blue` | `#3A515D` | info backgrounds |
| `bg_purple` | `#4A444E` | special backgrounds |

## File map

| File | Notes |
|---|---|
| `dotfiles/niri/.config/niri/config.kdl` | gaps, radius, focus ring, blur, overview, subtle animations |
| `dotfiles/alacritty/.config/alacritty/alacritty.toml` | terminal palette, 0.85 opacity, keybinds |
| `dotfiles/waybar/.config/waybar/config.jsonc` | modules and tooltips |
| `dotfiles/waybar/.config/waybar/style.css` | bar, pills, states |
| `dotfiles/fuzzel/.config/fuzzel/fuzzel.ini` | launcher, green selection, frosted background |
| `dotfiles/mako/.config/mako/config` | notifications, grouping, urgency colours |
| `dotfiles/gtklock/.config/gtklock/config.ini` | lock theme, clock and date |
| `dotfiles/gtklock/.config/gtklock/style.css` | frosted lock box and password field |
| `dotfiles/swaylock/.config/swaylock/config` | fallback lock indicator |
| `dotfiles/starship/.config/starship.toml` | prompt |
| `dotfiles/gtk/.themes/Everforest-Green-Dark-Medium/` | full GTK3 theme (vendored) |
| `dotfiles/gtk/.config/gtk-4.0/` | same theme as a libadwaita override |
| `dotfiles/gtk/.config/gtk-3.0/settings.ini` | GTK3 theme, icons, fonts, cursor |
| `dotfiles/wpaperd/.config/wpaperd/config.toml` | wallpaper directory, interval, fade |
| `dotfiles/systemd-user/.config/systemd/user/wpaperd.service` | wallpaper daemon lifecycle |
| `dotfiles/bin/.local/bin/wallpaper` | picker, reload and wpaperctl wrapper |
| `scripts/apply-everforest-icons.sh` | green Papirus folder overlay |
| `etc/greetd/config.toml` | tuigreet colour theme |

## Surfaces and effects

- **Bar:** opaque `bg0` with a `bg3` bottom border and 8 px pill modules.
- **Terminal:** Alacritty at `0.85` opacity; niri blurs the wallpaper behind it.
- **Launcher and notifications:** 90 % surfaces plus a niri layer blur.
- **Notification icons:** disabled (`icons=0`). Mako 1.11 on this
  gdk-pixbuf/glycin stack refuses the Papirus SVGs and draws a placeholder;
  text-only is cleaner until the loader is fixed.
- **Lock screen:** gtklock with a pre-blurred copy of the active wallpaper
  (`ffmpeg`, generated at lock time) and a dark translucent password box.
- **Blur:** `blur {}` uses 3 passes and xray (rendered once per wallpaper), so
  it is effectively free while idle.
- **Animations:** 120–140 ms open/close easings and critically damped springs.
  Idle power is unaffected; only the transition itself wakes the iGPU.

## Full GTK theme

The `Everforest-Green-Dark-Medium` folder is built from
[Fausto-Korpsvart/Everforest-GTK-Theme](https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme)
at the commit recorded in its `SOURCE` file. It is vendored so `stow` can
install it without a network build. It is GPL-3.0; the upstream `LICENSE` is in
the theme directory.

Rebuilding after an upstream update needs `sassc`:

```bash
git clone https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme /tmp/everforest-gtk
cd /tmp/everforest-gtk/themes
./install.sh -t green -c dark -s standard --tweaks medium -d /tmp/theme-out
# copy gtk-3.0 + index.theme into dotfiles/gtk/.themes/Everforest-Green-Dark-Medium
# copy gtk-4.0 into dotfiles/gtk/.config/gtk-4.0
```

GTK4/libadwaita ignores `gtk-theme-name` for most widgets; the files in
`~/.config/gtk-4.0` are the reliable override. GTK3 apps use the theme from
`~/.themes`. `gsettings` is set by `post-install.sh` and should match
`settings.ini`.

## Icons and cursor

- **Icons:** Papirus-Dark with Everforest-green folders. `make icons` builds a
  small `~/.local/share/icons/Papirus-Everforest` overlay of symlinks; it
  inherits Papirus-Dark and does not copy the icon set.
- **Cursor:** Adwaita at 24 px. It is neutral and already present; a matching
  Everforest cursor is not packaged.

## Fonts

- UI: **Noto Sans 11** (GTK and gsettings).
- Monospace UI: **JetBrainsMono Nerd Font 10**.
- Terminal: **JetBrainsMono Nerd Font 11.5**.
- Waybar: **JetBrainsMono Nerd Font 13**.
- Emoji: **Noto Color Emoji** (installed).

## Wallpapers

Wallpapers are user content and are not tracked. Put any PNG/JPEG/WebP/AVIF in
`~/Pictures/Wallpapers`; `wpaperd` cycles them every 30 minutes with a 1.2 s
fade. After changing the folder, run `wallpaper reload` to rescan it. The
daemon is a systemd user service (`wpaperd.service`); the active image is
exposed through the state symlink used by `wallpaper current` and the lock
screen. There is no generated wallpaper.

## Qt

No Qt applications are installed yet, so there is no Qt theme path. When the
first Qt app lands, prefer `qt6ct` from `extra` and set
`QT_QPA_PLATFORMTHEME=qt6ct`; keep `QT_QPA_PLATFORM=wayland` in niri's
`environment {}`.

## Changing the palette

Most apps take literal hex values, so a palette change is a search-and-replace
across the files above. If the accent changes, update `green` everywhere plus
the GTK `accent_*` colours and the vendored GTK theme (rebuild it). Waybar,
fuzzel, mako, Alacritty and swaylock use the same literals as this table.
