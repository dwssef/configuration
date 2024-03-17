#!/bin/bash
tee -a $HOME/.bashrc <<'EOF'
#######################################
alias l="ls"
alias ll='ls -lh'
alias la='ls -alh'
alias c='clear'
alias p='python3'
alias vz="vi $HOME/.bashrc"
alias vv="vi $HOME/.vimrc"
alias vb="vi $HOME/.bash_profile"
alias sz="source $HOME/.bashrc"
alias ports='netstat -tulanp'
alias server='python3 -m http.server'
alias bak='cp $1 $1.bak'
alias cdf='cd "$(ls -d */ | fzf)"'
alias zz='if [ ! -n "$1" ]; then eval "$(cat ~/.command | fzf)"; fi'
alias vzz="vi ~/.command"

alias mkdate='mkdir "$(date)" | sed 's/[[:space:]]//g''
export LANG="en_US.UTF-8"

hs() {
	history | vi -
}

cu() {
    local count=$1
    if [ -z "${count}" ]; then
        count=1
    fi
    local path=""
    for ((i = 0; i < count; i++)); do
        path="${path}../"
    done
    cd "$path" || return 1
}
EOF
