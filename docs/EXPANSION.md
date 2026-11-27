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
- Alacritty at 0.85 opacity; Zsh + Starship; Neovim installed, no config yet
- Waybar: workspaces, window title, clock, tray, audio, network, both batteries
- niri: six named workspaces, app routing, float rules, dropdown terminal,
  clipboard history, screenshot helpers, `dock` helper
- nftables default-deny inbound; reflector, paccache and fwupd timers
- Monthly maintenance report and user timer
- `make validate`, `make test`, `make check`
- Animations are intentionally off for battery life
- Commit signing is documented but not enabled
- External-monitor layout is implemented but untested without hardware

## 1. Look and feel

### High impact

- [ ] Decide the animation policy: keep off, or add subtle open/close/workspace
      transitions and measure idle power
- [ ] Waybar v2: choose modules and layout, spacing, tooltips, opacity
- [ ] Add useful Waybar modules: idle inhibitor, updates, media, CPU/memory,
      temperature, keyboard layout
- [ ] Generate a small wallpaper set and a way to rotate/choose it
- [ ] GTK/Qt depth: Adwaita-dark + green accent vs an Everforest GTK theme
- [ ] Qt theme path (`qt6ct` or environment variables)
- [ ] Icon and cursor theme decision
- [ ] Font pass: UI font, sizes, emoji, terminal weight
- [ ] Alacritty polish: keybinds, scrollback, cursor, optional blur
- [ ] Mako/fuzzel/swaylock polish: grouping, icons, timeouts, lock clock

### Medium

- [ ] Tune focus ring, border, shadow and tab indicator colours
- [ ] Workspace-specific gaps or struts if the bar/layout needs it
- [ ] Overview and workspace-switch visuals
- [ ] Firefox theme (`userChrome`/`userContent`) or a matching extension theme
- [ ] Neovim colorscheme and statusline
- [ ] Starship prompt refinement
- [ ] tuigreet/greetd theme, or a graphical greeter decision
- [ ] Optional boot polish (systemd-boot menu, Plymouth)

### Experiments

- [ ] niri window effects: blur, xray, noise, saturation (measure iGPU cost)
- [ ] Spring animation parameters
- [ ] Custom Waybar modules (clipboard, maintenance, updates)
- [ ] Lock-screen blurred screenshot instead of solid colour
- [ ] Layer-shell extras (notifications/control centre) if useful

## 2. Workflow and applications

### Editor and shell

- [ ] Neovim config: plugin manager, LSP, treesitter, telescope, git signs,
      everforest colorscheme, statusline
- [ ] Decide whether to start from scratch or a distro (Kickstart/LazyVim)
- [ ] Add CLI upgrades: `eza`, `zoxide`, `fzf`, `bat`, `fd`, `ripgrep`,
      `lazygit`, `btop`, `fastfetch`
- [ ] Zsh refinements: history search, completion styles, plugin tuning
- [ ] Shell secrets/agent integration if a key passphrase is added

### Desktop apps

- [ ] Screenshot annotation (`swappy` or `satty`) and OCR if useful
- [ ] Verify cliphist handles images as well as text
- [ ] mpv config and MPRIS/Waybar media integration
- [ ] File manager: Nautilus tweaks or a yazi-first workflow
- [ ] Browser: extensions, PWA, container tabs, VA-API check
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
- [ ] Decide whether to track a wallpaper image or keep it generated

## Suggested first session

1. Pick the animation policy and test two or three variants; check idle power.
2. Sketch Waybar v2 and decide which modules earn space on a 1080p bar.
3. Generate three wallpaper variants in the Everforest palette.
4. Choose the GTK/Qt theming path (accent-only vs full Everforest theme).
5. Start the Neovim config with the Everforest colorscheme and LSP.
6. Install the first CLI batch (`eza`, `zoxide`, `fzf`, `btop`, `lazygit`).
7. Add annotated screenshots (`swappy` or `satty`).

## Open questions

- How much animation is worth the battery cost?
- Waybar: minimal or information-dense?
- GTK theme: full Everforest theme or accent-only Adwaita?
- Neovim: hand-rolled config or a distro?
- AUR helper: `paru` or `yay`?
- Backups: local external disk, remote, or both?
- Commit signing: SSH key or a dedicated GPG key?
- External monitor: resolution and port when available?
