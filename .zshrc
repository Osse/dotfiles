# Completion {{{
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format '%BCompleting %d%b'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' special-dirs ..
eval "$(dircolors -b ~/.config/dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'l:|=* r:|=*' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'Errors: %e'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true
zstyle ':completion::complete:-tilde-::' tag-order '! users'

# Autoload functions
fpath=( ~/.zfunctions $fpath )
autoload ~/.zfunctions/[^_]*(.:t)

autoload -U compinit
compinit -i
compdef -d users
# }}}

# History {{{
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
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
if [[ $TERM = xterm ]]; then
     TERM="xterm-256color"
fi
# }}}

# Prompt {{{

# Git prompt {{{
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' actionformats '%F{72}[%f%m%F{72}%b%f%c%u %F{226}%a%F{72}]%f'
zstyle ':vcs_info:*' formats '%F{72}[%f%m%F{72}%b%f%c%u%F{72}]%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{40}•%f'
zstyle ':vcs_info:*' unstagedstr '%F{214}•%f'
zstyle ':vcs_info:git:set-message:*' hooks check-untracked check-upstream

+vi-check-untracked() {
    [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]] &&
    hook_com[unstaged]+='%F{red}•%f'
}

+vi-check-upstream() {
    local ours theirs
    git rev-list --count --left-right 'HEAD...@{u}' 2>/dev/null | read ours theirs
    ((ours)) && hook_com[misc]="%F{green}$ours▲%f"
    ((theirs)) && hook_com[misc]+="%F{yellow}$theirs▼%f"
    hook_com[misc]+=${hook_com[misc]:+ }
    return 0
}
# }}}

function precmd() {
    (( title_set )) || print -nP "\033]0;${SSH_CONNECTION:+SSH: }%n@%m:%1v\007"
    vcs_info
}

function title() {
    print -nP "\033]0;$*\007"
    title_set=1
}

function chpwd() {
    local REPLY
    disambiguate
    psvar[1]=$REPLY
}
chpwd

case $HOST in
    bigge)      hostcolor=215 ;;
    snyltevm)   hostcolor=81  ;;
    worklappie) hostcolor=191 ;;
    lappie)     hostcolor=206 ;;
    *)          hostcolor=1
esac
psvar[3]=$hostcolor

PS1='%B%F{green}%n%f@%F{%3v}%m%f:%F{blue}%1v%b${vcs_info_msg_0_}%(1j. %F{87}%j%f .)%f%(?..%F{red})$%f '
# }}}

# Keybindings {{{
bindkey -v
KEYTIMEOUT=5

# 'v' starter editor for kommando
autoload -U edit-command-line
autoload -U slash
zle -N edit-command-line
zle -N slash
bindkey '^N' slash
bindkey -M vicmd v edit-command-line
bindkey -M viins '^F' edit-command-line

# '^W' fix
zle -N osse-backward-kill-word
bindkey '^W' osse-backward-kill-word
zle -N rationalise-dot
bindkey '.' rationalise-dot

(( $+terminfo[cbt] )) && bindkey $terminfo[cbt] reverse-menu-complete
bindkey '^R' history-incremental-pattern-search-backward

# Code for sane binding of keys and handling of terminal modes {{{
# Adapted from Debian's /etc/zshrc
typeset -A key
key=( BackSpace  "${terminfo[kbs]}"
      Home       "${terminfo[khome]}"
      End        "${terminfo[kend]}"
      Insert     "${terminfo[kich1]}"
      Delete     "${terminfo[kdch1]}"
      Up         "${terminfo[kcuu1]}"
      Down       "${terminfo[kcud1]}"
      Left       "${terminfo[kcub1]}"
      Right      "${terminfo[kcuf1]}"
      PageUp     "${terminfo[kpp]}"
      PageDown   "${terminfo[knp]}"
)

function bind2maps () {
    local i sequence widget
    local -a maps

    while [[ "$1" != "--" ]]; do
        maps+=( "$1" )
        shift
    done
    shift

    sequence="${key[$1]}"
    widget="$2"

    [[ -z "$sequence" ]] && return 1

    for i in "${maps[@]}"; do
        bindkey -M "$i" "$sequence" "$widget"
    done
}

bind2maps emacs             -- BackSpace   backward-delete-char
bind2maps       viins       -- BackSpace   vi-backward-delete-char
bind2maps             vicmd -- BackSpace   vi-backward-char
bind2maps emacs             -- Home        beginning-of-line
bind2maps       viins vicmd -- Home        vi-beginning-of-line
bind2maps emacs             -- End         end-of-line
bind2maps       viins vicmd -- End         vi-end-of-line
bind2maps emacs viins       -- Insert      overwrite-mode
bind2maps             vicmd -- Insert      vi-insert
bind2maps emacs             -- Delete      delete-char
bind2maps       viins vicmd -- Delete      vi-delete-char
bind2maps emacs viins vicmd -- Up          history-beginning-search-backward
bind2maps emacs viins vicmd -- Down        history-beginning-search-forward
bind2maps emacs             -- Left        backward-char
bind2maps       viins vicmd -- Left        vi-backward-char
bind2maps emacs             -- Right       forward-char
bind2maps       viins vicmd -- Right       vi-forward-char
bind2maps       viins vicmd -- PageUp      ''
bind2maps       viins vicmd -- PageDown    ''

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init-1 () {
        emulate -L zsh
        printf '%s' ${terminfo[smkx]}
    }
    function zle-line-finish () {
        emulate -L zsh
        printf '%s' ${terminfo[rmkx]}
    }
    zle -N zle-line-finish
else
    function zle-line-init-1 () {
        :
    }
    for i in {s,r}mkx; do
        (( ${+terminfo[$i]} )) || debian_missing_features+=($i)
    done
    unset i
fi

unfunction bind2maps

autoload -U select-quoted select-bracketed surround
zle -N select-quoted
zle -N select-bracketed
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround

for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# }}}
# }}}

# Aliases {{{
alias -g L='| less'
alias -g N1='> /dev/null'
alias -g N2='2> /dev/null'
alias -g N='> /dev/null 2>&1'
alias -g XS=' $(xsel)'
alias fullname='readlink -f'
alias g=git
alias help='run-help'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -al'
alias man='noglob man'
alias pl='print -l'
alias q='exit'
alias v='vim'
alias vimrc='vim ~/.vim/vimrc'
alias zshrc='vim ~/.zshrc'
# }}}

#  Mode indication {{{
function zle-line-init-2 zle-keymap-select {
    RPS1="%B${${KEYMAP/vicmd/n}/(main|viins)/i}%b"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-keymap-select
# }}}

bracketed-paste() {
    (( NUMERIC = 2 - $+NUMERIC ))
    zle .bracketed-paste
}
zle -N bracketed-paste

# Create zle-line-init
function zle-line-init {
    zle-line-init-1
    zle-line-init-2
}
zle -N zle-line-init

# Other functions {{{

function ls grep egrep fgrep {
    command $0 --color=auto "$@"
}

function :he :h :help {
    vim +"help $1" +only +'map q ZQ'
}

function mkcd() {
    [[ ! -z $1 ]] && mkdir -p $1 && cd $1
}

function mvcd() {
    (( $# > 1 )) && mv "$@" && cd "$@[-1]"
}

function copy() {
    fc -ln -1 | sed -e 's|\\n|;|g' |
    tr -d '\n' | xsel -b
}

function sprunge() {
    curl -sF 'sprunge=<-' http://sprunge.us | tr -d '\n'
    echo ${1:+\?$1}
}
# }}}

# vim: foldmethod=marker foldlevel=0

