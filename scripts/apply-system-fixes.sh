#!/usr/bin/env bash
# Apply system-level maintenance fixes on an existing install.
# Safe to re-run; requires root because it edits /etc and enables units.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

# --- ESP permissions --------------------------------------------------------
# systemd-boot warns when the ESP and its random-seed file are world-readable.
if grep -q 'fmask=0022,dmask=0022' /etc/fstab; then
  backup="/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"
  cp -a /etc/fstab "$backup"
  sed -i 's/fmask=0022,dmask=0022/fmask=0077,dmask=0077/' /etc/fstab
  log "Restricted ESP permissions in /etc/fstab (backup: $backup)"
  if mountpoint -q /boot; then
    mount -o remount /boot || warn "Could not remount /boot; reboot to apply."
  fi
else
  log "ESP permissions already restricted, or pattern not found."
fi

# --- maintenance timers -----------------------------------------------------
systemctl enable --now paccache.timer
systemctl enable --now fwupd-refresh.timer 2>/dev/null || \
  warn "fwupd-refresh.timer unavailable; install fwupd first."

# --- explicit package reasons ----------------------------------------------
if pacman -Q gnupg >/dev/null 2>&1; then
  pacman -D --asexplicit gnupg >/dev/null
  log "Marked gnupg as explicitly installed."
fi

# --- tooling ----------------------------------------------------------------
# checkupdates (pacman-contrib) needs fakeroot when run as a normal user.
pacman -S --needed --noconfirm fakeroot

log "System fixes applied."
