# oh-my-zsh: theme, plugins, and the framework itself.
#
# Guarded so the shell still starts on a machine where oh-my-zsh has not been
# installed yet. Run ./bootstrap.sh to install it.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    z
    alias-tips
    docker
    docker-compose
    pnpm
    aliases
    python
    pip
)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
else
    printf 'dotfiles: oh-my-zsh not found at %s (run ./bootstrap.sh)\n' "$ZSH" >&2
fi
