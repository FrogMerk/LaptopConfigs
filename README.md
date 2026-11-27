# LaptopConfigs

Minimal, reproducible Arch setup for a Lenovo ThinkPad T480 (1080p, Intel iGPU, no touchscreen): **niri** + **greetd/tuigreet**, systemd-boot, ext4.

System config lives in `etc/`, dotfiles in `dotfiles/` (stowed into `$HOME`), and the install is split into small, reviewable scripts. The goal is a small package set you can rebuild from git rather than a curated meta-distribution.

## What you get

- Vanilla Arch base, no meta-distro layer
- niri scrollable tiling with native touchpad gestures
- greetd + tuigreet login, starting `niri-session`
- Alacritty + Zsh + Starship, themed with Everforest Dark
- Waybar, mako, fuzzel, swaylock and wpaperd
- Clipboard history (cliphist) and removable-drive automount (udiskie)
- Neovim, xdg default-app associations and personal helper scripts
- Monthly maintenance timer and a one-command restore test
- nftables default-deny inbound firewall
- Weekly reflector mirror refresh (Australia, HTTPS)
- PipeWire, NetworkManager, BlueZ
- TLP + thermald + zram + ThinkPad charge thresholds
- `linux` and `linux-lts` boot entries
- Dotfiles managed with GNU stow; `/etc` versioned with etckeeper

## Before you start

1. **Back up everything.** `10-partition.sh` wipes the target disk.
2. Boot the Arch ISO in **UEFI** mode and connect Wi-Fi:
   ```bash
   iwctl
   # station wlan0 scan
   # station wlan0 get-networks
   # station wlan0 connect <SSID>
   ```
3. Clone this repo into the live environment (or copy it from a USB stick):
   ```bash
   git clone <your-repo-url> ~/LaptopConfigs
   cd ~/LaptopConfigs
   cp bootstrap/config.env.example bootstrap/config.env
   $EDITOR bootstrap/config.env
   ```

Check the disk name before editing the config:

```bash
lsblk -d -o NAME,SIZE,MODEL,TRAN
```

`config.env` also sets the console keymap and `XKB_LAYOUT`; the latter is written into the niri config by `30-chroot.sh`.

## Install

Run from the live ISO, in order:

```bash
sudo ./bootstrap/00-preflight.sh
sudo ./bootstrap/10-partition.sh    # destructive; asks you to retype the disk
sudo ./bootstrap/20-pacstrap.sh
sudo arch-chroot /mnt /root/LaptopConfigs/bootstrap/30-chroot.sh
```

`30-chroot.sh` asks for the root and user passwords, installs systemd-boot, copies the `etc/` overlays and enables services. When it finishes:

```bash
exit
umount -R /mnt
reboot
```

## First boot

Log in at tuigreet; it starts niri. Open a terminal with `Mod+T` and bring the repo into your home directory:

```bash
sudo cp -a /root/LaptopConfigs ~/LaptopConfigs
sudo chown -R "$USER:$USER" ~/LaptopConfigs
cd ~/LaptopConfigs
./post-install.sh
```

If you already pushed the repo to GitHub, clone it instead:

```bash
git clone <your-repo-url> ~/LaptopConfigs
cd ~/LaptopConfigs
./post-install.sh
```

`post-install.sh` backs up any config niri generated on first launch, then stows the dotfiles. Re-save or re-login after config changes; niri hot-reloads on save.

Set Zsh as the login shell once, then log out and back in:

```bash
chsh -s /usr/bin/zsh
```

On an existing install, `sudo ./scripts/install-baseline.sh` installs any
missing desktop packages and sets the login shell in one step.

## Keybinds

| Key | Action |
|---|---|
| `Mod+T` / `Mod+Return` | terminal (Alacritty) |
| `Mod+D` | launcher (fuzzel) |
| `Mod+E` | file manager (Nautilus) |
| `Mod+Grave` | dropdown terminal (Alacritty, `--class dropdown`) |
| `Mod+Shift+D` | dock: extend display to the external monitor |
| `Mod+Q` | close window |
| `Mod+H/J/K/L` or arrows | focus |
| `Mod+Shift+H/J/K/L` | move column/window |
| `Mod+1..6` | named workspace (term/web/code/media/chat/files) |
| `Mod+7..9` | scratch workspace |
| `Mod+Shift+1..6` | move column to a named workspace |
| `Mod+Shift+7..9` | move column to a scratch workspace |
| `Mod+Page_Up/Down` | previous/next workspace |
| `Mod+R` | cycle column width |
| `Mod+Minus` / `Mod+Equal` | shrink/grow column |
| `Mod+F` | maximize column |
| `Mod+Shift+F` | fullscreen |
| `Mod+V` | toggle floating |
| `Mod+Shift+V` | clipboard history (cliphist + fuzzel) |
| `Mod+Shift+W` | wallpaper picker |
| `Mod+Alt+W` | next wallpaper |
| `Mod+Space` | focus floating/tiling |
| `Mod+O` | overview |
| `Super+Alt+L` | lock |
| `Mod+Escape` | toggle keyboard-shortcut inhibitor |
| `Mod+Print` / `Mod+S` | interactive screenshot (niri UI, saves to disk) |
| `Mod+Shift+Print` / `Mod+Shift+S` | full-screen screenshot |
| `Mod+Alt+Print` / `Mod+Alt+S` | region screenshot to clipboard |
| `Mod+Alt+Shift+Print` | full-screen screenshot to clipboard |
| `Mod+Shift+E` | quit niri |
| media keys | playerctl play/pause, next, previous |

