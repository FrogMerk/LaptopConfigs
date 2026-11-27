# Expansion and refinement backlog

The base install and roadmap through phase 4 are complete. This is the next
phase: visual polish, workflow upgrades, and quality-of-life experiments.

Start a new session with:

```bash
cd ~/LaptopConfigs
git pull
make validate
make test
```

## Current baseline

- Arch + niri 26.04 on a ThinkPad T480: 1080p, Intel iGPU, no VRR
- Everforest Dark (medium), 12 px gaps, 12 px window radius
- Full Everforest GTK theme, Papirus-Dark with green folders, Adwaita cursors
- Alacritty at 0.85 opacity with niri background blur; Zsh + Starship; micro
- Waybar v2: workspaces, title, clock, media, idle inhibitor, updates, audio,
  network, CPU, memory, temperature, both batteries, tray
- `wpaperd` cycles user-supplied wallpapers with a fuzzel picker
- niri: subtle transitions, overview effects, six named workspaces, app routing,
  float rules, dropdown terminal, clipboard history, screenshot helpers, `dock`
- nftables default-deny inbound; reflector, paccache and fwupd timers
- Monthly maintenance report and user timer
- `make validate`, `make test`, `make check`, `make icons`
- Commit signing is documented but not enabled
- External-monitor layout is implemented but untested without hardware

## 1. Look and feel

### High impact

- [x] Animation policy: subtle 120–140 ms easings and damped springs. Idle
      power is unaffected; only the transition itself wakes the iGPU
- [x] Waybar v2: medium density, 34 px bar, 8 px pills, tooltips and state colours
- [x] Useful Waybar modules: idle inhibitor, custom updates, media, CPU/memory,
      temperature. Keyboard layout skipped (only `us` is configured)
- [x] Wallpaper manager: `wpaperd` runs as a user service and cycles
      `~/Pictures/Wallpapers`; `wallpaper pick/next/reload` controls it. Images
      are user-sourced, not generated
- [x] GTK depth: full Everforest GTK theme (green/dark/medium), vendored for stow
- [x] Qt theme path: deferred; no Qt apps are installed yet. Prefer `qt6ct` later
- [x] Icon and cursor decision: Papirus-Dark with a green folder overlay;
      Adwaita cursors at 24 px
- [x] Font pass: Noto Sans 11 UI, JetBrainsMono NF 11.5 terminal, 13 Waybar,
      Noto Color Emoji
- [x] Alacritty polish: keybinds, 50k scrollback, selection clipboard, OSC 52,
      wider padding, 0.85 opacity plus niri blur
- [x] Mako/fuzzel/swaylock polish: grouping, urgent timeouts, green launcher
      selection, caps/layout lock colours. Notification icons are off because
      mako cannot load the Papirus SVGs on this stack; lock clock needs
      `swaylock-effects` and is deferred

### Medium

- [x] Tune focus ring, border, shadow and overview colours
- [ ] Workspace-specific gaps or struts: not needed at this layout
- [x] Overview and workspace-switch visuals: zoom, backdrop, shadow, springs
- [x] Editor: micro replaces Neovim; Everforest shell and app theme carry over
      without a modal editor config
- [x] Starship prompt refinement: reviewed; the minimal two-line prompt is kept
- [x] tuigreet/greetd theme: Everforest colours and a short time format
- [ ] Optional boot polish (systemd-boot menu, Plymouth)

### Experiments

- [x] niri window effects: blur with xray, noise 0.02 and saturation 1.2.
      Xray renders blur once per wallpaper, so idle cost is negligible
- [x] Spring animation parameters: tuned for short, non-bouncy movement
- [x] Custom Waybar module: hourly `checkupdates` count, hidden when zero
- [x] Lock-screen blurred wallpaper: gtklock plus an ffmpeg-generated frost;
      a real password field replaces the swaylock ring
- [ ] Layer-shell extras (notifications/control centre) if useful

## 2. Workflow and applications

### Editor and shell

- [x] Editor: micro replaces Neovim; no modal/vim config needed
- [ ] Optional micro theme/syntax tweaks if the defaults feel plain
- [ ] Add CLI upgrades: `eza`, `zoxide`, `fzf`, `bat`, `fd`, `ripgrep`,
      `lazygit`, `btop`, `fastfetch`
- [ ] Zsh refinements: history search, completion styles, plugin tuning
- [ ] Shell secrets/agent integration if a key passphrase is added

### Desktop apps

- [ ] Screenshot annotation (`swappy` or `satty`) and OCR if useful
- [ ] Verify cliphist handles images as well as text
- [ ] mpv config and MPRIS/Waybar media integration
- [ ] File manager: Nautilus tweaks or a yazi-first workflow
- [ ] Browser: Epiphany web apps, bookmarks, VA-API/GStreamer check
- [ ] Communication apps (Signal/Discord/Telegram) via repo, Flatpak or AUR
- [ ] PDF/office tooling if needed
- [ ] More MIME defaults (archives, PDFs, mail, calendars)

### Productivity

- [ ] Password store (`pass` + GPG/age) and browser integration
- [ ] Commit signing (SSH or GPG) and GitHub signing key
- [ ] Backups: restic to an external disk or remote, plus a restore drill
- [ ] AUR helper and base-devel for future packages
- [ ] Git extras: delta, lazygit, difftastic?
- [ ] Personal scripts: fuzzel modes, quick notes, project launcher
- [ ] Notification history / do-not-disturb workflow
- [ ] Power tuning: TLP refinement, suspend hooks, idle power measurement

## 3. System and reliability

- [ ] Backup strategy and schedule; test restoring `$HOME` and `/etc`
- [ ] Journald retention decision
- [ ] Firewall refinement if SSH or local services are added
- [ ] Kernel strategy: stay on `linux`, test `linux-lts` boot
- [ ] Boot entries, timeout and default kernel review
- [ ] Update cadence: review `make check` output monthly
- [ ] Monitoring: `btop`, `lm_sensors`, battery health
- [ ] Bluetooth/audio devices and codecs
- [ ] Printing/scanning only if needed
- [ ] Locale and keyboard extras (compose key, dead keys)
- [ ] Dock/external monitor test and scale decision when hardware is available
- [ ] Firmware: Thunderbolt/EC notes, fwupd cadence
- [ ] Hibernation decision (currently zram only, no hibernate)

## 4. Repo and meta

- [ ] Shellcheck/shfmt pre-commit or CI
- [ ] GitHub Actions for TOML/JSON/shell validation (niri needs the local session)
- [ ] Keybind cheatsheet in `docs/KEYS.md`
- [ ] Keep `docs/THEME.md`, `docs/AUDIT.md` and this backlog current
- [ ] Consider GitHub Issues/Projects for larger experiments
- [ ] Dotfiles portability review (hardcoded paths, output names)
- [x] Decide whether to track a wallpaper image: no; user-sourced and managed by
      `wpaperd`

## Suggested next session

The look-and-feel pass is complete. Next up:

1. Optional micro theme/syntax tweaks; the editor works out of the box.
2. Install the first CLI batch (`eza`, `zoxide`, `fzf`, `btop`, `lazygit`).
3. Add annotated screenshots (`swappy` or `satty`).
4. Try Epiphany web apps and check VA-API playback with the GStreamer plugins.
5. Test the external-monitor profile when hardware is available.

## Open questions

- AUR helper: `paru` or `yay`?
- Backups: local external disk, remote, or both?
- Commit signing: SSH key or a dedicated GPG key?
- External monitor: resolution and port when available?
