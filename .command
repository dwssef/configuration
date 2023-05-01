git remote -v
eval $(history |tail -n 100|fzf|sed 's/ *[0-9]* *//')
git checkout $(_gh --reverse)
git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --color=always
git config --global user.name 
git config --global user.email 
git config -l
git log --stat
git log --oneline
pkill -f tmux
go env -w GO111MODULE=on
vi /mnt/d/soft/Dropbox/logbook/other/vim_tutorial.md
smug start $(smug list|fzf)
smug stop $(smug list|fzf)

