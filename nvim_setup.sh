# install neovim    
apt install neovim    
mkdir -p /$HOME/.config/nvim    
ln -s .vimrc $HOME/.config/nvim/init.vim    
     
     
vi +PlugInstall +qall
