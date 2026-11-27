# Roadmap

Working notes for turning the fresh T480 install into a maintained setup.
Each phase ends with a commit; tick items as they land.

Status: 2026-11-27

## 0 — Repo hygiene

- [x] Bootstrap scripts and first install
- [x] Stow niri / foot / fuzzel / mako dotfiles
- [ ] Commit installed locale/keymap drift
- [ ] Remove stray line from `config.env.example`
- [ ] Auto-discover dotfile packages in `scripts/apply-dotfiles.sh`
- [ ] Remove `t480-arch` path assumptions from bootstrap scripts
- [ ] Set a git identity for commits
- [ ] Reconcile `packages/*.txt` with `pacman -Qqe`
- [ ] Refresh README (repo name, layout, status)

## 1 — Visual baseline

- [ ] Pick a theme (current accent palette is Catppuccin Mocha)
- [ ] Waybar config + autostart
- [ ] Swaylock config
- [ ] Wallpaper and wallpaper daemon
- [ ] GTK / Qt theme, icon theme, cursor theme
- [ ] UI and monospace font choices
- [ ] Mako, fuzzel, foot visual consistency
- [ ] Lock/idle screen visually match the session

## 2 — niri ergonomics

- [ ] Window rules (float, opacity, workspace placement)
- [ ] Named workspaces and output layout
- [ ] Media keys (playerctl) and extra laptop keys
- [ ] Screenshot workflow (grim + slurp + clipboard/disk)
- [ ] Clipboard history (cliphist or similar)
- [ ] Idle and lock policy (swayidle)
- [ ] Animation and gesture tuning
- [ ] XWayland / portal verification

## 3 — System

- [ ] Service audit (reflector, paccache, fwupd, fstrim)
- [ ] Package prune (unused alacritty, GNOME portal/nautilus decision)
- [ ] Firewall decision
- [ ] Backup and restore test for `LaptopConfigs`
- [ ] Firmware / EC update note
- [ ] Verify TLP, zram, suspend, charge thresholds after updates
- [ ] Secrets handling (SSH, GPG, credentials)

## 4 — Workflow

- [ ] Shell choice and prompt
- [ ] Terminal choice (foot vs alacritty)
- [ ] Editor and dev tooling
- [ ] Default applications (`xdg-mime`)
- [ ] SSH / GPG setup
- [ ] Personal scripts in `~/.local/bin`

## Open decisions

- Theme family and accent colour
- Status bar: Waybar, another bar, or none
- Terminal and shell stack
- Keep or remove `xdg-desktop-portal-gnome` and its GNOME dependencies
- Whether the repo should bootstrap a fresh machine or only restore this one
