#!/bin/bash
tee -a $HOME/.bashrc <<'EOF'
#######################################
alias l="ls"
alias ll='ls -lh'
alias la='ls -alh'
alias p='python3'
alias vz="vi $HOME/.bashrc"
alias vv="vi $HOME/.vimrc"
alias vb="vi $HOME/.bash_profile"
alias sz="source $HOME/.bashrc"
alias ports='netstat -tulanp'
alias server='python3 -m http.server'
alias cdf='cd "$(ls -d */ | fzf)"'
alias dps="docker ps -a"
alias dmi="docker images"

alias mkdate='mkdir "$(date)" | sed 's/[[:space:]]//g''
export LANG="en_US.UTF-8"

hs() {
	history | vi -
}

c() {
    if [ -n "$TMUX" ]; then
        tmux clear-history
    fi
    clear
}

# Solve .bash_profile not working issue in vscode terminal
if [ "$TERM_PROGRAM" = "vscode" ]; then
    [ -f ~/.bash_profile ] && source ~/.bash_profile
fi

export FZF_DEFAULT_OPTS='-m --height 50% --border'
EOF
