#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
adopt=false
check=false

while (($#)); do
  case "$1" in
    --adopt)
      if $adopt; then
        echo "Error: --adopt solo puede indicarse una vez." >&2
        exit 2
      fi
      adopt=true
      ;;
    --check)
      if $check; then
        echo "Error: --check solo puede indicarse una vez." >&2
        exit 2
      fi
      check=true
      ;;
    *)
      echo "Uso: $0 [--check] [--adopt]" >&2
      exit 2
      ;;
  esac
  shift
done

if $check && $adopt; then
  echo "Error: --check y --adopt no se pueden usar juntos." >&2
  exit 2
fi

if [[ ! -d "$repo_dir/home" ]]; then
  echo "Error: no se encuentra el directorio de configuración: $repo_dir/home" >&2
  exit 1
fi

if [[ ! -d "$HOME" || ! -w "$HOME" ]]; then
  echo "Error: el directorio HOME no existe o no permite escritura: $HOME" >&2
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: instala GNU Stow antes de continuar." >&2
  echo "Arch Linux: sudo pacman -S stow" >&2
  exit 1
fi

if $check; then
  echo "Comprobando enlaces de $repo_dir/home en $HOME (simulación; no se cambiarán archivos)..."
  if stow --simulate --verbose -d "$repo_dir" -t "$HOME" home; then
    echo "Comprobación completada: Stow no ha encontrado conflictos."
  else
    status=$?
    echo "Comprobación fallida: revisa los conflictos indicados por Stow. No se han cambiado archivos." >&2
    exit "$status"
  fi
  exit 0
fi

if $adopt; then
  echo "Aviso: --adopt puede mover archivos existentes al repositorio de dotfiles y modificar su contenido." >&2
  stow --adopt -d "$repo_dir" -t "$HOME" home
else
  stow -d "$repo_dir" -t "$HOME" home
fi

echo "Dotfiles enlazados desde $repo_dir/home"
