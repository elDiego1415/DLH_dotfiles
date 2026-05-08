#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
adopt=false

if [[ "${1:-}" == "--adopt" ]]; then
  adopt=true
elif [[ "${1:-}" != "" ]]; then
  echo "Uso: $0 [--adopt]" >&2
  exit 2
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: instala GNU Stow antes de continuar." >&2
  echo "Arch Linux: sudo pacman -S stow" >&2
  exit 1
fi

if $adopt; then
  stow --adopt -d "$repo_dir" -t "$HOME" home
else
  stow -d "$repo_dir" -t "$HOME" home
fi

echo "Dotfiles enlazados desde $repo_dir/home"
