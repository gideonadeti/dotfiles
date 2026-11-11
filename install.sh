#!/usr/bin/env bash
# install.sh — link these dotfiles into $HOME.
#
#   ./install.sh --dry-run    show what would happen, change nothing
#   ./install.sh              back up existing files, then symlink
#   ./install.sh --uninstall  restore the most recent backup
#
# Existing real files are moved to ~/.dotfiles-backup-<timestamp>/, never deleted.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
MODE="install"
DRY=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run | --uninstall]

  --dry-run    print every action without changing anything
  --uninstall  remove the symlinks and restore the latest backup
  -h, --help   show this help
EOF
}

die() { printf '%s: error: %s\n' "$(basename "$0")" "$*" >&2; exit 1; }

run() {
    if [ "$DRY" -eq 1 ]; then
        printf '[dry-run]'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run)   DRY=1; shift ;;
        --uninstall) MODE="uninstall"; shift ;;
        -h|--help)   usage; exit 0 ;;
        *)           die "unknown option: $1 (try --help)" ;;
    esac
done

# source-relative:destination-relative
LINKS=(
    "zsh/.zshrc:.zshrc"
    "bash/.bashrc:.bashrc"
    "bash/.bash_profile:.bash_profile"
    "profile/.profile:.profile"
    "tmux/.tmux.conf:.tmux.conf"
    "git/.gitconfig:.gitconfig"
    "ssh/config:.ssh/config"
)

if [ "$MODE" = "uninstall" ]; then
    # Timestamped names sort lexicographically, so the last match is newest.
    BACKUP=""
    for candidate in "$HOME"/.dotfiles-backup-*; do
        [ -d "$candidate" ] || continue
        BACKUP="$candidate"
    done
    [ -n "$BACKUP" ] || die "no ~/.dotfiles-backup-* directory found"
    printf 'restoring from %s\n' "$BACKUP"

    for entry in "${LINKS[@]}"; do
        dst="$HOME/${entry##*:}"
        if [ -L "$dst" ]; then
            run rm -f "$dst"
        fi
    done

    while IFS= read -r -d '' file; do
        rel="${file#"$BACKUP"/}"
        run mkdir -p "$HOME/$(dirname "$rel")"
        run cp -a "$file" "$HOME/$rel"
    done < <(find "$BACKUP" -type f -print0)

    printf 'done. open a new terminal.\n'
    exit 0
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.dotfiles-backup-$STAMP"

run mkdir -p "$BACKUP"
[ -d "$HOME/.ssh" ] || run mkdir -p "$HOME/.ssh"
run chmod 700 "$HOME/.ssh"

# Preserve existing SSH hosts: the tracked config only includes config.local.
have_config_local=0
[ -f "$HOME/.ssh/config.local" ] && have_config_local=1

if [ -f "$HOME/.ssh/config" ] && [ ! -L "$HOME/.ssh/config" ] && [ "$have_config_local" -eq 0 ]; then
    run cp -a "$HOME/.ssh/config" "$HOME/.ssh/config.local"
    run chmod 600 "$HOME/.ssh/config.local"
    have_config_local=1
    printf 'migrated existing SSH hosts to ~/.ssh/config.local\n'
fi

if [ "$have_config_local" -eq 0 ]; then
    if [ "$DRY" -eq 1 ]; then
        printf '[dry-run] create ~/.ssh/config.local\n'
    else
        printf '# Machine-specific SSH hosts. Not tracked by git.\n' > "$HOME/.ssh/config.local"
        chmod 600 "$HOME/.ssh/config.local"
    fi
fi

# Machine-specific shell overrides.
if [ ! -f "$REPO/zsh/90-local.zsh" ]; then
    run cp "$REPO/zsh/90-local.zsh.example" "$REPO/zsh/90-local.zsh"
fi

for entry in "${LINKS[@]}"; do
    src="$REPO/${entry%%:*}"
    rel="${entry##*:}"
    dst="$HOME/$rel"

    if [ ! -e "$src" ]; then
        printf 'skip: missing %s\n' "$src" >&2
        continue
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        rel_dir="$(dirname "$rel")"
        if [ "$rel_dir" = "." ]; then
            run mkdir -p "$BACKUP"
        else
            run mkdir -p "$BACKUP/$rel_dir"
        fi
        run mv "$dst" "$BACKUP/$rel"
        printf 'backed up %s\n' "$dst"
    fi

    run mkdir -p "$(dirname "$dst")"
    run ln -sfn "$src" "$dst"
    printf 'linked %s -> %s\n' "$dst" "$src"
done

if [ "$DRY" -eq 0 ]; then
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
fi

printf '\ndone. open a new terminal, or run: exec zsh\n'
printf 'rollback: %s --uninstall\n' "$0"
