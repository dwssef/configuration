source ~/.bashrc
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
