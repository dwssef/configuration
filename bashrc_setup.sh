#!/bin/bash
tee -a $HOME/.bashrc <<'EOF'
#######################################
alias l="tree -C -L 1"
alias ll='ls -lh'
alias la='ls -alh'
alias c='clear'
alias p='python'
alias vz="vi $HOME/.bashrc"
alias vv="vi $HOME/.vimrc"
alias vb="vi $HOME/.bash_profile"
alias sz="source $HOME/.bashrc"
alias ports='netstat -tulanp'
alias t="tree -L $1"

alias mkdate='mkdir "$(date)" | sed 's/[[:space:]]//g''
export LANG="en_US.UTF-8"

hs() {
	history | grep "$1"
}

function cu {
    local count=$1
    if [ -z "${count}" ]; then
        count=1
    fi
    local path=""
    for i in $(seq 1 ${count}); do
        path="${path}../"
    done
    cd $path
}

EOF
