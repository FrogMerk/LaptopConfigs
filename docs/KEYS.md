# Keybinds

`Mod` is the Super key. The full set lives in
`dotfiles/niri/.config/niri/config.kdl`; this is the quick reference.

## Applications

| Key | Action |
|---|---|
| `Mod+T` / `Mod+Return` | terminal (Alacritty) |
| `Mod+Space` | app launcher (fuzzel) |
| `Mod+E` | file manager (Nautilus) |
| `Mod+Grave` | dropdown terminal (Alacritty, `--class dropdown`) |
| `Mod+Shift+D` | dock: extend display to the external monitor |
| `Mod+Q` | close window |

## Focus and windows

| Key | Action |
|---|---|
| `Mod+Left/Right` or `Mod+H/L` | focus column left/right |
| `Mod+Up/Down` or `Mod+K/J` | focus window up/down |
| `Mod+Shift+Left/Right` or `Mod+Shift+H/L` | move column left/right |
| `Mod+Shift+Up/Down` or `Mod+Shift+K/J` | move window up/down |
| `Mod+F` | maximize column |
| `Mod+Shift+F` | fullscreen window |
| `Mod+V` | toggle floating |
| `Mod+Shift+Space` | focus between floating and tiling |
| `Mod+Comma` / `Mod+Period` | consume / expel window |
| `Mod+O` | overview |
| `Mod+R` / `Mod+Shift+R` | cycle column width forward/back |
| `Mod+Minus` / `Mod+Equal` | shrink / grow column |

## Workspaces

| Key | Action |
|---|---|
| `Mod+Page_Up` / `Mod+Page_Down` | previous / next workspace |
| `Mod+Shift+Page_Up` / `Mod+Shift+Page_Down` | move column to previous / next workspace |
| `Mod+1..6` | named workspace: term, web, code, media, chat, files |
| `Mod+7..9` | scratch workspaces |
| `Mod+Shift+1..6` | move column to a named workspace |
| `Mod+Shift+7..9` | move column to a scratch workspace |

## Screenshots, clipboard and wallpaper

| Key | Action |
|---|---|
| `Mod+Shift+V` | clipboard history (cliphist + fuzzel) |
| `Mod+Print` / `Mod+S` | interactive screenshot (niri UI, saves to disk) |
| `Mod+Shift+Print` / `Mod+Shift+S` | full-screen screenshot |
| `Mod+Alt+Print` / `Mod+Alt+S` | region screenshot to clipboard |
| `Mod+Alt+A` | region screenshot → satty annotation → clipboard + file |
| `Mod+Alt+Shift+Print` | full-screen screenshot to clipboard |
| `Mod+Shift+W` | wallpaper picker (fuzzel) |
| `Mod+Alt+W` | next wallpaper |

## Session and screen

| Key | Action |
|---|---|
| `Super+Alt+L` | lock (gtklock, frosted wallpaper) |
| `Mod+Escape` | toggle keyboard-shortcut inhibitor |
| `Mod+Shift+P` | power off monitors |
| `Mod+Shift+Slash` | show niri hotkey overlay |
| `Mod+Shift+E` | quit niri |

Idle policy: lock after 5 minutes, display off after 6, suspend after 20.
Media keys control volume, brightness and `playerctl`.

## Shell

| Key | Action |
|---|---|
| `Ctrl+R` | fuzzy history search (fzf) |
| `Ctrl+T` | fuzzy file picker (fzf + fd) |
| `Alt+C` | fuzzy directory jump (fzf + fd) |
| `z <dir>` / `zi` | zoxide jump / interactive jump |
| `lg` | lazygit |
