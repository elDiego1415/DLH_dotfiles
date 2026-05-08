# DLH dotfiles

Configuracion personal para Hyprland, Waybar, Kitty, Zsh y herramientas de terminal.

## Estructura

- `home/`: archivos que se enlazan directamente en `$HOME` con GNU Stow.
- `home/.config/`: configuraciones de aplicaciones.
- `home/scripts/`: scripts personales usados por el entorno.
- `install.sh`: instalador simple basado en Stow.

## Instalacion

```bash
git clone git@github.com:elDiego1415/DLH_dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

El instalador ejecuta:

```bash
stow -d ~/dotfiles -t ~ home
```

Si algun archivo ya existe en tu `$HOME`, Stow avisara del conflicto. En ese caso, mueve el archivo antiguo o comparalo antes de volver a ejecutar el instalador.

## Actualizar el repo

Despues de cambiar una configuracion en tu sistema, copia el archivo actualizado al repo y revisa el diff:

```bash
cp ~/.config/waybar/config ~/dotfiles/home/.config/waybar/config
cd ~/dotfiles
git diff
git status
```

## Incluye

- Shell: `.zshrc`, `.bashrc`, `.bash_profile`, `.gitconfig`
- Entorno grafico: `hypr`, `waybar`, `mako`, `wofi`, `gtk-3.0`, `xsettingsd`
- Terminal y CLI: `kitty`, `nvim`, `btop`, `fastfetch`, `yazi`, `lsd`, `lazygit`, `cava`
- Otros: `quickshell`, `waypaper`, `mpv`, scripts personales
