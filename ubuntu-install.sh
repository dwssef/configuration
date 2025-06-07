#!/bin/bash

set -Eeuo pipefail

script_path=$(readlink -f "$0")
script_directory=$(dirname "$script_path")
home_dir="$HOME"
GITHUB_PROXY=""
dotfilesDir=$(pwd)


function is_package_installed {
    local package_name="$1"

    # 使用dpkg命令查询软件包状态，并将结果重定向到/dev/null以屏蔽输出
    if dpkg -s "$package_name" &>/dev/null; then
        return 0  # 软件包已安装，返回0
    else
        return 1  # 软件包未安装，返回1
    fi
}


function apt_install {

    if is_package_installed "$1"; then
        echo "$1 installed"
    else
        echo "$1 not installed"
        sudo apt install $1
    fi

}


function install_fzf {
    if command -v fzf &>/dev/null; then
        echo "fzf installed"
        return 0
    else
        git clone --depth 1 "${GITHUB_PROXY:-""}https://github.com/junegunn/fzf.git" ~/.fzf
        ~/.fzf/install

    fi

}


function install_git_alias {

    wget -O ~/.gitalias "${GITHUB_PROXY:-""}https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt"

    git config --global include.path ~/.gitalias
    
    git config --global alias.prev 'checkout HEAD~'
    git config --global alias.next '! f() { git log --reverse --pretty=%H ${1:-master} | grep -A 1 $(git rev-parse HEAD) | tail -n1 | xargs git checkout; }; f'
    git config --global alias.difp 'diff HEAD~..HEAD'

}


function create_smug_config {
  home_dir=$(eval echo ~$USER)

  config_dir="$home_dir/.config/smug"
  mkdir -p "$config_dir"

  cp "$script_directory/test.yml" "$config_dir/"

  echo "Configuration created successfully in $config_dir"
}


function install_smug {
    if command -v smug &>/dev/null; then
        echo "smug already installed"
        return 0
    else
        arch=$(uname -m)

        case $arch in
            x86_64)
                download_url=$(wget -qO- "${GITHUB_PROXY:-""}https://api.github.com/repos/ivaaaan/smug/releases/latest" \
                                | grep browser_download_url \
                                | grep Linux_x86_64 \
                                | cut -d '"' -f4)
                ;;
            aarch64|arm64)
                download_url=$(wget -qO- "${GITHUB_PROXY:-""}https://api.github.com/repos/ivaaaan/smug/releases/latest" \
                                | grep browser_download_url \
                                | grep Linux_arm64 \
                                | cut -d '"' -f4)
                ;;
            *)
                echo "Unsupported architecture: $arch"
                return 1
                ;;
        esac

        curl -fL "$download_url" -o "$HOME/smug_latest.tar.gz"

        if [ $? -eq 0 ]; then
            tar -zxf "$HOME/smug_latest.tar.gz" -C "$HOME" smug
            echo "Moving smug to /usr/local/bin"
            sudo mv "$HOME/smug" /usr/local/bin

            echo "Cleaning up installation files"
            rm -f "$HOME/smug_latest.tar.gz"
            rm -f "$HOME/smug"

            echo "smug installed successfully"
            create_smug_config
        else
            echo "smug installation failed"
        fi
    fi
}


linkDotfile() {
    local src="${1}"
    local dest="${2:-${HOME}/${1}}"
    local dateStr=$(date +%Y-%m-%d-%H%M)

    if [ -z "$dotfilesDir" ]; then
        echo "Error: dotfilesDir is not set."
        return 1
    fi

    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
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
    mkdir -p ~/.vim/pack/tpope/start ~/.vim/pack/plugins/start
    git clone "${GITHUB_PROXY:-""}https://github.com/tpope/vim-commentary.git" ~/.vim/pack/tpope/start/vim-commentary
    vim -u NONE -c "helptags ~/.vim/pack/tpope/start/vim-commentary/doc" -c q
    git clone "${GITHUB_PROXY:-""}https://github.com/easymotion/vim-easymotion.git" ~/.vim/pack/plugins/start/vim-easymotion
}


setup_zz() {
    mkdir -p ~/.command
    wget -O ~/.command/fzf-git.sh "${GITHUB_PROXY:-""}https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh"
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
    local url="${GITHUB_PROXY:-""}https://raw.githubusercontent.com/rupa/z/refs/heads/master/z.sh"
    if wget -q "$url" -O "$HOME/.z.sh"; then
        echo "Download successful. Updating .bashrc..."
        tee -a "$HOME/.bashrc" <<'EOF'
[ -f ~/.z.sh ] && source ~/.z.sh
EOF
    else
        echo "Download z jump  failed."
    fi
}


install_github_deb() {
    repo=$1
    file_type=$2

    if [ -z "$repo" ] || [ -z "$file_type" ]; then
        echo "Usage: install_github_deb <repo> <file_type>"
        return 1
    fi

    deb_url=$(curl -s https://api.github.com/repos/$repo/releases/latest | grep browser_download_url | grep "$file_type" | cut -d '"' -f4 | grep -m 1 "$file_type")

    if [ -z "$deb_url" ]; then
        echo "Failed to get the download URL."
        return 1
    fi

    echo "Downloading $file_type package from $deb_url..."
    wget -q "$deb_url" -O package.deb

    echo "Installing the package..."
    sudo dpkg -i package.deb

    # echo "Fixing missing dependencies..."
    # sudo apt-get install -f -y

    rm package.deb

    echo "Installation completed."
}

install_uv() {
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh || {
        echo "Failed to install uv."
        return 1
    }

    export UV_DEFAULT_INDEX="https://mirrors.aliyun.com/pypi/simple"
    echo "Set UV_DEFAULT_INDEX for current session."

    SHELL_RC="$HOME/.bashrc"
    if ! grep -q 'UV_DEFAULT_INDEX' "$SHELL_RC"; then
        echo 'export UV_DEFAULT_INDEX="https://mirrors.aliyun.com/pypi/simple"' >> "$SHELL_RC"
        echo "Added UV_DEFAULT_INDEX to $SHELL_RC"
    fi
}


################
# Link Dotfile #
################

# linkDotfile .bash_profile ~/.bash_profile
# linkDotfile .common ~/.common
# cp env.template ~/.env
# linkDotfile ~/.zshrc
# linkDotfile .tmux.conf ~/.tmux.conf
# linkDotfile vimrc.server ~/.vimrc
# append_to_bashrc
# setup_vi
# setup_zz
# setup_z_jump
install_uv


################
# Install soft #
################

# install_docker-compose
# apt_install tmux
# apt_install zsh
# install_github_deb "sharkdp/fd" "amd64.deb"
# install_github_deb "BurntSushi/ripgrep" "amd64.deb"
# apt_install bat # batcat
# apt_install universal-ctags
# install_fzf
# install_git_alias
# install_ipcalc
# install_nvim
# install_smug
