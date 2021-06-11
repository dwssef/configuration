export ZSH="/home/atcg/.oh-my-zsh"
ZSH_THEME="theunraveler"
# ZSH_THEME="kardan"
plugins=(git z)
source $ZSH/oh-my-zsh.sh
source /home/atcg/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

host_ip=$(cat /etc/resolv.conf |grep "nameserver" |cut -f 2 -d " ")
# alias proxy="export http_proxy=socks5://$host_ip:22222; export https_proxy=socks5://$host_ip:22222"
alias proxy="export http_proxy=socks5://192.168.1.107:22222; export https_proxy=socks5://192.168.1.107:22222"
alias unproxy='unset http_proxy; unset https_proxy'
alias pyweb='python3 -m http.server'
alias rf='rm -rf'
alias fds='fd --search-path'
alias python='python3'
alias cg='curl -L -O'
alias vz='vi ~/.zshrc'
alias sz='source ~/.zshrc'
# alias vv='vi ~/.vimrc'
alias vv='vi ~/.config/nvim/init.vim'
alias c='clear'
alias g='grep'
alias h='history'
alias vf='vi $(fzf)'
alias fzf="fzf --reverse -m -0"
alias subl='/mnt/d/soft/SublimeText/subl.exe'
alias cu="cd ../"
alias code="code.exe"
alias ac="conda activate"
alias dud='du -d 1 -h'
alias adc="conda deactivate"
alias chr="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
alias vi="nvim"
alias o="explorer.exe ."

# English
# translation - context.reverso.net
alias tran="python3 ~/.translation.py english chinese $1"
alias def="cambrinary -w"

alias l="tree -L 1"
alias la="ls -alh"
alias rg="=rg -S"
alias rg1="=rg -S --maxdepth 1"
alias rg2="=rg -S --maxdepth 2"
###################

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/home/atcg/.yarn/bin
export PATH=$PATH:/home/atcg/.local/bin
export GITLAB_HOME=$HOME/gitlab

complete -W "\$(gf -list)" g

# golang
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export FZF_DEFAULT_OPTS="--height 95% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"

cde(){
    cd /mnt/e/desktop
    #cd /mnt/c/Users/Torrl/Desktop
}

gitc(){
    gitc_ret=`echo $1|sed 's/github.com/github.com.cnpmjs.org/g'`
    git clone $gitc_ret
}

shrug(){
    echo -n "¯\_(ツ)_/¯" |clip.exe
}

mkcd () { mkdir -p "$1" && cd "$1" }

de() {
    if [ ! -n "$1" ] ;then
        python3 ~/.deepl.py EN ZH "`clippaste`"
    else
	python3 ~/.deepl.py EN ZH $*
    fi
}

dc() {
    if [ ! -n "$1" ] ;then
        python3 ~/.deepl.py ZH EN "`clippaste`"
    else
	python3 ~/.deepl.py ZH EN $1
    fi
}

clo() {
    curl -s https://api.codetabs.com/v1/loc/\?github\=$1 |jq
}
# https://api.github.com/repos/vitalets/webrtc-ips/commits

cat<<EOF
##################
+ English word+20
+ python pattern
+ bruce
- fund investment
- scikit learn 
- blockchain Golang [[google bookmark]]
##################
EOF

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/atcg/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     # if [ -f "/home/atcg/miniconda3/etc/profile.d/conda.sh" ]; then
#     #     . "/home/atcg/miniconda3/etc/profile.d/conda.sh"
#     # else
export PATH="/home/atcg/miniconda3/bin:$PATH"
# fi
# unset __conda_setup
# <<< conda initialize <<<

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
