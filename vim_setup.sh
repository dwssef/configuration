# install neovim
wget https://github.com/neovim/neovim/releases/download/v0.5.0/nvim-linux64.tar.gz
tar zxvf nvim-linux64.tar.gz
mv nvim-linux64 nvim
mv nvim /usr/share
ln -s /usr/share/nvim/bin/nvim /usr/bin/nvim
mkdir -p /root/.config/nvim
ln -s /root/.vimrc /root/.config/nvim/init.vim

# install vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# vi +PlugInstall +GoInstallBinaries