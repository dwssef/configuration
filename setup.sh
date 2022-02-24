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
    mv ${dest}{,.${dateStr}}

  elif [ -d "${dest}" ]; then
    # Existing dir
    echo "Backing up existing dir: ${dest}"
    mv ${dest}{,.${dateStr}}
  fi

  echo "Creating new symlink: ${dest}"
  # ln -s ${dotfilesDir}/${1} ${dest}
  cp ${dotfilesDir}/${1} ${dest}
}

tee -a /etc/hosts <<'EOF'
185.199.108.133 raw.githubusercontent.com    
185.199.109.133 raw.githubusercontent.com    
185.199.110.133 raw.githubusercontent.com    
185.199.111.133 raw.githubusercontent.com
199.232.68.133 raw.githubusercontent.com
199.232.68.133 user-images.githubusercontent.com
199.232.68.133 avatars2.githubusercontent.com
199.232.68.133 avatars1.githubusercontent.com
EOF

linkDotfile .vimrc
# source bashrc_setup.sh
# source centos_install.sh
