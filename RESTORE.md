# Restore

Guia rapida para volver a este entorno despues de reinstalar Linux.

## Orden recomendado

```bash
git clone git@github.com:elDiego1415/DLH_dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo pacman -S --needed - < packages/pacman-explicit.txt
```

La lista de AUR incluye `yay`, así que no se puede usar `yay` para instalarla desde cero. Instala primero el helper desde el AUR siguiendo su método de compilación (`base-devel` y `git` ya están incluidos en la lista):

```bash
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
cd ~/dotfiles
yay -S --needed - < packages/aur.txt
```

Después enlaza la configuración:

```bash
./install.sh
```

`install.sh` enlaza `home/` en `$HOME` usando GNU Stow. Sin argumentos, Stow se detiene si encuentra archivos que entrarían en conflicto. Inspecciona esos conflictos antes de resolverlos.

`./install.sh --adopt` permite que Stow adopte archivos existentes y puede modificar archivos del repositorio. Úsalo solo después de revisar los conflictos y tener claro qué archivos quieres conservar; no es un modo de previsualización.

## Paquetes

Paquetes explicitos actuales:

```bash
sudo pacman -S --needed - < packages/pacman-explicit.txt
```

Paquetes AUR actuales:

```bash
yay -S --needed - < packages/aur.txt
```

En el momento de crear este backup no había Flatpaks instalados. Esa nota es histórica y conviene actualizarla al generar una copia nueva.

## Dependencias del entorno

- Hyprland inicia Waybar, Hyprpaper, Blueman, el agente de autenticación de Polkit, Mako y el script `aviso-bateria.sh`.
- Los comandos `playerctl`, `wpctl` y `nm-connection-editor` se usan desde controles de Waybar o atajos. `wpctl` lo proporciona WirePlumber y `nm-connection-editor` NetworkManager Applet. `playerctl` debe estar instalado para que funcionen los controles multimedia.
- Los plugins de Zsh se cargan desde las rutas de Arch bajo `/usr/share/zsh/plugins/`; el shell ahora omite cada plugin si su archivo no está instalado.
- Tras reinstalar, comprueba que los servicios que uses estén habilitados, por ejemplo NetworkManager, Bluetooth, impresión o Timeshift. La lista de paquetes instala software, pero no restaura automáticamente el estado de los servicios ni sus datos.

## Notas antes de borrar Linux

- El repo de dotfiles esta pensado para restaurar shell, Hyprland, Waybar, Kitty, scripts, fondos y herramientas CLI.
- No guarda claves privadas, tokens, perfiles de navegador, partidas, configuraciones completas de Steam ni datos personales.
- Guarda aparte `~/.ssh`, `~/.gnupg`, documentos, proyectos, notas y cualquier dato de aplicaciones que quieras conservar.
- En este sistema habia un enlace roto antiguo en `~/.config/hypr/hyprland_save.conf`; la configuracion versionada activa es `hyprland.lua`.
