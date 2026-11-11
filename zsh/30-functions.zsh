# Shell functions. These run in the current shell, which is why they are not
# scripts: `cd` inside a function changes your directory, inside a script it
# only changes the child's.

# marco/polo: remember a directory, jump back to it.
marco() {
    MARCO_DIR="$PWD"
    printf 'marco: saved %s\n' "$MARCO_DIR"
}

polo() {
    if [ -z "${MARCO_DIR:-}" ]; then
        printf 'polo: run marco first\n' >&2
        return 1
    fi
    cd "$MARCO_DIR" || return 1
}

# mkcd: create a directory and enter it.
mkcd() {
    if [ "$#" -ne 1 ]; then
        printf 'usage: mkcd <dir>\n' >&2
        return 64
    fi
    mkdir -p -- "$1" && cd -- "$1"
}

# newest [dir]: print the most recently modified regular file.
newest() {
    local dir="${1:-.}"
    if find "$dir" -type f -printf '' 2>/dev/null; then
        find "$dir" -type f -printf '%T@\t%p\n' | sort -rn | head -1 | cut -f2-
    else
        # BSD/macOS find has no -printf.
        find "$dir" -type f -exec stat -f '%m %N' {} + | sort -rn | head -1 | cut -d' ' -f2-
    fi
}

# pidwait PID...: wait for processes that are not your children.
pidwait() {
    local pid
    for pid in "$@"; do
        while kill -0 "$pid" 2>/dev/null; do
            sleep 1
        done
    done
}
