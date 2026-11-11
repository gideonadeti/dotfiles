#!/usr/bin/env bash
# Test the installer against a throwaway $HOME. No real files are touched.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export HOME="$TMP/home"
mkdir -p "$HOME/.ssh"
printf 'original zshrc\n' > "$HOME/.zshrc"
printf 'original gitconfig\n' > "$HOME/.gitconfig"
printf 'Host original\n    HostName example.com\n' > "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# Dry run must not change anything.
"$REPO/install.sh" --dry-run >/dev/null
if [ ! -f "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
    fail "dry-run changed .zshrc"
fi
if [ ! -f "$HOME/.ssh/config" ] || [ -L "$HOME/.ssh/config" ]; then
    fail "dry-run changed SSH config"
fi

# Install.
"$REPO/install.sh" >/dev/null
[ -L "$HOME/.zshrc" ] || fail ".zshrc was not linked"
[ -L "$HOME/.gitconfig" ] || fail ".gitconfig was not linked"
[ -L "$HOME/.ssh/config" ] || fail "SSH config was not linked"
grep -q 'Host original' "$HOME/.ssh/config.local" || fail "SSH hosts were not migrated"

# Running it again must be harmless.
"$REPO/install.sh" >/dev/null

# The shell config must load and define the expected alias and function.
DOTFILES="$REPO" zsh -i -c 'alias clr >/dev/null && type marco >/dev/null' \
    || fail "zsh config did not load"

# Uninstall restores the originals.
"$REPO/install.sh" --uninstall >/dev/null
[ ! -L "$HOME/.zshrc" ] || fail ".zshrc is still a symlink"
grep -q 'original zshrc' "$HOME/.zshrc" || fail ".zshrc was not restored"
grep -q 'original gitconfig' "$HOME/.gitconfig" || fail ".gitconfig was not restored"

printf 'install-test: OK\n'
