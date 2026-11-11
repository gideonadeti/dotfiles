# ~/.zshrc — loader for the dotfiles modules.
#
# Keep this file small. Put real configuration in zsh/NN-*.zsh.
# Modules load in filename order, so 90-local.zsh always has the last word.

# Resolve the repository from this file's own path (through the symlink).
# %x is zsh's "file currently being sourced"; :A resolves the symlink.
# Override with DOTFILES=... if you keep the repo somewhere unusual.
DOTFILES="${DOTFILES:-${${(%):-%x}:A:h:h}}"

for _module in "$DOTFILES"/zsh/*.zsh; do
    [ -r "$_module" ] && source "$_module"
done
unset _module
