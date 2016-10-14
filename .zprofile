# Environment variables
export SUDO_EDITOR=vim
export EDITOR=vim
export BROWSER=firefox
export GCC_COLORS=1

# Add stuff to PATH
path=( /mingw64/bin $HOME/bin $path )
typeset -U path

manpath=( /mingw64/share/man $manpath )
