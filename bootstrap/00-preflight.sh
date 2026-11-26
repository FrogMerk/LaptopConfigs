#!/usr/bin/env bash
# Verify the live environment before touching any disk.
set -Eeuo pipefail
source "$(dirname -- "$0")/lib.sh"

require_root
log "Preflight checks"

[[ -d /sys/firmware/efi ]] || die "Not booted in UEFI mode. Reboot the ISO in UEFI mode."
log "UEFI: yes"

if ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
  log "Network: online"
else
  warn "No internet. In the live ISO run: iwctl"
  warn "  station wlan0 scan && station wlan0 connect <SSID>"
fi

timedatectl set-ntp true 2>/dev/null || warn "Could not enable NTP; check the clock manually."

for c in sgdisk partprobe mkfs.ext4 mkfs.fat wipefs pacstrap arch-chroot; do
  need_cmd "$c"
done

if [[ ! -f "$CONFIG_FILE" ]]; then
  warn "No bootstrap/config.env yet. Create it first:"
  warn "  cp bootstrap/config.env.example bootstrap/config.env"
  warn "  \$EDITOR bootstrap/config.env"
  exit 1
fi

load_config
require_blockdev "$DISK"

log "Disks:"
lsblk -d -o NAME,SIZE,MODEL,TRAN

log "Target: $DISK"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS "$DISK" || true

if [[ "$SWAP_SIZE" == "0" ]]; then
  log "Swap: zram only (no hibernate)"
else
  log "Swap: ${SWAP_SIZE} partition (hibernate possible if >= RAM)"
fi

warn "Everything on $DISK will be destroyed by 10-partition.sh."
