export ZSH="/home/atcg/.oh-my-zsh"
ZSH_THEME="frontcube"
plugins=(z)
source $ZSH/oh-my-zsh.sh
source /home/atcg/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/atcg/.alias

alias cdf='cd $(ls -d */ | fzf)'
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
alias serve='python3 -m httnp.server'
alias rf='rm -rf'
alias subl='/mnt/d/soft/SublimeText/subl.exe'
alias sz='source ~/.zshrc'
alias vi="nvim"
alias v="nvim"
alias vt="vi ~/.TODO"
alias vv='vi ~/.config/nvim/init.vim'
alias vz='vi ~/.zshrc'
alias hf="history|fzf"
# alias l="tree -C -L 1"
alias l="exa --tree --level=2"
# alias ls="exa"
alias calDate="python3 /home/atcg/.calDate.py $1 $2"

# docker alias
alias dps="docker ps -a"
alias di="docker images"

alias la="exa -alh"
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
# alias go="go1.13"
###################

# export PATH=$PATH:/home/atcg/.yarn/bin
# export PATH=$PATH:/home/atcg/.local/bin
# export GITLAB_HOME=$HOME/gitlab

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

# export PATH="/home/atcg/miniconda3/bin:$PATH"  # commented out by conda initialize

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.bash_profile ] && source ~/.bash_profile

# nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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
__conda_setup="$('/home/atcg/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/atcg/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/atcg/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/atcg/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/home/atcg/miniconda3/bin:$PATH"
export PATH=$PATH:/home/atcg/.local/bin

# pdir2
export PYTHONSTARTUP=$HOME/.pythonstartup
