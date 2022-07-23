export ZSH="/home/atcg/.oh-my-zsh"
ZSH_THEME="theunraveler"
# plugins=(z)
source $ZSH/oh-my-zsh.sh
source /home/atcg/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/atcg/.alias

alias di="docker images"
alias cdf='cd $(ls -d */ | fzf)'
host_ip=$(cat /etc/resolv.conf |grep "nameserver" |cut -f 2 -d " ")
# alias proxy="export http_proxy=socks5://$host_ip:17254; export https_proxy=socks5://$host_ip:17254"
# alias unproxy='unset http_proxy; unset https_proxy'
alias proxy="export ALL_PROXY=http://$host_ip:17254"
alias unproxy="unset ALL_PROXY"
alias ac="conda activate"
alias adc="conda deactivate"
alias c='clear'
alias cg='curl -L -O'
alias chr="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
alias code="code.exe"
alias dud='du -d 1 -h'
alias fds='fd --search-path'
alias fzf="fzf --reverse -m -0"
alias o="explorer.exe ."
alias p='python3'
alias python='python3'
alias serve='python3 -m http.server'
alias rf='rm -rf'
alias subl='/mnt/d/soft/SublimeText/subl.exe'
alias sz='source ~/.zshrc'
alias vf='vi $(fzf)'
alias vi="nvim"
alias v="nvim"
alias vt="vi ~/.TODO"
alias vv='vi ~/.config/nvim/init.vim'
alias vz='vi ~/.zshrc'
# alias l="tree -C -L 1"
alias l="exa --tree --level=1"

# docker alias
alias dps="docker ps -a"
alias di="docker images"

# English
alias tran="python3 ~/.translation.py english chinese $1"
alias de="python3 /home/atcg/.deepl.py $1"
alias calDate="python3 /home/atcg/.calDate.py $1 $2"
alias def="deep"
alias dec='python3 /home/atcg/.deepl.py EN ZH "`clippaste`"'
alias dee='python3 /home/atcg/.deepl.py ZH EN "`clippaste`"'

alias la="exa -alh"
alias rg="=rg -S"
alias rg1="=rg -S --maxdepth 1"
alias rg2="=rg -S --maxdepth 2"

# other
alias pw="~/.pw"
alias e.="explorer.exe ."
alias y="youdao"
alias vb="vi ~/.bash_profile"
alias vc="vi ~/.command"
# alias go="go1.13"
###################

export PATH=$PATH:/home/atcg/.yarn/bin
export PATH=$PATH:/home/atcg/.local/bin
export GITLAB_HOME=$HOME/gitlab

complete -W "\$(gf -list)" g

# Golang
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Go 1.13
# export GOROOT=$(go1.13 env GOROOT)

# TODO
# cat<<EOF
# EOF

export PATH="/home/atcg/miniconda3/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.bash_profile ] && source ~/.bash_profile

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
if [[ "$(umask)" == '000' ]]; then
    umask 022
fi

# File Search
alias fzf.w="fzf --height 40% --layout reverse --info inline --border \
    --preview 'file {}' --preview-window down:1:noborder \
    --color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'"
