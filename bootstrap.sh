#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:herbermqh/.dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"
SSH_PUBLIC_KEY="${SSH_KEY}.pub"

install_qrencode() {
    if command -v qrencode >/dev/null 2>&1; then
        return 0
    fi

    echo "📦 qrencode no está instalado; instalándolo..."

    if [ "$(id -u)" -eq 0 ]; then
        pacman -Sy --needed --noconfirm qrencode
    elif command -v sudo >/dev/null 2>&1; then
        sudo pacman -Sy --needed --noconfirm qrencode
    else
        echo "❌ Se necesitan permisos de administrador para instalar qrencode."
        exit 1
    fi
}

ssh_is_authenticated() {
    local output

    output="$(ssh -T \
        -o BatchMode=yes \
        -o ConnectTimeout=10 \
        git@github.com 2>&1 || true)"

    grep -q "successfully authenticated" <<< "$output"
}

show_public_key() {
    echo
    echo "🔑 Añade esta clave pública a GitHub:"
    echo "   https://github.com/settings/keys"
    echo
    cat "$SSH_PUBLIC_KEY"
    echo
    echo "📱 Código QR de la clave pública:"
    qrencode -t ANSIUTF8 < "$SSH_PUBLIC_KEY"
}

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

install_qrencode

if [ ! -f "$SSH_KEY" ]; then
    read -r -p "Introduce tu correo asociado a GitHub: " GITHUB_EMAIL

    if [ -z "$GITHUB_EMAIL" ]; then
        echo "❌ El correo no puede estar vacío."
        exit 1
    fi

    echo "🔐 Generando clave SSH..."
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$SSH_KEY"
fi

chmod 600 "$SSH_KEY"
chmod 644 "$SSH_PUBLIC_KEY"

if command -v ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "$SSH_KEY" >/dev/null 2>&1 || true
fi

if ! ssh_is_authenticated; then
    show_public_key
    echo
    echo "Añade la clave a GitHub y pulsa Enter para continuar."
    read -r
fi

if ! ssh_is_authenticated; then
    echo "❌ No se pudo verificar la autenticación SSH con GitHub."
    echo "Comprueba que añadiste la clave pública completa y vuelve a ejecutar este script."
    exit 1
fi

echo "✅ Autenticación SSH verificada."

if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "✅ .dotfiles ya está clonado en $DOTFILES_DIR."
    exit 0
fi

if [ -e "$DOTFILES_DIR" ]; then
    echo "❌ '$DOTFILES_DIR' existe, pero no es un repositorio Git."
    echo "Usa otra ubicación con DOTFILES_DIR=/otra/ruta bash bootstrap.sh."
    exit 1
fi

echo "📥 Clonando .dotfiles en $DOTFILES_DIR..."
git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

echo "✅ .dotfiles fue clonado correctamente."
