# Completion {{{
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format '%BCompleting %d%b'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
eval "$(dircolors -b)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'l:|=* r:|=*' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'Errors: %e'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true

autoload -U compinit
compinit -i
compdef -d users
# }}}

# History {{{
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# }}}

# Options {{{
setopt append_history    \
       extended_glob     \
       auto_cd           \
       cdable_vars       \
       prompt_subst      \
       transient_rprompt \
       hist_ignore_dups
# }}}

# TERM {{{
# This is apparently a mad thing, but gnome-terminal :(
if [[ $TERM = xterm* ]]; then
     export TERM="xterm-256color"
fi
# }}}

# Prompt {{{

# Git prompt {{{
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '%F{72}[%b%c%u%F{72}]%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{40}•%f'
zstyle ':vcs_info:*' unstagedstr '%F{214}•%f'
zstyle ':vcs_info:git+set-message:*' hooks check-untracked

+vi-check-untracked() {
    [[ -n $(git ls-files --others --exclude-standard 2>&-) ]] &&
    hook_com[unstaged]="${hook_com[unstaged]}%F{red}•"
}
# }}}

function precmd() {
    vcs_info
}

function disambiguate() {
    # short holds the result we want to print
    # full holds the full path up to the current segment
    # part holds the current segment, will get as few characters as
    # possible from cur, which is the full current segment
    local short full part cur
    local first
    local -a split    # the array we loop over

    if [[ $PWD == / ]]; then
      REPLY=/
      return 0
    fi

    # We do the (D) expansion right here and
    # handle it later if it had any effect
    pwd=${(Q)${(D)1:-$PWD}}
    split=(${(s:/:)pwd})
    # Handling. Perhaps NOT use (D) above and check after shortening?
    # if [[ $#split -eq 1 ]]; then
    #     split[1]=${split[1]/#[^~]*//$split[1]}
    #     REPLY=$split[1]
    #     return 0
    if [[ $split[1] = \~* ]]; then
        # named directory we skip shortening the first element
        # and manually prepend the first element to the return value
        first=$split[1]
        # full should already contain the first
        # component since we don't start there
        full=$~split[1]
        shift split
    fi

    for cur ($split[1,-2]) {
      while {
               part+=$cur[1]
               cur=$cur[2,-1]
               local -a a
               a=( $full/$part*(-/N) )
               # continue adding if more than one directory matches or
               # the current string is . or ..
               # but stop if there are no more characters to add
               (( $#a > 1 )) || [[ $part == (.|..) ]] && (( $#cur > 0 ))
            } { # this is a do-while loop
      }
      full+=/$part$cur
      short+=/$part
      part=
    }
    REPLY=$first$short${split[-1]:+/$split[-1]}
    return 0
}

function chpwd() {
    local REPLY
    disambiguate
    psvar[1]=$REPLY
}
chpwd

case $HOST in
    osse-w760)
        [[ -z $SSH_CONNECTION ]] &&
            hostcolor=green ||
            hostcolor=yellow ;;
    ow-linux)
        hostcolor=green ;;
    laleh)
        hostcolor=yellow ;;
    ow-server)
        hostcolor=magenta ;;
    *)
        hostcolor=white ;;
esac
PS1="%B%F{green}%n%f@%F{$hostcolor}%m%f:%F{blue}%1v%b"'${vcs_info_msg_0_}'"%f%b%(?..%F{red})$%f%b "
# }}}

# Keybindings {{{
bindkey -v

# 'v' starter editor for kommando
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Neeeesten perfekt
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward

bindkey '\e[Z' reverse-menu-complete
bindkey '^R' history-incremental-search-backward
bindkey '^W' osse-backward-kill-word

[[ -z "$terminfo[khome]" ]] || bindkey -M viins "$terminfo[khome]" beginning-of-line &&
                               bindkey -M vicmd "$terminfo[khome]" beginning-of-line
[[ -z "$terminfo[kend]"  ]] || bindkey -M viins "$terminfo[kend]" end-of-line &&
                               bindkey -M vicmd "$terminfo[kend]" end-of-line
[[ -z "$terminfo[kdch1]" ]] || bindkey -M viins "$terminfo[kdch1]" vi-delete-char &&
                               bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
[[ -z "$terminfo[kpp]"   ]] || bindkey -M viins -s "$terminfo[kpp]" ''
[[ -z "$terminfo[knp]"   ]] || bindkey -M viins -s "$terminfo[knp]" ''
# }}}

# Aliases {{{
alias -g L='| less'
alias -g N1='> /dev/null'
alias -g N2='2> /dev/null'
alias -g N='> /dev/null 2>&1'
alias -g XS=' $(xsel)'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias fixlink='cd `readlink -nf .`'
alias fullname='readlink -f'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias q='exit'
alias vimrc='vim ~/.vimrc'
alias zshrc='vim ~/.zshrc'
# }}}

#  Mode indication {{{
function zle-line-init zle-keymap-select {
    RPS1="%B${${KEYMAP/vicmd/n}/(main|viins)/i}%b"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
# }}}

# Other functions {{{
function cd () {
if [[ -z $2 ]]; then
    if [[ -f $1 ]]; then
        builtin cd $1:h
    else
        builtin cd $1
    fi
else
    if [[ -z $3 ]]; then
        builtin cd $1 $2
    else
        echo cd: too many arguments
    fi
fi
}

function togglegit {
    if [[ -d "$HOME/.git" && ! -d "$HOME/.git.off" ]]; then
        mv "$HOME/.git" "$HOME/.git.off"
    elif [[ ! -d "$HOME/.git" && -d "$HOME/.git.off" ]]; then
        mv "$HOME/.git.off" "$HOME/.git"
    else
        echo "pleasefix" >&2
        return 1
    fi
}

function :he :h :help {
    vim +":he $1" +'wincmd o' +'nnoremap q :q!<CR>'
}

function tempd() {
    tempdir=$(mktemp -d)
    echo "\$tempdir set to $tempdir"
    cd $tempdir
}

function tempf() {
    if [[ -n $1 ]]; then
        tempfile=$(mktemp --suffix=.$1)
    else
        tempfile=$(mktemp)
    fi
    echo "\$tempfile set to $tempfile"
    vim $tempfile
}

function mkcd() {
    [[ ! -z $1 ]] && mkdir $1 && cd $1
}

function _users() {}

function osse-backward-kill-word {
    zle vi-backward-word
    zle vi-change-eol
}
zle -N osse-backward-kill-word

function copy() {
    fc -ln -1 | sed -e 's|\\n|;|g' |
    tr -d '\n' | xsel -b
}
# }}}

if [[ -f "$HOME/.zshrc.local" ]] then
    source "$HOME/.zshrc.local"
fi

# vim: foldmethod=marker foldlevel=0

