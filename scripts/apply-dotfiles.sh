#!/usr/bin/env bash
# Stow dotfiles into $HOME, backing up anything already there.
set -Eeuo pipefail
REPO_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
DOTFILES="$REPO_DIR/dotfiles"

command -v stow >/dev/null 2>&1 || {
  echo "stow is not installed: sudo pacman -S stow" >&2
  exit 1
}

packages=("$@")
if [[ ${#packages[@]} -eq 0 ]]; then
  mapfile -t packages < <(
    find "$DOTFILES" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
  )
fi

backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
for pkg in "${packages[@]}"; do
  [[ -d "$DOTFILES/$pkg" ]] || {
    echo "Unknown dotfiles package: $pkg" >&2
    exit 1
  }
  target="$HOME/.config/$pkg"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$backup/.config"
    mv "$target" "$backup/.config/$pkg"
    echo "Backed up ~/.config/$pkg -> $backup/.config/$pkg"
  fi
done

cd "$DOTFILES"
stow --verbose=1 --target="$HOME" "${packages[@]}"
