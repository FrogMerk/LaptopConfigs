#!/usr/bin/env bash
# Install and initialise restic backups for $HOME and /etc.
# Usage: sudo ./scripts/install-backups.sh [repository-path]
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
repo="${1:-/var/backups/restic}"
repo="${repo%/}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
  die "Run as root: sudo $0 [repository-path]"
fi

case "$repo" in
  /home/eddo/*|/etc/*)
    die "Repository must be outside the backed-up paths (/home/eddo and /etc)."
    ;;
esac

# Avoid silently writing an external-target backup into the root filesystem
# when the disk was not mounted.
case "$repo" in
  /mnt/*|/media/*|/run/media/*)
    parent="$(dirname "$repo")"
    mount_target="$(findmnt -n -o TARGET -T "$parent" 2>/dev/null || true)"
    if [[ -z "$mount_target" || "$mount_target" == "/" ]]; then
      die "Mount the external disk before using $repo."
    fi
    ;;
esac

pacman -S --needed --noconfirm restic
command -v openssl >/dev/null 2>&1 || die "openssl is required for the repository password."

if [[ -f /etc/restic/env ]] &&
   ! grep -Fqx "RESTIC_REPOSITORY=$repo" /etc/restic/env; then
  warn "Changing the restic repository; existing snapshots are not migrated automatically."
fi

install -d -m 700 /etc/restic
install -d -m 700 /var/cache/restic
install -d -m 700 "$repo"

if [[ ! -s /etc/restic/password ]]; then
  (umask 077; openssl rand -base64 32 > /etc/restic/password)
  log "Generated a new repository password."
fi
chmod 600 /etc/restic/password

install -Dm600 "$REPO_DIR/etc/restic/include" /etc/restic/include
install -Dm600 "$REPO_DIR/etc/restic/exclude" /etc/restic/exclude

cat > /etc/restic/env <<EOF
RESTIC_REPOSITORY=$repo
RESTIC_PASSWORD_FILE=/etc/restic/password
EOF
chmod 600 /etc/restic/env

install -Dm644 "$REPO_DIR/etc/systemd/system/restic-backup.service" \
  /etc/systemd/system/restic-backup.service
install -Dm644 "$REPO_DIR/etc/systemd/system/restic-backup.timer" \
  /etc/systemd/system/restic-backup.timer
systemctl daemon-reload

set -a
# shellcheck disable=SC1091
. /etc/restic/env
set +a
export RESTIC_CACHE_DIR=/var/cache/restic

if [[ ! -f "$repo/config" ]]; then
  restic init
  log "Initialised restic repository at $repo."
else
  log "Using existing restic repository at $repo."
fi

systemctl enable --now restic-backup.timer
systemctl start restic-backup.service
log "First backup complete."

if [[ "$repo" == /var/backups/* ]]; then
  warn "Repository is on the internal disk. Copy it to an external disk or remote for disk-failure protection."
fi

cat <<EOF

Repository: $repo
Password:   /etc/restic/password (root-only)

Copy that password into NordPass now. Without it the repository cannot be
restored. Then verify the snapshot:

  sudo $REPO_DIR/scripts/test-backup.sh

EOF

log "Running restore drill"
"$REPO_DIR/scripts/test-backup.sh"
