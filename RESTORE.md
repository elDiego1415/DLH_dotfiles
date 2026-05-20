# Restore

Guia rapida para volver a este entorno despues de reinstalar Linux.

## Clonar dotfiles

```bash
git clone git@github.com:elDiego1415/DLH_dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo pacman -S --needed git stow
./install.sh
```

`install.sh` enlaza `home/` en `$HOME` usando GNU Stow.

## Paquetes

Paquetes explicitos actuales:

```bash
sudo pacman -S --needed - < packages/pacman-explicit.txt
```

Paquetes AUR actuales:

```bash
yay -S --needed - < packages/aur.txt
```

No hay Flatpaks instalados en el momento de crear este backup.

## Notas antes de borrar Linux

- El repo de dotfiles esta pensado para restaurar shell, Hyprland, Waybar, Kitty, scripts, fondos y herramientas CLI.
- No guarda claves privadas, tokens, perfiles de navegador, partidas, configuraciones completas de Steam ni datos personales.
- Guarda aparte `~/.ssh`, `~/.gnupg`, documentos, proyectos, notas y cualquier dato de aplicaciones que quieras conservar.
- En este sistema habia un enlace roto antiguo en `~/.config/hypr/hyprland_save.conf`; la configuracion versionada activa es `hyprland.lua`.
