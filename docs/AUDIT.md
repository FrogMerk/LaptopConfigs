# System audit

Snapshot from 2026-11-27, after the first boot and the Everforest/niri setup.

## Snapshot

| Item | Result |
|---|---|
| Packages | 596 total, 65 explicit |
| Orphans / foreign packages | none |
| Manifest drift | none except `gnupg` was installed as a dependency |
| Failed units | none (system or user) |
| Disk | 6.4 G used of 233 G; `/boot` 90 M of 1 G |
| Pacman cache | 1.9 G, 1236 files |
| Journal | 16 M |
| Boot | 34.6 s total: 20.9 s firmware, 3.1 s loader, 5.2 s initrd, 4.4 s userspace |
| Suspend | `[deep]` |
| zram | 3.8 G, zstd, active |
| Batteries | BAT0 80% (health 81%), BAT1 79% (health 100%) |
| Pending upgrades | 0 (from current sync DB) |
| Firmware | EC update offered by fwupd is Windows-only |

## Findings

1. **ESP is world-readable.** `/boot` and `/boot/loader/random-seed` were mode
   755, so systemd-boot warns about an insecure random seed. The fstab entry is
   now `fmask=0077,dmask=0077`; the running kernel kept reporting the old mask
   after remount, so verify with `findmnt /boot` after the next reboot.
2. **Maintenance timers are disabled.** `paccache.timer`,
   `fwupd-refresh.timer` and `reflector.timer` are all disabled.
3. **No inbound firewall.** `nftables` is installed but inactive. Only
   localhost and DHCPv6 are listening, so the exposure is low.
4. **`checkupdates` fails** because `fakeroot` is missing.
5. **`gnupg` is a dependency**, not an explicitly installed package.
6. **GNOME portal stack + Nautilus** are present. Kept intentionally because
   Nautilus is the file manager and the GNOME portal provides screencasting.
7. **`getty@tty1` is enabled but inactive**; greetd owns tty1. Harmless.
8. **Reflector** is installed but its timer is disabled and the config still
   uses the default worldwide mirror selection.
9. **Journal noise** from TDX, `wpa_supplicant` multicast and the Bluetooth
   ACPI probe is hardware/driver chatter, not a fault.

## Applied by `scripts/apply-system-fixes.sh`

- Restrict ESP permissions in fstab (reboot if the live mount keeps the old masks)
- Enable `paccache.timer` and `fwupd-refresh.timer`
- Install and enable the default-deny `nftables` ruleset
- Configure reflector for Australia and enable `reflector.timer`
- Mark `gnupg` explicit
- Install `fakeroot` so `checkupdates` works

## Recommended next

- Test a restore of `LaptopConfigs` on a scratch user or VM.
- Set up GPG for commit/email signing if wanted; SSH auth already works.
- Establish a monthly `pacman -Syu` and `checkupdates` routine.
- Keep the EC firmware update in mind, but it is Windows-only.
