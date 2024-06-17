# Environment variables
export SUDO_EDITOR=vim
export EDITOR=vim
export BROWSER=firefox
export GCC_COLORS=1
export CARGO_TARGET_DIR=$HOME/dev/cargo_target_dir

# Add stuff to PATH
path=( $HOME/bin $HOME/.gem/ruby/2.1.0/bin $HOME/.cargo/bin $HOME/.fzf/bin $path )
typeset -U path
