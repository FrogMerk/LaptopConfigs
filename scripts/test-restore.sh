#!/usr/bin/env bash
# Restore the committed repo into a temporary HOME and validate the result.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/laptopconfigs-restore.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ -n "$(git -C "$REPO_DIR" status --porcelain)" ]]; then
  printf '\033[1;33m[!]\033[0m Working tree is dirty; testing committed HEAD only.\n' >&2
fi

log "Archiving committed tree"
mkdir -p "$tmp/repo"
git -C "$REPO_DIR" archive HEAD | tar -x -C "$tmp/repo"
git -C "$REPO_DIR" fsck --no-progress >/dev/null

log "Stowing into a temporary HOME"
HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/home/.config" \
  "$tmp/repo/scripts/apply-dotfiles.sh" >/dev/null

log "Checking restored links"
links=(
  .config/niri
  .config/alacritty
  .config/waybar
  .config/fuzzel
  .config/mako
  .config/swaylock
  .config/starship.toml
  .config/gtk-3.0
  .config/gtk-4.0
  .config/mimeapps.list
  .config/systemd/user/maintenance-check.timer
  .zshrc
  .local/bin/screenshot-region
)
for link in "${links[@]}"; do
  [[ -e "$tmp/home/$link" ]] || fail "missing restored path: $link"
done

log "Validating niri config"
HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/home/.config" \
  niri validate 2>&1 | tail -1

log "Validating config formats"
python3 - "$tmp/repo" <<'PY'
import json
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
tomllib.loads((root / "dotfiles/alacritty/.config/alacritty/alacritty.toml").read_text())
tomllib.loads((root / "dotfiles/starship/.config/starship.toml").read_text())
json.loads((root / "dotfiles/waybar/.config/waybar/config.jsonc").read_text())
print("TOML and JSON configs OK")
PY

XDG_CONFIG_HOME="$tmp/home/.config" fuzzel --check-config >/dev/null
echo "fuzzel config OK"

log "Checking nftables syntax"
if command -v unshare >/dev/null && \
   unshare -Urn nft -c -f "$tmp/repo/etc/nftables.conf" 2>/dev/null; then
  echo "nftables config OK"
else
  echo "nftables check skipped (user namespaces unavailable)"
fi

log "Regenerating wallpaper at test size"
python3 "$tmp/repo/scripts/make-wallpaper.py" \
  --width 320 --height 180 --output "$tmp/wall.png" >/dev/null
[[ -s "$tmp/wall.png" ]] || fail "wallpaper was not generated"

log "Checking shell syntax"
bash -n "$tmp"/repo/bootstrap/*.sh "$tmp"/repo/scripts/*.sh "$tmp"/repo/post-install.sh

log "Restore test passed"
