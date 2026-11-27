#!/usr/bin/env bash
# Monthly maintenance report. Safe to run manually or from the user timer.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/maintenance"
mkdir -p "$cache_dir"
report="$cache_dir/last-check.txt"

updates="$(checkupdates 2>&1 || true)"
if [[ -z "$updates" ]]; then
  update_count=0
  updates="none"
else
  update_count="$(printf '%s\n' "$updates" | grep -c . || true)"
fi

orphans="$(pacman -Qtdq 2>/dev/null || true)"
failed="$(systemctl --failed --no-legend 2>/dev/null || true)"

{
  printf 'Maintenance check — %s\n\n' "$(date -Iseconds)"
  printf '## Updates (%s)\n%s\n\n' "$update_count" "$updates"
  printf '## Orphan packages\n%s\n\n' "${orphans:-none}"
  printf '## Failed units\n%s\n\n' "${failed:-none}"
  printf '## Disk\n'
  df -h / /boot
  printf '\n## Firmware\n'
  fwupdmgr get-updates 2>&1 | tail -20 || true
  printf '\n## Repo status\n'
  git -C "$REPO_DIR" status --short 2>&1 || true
  printf '\n## niri config\n'
  niri validate 2>&1 | tail -2 || true
} > "$report" 2>&1

if command -v notify-send >/dev/null 2>&1; then
  notify-send -a maintenance "Monthly maintenance" \
    "$update_count updates, ${failed:+failed units, }report: $report"
fi

printf 'Wrote %s\n' "$report"
