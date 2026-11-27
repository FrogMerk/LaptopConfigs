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

parent_is_symlink() {
  local rel="$1" path="$HOME" part last
  local -a parts
  IFS='/' read -r -a parts <<< "$rel"
  last=$(( ${#parts[@]} - 1 ))
  for part in "${parts[@]:0:last}"; do
    path="$path/$part"
    [[ -L "$path" ]] && return 0
  done
  return 1
}

for pkg in "${packages[@]}"; do
  pkgdir="$DOTFILES/$pkg"
  [[ -d "$pkgdir" ]] || {
    echo "Unknown dotfiles package: $pkg" >&2
    exit 1
  }

  # Back up existing real files that stow would otherwise refuse to replace.
  # Skip anything under an already-symlinked directory (managed by stow).
  while IFS= read -r -d '' src; do
    rel="${src#"$pkgdir"/}"
    parent_is_symlink "$rel" && continue
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" && ! -d "$target" ]]; then
      mkdir -p "$backup/$(dirname -- "$rel")"
      mv -- "$target" "$backup/$rel"
      echo "Backed up ~/$rel -> $backup/$rel"
    fi
  done < <(find "$pkgdir" \( -type f -o -type l \) -print0)
done

cd "$DOTFILES"
stow --verbose=1 --restow --target="$HOME" "${packages[@]}"
