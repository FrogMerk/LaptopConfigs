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

backup_file() {
  local file="$1"
  [[ -e "$file" ]] || return 0
  cp -a "$file" "$file.bak.$(date +%Y%m%d-%H%M%S)"
}

# --- ESP permissions --------------------------------------------------------
# systemd-boot warns when the ESP and its random-seed file are world-readable.
if grep -q 'fmask=0022,dmask=0022' /etc/fstab; then
  backup_file /etc/fstab
  sed -i 's/fmask=0022,dmask=0022/fmask=0077,dmask=0077/' /etc/fstab
  log "Restricted ESP permissions in /etc/fstab."
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

# --- firewall ---------------------------------------------------------------
pacman -S --needed --noconfirm nftables
pacman -D --asexplicit nftables >/dev/null 2>&1 || true
backup_file /etc/nftables.conf
install -Dm644 "$REPO_DIR/etc/nftables.conf" /etc/nftables.conf
nft -c -f /etc/nftables.conf
systemctl enable nftables.service
systemctl restart nftables.service
log "nftables enabled with default-deny inbound rules."

# --- reflector --------------------------------------------------------------
if ! pacman -Q reflector >/dev/null 2>&1; then
  pacman -S --needed --noconfirm reflector
fi
backup_file /etc/xdg/reflector/reflector.conf
install -Dm644 "$REPO_DIR/etc/xdg/reflector/reflector.conf" \
  /etc/xdg/reflector/reflector.conf
systemctl enable reflector.timer
backup_file /etc/pacman.d/mirrorlist
if systemctl start reflector.service; then
  log "Reflector refreshed the mirrorlist (Australia, HTTPS, 10 newest)."
else
  warn "Reflector refresh failed; restoring the previous mirrorlist."
  latest_backup="$(ls -1t /etc/pacman.d/mirrorlist.bak.* 2>/dev/null | head -1 || true)"
  [[ -n "$latest_backup" ]] && cp -a "$latest_backup" /etc/pacman.d/mirrorlist
fi

# --- explicit package reasons ----------------------------------------------
if pacman -Q gnupg >/dev/null 2>&1; then
  pacman -D --asexplicit gnupg >/dev/null
  log "Marked gnupg as explicitly installed."
fi

# --- tooling ----------------------------------------------------------------
# checkupdates (pacman-contrib) needs fakeroot when run as a normal user.
pacman -S --needed --noconfirm fakeroot

log "System fixes applied."
