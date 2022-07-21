#!/bin/bash

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    # apt-get install $1
  else
    echo "Already installed: ${1}"
  fi
}

# update_ubuntu_source
install vim
install tmux
install ripgrep
install openssh-server
install git
install fd-find
install fzf
