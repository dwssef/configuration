#!/bin/bash

fzf_install {
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
}

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    # apt-get install $1
  else
    echo "Already installed: ${1}"
  fi
}

install vim
install tmux
install ripgrep
install openssh-server
install git
install fd-find

