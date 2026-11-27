# LaptopConfigs

Minimal, reproducible Arch setup for a Lenovo ThinkPad T480 (1080p, Intel iGPU, no touchscreen): **niri** + **greetd/tuigreet**, systemd-boot, ext4.

System config lives in `etc/`, dotfiles in `dotfiles/` (stowed into `$HOME`), and the install is split into small, reviewable scripts. The goal is a small package set you can rebuild from git rather than a curated meta-distribution.

## What you get

- Vanilla Arch base, no meta-distro layer
- niri scrollable tiling with native touchpad gestures
- greetd + tuigreet login, starting `niri-session`
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

## Keybinds

| Key | Action |
|---|---|
| `Mod+T` / `Mod+Return` | terminal (foot) |
| `Mod+D` | launcher (fuzzel) |
| `Mod+Q` | close window |
| `Mod+H/J/K/L` or arrows | focus |
| `Mod+Shift+H/J/K/L` | move column/window |
| `Mod+1..9` | workspace |
| `Mod+Shift+1..9` | move column to workspace |
| `Mod+Page_Up/Down` | previous/next workspace |
| `Mod+R` | cycle column width |
| `Mod+Minus` / `Mod+Equal` | shrink/grow column |
| `Mod+F` | maximize column |
| `Mod+Shift+F` | fullscreen |
| `Mod+V` | toggle floating |
| `Mod+Space` | focus floating/tiling |
| `Mod+O` | overview |
| `Super+Alt+L` | lock |
| `Mod+Escape` | toggle keyboard-shortcut inhibitor |
| `Mod+Print` / `Mod+S` | interactive screenshot (clipboard + disk) |
| `Mod+Shift+Print` / `Mod+Shift+S` | full-screen screenshot |
| `Mod+Shift+E` | quit niri |

Touchpad gestures are niri's defaults: horizontal scroll pans the column view, swipes switch workspaces. Tune `input.touchpad` in `dotfiles/niri/.config/niri/config.kdl`.

## T480 notes

- Confirm S3 suspend: `cat /sys/power/mem_sleep` should show `[deep]`. If it shows `s2idle`, set the BIOS sleep state to **Linux**.
- Update Thunderbolt firmware: `fwupdmgr get-updates && sudo fwupdmgr update`. T480 units have a known Thunderbolt controller bug.
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

## Layout

```
.
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
│   ├── niri/.config/niri/config.kdl
│   ├── foot/.config/foot/foot.ini
│   ├── fuzzel/.config/fuzzel/fuzzel.ini
│   └── mako/.config/mako/config
├── etc/
│   ├── greetd/config.toml
│   ├── tlp.d/10-t480.conf
│   ├── systemd/zram-generator.conf
│   └── sysctl.d/99-zram.conf
├── docs/
│   └── ROADMAP.md
├── scripts/
│   ├── apply-dotfiles.sh
│   └── install-extras.sh
└── post-install.sh
```

## Troubleshooting

- **greetd loop or black screen:** `systemctl status greetd`, then `journalctl -u greetd`. Verify `/etc/greetd/config.toml` runs `tuigreet --cmd niri-session`.
- **niri won't start after editing config:** run `niri validate`. A bad config at startup prevents the session; live reload keeps the last working state.
- **No audio:** `systemctl --user status pipewire wireplumber`.
- **Wi-Fi not connecting:** `nmcli device wifi list`, then `nmtui`.
- **Boot entry missing:** from the live ISO, mount the ESP and run `bootctl --esp-path=/mnt/boot install`, then recreate the loader entries.
- **No `deep` sleep:** check `cat /sys/power/mem_sleep`; if only `s2idle` is listed, enable Linux S3 in the BIOS.

## Security

`bootstrap/config.env` is gitignored, but treat it as sensitive: it contains your hostname and disk layout, not passwords. Never commit Wi-Fi credentials, SSH keys, or passphrases. Keep secrets in `pass`/`age` outside this repo.
