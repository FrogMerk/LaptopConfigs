#!/usr/bin/env bash
# Partition and format the target disk. Destructive.
set -Eeuo pipefail
source "$(dirname -- "$0")/lib.sh"

require_root
load_config
require_blockdev "$DISK"

log "This will ERASE $DISK and create:"
printf '  %-14s %-10s %s\n' "$(part 1)" "$ESP_SIZE" "EFI (FAT32)"
if [[ "$SWAP_SIZE" == "0" ]]; then
  printf '  %-14s %-10s %s\n' "$(part 2)" "rest" "ext4 root"
else
  printf '  %-14s %-10s %s\n' "$(part 2)" "rest-$SWAP_SIZE" "ext4 root"
  printf '  %-14s %-10s %s\n' "$(part 3)" "$SWAP_SIZE" "swap"
fi

printf '\nType the device path to confirm (%s): ' "$DISK"
read -r confirm
[[ "$confirm" == "$DISK" ]] || die "Aborted; nothing was changed."

# Make sure nothing on the target is mounted.
swapoff -a || true
umount -R /mnt 2>/dev/null || true

log "Wiping signatures on $DISK"
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"

log "Creating GPT layout"
if [[ "$SWAP_SIZE" == "0" ]]; then
  sgdisk -n 1:0:+"$ESP_SIZE" -t 1:ef00 \
         -n 2:0:0            -t 2:8300 \
         "$DISK"
else
  sgdisk -n 1:0:+"$ESP_SIZE" -t 1:ef00 \
         -n 2:0:-"$SWAP_SIZE" -t 2:8300 \
         -n 3:0:0             -t 3:8200 \
         "$DISK"
fi

partprobe "$DISK"
udevadm settle

ESP=$(part 1)
ROOT=$(part 2)
require_blockdev "$ESP"
require_blockdev "$ROOT"

log "Formatting"
mkfs.fat -F32 -n ESP "$ESP"
mkfs.ext4 -L arch-root "$ROOT"

if [[ "$SWAP_SIZE" != "0" ]]; then
  SWAP=$(part 3)
  require_blockdev "$SWAP"
  mkswap -L swap "$SWAP"
fi

log "Done:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTTYPENAME "$DISK"
