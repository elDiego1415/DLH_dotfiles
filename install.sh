#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: instala GNU Stow antes de continuar." >&2
  echo "Arch Linux: sudo pacman -S stow" >&2
  exit 1
fi

stow -d "$repo_dir" -t "$HOME" home

echo "Dotfiles enlazados desde $repo_dir/home"
