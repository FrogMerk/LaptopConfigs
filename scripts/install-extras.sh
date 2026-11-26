#!/usr/bin/env bash
# Install the optional packages from packages/extras.txt.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"

mapfile -t PKGS < <(grep -vE '^[[:space:]]*(#|$)' "$REPO_DIR/packages/extras.txt")
[[ ${#PKGS[@]} -gt 0 ]] || { echo "Nothing to install."; exit 0; }

echo "Installing: ${PKGS[*]}"
sudo pacman -S --needed "${PKGS[@]}"
