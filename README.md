# dotfiles-bootstrap

Bootstrap inicial para una instalación de Arch Linux desde una TTY.

## Responsabilidad

Este repositorio hace únicamente lo siguiente:

1. Instala `qrencode` si no está instalado.
2. Genera o verifica una clave SSH.
3. Muestra la clave pública en texto y mediante QR.
4. Comprueba la autenticación SSH con GitHub.
5. Clona el repositorio privado `herbermqh/.dotfiles`.

No instala Arch Linux, no particiona discos, no configura GRUB, no instala paquetes del sistema y no ejecuta scripts de `.dotfiles`.

La futura instalación de Arch Linux debe añadirse en un archivo separado, por ejemplo `install_arch.sh`, sin mezclarla con `bootstrap.sh`.

## Uso desde la ISO de Arch Linux

```bash
git clone https://github.com/herbermqh/dotfiles-bootstrap.git
cd dotfiles-bootstrap
bash bootstrap.sh
```

El script crea la clave `~/.ssh/id_ed25519` si no existe. Después de añadir la clave pública a GitHub, verifica la conexión y clona:

```text
git@github.com:herbermqh/.dotfiles.git
```

en:

```text
~/.dotfiles
```

## Dependencia QR

Si `qrencode` no está instalado, el script intenta instalarlo automáticamente mediante `pacman`. Para ello se ejecuta como `root` o mediante un usuario con `sudo`.

## Personalización

```bash
DOTFILES_REPO=git@github.com:herbermqh/.dotfiles.git \
DOTFILES_DIR=/otra/ruta/.dotfiles \
bash bootstrap.sh
```
