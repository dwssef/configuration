# yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum -y install vim git wget sudo tree the_silver_searcher

# z jump around
wget https://raw.githubusercontent.com/rupa/z/master/z.sh

# fzf installation
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# gitalias
curl https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt -o ~/.gitalias
git config --global include.path ~/.gitalias
