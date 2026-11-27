#!/usr/bin/env bash
# Build a small user icon theme on top of Papirus-Dark that replaces the blue
# folder icons with Papirus' green variants. No root and no copied megabytes:
# the theme is a set of symlinks plus an index.theme that inherits Papirus-Dark.
set -Eeuo pipefail

src="${PAPIRUS_SRC:-/usr/share/icons/Papirus-Dark}"
name="Papirus-Everforest"
dest="${XDG_DATA_HOME:-$HOME/.local/share}/icons/$name"

if [[ ! -d "$src/48x48/places" ]]; then
  echo "Papirus-Dark not found at $src (install papirus-icon-theme)." >&2
  exit 1
fi

rm -rf "$dest"
mkdir -p "$dest"

dirs=()
for size in 8x8 16x16 16x16@2x 18x18 18x18@2x 22x22 22x22@2x 24x24 24x24@2x \
            32x32 32x32@2x 48x48 48x48@2x 64x64 64x64@2x 96x96 96x96@2x \
            128x128 128x128@2x; do
  places="$src/$size/places"
  [[ -d "$places" ]] || continue
  mkdir -p "$dest/$size/places"
  dirs+=("$size/places")

  while IFS= read -r -d '' icon; do
    base="$(basename "$icon")"
    [[ "$base" == folder-green* ]] && continue
    [[ "$base" == folder.svg || "$base" == folder-*.svg ]] || continue

    green=
    case "$base" in
      folder.svg) green="folder-green.svg" ;;
      folder-open.svg) green="folder-green-open.svg" ;;
      folder-*.svg) green="folder-green-${base#folder-}" ;;
    esac

    [[ -n "$green" && -e "$places/$green" ]] || continue
    ln -s "$places/$green" "$dest/$size/places/$base"
  done < <(find "$places" -maxdepth 1 -name 'folder*.svg' -print0)

  # XDG user directories use their own names for the home and desktop icons.
  if [[ -e "$places/user-home.svg" && -e "$places/folder-green.svg" ]]; then
    ln -s "$places/folder-green.svg" "$dest/$size/places/user-home.svg"
  fi
  if [[ -e "$places/folder-green-desktop.svg" ]]; then
    ln -s "$places/folder-green-desktop.svg" "$dest/$size/places/user-desktop.svg"
  fi
done

plain=()
scaled=()
for dir in "${dirs[@]}"; do
  if [[ "$dir" == *"@2x/places" ]]; then
    scaled+=("$dir")
  else
    plain+=("$dir")
  fi
done

{
  echo "[Icon Theme]"
  echo "Name=$name"
  echo "Comment=Papirus-Dark with Everforest green folders"
  echo "Inherits=Papirus-Dark"
  echo "Example=folder"
  echo "FollowsColorScheme=true"
  printf 'Directories='
  (IFS=,; printf '%s' "${plain[*]}")
  echo
  if [[ ${#scaled[@]} -gt 0 ]]; then
    printf 'ScaledDirectories='
    (IFS=,; printf '%s' "${scaled[*]}")
    echo
  fi
  for dir in "${dirs[@]}"; do
    base="${dir%/places}"
    scale=1
    size="${base%@2x}"
    size="${size%%x*}"
    [[ "$base" == *"@2x" ]] && scale=2
    echo
    echo "[$dir]"
    echo "Context=Places"
    echo "Size=$size"
    [[ "$scale" -eq 2 ]] && echo "Scale=2"
    echo "Type=Fixed"
  done
} > "$dest/index.theme"

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t "$dest" >/dev/null 2>&1 || true
fi

echo "wrote $dest"
