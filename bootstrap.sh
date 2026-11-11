#!/usr/bin/env bash
# bootstrap.sh — install the packages these dotfiles expect.
#
#   ./bootstrap.sh --dry-run   show what would be installed
#   ./bootstrap.sh             install packages, oh-my-zsh, and plugins
#
# It never changes your login shell; it prints the chsh command at the end.
set -euo pipefail

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

run() {
    if [ "$DRY" -eq 1 ]; then
        printf '[dry-run]'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

FEDORA_PKGS=(git zsh tmux fzf ripgrep fd-find jq curl htop shellcheck)
DEBIAN_PKGS=(git zsh tmux fzf ripgrep fd-find jq curl htop shellcheck)
MACOS_PKGS=(git zsh tmux fzf ripgrep fd jq curl htop shellcheck)

if command -v dnf >/dev/null 2>&1; then
    run sudo dnf install -y "${FEDORA_PKGS[@]}"
elif command -v apt-get >/dev/null 2>&1; then
    run sudo apt-get update
    run sudo apt-get install -y "${DEBIAN_PKGS[@]}"
elif command -v brew >/dev/null 2>&1; then
    run brew install "${MACOS_PKGS[@]}"
else
    printf 'bootstrap: no supported package manager (dnf, apt-get, brew)\n' >&2
    exit 1
fi

# Debian installs the fd binary as fdfind.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    run mkdir -p "$HOME/.local/bin"
    run ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
run mkdir -p "$ZSH_CUSTOM/plugins"

install_plugin() {
    local name="$1" url="$2"
    if [ -d "$HOME/.oh-my-zsh/plugins/$name" ]; then
        printf 'plugin %s: bundled with oh-my-zsh\n' "$name"
        return
    fi
    if [ -d "$ZSH_CUSTOM/plugins/$name" ]; then
        printf 'plugin %s: already installed\n' "$name"
        return
    fi
    run git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name"
}

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
install_plugin alias-tips https://github.com/djui/alias-tips
install_plugin pnpm https://github.com/ntnyq/omz-plugin-pnpm

if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    printf '\nTo make zsh your login shell:\n  chsh -s %s\n' "$(command -v zsh)"
fi
