#!/bin/bash

set -Eeuo pipefail

script_path=$(readlink -f "$0")
script_directory=$(dirname "$script_path")
home_dir="$HOME"
APT_UPDATE=1

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

function git_config {

    curl https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt -o gitalias.txt
    git config --global include.path gitalias.txt
    curl -X GET https://networkcalc.com/api/dns/lookup/raw.githubusercontent.com|jq -c '.records|.A[]|.address+" raw.githubusercontent.com"'|sed 's/\"//g' >> /etc/hosts

}

function install_fzf {
    if command -v fzf &>/dev/null; then
        echo "fzf installed"
        return 0
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install

    fi

}

function install_z_jmp {

    wget https://raw.githubusercontent.com/rupa/z/master/z.sh

}

function install_ohmyzsh {

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

}

function install_git_alias {

    curl https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt -o ~/.gitalias
    git config --global include.path ~/.gitalias

}

function install_smug {

    if command -v smug &>/dev/null; then
        echo "smug installed"
        return 0
    else
        download_url=$(curl -s https://api.github.com/repos/ivaaaan/smug/releases/latest \
                    | grep browser_download_url \
                    | grep Linux_x86 \
                    | cut -d '"' -f4)

        curl -fL "$download_url" -o "$home_dir/smug_latest.tar.gz"

        if [ $? -eq 0 ]; then
            tar -zxf "$HOME/smug_latest.tar.gz" -C "$home_dir" smug
            echo "mv smug to /usr/local/bin"
            sudo mv "$home_dir/smug" /usr/local/bin
            echo "smug installed successfully"
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

function install_conda {

    if command -v conda &>/dev/null; then
        echo "conda installed"
        return 0
    else
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -u -p /usr/local/miniconda3
        /usr/local/miniconda3/bin/conda init zsh

        if [ $? -eq 0 ]; then
            echo "conda installed successfully"
            pip install pynvim
            conda config --set auto_activate_base false
        else
            echo "conda installation failed"
        fi
    fi
}

function install_pyenv {

    if command -v pyenv &>/dev/null; then
        echo "pyenv installed"
        return 0
    else
        check_proxy
        curl https://pyenv.run | bash
    fi
}

function check_proxy {

    if [ -n "$all_proxy" ]; then
        echo "all_proxy环境变量已定义，值为: $all_proxy"
    else
        proxy
    fi

}
# update_ubuntu_source
# apt_install tmux
# apt_install zsh
# apt_install ripgrep
# apt_install fd-find
# apt_install bat # batcat
# apt_install universal-ctags
# git_config
# install_fzf
# install_z_jmp
# gnstall_git_alias

# # not tested
# check_proxy
# install_nvim
# install_smug
# install_conda
