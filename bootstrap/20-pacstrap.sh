#!/usr/bin/env bash
# Mount the new filesystems and pacstrap the base + desktop packages.
set -Eeuo pipefail
source "$(dirname -- "$0")/lib.sh"

require_root
load_config
require_blockdev "$DISK"

ESP=$(part 1)
ROOT=$(part 2)
require_blockdev "$ESP"
require_blockdev "$ROOT"

log "Mounting filesystems"
umount -R /mnt 2>/dev/null || true
mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$ESP" /mnt/boot

if [[ "$SWAP_SIZE" != "0" ]]; then
  swapon "$(part 3)"
fi

mapfile -t PKGS < <(
  cat "$REPO_DIR/packages/base.txt" "$REPO_DIR/packages/desktop.txt" \
    | grep -vE '^[[:space:]]*(#|$)'
)

log "Installing ${#PKGS[@]} packages"
pacstrap -K /mnt "${PKGS[@]}"

log "Writing fstab"
genfstab -U /mnt >> /mnt/etc/fstab

log "Copying repo into the new system"
REPO_NAME="$(basename "$REPO_DIR")"
mkdir -p "/mnt/root/$REPO_NAME"
cp -a "$REPO_DIR/." "/mnt/root/$REPO_NAME/"

log "Base install complete."
cat <<EOF

Next:
  arch-chroot /mnt /root/$REPO_NAME/bootstrap/30-chroot.sh

EOF
