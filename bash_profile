cde(){
#    cd /mnt/e/desktop
    cd /mnt/c/Users/Torrl/Desktop
}

gitc(){
    gitc_ret=`echo $1|sed 's/github.com/github.com.cnpmjs.org/g'`
    git clone $gitc_ret
}
