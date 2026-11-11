# Environment: PATH and tool integrations.
#
# Every optional tool is guarded, so a missing binary produces no error and no
# half-configured PATH.

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME/bin:"*) ;;
    *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# uv / pipx style local binaries
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Scripts that ship with these dotfiles
if [ -n "${DOTFILES:-}" ]; then
    case ":$PATH:" in
        *":$DOTFILES/bin:"*) ;;
        *) export PATH="$DOTFILES/bin:$PATH" ;;
    esac
fi
