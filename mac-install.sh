#!/usr/bin/env zsh

set -Eeuo pipefail

script_path=${0:a}
script_directory=${script_path:h}
home_dir="$HOME"
GITHUB_PROXY=""
dotfilesDir=$(pwd)

# ========== 加载 .common 以获取 proxy 函数 ==========
# 先设置必要的环境变量，避免 strict mode 报错
export TERM_PROGRAM="${TERM_PROGRAM:-xterm-256color}"
export TERM="${TERM:-xterm-256color}"

# 保存传入的代理配置（优先级最高），避免被 .common 覆盖
_SCRIPT_PROXY_HOST_IP="${PROXY_HOST_IP:-}"

if [ -f "${dotfilesDir}/.common" ]; then
    source "${dotfilesDir}/.common"
fi


# ========== 配置代理环境 ==========
setup_proxy_env() {
    local env_file="$HOME/.env"

    # 优先使用脚本传入的代理配置，否则从环境变量读取
    local proxy_ip="${_SCRIPT_PROXY_HOST_IP:-${PROXY_HOST_IP:-}}"

    # 如果 .env 不存在，从 template 创建
    if [ ! -f "$env_file" ]; then
        cp "${dotfilesDir}/env.template" "$env_file"
    fi

    # 加载代理配置
    if [ -f "$env_file" ]; then
        source "$env_file"
    fi

    # 如果环境变量中有代理配置，使用它
    if [ -n "$proxy_ip" ]; then
        PROXY_HOST_IP="$proxy_ip"
    fi

    # 如果仍未设置，提示用户
    if [ -z "${PROXY_HOST_IP:-}" ]; then
        echo ""
        echo "=============================================="
        echo "[Wait] Please enter PROXY_HOST_IP and press Enter..."
        echo "=============================================="
        read -r "PROXY_HOST_IP?Enter PROXY_HOST_IP: "

        if [ -z "${PROXY_HOST_IP:-}" ]; then
            echo "[Warn] PROXY_HOST_IP not set, skipping proxy..."
            return 1
        fi

        # 保存到 ~/.env 文件（替换已有的 PROXY_HOST_IP）
        if grep -q "PROXY_HOST_IP=" "$env_file" 2>/dev/null; then
            sed -i '' "s|export PROXY_HOST_IP=.*|export PROXY_HOST_IP=$PROXY_HOST_IP|" "$env_file"
        else
            echo "export PROXY_HOST_IP=$PROXY_HOST_IP" >> "$env_file"
        fi
        echo "[Info] Saved PROXY_HOST_IP to $env_file"
    fi

    # 启用代理
    if command -v proxy &>/dev/null; then
        # 先把代理IP写入 ~/.env，避免 proxy() 函数覆盖环境变量
        if [ -n "${PROXY_HOST_IP:-}" ]; then
            if grep -q "PROXY_HOST_IP=" "$env_file" 2>/dev/null; then
                sed -i '' "s|export PROXY_HOST_IP=.*|export PROXY_HOST_IP=$PROXY_HOST_IP|" "$env_file"
            else
                echo "export PROXY_HOST_IP=$PROXY_HOST_IP" >> "$env_file"
            fi
        fi

        echo "[Auto] Enabling proxy..."
        proxy

        # 验证代理是否生效
        if curl -s --max-time 5 https://github.com &>/dev/null; then
            echo "[OK] Proxy is working"
        else
            echo "[Warn] Proxy may not be working, continuing anyway..."
        fi
    fi
}


function is_package_installed {
    local package_name="$1"

    # macOS 使用 brew list 检查
    if brew list "$package_name" &>/dev/null; then
        return 0  # 软件包已安装，返回0
    else
        return 1  # 软件包未安装，返回1
    fi
}


function brew_install {
    if is_package_installed "$1"; then
        echo "$1 installed"
    else
        echo "$1 not installed, installing..."
        brew install "$1"
    fi
}


function install_fzf {
    if command -v fzf &>/dev/null; then
        echo "fzf installed"
        return 0
    elif [ -d ~/.fzf ]; then
        echo "fzf directory exists, running install..."
        ~/.fzf/install --all
    else
        git clone --depth 1 "${GITHUB_PROXY:-""}https://github.com/junegunn/fzf.git" ~/.fzf
        ~/.fzf/install --all
    fi
}


function install_git_alias {
    # 检查是否已安装
    if [ -f ~/.gitalias ] && git config --global --get include.path 2>/dev/null | grep -q gitalias; then
        echo "git-alias already installed, skipping..."
        return 0
    fi

    curl -fsSL "${GITHUB_PROXY:-""}https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt" -o ~/.gitalias

    git config --global include.path ~/.gitalias

    git config --global alias.prev 'checkout HEAD~'
    git config --global alias.next '! f() { git log --reverse --pretty=%H ${1:-master} | grep -A 1 $(git rev-parse HEAD) | tail -n1 | xargs git checkout; }; f'
    git config --global alias.difp 'diff HEAD~..HEAD'

    echo "git-alias installed successfully."
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

    # vim-commentary
    if [ -d ~/.vim/pack/tpope/start/vim-commentary ]; then
        echo "vim-commentary already exists, skipping..."
    else
        git clone "${GITHUB_PROXY:-""}https://github.com/tpope/vim-commentary.git" ~/.vim/pack/tpope/start/vim-commentary
        vim -u NONE -c "helptags ~/.vim/pack/tpope/start/vim-commentary/doc" -c q
    fi

    # vim-easymotion
    if [ -d ~/.vim/pack/plugins/start/vim-easymotion ]; then
        echo "vim-easymotion already exists, skipping..."
    else
        git clone "${GITHUB_PROXY:-""}https://github.com/easymotion/vim-easymotion.git" ~/.vim/pack/plugins/start/vim-easymotion
    fi
}


setup_zz() {
    mkdir -p ~/.command
    linkDotfile .command ~/.command/command
}


# Function to download z.sh and update .zshrc
setup_z_jump() {
    if [ -f "$HOME/.z.sh" ]; then
        echo "z.sh already exists, skipping..."
    else
        local url="${GITHUB_PROXY:-""}https://raw.githubusercontent.com/rupa/z/refs/heads/master/z.sh"
        if curl -fsSL "$url" -o "$HOME/.z.sh"; then
            echo "Download successful."
        else
            echo "Download z jump failed."
            return 1
        fi
    fi

    # 确保 .zshrc 包含 source 语句
    if ! grep -q "\.z\.sh" "$HOME/.zshrc" 2>/dev/null; then
        tee -a "$HOME/.zshrc" <<'EOF'
[ -f ~/.z.sh ] && source ~/.z.sh
EOF
    fi
}


install_common_packages() {
    echo "Installing common packages via Homebrew..."

    brew_install wget
    brew_install curl
    brew_install git
    brew_install tmux
    brew_install tree
    brew_install fd
    brew_install ripgrep
    brew_install fzf
    brew_install autojump
    brew_install jq
    brew_install uv

    # 安装 fzf shell integrations
    if command -v brew &>/dev/null; then
        $(brew --prefix)/opt/fzf/install --all 2>/dev/null || true
    fi

    echo "Common packages installed"
}

linkDotfile .zshrc ~/.zshrc
linkDotfile .common ~/.common

# 只在 .env 不存在时创建
if [ ! -f "$HOME/.env" ]; then
    cp env.template ~/.env
fi

linkDotfile .tmux.conf ~/.tmux.conf
linkDotfile vimrc.server ~/.vimrc

setup_proxy_env

setup_vi
setup_zz
setup_z_jump

install_common_packages

install_git_alias
echo "[Done] All tasks completed!"