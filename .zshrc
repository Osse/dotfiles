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
zstyle ':completion::complete:-tilde-::' tag-order '! users'

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
if [[ $TERM = xterm* ]]; then
     export TERM="xterm-256color"
fi
# }}}

# Autoload functions
fpath=( ~/.zfunctions $fpath )
autoload ~/.zfunctions/[^_]*(.:t)

# Prompt {{{

# Git prompt {{{
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' actionformats '%F{72}[%b%c%u %F{226}%a%F{72}]%f'
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

function chpwd() {
    local REPLY
    disambiguate
    psvar[1]=$REPLY
}
chpwd

case $HOST in
    osse-w760|ow-linux)
        [[ -z $SSH_CONNECTION ]] &&
            hostcolor=green ||
            hostcolor=yellow ;;
    laleh)
        hostcolor=yellow ;;
    ow-server)
        hostcolor=magenta ;;
    bigge)
        hostcolor=215 ;;
    *)
        hostcolor=white ;;
esac
PS1='%B%F{green}%n%f@%F{$hostcolor}%m%f:%F{blue}%1v%b${vcs_info_msg_0_}%f%(?..%F{red})$%f '
# }}}

# Keybindings {{{
bindkey -v

# 'v' starter editor for kommando
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# '^W' fix
autoload -U osse-backward-kill-word
zle -N osse-backward-kill-word
bindkey '^W' osse-backward-kill-word

# Neeeesten perfekt
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward

bindkey '\e[Z' reverse-menu-complete
bindkey '^R' history-incremental-search-backward
bindkey '^H' backward-delete-char
bindkey '^?' backward-delete-char

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
alias g=git
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias man='noglob man'
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

function :he :h :help {
    vim +":he $1" +'wincmd o' +'nnoremap q :q!<CR>'
}

function mkcd() {
    [[ ! -z $1 ]] && mkdir $1 && cd $1
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
    echo $output${1:+\?$1}
}
# }}}

# vim: foldmethod=marker foldlevel=0

