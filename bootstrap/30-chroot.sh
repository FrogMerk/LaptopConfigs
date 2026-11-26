#!/usr/bin/env bash
# Configure the new system from inside arch-chroot.
set -Eeuo pipefail
source "$(dirname -- "$0")/lib.sh"

require_root

# Refuse to run on the live ISO: there / is an overlay, in the new system it is ext4.
if [[ "$(findmnt -n -o FSTYPE / 2>/dev/null)" == "overlay" ]]; then
  die "Run this inside the new system: arch-chroot /mnt /root/t480-arch/bootstrap/30-chroot.sh"
fi

load_config

log "Configuring $HOSTNAME"

# --- clock and locale -------------------------------------------------------
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

sed -i "s/^#[[:space:]]*\(${LOCALE}\)/\1/" /etc/locale.gen
locale-gen
printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf
printf 'KEYMAP=%s\n' "$KEYMAP" > /etc/vconsole.conf

# --- hostname ---------------------------------------------------------------
printf '%s\n' "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# --- users ------------------------------------------------------------------
log "Set the root password"
passwd

if ! id "$USERNAME" >/dev/null 2>&1; then
  useradd -m -G wheel -s /bin/bash "$USERNAME"
else
  usermod -aG wheel "$USERNAME"
fi
usermod -aG video "$USERNAME"
log "Set the password for $USERNAME"
passwd "$USERNAME"

install -d -m 0755 /etc/sudoers.d
printf '%%wheel ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/10-wheel
chmod 0440 /etc/sudoers.d/10-wheel
visudo -cf /etc/sudoers.d/10-wheel

# --- services ---------------------------------------------------------------
# Safety net: the greetd package normally creates this via sysusers.
id greeter >/dev/null 2>&1 || \
  useradd --system --no-create-home --home-dir /var/lib/greetd --shell /usr/bin/nologin greeter

systemctl enable NetworkManager.service
systemctl enable greetd.service
systemctl enable tlp.service
systemctl enable thermald.service
systemctl enable bluetooth.service
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd.service
systemctl enable systemd-boot-update.service 2>/dev/null || true

# --- /etc overlays ----------------------------------------------------------
log "Installing /etc overlays from the repo"
while IFS= read -r -d '' f; do
  rel=${f#"$REPO_DIR/etc/"}
  install -Dm644 "$f" "/etc/$rel"
done < <(find "$REPO_DIR/etc" -type f -print0)

# Make config.env authoritative for the initial niri keyboard layout.
NIRI_CONF="$REPO_DIR/dotfiles/niri/.config/niri/config.kdl"
if [[ -f "$NIRI_CONF" ]]; then
  sed -i "s/layout \"[^\"]*\"/layout \"$XKB_LAYOUT\"/" "$NIRI_CONF"
  log "niri keyboard layout: $XKB_LAYOUT"
fi

# --- bootloader -------------------------------------------------------------
[[ -d /sys/firmware/efi ]] || die "EFI variables not visible. Run bootctl from the live ISO instead."
findmnt -n /boot >/dev/null || die "/boot is not a mountpoint; mount the ESP first."

ROOT_UUID=$(findmnt -n -o UUID /)
[[ -n "$ROOT_UUID" ]] || die "Could not determine the root filesystem UUID."

log "Installing systemd-boot"
bootctl --esp-path=/boot install

DEFAULT_ENTRY=$(entry_name "${KERNELS%% *}")

for k in $KERNELS; do
  entry=$(entry_name "$k")
  {
    printf 'title   Arch Linux (%s)\n' "$k"
    printf 'linux   /vmlinuz-%s\n' "$k"
    if [[ -f /boot/intel-ucode.img ]]; then
      printf 'initrd  /intel-ucode.img\n'
    fi
    printf 'initrd  /initramfs-%s.img\n' "$k"
    printf 'options root=UUID=%s rw quiet mem_sleep_default=deep\n' "$ROOT_UUID"
  } > "/boot/loader/entries/$entry.conf"
  log "Wrote /boot/loader/entries/$entry.conf"
done

cat > /boot/loader/loader.conf <<EOF
default $DEFAULT_ENTRY
timeout 4
console-mode max
EOF

log "Rebuilding initramfs"
mkinitcpio -P

log "Done."
cat <<'EOF'

Next:
  exit
  umount -R /mnt
  reboot

EOF
