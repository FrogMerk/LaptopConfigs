#!/usr/bin/env bash
# Verify the latest restic snapshot by restoring a sample of /etc and $HOME.
set -Eeuo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
  die "Run as root: sudo $0"
fi

[[ -f /etc/restic/env ]] || die "No restic environment at /etc/restic/env; run install-backups.sh first."

set -a
# shellcheck disable=SC1091
. /etc/restic/env
set +a
export RESTIC_CACHE_DIR=/var/cache/restic

tmp="$(mktemp -d "${TMPDIR:-/tmp}/restic-restore.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

log "Checking repository integrity (1% data sample)"
restic check --read-data-subset=1%

log "Restoring sample files from the latest snapshot"
restic restore latest --target "$tmp" \
  --include /etc/hostname \
  --include /etc/os-release \
  --include /home/eddo/LaptopConfigs/README.md

for file in /etc/hostname /etc/os-release; do
  [[ -f "$tmp$file" ]] || die "Missing restored file: $file"
  cmp -s "$file" "$tmp$file" || die "Restored file differs: $file"
done

[[ -s "$tmp/home/eddo/LaptopConfigs/README.md" ]] ||
  die "Missing restored home file: /home/eddo/LaptopConfigs/README.md"

log "Restore drill passed"
