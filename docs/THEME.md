# Theme

**Everforest Dark, medium contrast.** A green-based, warm, low-contrast palette
designed for long sessions. See the upstream palette:
<https://github.com/sainnhe/everforest/blob/master/palette.md>.

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
| `dotfiles/niri/.config/niri/config.kdl` | background and focus ring |
| `dotfiles/alacritty/.config/alacritty/alacritty.toml` | full terminal palette |
| `dotfiles/foot/.config/foot/foot.ini` | fallback terminal palette |
| `dotfiles/waybar/.config/waybar/style.css` | bar and workspace colours |
| `dotfiles/fuzzel/.config/fuzzel/fuzzel.ini` | launcher |
| `dotfiles/mako/.config/mako/config` | notifications |
| `dotfiles/swaylock/.config/swaylock/config` | lock screen |
| `dotfiles/starship/.config/starship.toml` | prompt |
| `dotfiles/gtk/.config/gtk-3.0/gtk.css` | GTK3 accents over Adwaita-dark |
| `dotfiles/gtk/.config/gtk-4.0/gtk.css` | GTK4 / libadwaita accents |
| `scripts/make-wallpaper.py` | generated wallpaper, no external assets |

## Changing the palette

Most apps take literal hex values, so a theme change is a search-and-replace
across the files above. Keep this table and the wallpaper generator's constants
in sync. If the accent changes, update `green` everywhere plus the GTK
`accent_*` colours.
