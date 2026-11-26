#!/usr/bin/env bash
# Shared helpers for the T480 Arch bootstrap scripts.
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_DIR/bootstrap"
CONFIG_FILE="${CONFIG_FILE:-$BOOTSTRAP_DIR/config.env}"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

on_error() {
  local exit_code=$?
  printf '\n\033[1;31m[x]\033[0m Failed at %s:%s (exit %s)\n' \
    "${BASH_SOURCE[0]}" "${BASH_LINENO[0]}" "$exit_code" >&2
  exit "$exit_code"
}
trap on_error ERR

require_root() {
  [[ $EUID -eq 0 ]] || die "Run as root (sudo)."
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required tool: $1"
}

load_config() {
  [[ -f "$CONFIG_FILE" ]] || die \
    "Missing $CONFIG_FILE. Copy bootstrap/config.env.example to bootstrap/config.env and edit it."
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  : "${DISK:?DISK must be set in config.env}"
  : "${HOSTNAME:?HOSTNAME must be set in config.env}"
  : "${USERNAME:?USERNAME must be set in config.env}"
  : "${TIMEZONE:?TIMEZONE must be set in config.env}"
  : "${LOCALE:?LOCALE must be set in config.env}"
  : "${KEYMAP:?KEYMAP must be set in config.env}"
  : "${XKB_LAYOUT:?XKB_LAYOUT must be set in config.env}"
  : "${ESP_SIZE:?ESP_SIZE must be set in config.env}"
  : "${SWAP_SIZE:?SWAP_SIZE must be set in config.env}"
  : "${KERNELS:?KERNELS must be set in config.env}"
}

# part 1 -> /dev/nvme0n1p1, part 2 -> /dev/sda2, etc.
part() {
  local n=$1
  if [[ "$DISK" =~ (nvme|mmcblk|loop) ]]; then
    printf '%sp%s\n' "$DISK" "$n"
  else
    printf '%s%s\n' "$DISK" "$n"
  fi
}

require_blockdev() {
  [[ -b "$1" ]] || die "Not a block device: $1"
}

# entry_name linux -> arch, entry_name linux-lts -> arch-lts
entry_name() {
  case "$1" in
    linux)     printf 'arch\n' ;;
    linux-lts) printf 'arch-lts\n' ;;
    *)         printf '%s\n' "$1" ;;
  esac
}