`udiskie` runs at login, automounts removable drives and shows a Waybar tray icon. Clipboard history uses `cliphist` + fuzzel and is installed by the baseline script.

Idle policy: lock after 5 minutes, display off after 6 minutes, suspend after 20 minutes. Lock is `swayidle` → `lock-screen` (swaylock with the current wallpaper); suspend is skipped when an app holds an idle inhibitor.

Touchpad gestures are niri's defaults: horizontal scroll pans the column view, swipes switch workspaces. Tune `input.touchpad` in `dotfiles/niri/.config/niri/config.kdl`.

## Workspaces

| Key | Workspace | Used for |
|---|---|---|
| `Mod+1` | `term` | terminals |
| `Mod+2` | `web` | Firefox |
| `Mod+3` | `code` | editors and IDEs |
| `Mod+4` | `media` | mpv, imv, image viewers |
| `Mod+5` | `chat` | Discord, Signal, Telegram, Slack |
| `Mod+6` | `files` | Nautilus |
| `Mod+7..9` | dynamic | scratch workspaces |

Waybar shows the workspace names. Apps route automatically: Firefox to `web`, Nautilus to `files`, viewers to `media`, and chat/code apps to their workspaces. New windows use the rules in `dotfiles/niri/.config/niri/config.kdl`; move anything manually with `Mod+Shift+<number>`.

## Defaults

- Editor: Neovim (`EDITOR=nvim`, `vim` aliased to `nvim`)
- Browser: Firefox
- Files: Nautilus
- Images: imv
- Video: mpv
- Terminal: Alacritty

Associations live in `dotfiles/xdg/.config/mimeapps.list`; `xdg-mime query default <type>` verifies them.

## Theming

Everforest Dark (medium contrast) is applied across niri, Alacritty, Waybar,
fuzzel, mako, swaylock, Starship, the greetd greeter and a full Everforest GTK
theme. Papirus-Dark gets a green folder overlay (`make icons`), and niri blurs
the wallpaper behind the terminal, launcher and notifications. See
`docs/THEME.md` for the palette, files and licensing notes.

## Wallpapers

`wpaperd` cycles everything you put in `~/Pictures/Wallpapers` every 30
minutes (subdirectories included). It runs as the `wpaperd.service` systemd
user unit. Control it with:

```bash
wallpaper pick      # choose with fuzzel (also Mod+Shift+W)
wallpaper next      # or Mod+Alt+W
wallpaper prev
wallpaper reload    # rescan after adding/removing files
wallpaper pause
wallpaper resume
wallpaper current   # print the active image
```

After adding or deleting images, run `wallpaper reload`; otherwise the current
image stays on screen until the 30-minute cycle ends. Do not run `wpaperd`
directly in a terminal — a second instance replaces the IPC socket and breaks
`wpaperctl`. Use `wallpaper reload` or:

```bash
systemctl --user restart wpaperd.service
```

`wpaperd` keeps a symlink to the active image in
`~/.local/state/wpaperd/wallpapers`; the lock screen uses it too. To change the
directory or interval, edit
`dotfiles/wpaperd/.config/wpaperd/config.toml`.

## T480 notes

- Confirm S3 suspend: `cat /sys/power/mem_sleep` should show `[deep]`. If it shows `s2idle`, set the BIOS sleep state to **Linux**.
- Update Thunderbolt firmware: `fwupdmgr get-updates && sudo fwupdmgr update`. T480 units have a known Thunderbolt controller bug. fwupd may offer an embedded-controller update that is Windows-only; leave it alone on Linux.
- Charge thresholds are set to 80% in `etc/tlp.d/10-t480.conf`; verify with `sudo tlp-stat -b`.
- **Never install `power-profiles-daemon` alongside TLP.**
- Expected idle: roughly 5–7 W at low brightness. That is about 9–13 h on the 24 Wh + 72 Wh dual battery, or 4–5 h on the internal battery alone.
- If the panel flickers, try `i915.enable_psr=0` as a kernel parameter before blaming the compositor.

## Updating

```bash
sudo pacman -Syu
```

- Read <https://archlinux.org/news> before a large update.
- `linux-lts` is installed as a fallback; pick it from the systemd-boot menu if an update breaks the main kernel.
- The package cache keeps three versions (`paccache -rk3`). Downgrade with:
  ```bash
  sudo pacman -U /var/cache/pacman/pkg/<pkg>-<version>.pkg.tar.zst
  ```
