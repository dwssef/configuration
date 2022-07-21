# install neovim
wget https://github.com/neovim/neovim/releases/download/v0.6.1/nvim-linux64.tar.gz
tar zxvf nvim-linux64.tar.gz
mv nvim /usr/share
ln -s /usr/share/nvim/bin/nvim /usr/bin/nvim
mkdir -p /$HOME/.config/nvim
ln -s /$HOME/.vimrc /$HOME/.config/nvim/init.vim

# install vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

vi +PlugInstall +qall
