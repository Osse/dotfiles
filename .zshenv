skip_global_compinit=1

# Local modifications
if [[ -f "$HOME/.zshenv.local" ]] then
    source "$HOME/.zshenv.local"
fi