- There are no filesystem snapshots on ext4. `/etc` history is in etckeeper; dotfiles are in git. Keep a rescue USB and know the `arch-chroot` procedure.
- `checkupdates` lists pending upgrades without touching the system.
- `paccache.timer` trims the package cache weekly; `reflector.timer` refreshes the mirrorlist weekly.
- `nftables.service` applies `/etc/nftables.conf`, which denies unsolicited inbound traffic.
- `make check` (or the `maintenance` command) writes a monthly report; the user timer runs it on the first of each month at 09:00 and sends a notification.

## System maintenance

Apply the one-time audit fixes on an existing install:

```bash
sudo ./scripts/apply-system-fixes.sh
```

It restricts ESP permissions, enables the maintenance timers, installs the
nftables ruleset, configures reflector for Australia, and installs `fakeroot`.
Re-running it is safe. Reboot once after the first run so the ESP mask is
applied from fstab.

Monthly report and restore test:

```bash
make check    # ~/.cache/maintenance/last-check.txt
make test     # restore HEAD into a temporary HOME and validate it
```

Enable or inspect the monthly timer:

```bash
systemctl --user list-timers maintenance-check.timer
```

## Docking

With an external monitor connected:

```bash
dock extend          # internal + external to the right
dock external-only   # external only
dock internal-only   # back to the laptop panel
```

`Mod+Shift+D` runs `dock extend`. The same helper is in
`dotfiles/bin/.local/bin/dock`; adjust the position if the monitor is on the
left.

## Layout

```
.
├── Makefile
├── bootstrap/
│   ├── config.env.example
│   ├── lib.sh
│   ├── 00-preflight.sh
│   ├── 10-partition.sh
│   ├── 20-pacstrap.sh
│   └── 30-chroot.sh
├── packages/
│   ├── base.txt
│   ├── desktop.txt
│   └── extras.txt
├── dotfiles/
│   ├── alacritty/.config/alacritty/alacritty.toml
│   ├── bin/.local/bin/
│   ├── fuzzel/.config/fuzzel/fuzzel.ini
│   ├── gtk/.config/gtk-3.0/settings.ini
│   ├── gtk/.config/gtk-4.0/ (Everforest libadwaita override)
│   ├── gtk/.themes/Everforest-Green-Dark-Medium/
│   ├── mako/.config/mako/config
│   ├── niri/.config/niri/config.kdl
│   ├── starship/.config/starship.toml
│   ├── swaylock/.config/swaylock/config
│   ├── systemd-user/.config/systemd/user/
│   ├── wpaperd/.config/wpaperd/config.toml
│   ├── waybar/.config/waybar/config.jsonc
│   ├── waybar/.config/waybar/style.css
│   ├── xdg/.config/mimeapps.list
│   └── zsh/.zshrc
├── etc/
│   ├── greetd/config.toml
│   ├── nftables.conf
│   ├── tlp.d/10-t480.conf
│   ├── systemd/zram-generator.conf
│   ├── sysctl.d/99-zram.conf
│   └── xdg/reflector/reflector.conf
├── docs/
│   ├── AUDIT.md
│   ├── EXPANSION.md
│   ├── ROADMAP.md
│   ├── SECRETS.md
│   └── THEME.md
├── scripts/
│   ├── apply-dotfiles.sh
│   ├── apply-everforest-icons.sh
│   ├── apply-system-fixes.sh
│   ├── install-baseline.sh
│   ├── install-extras.sh
│   ├── maintenance-check.sh
│   └── test-restore.sh
└── post-install.sh
```

## Troubleshooting

- **greetd loop or black screen:** `systemctl status greetd`, then `journalctl -u greetd`. Verify `/etc/greetd/config.toml` runs `tuigreet --cmd niri-session`.
- **niri won't start after editing config:** run `niri validate`. A bad config at startup prevents the session; live reload keeps the last working state.
- **Waybar missing or empty:** run `waybar` from a terminal and read the error; check `~/.config/waybar/config.jsonc`. niri hot-reloads binds, but `spawn-at-startup` only runs on login.
- **No wallpaper:** confirm `wpaperd` is installed, `~/Pictures/Wallpapers` contains images, and `wpaperctl status` reports a running output. Check `~/.config/wpaperd/config.toml` and `journalctl --user -b` for parse errors.
- **No audio:** `systemctl --user status pipewire wireplumber`.
- **Wi-Fi not connecting:** `nmcli device wifi list`, then `nmtui`.
- **Boot entry missing:** from the live ISO, mount the ESP and run `bootctl --esp-path=/mnt/boot install`, then recreate the loader entries.
- **No `deep` sleep:** check `cat /sys/power/mem_sleep`; if only `s2idle` is listed, enable Linux S3 in the BIOS.
- **Permission denied under `/boot`:** expected; the ESP is root-only (`700`). Use `sudo` for boot files.

## Security

`bootstrap/config.env` is gitignored, but treat it as sensitive: it contains your hostname and disk layout, not passwords. Never commit Wi-Fi credentials, SSH keys, or passphrases. Keep secrets in `pass`/`age` outside this repo. Authentication and signing notes live in `docs/SECRETS.md`.
