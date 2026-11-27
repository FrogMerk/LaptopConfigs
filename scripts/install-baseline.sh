#!/usr/bin/env bash
# Install packages/desktop.txt on an existing system and set Zsh as the login
# shell. Safe to re-run: pacman skips packages that are already installed.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

mapfile -t PKGS < <(grep -vE '^[[:space:]]*(#|$)' "$REPO_DIR/packages/desktop.txt")
[[ ${#PKGS[@]} -gt 0 ]] || { echo "Nothing to install."; exit 0; }

echo "Installing desktop packages: ${#PKGS[@]} entries"
pacman -S --needed --noconfirm "${PKGS[@]}"

target_user="${SUDO_USER:-}"
if [[ -n "$target_user" && "$target_user" != "root" ]]; then
  if command -v zsh >/dev/null 2>&1; then
    chsh -s /usr/bin/zsh "$target_user"
    echo "Login shell for $target_user set to /usr/bin/zsh"
    echo "Open a new terminal (or log out and back in) to use it."
  fi
fi
