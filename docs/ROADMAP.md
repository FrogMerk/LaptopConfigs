# Roadmap

Working notes for turning the fresh T480 install into a maintained setup.
Tick items as they land; each phase ends with a commit.

Status: 2026-11-27

## Decisions

- Theme: **Everforest Dark (medium contrast)**, full GTK theme + green Papirus folders
- Bar: **Waybar v2**, medium density
- Terminal/shell: **Alacritty + Zsh + Starship**
- WM: **niri**, scrollable tiling
- Wallpaper: **wpaperd** cycling a user-supplied collection in `~/Pictures/Wallpapers`

## 0 — Repo hygiene (done)

- [x] Bootstrap scripts and first install
- [x] Stow niri / fuzzel / mako dotfiles
- [x] Commit installed locale/keymap drift
- [x] Remove stray line from `config.env.example`
- [x] Auto-discover dotfile packages in `scripts/apply-dotfiles.sh`
- [x] Remove `t480-arch` path assumptions from bootstrap scripts
- [x] Set a local git identity
- [x] Add `docs/ROADMAP.md` and `docs/THEME.md`
- [ ] Push the repo to GitHub (needs SSH key or token)

## 1 — Visual baseline (done)

- [x] Apply Everforest to niri, fuzzel, mako, Alacritty
- [x] Waybar config and stylesheet
- [x] Swaylock config
- [x] Starship prompt and Zsh config
- [x] GTK theme: full Everforest green/dark/medium plus green Papirus folders
- [x] Install `zsh`, `starship`, `wpaperd`, `papirus-icon-theme`
- [x] Set login shell to Zsh
- [x] Start Waybar and verify it loads
- [x] Install `wpaperd` and verify the wallpaper
- [x] Verify swaylock, mako, fuzzel, Alacritty
- [x] Waybar refinements: dual batteries, tooltips, spacing, media/updates/CPU
- [x] Replace the generated wallpaper with a managed collection
- [x] Cursor theme decision: Adwaita at 24 px
- [x] Qt theme decision: defer `qt6ct` until a Qt app is installed
- [x] Add the full Everforest GTK theme (vendored, no AUR needed)
- [x] Subtle niri animations, overview effects and background blur

## 2 — niri ergonomics

- [x] Window rules: float utilities, viewers, Firefox PiP, dropdown terminal
- [x] Dropdown terminal (`Mod+Grave`)
- [x] Clipboard history (`cliphist` + fuzzel)
- [x] Screenshot workflow: built-in UI plus region/full to clipboard
- [x] `udiskie` automount + tray integration
- [x] Verify media keys and add any missing laptop keys
- [x] Named workspaces (`term`, `web`, `code`, `media`, `chat`, `files`)
- [x] App-to-workspace placement rules
- [x] Idle and lock policy: lock 5 min, display off 6 min, suspend 20 min
- [x] Animation and gesture tuning: animations intentionally off for battery; defaults verified
- [x] XWayland and portal verification: satellite launched with an X11 Firefox window; portals active
- [x] External monitor / docking profile: `dock` helper plus output template

## 3 — System

Audit snapshot and findings: `docs/AUDIT.md`.

- [x] Reconcile package manifests with the installed set (no drift)
- [x] Decide on `xdg-desktop-portal-gnome` + Nautilus (keep both)
- [x] Service audit: no failed units; timers need enabling
- [x] Verify TLP, zram, suspend and charge thresholds
- [x] Firmware / EC update note (EC is Windows-only)
- [x] Run `sudo ./scripts/apply-system-fixes.sh` (ESP mask verified after reboot, timers, firewall, reflector, fakeroot)
- [x] Firewall decision: `nftables` default-deny inbound
- [x] Reflector: Australia, HTTPS, weekly timer
- [x] Backup and restore test for `LaptopConfigs` (`make test`)
- [x] Secrets handling: SSH auth configured; signing options in `docs/SECRETS.md`
- [x] Monthly update/maintenance cadence: report script plus user timer

## 4 — Workflow

- [x] Refine Zsh aliases, plugins and completion behaviour
- [x] Editor choice: Neovim (`EDITOR=nvim`, `vim` aliased)
- [x] Default applications via `xdg-mime` (`mimeapps.list`)
- [x] SSH / GPG setup: SSH auth configured; signing options documented
- [x] Personal scripts in `~/.local/bin` (screenshots, clipboard, lock, dock)
- [x] Repository Makefile (`dots`, `validate`, `test`, `check`, `icons`)

## 5 — Expansion and refinement

See `docs/EXPANSION.md` for the full backlog.

- [x] Animation and visual polish pass
- [x] Waybar v2 and wallpaper manager
- [x] GTK/icon/cursor theme depth (Qt deferred until needed)
- [ ] Neovim configuration and shell upgrades
- [ ] Backups, signing, AUR tooling and daily-workflow extras

## Next up

The look-and-feel pass is complete. The next phase is logged in
`docs/EXPANSION.md`: Neovim, the CLI batch, annotated screenshots, a Firefox
theme and backups. Start a fresh session with `git pull`, `make validate`,
`make test`.
