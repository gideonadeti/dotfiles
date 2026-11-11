# ~/.bashrc

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User-specific PATH
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac
export PATH

# Drop-in configuration files
if [ -d "$HOME/.bashrc.d" ]; then
    for rc in "$HOME"/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
    unset rc
fi

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
