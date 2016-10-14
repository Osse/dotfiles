# if running bash
# zsh reads .zshrc regardless
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

export EDITOR=nvim
export SUDO_EDITOR=$EDITOR
export BROWSER=firefox
export GCC_COLORS=1
export CARGO_TARGET_DIR=$HOME/.cache/cargo_target_dir

prefix_path() {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="$1:$PATH"
            ;;
    esac
}

prefix_path /mingw64/bin

for bin in .fzf/bin .cargo/bin .local/*/bin .local/bin; do
    [ -d "$bin" ] || continue
    prefix_path "$HOME/$bin"
done

unset -f prefix_path

MANPATH="/mingw64/share/man:$MANPATH"
