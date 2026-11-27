#!/usr/bin/env bash
# First-boot setup: stow dotfiles and report the state of the machine.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your user, not root." >&2
  exit 1
fi

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }

log "Applying dotfiles"
"$REPO_DIR/scripts/apply-dotfiles.sh"

mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"

if command -v niri >/dev/null 2>&1; then
  log "Validating niri config"
  if ! niri validate; then
    warn "niri validate failed. Fix the config before logging out."
  fi
fi

if command -v fwupdmgr >/dev/null 2>&1; then
  log "Enabling firmware refresh timer"
  sudo systemctl enable --now fwupd-refresh.timer 2>/dev/null || true
fi

log "Service status"
systemctl is-enabled greetd tlp thermald NetworkManager bluetooth 2>/dev/null || true

cat <<'EOF'

Post-install checklist
  1. Firmware (Thunderbolt!):  fwupdmgr get-updates && sudo fwupdmgr update
  2. S3 suspend:               cat /sys/power/mem_sleep   # expect [deep]
  3. Charge thresholds:        sudo tlp-stat -b
  4. Optional extras:          ./scripts/install-extras.sh

EOF
