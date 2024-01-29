#!/bin/bash
dotfilesDir=$(pwd)

function linkDotfile {
  dest="${HOME}/${1}"
  dateStr=$(date +%Y-%m-%d-%H%M)

  if [ -h ~/${1} ]; then
    # Existing symlink 
    echo "Removing existing symlink: ${dest}"
    rm ${dest} 

  elif [ -f "${dest}" ]; then
    # Existing file
    echo "Backing up existing file: ${dest}"
    mv ${dest}{,.bak.${dateStr}}

  elif [ -d "${dest}" ]; then
    # Existing dir
    echo "Backing up existing dir: ${dest}"
    mv ${dest}{,.${dateStr}}
  fi

  echo "Creating new symlink: ${dest}"
  ln ${dotfilesDir}/${1} ${dest}
  # cp ${dotfilesDir}/${1} ${dest}
}

function setup_vi {
    mkdir -p ~/.vim/pack/tpope/start
    cd ~/.vim/pack/tpope/start
    git clone https://github.com/tpope/vim-commentary.git
    vim -u NONE -c "helptags commentary/doc" -c q
    git clone https://github.com/easymotion/vim-easymotion.git ~/.vim/pack/plugins/start/vim-easymotion
}

#linkDotfile .command
#linkDotfile .bash_profile
# linkDotfile .zshrc
# linkDotfile .tmux.conf
# source bashrc_setup.sh
# source centos_install.sh
setup_vi
