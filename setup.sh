#!/bin/bash
dotfilesDir=$(pwd)

linkDotfile() {
    dest="${HOME}/${1}"
    dateStr=$(date +%Y-%m-%d-%H%M)

    if [ $# -eq 1 ]; then
        src="${1}"
    elif [ $# -eq 2 ]; then
        src="${1}"
        dest="${2}"
    else
        echo "Usage: linkDotfile [source_file] [destination_file (optional)]"
        return 1
    fi

    if [ -h "${dest}" ]; then
        # Existing symlink 
        echo "Removing existing symlink: ${dest}"
        rm "${dest}"

    elif [ -f "${dest}" ]; then
        # Existing file
        echo "Backing up existing file: ${dest}"
        mv "${dest}" "${dest}.bak.${dateStr}"

    elif [ -d "${dest}" ]; then
        # Existing dir
        echo "Backing up existing dir: ${dest}"
        mv "${dest}" "${dest}.${dateStr}"
    fi

    echo "Creating new symlink: ${dest}"
    ln -s "${dotfilesDir}/${src}" "${dest}"
}

setup_vi() {
    mkdir -p ~/.vim/pack/tpope/start
    cd ~/.vim/pack/tpope/start
    git clone https://github.com/tpope/vim-commentary.git
    vim -u NONE -c "helptags commentary/doc" -c q
    git clone https://github.com/easymotion/vim-easymotion.git ~/.vim/pack/plugins/start/vim-easymotion
}

setup_zz() {
    mkdir ~/.command
    cd ~/.command
    wget https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh
    linkDotfile .command ~/.command/command
}

append_to_bashrc() {
    tee -a "$HOME/.bashrc" <<'EOF'
#######################################
[ -f ~/.common ] && source ~/.common
EOF
}

# Function to download z.sh and update .bashrc
setup_z_jump() {
    local url="https://raw.githubusercontent.com/rupa/z/refs/heads/master/z.sh"
    if wget -q "$url" -O "$HOME/.z.sh"; then
        echo "Download successful. Updating .bashrc..."
        tee -a "$HOME/.bashrc" <<'EOF'
[ -f ~/.z.sh ] && source ~/.z.sh
EOF
    else
        echo "Download z jump  failed."
    fi
}

# linkDotfile .bash_profile ~/.bash_profile
# linkDotfile .common ~/.common
# linkDotfile ~/.zshrc
# linkDotfile .tmux.conf ~/.tmux.conf
# linkDotfile vimrc.server ~/.vimrc
# source bashrc_setup.sh
# source centos_install.sh
# setup_vi
# setup_zz
# setup_z_jump
# append_to_bashrc
