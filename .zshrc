export ZSH="/home/dw/.oh-my-zsh"
# ZSH_THEME="frontcube"
ZSH_THEME="gentoo"
plugins=(z)
source $ZSH/oh-my-zsh.sh
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.alias

alias cdf='cd "$(ls -d */ | fzf)"'
alias c='clear'
alias cg='curl -L -O'
alias chr="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
alias dud='du -d 1 -h'
alias fds='fd --search-path'
alias fzf="fzf --reverse -m -0"
alias o="explorer.exe ."
alias p='python3'
alias pip="python3 -m pip"
alias server='python3 -m http.server'
alias rf='rm -rf'
alias subl='/mnt/d/soft/SublimeText/subl.exe'
alias sz='source ~/.zshrc'
alias vi='nvim'
alias vv='vi ~/.config/nvim/init.vim'
alias vz='vi ~/.zshrc'
alias va='vi ~/.alias'
alias hf="history|fzf"
alias l="ls -alh"
alias lt="tree -C -L 2"
# alias l="exa --tree --level=2"
# alias ls="exa"
alias calDate="python3 /home/atcg/.calDate.py $1 $2"

# docker alias
alias dps="docker ps -a"
alias di="docker images"

alias la="ls -alh"
alias rg="=rg -S"
alias rg1="=rg -S --maxdepth 1"
alias rg2="=rg -S --maxdepth 2"
# alias d2c="diff <($1) <($2)"

# other
alias pw="~/.pw"
alias e.="explorer.exe ."
alias y="youdao"
alias vb="vi ~/.bash_profile"
alias vc="vi ~/.command"
alias proxy_test="curl -vv https://google.com"
# alias code="code.exe"
# alias code='code.exe --remote wsl+Ubuntu "$(pwd)"'
# alias code="/home/dw/.vscode-server/bin/695af097c7bd098fbf017ce3ac85e09bbc5dda06/bin/remote-cli/code"
alias time='/usr/bin/time'
alias gsize='function __gsize() { curl -s "https://api.github.com/repos/$1" | jq ".size" | numfmt --to=iec --from-unit=1024; }; __gsize'

complete -W "\$(gf -list)" g

# Golang
# export GOROOT=/usr/local/go
# export GOPATH=$HOME/go
# export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.bash_profile ] && source ~/.bash_profile

if [[ "$(umask)" == '000' ]]; then
    umask 022
fi
export TERM=xterm-256color
export FZF_DEFAULT_COMMAND='rg'
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/dw/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/dw/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/dw/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/dw/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# export PATH=$PATH:/home/dw/miniconda3/bin  # commented out by conda initialize
# export PATH="/home/dw/miniconda3/bin:$PATH"  # commented out by conda initialize
export PATH=$PATH:/home/dw/.local/bin

export PYTHONSTARTUP=$HOME/.pystartup
export GOPROXY=https://goproxy.cn,direct
export GOROOT=/usr/local/go
export PATH=$PATH:/usr/local/go/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
