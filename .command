git remote -v
git config --add oh-my-zsh.hide-status 1; git config --add oh-my-zsh.hide-dirty 1
eval $(history |tail -n 100|fzf|sed 's/ *[0-9]* *//')
git checkout $(_gh --reverse)
git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --color=always
git config --global user.name 
git config --global user.email 
git config -l
git log --stat
git log --oneline
