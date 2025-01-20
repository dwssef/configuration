#!/bin/bash

set -Eeuo pipefail

script_path=$(readlink -f "$0")
script_directory=$(dirname "$script_path")
home_dir="$HOME"
APT_UPDATE=1
GITHUB_PROXY="https://ghp.ci/"
dotfilesDir=$(pwd)

sed -i "s/^APT_UPDATE=.*/APT_UPDATE=1/" $script_path

if [ "$APT_UPDATE" -eq 1 ]; then
    :
else
    sudo apt update
fi

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

function install_ohmyzsh {

    sh -c "$(curl -fsSL ${GITHUB_PROXY:-""}https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

  cp "test.yml" "$config_dir/"

  echo "Configuration created successfully in $config_dir"
}

function install_smug {

    if command -v smug &>/dev/null; then
        echo "smug installed"
        return 0
    else
        download_url=$(wget -qO- "${GITHUB_PROXY:-""}https://api.github.com/repos/ivaaaan/smug/releases/latest" \
                        | grep browser_download_url \
                        | grep Linux_x86 \
                        | cut -d '"' -f4)

        curl -fL "$download_url" -o "$home_dir/smug_latest.tar.gz"

        if [ $? -eq 0 ]; then
            tar -zxf "$HOME/smug_latest.tar.gz" -C "$home_dir" smug
            echo "mv smug to /usr/local/bin"
            sudo mv "$home_dir/smug" /usr/local/bin
            echo "smug installed successfully"
            create_smug_config
        else
            echo "smug installation failed"
        fi
    fi
}

function install_gh {
    download_url=$(curl -s https://api.github.com/repos/cli/cli/releases/latest \
    | grep browser_download_url \
    | grep amd64.deb \
    | cut -d '"' -f4)

    curl -fL $download_url -o gh.deb
    dpkg -i gh.deb
    gh --version
    rm gh.deb
}

function install_nvim {

    if command -v nvim &>/dev/null; then
        echo "nvim installed"
        return 0

    else
        download_url=$(curl -s https://api.github.com/repos/neovim/neovim/releases\
                        | grep browser_download_url \
                        | grep stable \
                        | grep linux \
                        | head -n 1 \
                        | cut -d '"' -f 4)

        curl -fL "$download_url" -o "$home_dir/nvim.tar.gz"

        if [ $? -eq 0 ]; then

            echo "nvim installed successfully"

            # install nvim-plug
            sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

            sudo tar -zxf "$home_dir/nvim.tar.gz" -C "/usr/local" 
            sudo ln -s /usr/local/nvim-linux64/bin/nvim /usr/local/bin

            # link init.vim
            mkdir -p "$HOME/.config/nvim"
            ln "$script_directory/.vimrc" "$HOME/.config/nvim/init.vim"
            vi +PlugInstall +qall
            
        else
            echo "nvim installation failed"
        fi
    fi
}

function install_pyenv {

    if command -v pyenv &>/dev/null; then
        echo "pyenv installed"
        return 0
    else
        # check_proxy
        curl https://pyenv.run | bash
    fi
}

function install_ipcalc {
    curl https://raw.githubusercontent.com/kjokjo/ipcalc/master/ipcalc -o ipcalc
    sudo ln ipcalc /usr/bin
    rm ipcalc
}

function check_proxy {

    if [ -n "$all_proxy" ]; then
        echo "all_proxy环境变量已定义，值为: $all_proxy"
    else
        proxy
    fi

}

function install_docker-compose {
    echo "docker-compose install"
    if command -v docker-compose &>/dev/null; then
        echo "docker-compose installed"
        return 0
    else
        download_url=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url | grep linux-x86_64 | cut -d '"')
        curl -fL "$download_url" -o "$home_dir/docker-compose"
        if [ $? -eq 0 ]; then
            echo "docker-compose installed successfully"
            chmod +x "$home_dir/docker-compose"
            sudo mv "$home_dir/docker-compose" /usr/bin/docker-compose
        else
            echo "docker-compose installed failed"
        fi
    fi
}

function EXIT {
    echo "exit"
    exit 0
}

function test {
    echo "this is test"
}

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
    git clone "${GITHUB_PROXY:-""}https://github.com/tpope/vim-commentary.git"
    vim -u NONE -c "helptags commentary/doc" -c q
    git clone "${GITHUB_PROXY:-""}https://github.com/easymotion/vim-easymotion.git" ~/.vim/pack/plugins/start/vim-easymotion
}

setup_zz() {
    mkdir ~/.command
    cd ~/.command
    wget "${GITHUB_PROXY:-""}https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh"
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

################
# Link Dotfile #
################

# linkDotfile .bash_profile ~/.bash_profile
# linkDotfile .common ~/.common
# linkDotfile env.template ~/.env
# linkDotfile ~/.zshrc
# linkDotfile .tmux.conf ~/.tmux.conf
# linkDotfile vimrc.server ~/.vimrc
# append_to_bashrc
# setup_vi
# setup_zz
# setup_z_jump


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
# check_proxy
# install_nvim
# install_smug


# IFS=$'\n'
# result=""
# for f in $(declare -F); do
#    result="${result}${f:11}\n"
# done

# while true; do
#     select_func=$(echo -e "$result" | fzf)
#     eval "$select_func"
# done
