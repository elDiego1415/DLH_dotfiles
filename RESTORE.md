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
./install.sh --check
./install.sh
```

`./install.sh --check` comprueba que existe `home/`, que `$HOME` permite escritura y que GNU Stow está instalado. Luego ejecuta Stow en modo simulación y muestra los enlaces que intentaría crear. No modifica archivos. Si aparecen conflictos, resuélvelos y vuelve a ejecutar la comprobación antes de instalar.

`./install.sh` crea los enlaces. Si Stow encuentra conflictos, se detiene sin reemplazar los archivos existentes.

`./install.sh --adopt` pide a Stow que adopte archivos existentes en el repositorio y puede moverlos o modificar el contenido del repositorio. El instalador muestra un aviso, pero continúa sin pedir confirmación. Revisa primero los conflictos con `--check` y usa `--adopt` solo si quieres conservar esos archivos en los dotfiles.

Las opciones `--check` y `--adopt` no se pueden combinar. El instalador no instala paquetes: eso se hace en los pasos anteriores.

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
