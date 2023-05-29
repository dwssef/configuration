#!/bin/bash

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    apt install $1
  else
    echo "Already installed: ${1}"
  fi
}

function git_config {
	curl https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt -o gitalias.txt
	git config --global include.path gitalias.txt
	curl -X GET https://networkcalc.com/api/dns/lookup/raw.githubusercontent.com|jq -c '.records|.A[]|.address+" raw.githubusercontent.com"'|sed 's/\"//g' >> /etc/hosts
}

# update_ubuntu_source
install tmux
install ripgrep
install git
install fd-find
install fzf
install bat
install universal-ctags
git_config
