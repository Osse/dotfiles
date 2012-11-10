skip_global_compinit=1

# Environment variables{{{
export SUDO_EDITOR=vim
export EDITOR=vim
# }}}

# Add stuff to PATH
path=( /home/osse/bin $path )
typeset -U path

if [[ -f "$HOME/.zshenv.local" ]] then
    source "$HOME/.zshenv.local"
fi
