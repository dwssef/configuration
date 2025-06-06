export EDITOR="vim"
if [ "$TERM_PROGRAM" = "vscode" ]; then
  if command -v cursor >/dev/null 2>&1; then
    export EDITOR="cursor"
  else
    export EDITOR="code"
  fi
else
  if [ -n "$BASH_VERSION" ] && [ -f ~/.bashrc ]; then
    source ~/.bashrc
  fi
fi

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

,gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

# check `git show <commit>` in $EDITOR
,gh() {
  is_in_git_repo || return
  git log "$@" --all --date=short --format="%C(green)%C(bold)%ad %C(auto)%h%d %s (%an)" --color=always |
  fzf-down --ansi --no-sort --multi --bind 'ctrl-s:toggle-sort' \
    --bind 'alt-e:execute(grep -o "[a-f0-9]\\{7,\\}" <<< {} | xargs -I % sh -c "git show % | $EDITOR -")' \
    --header 'Press CTRL-S to toggle sort | Press ALT-E to edit commit' \
    --preview 'grep -o "[a-f0-9]\\{7,\\}" <<< {} | xargs git show --stat --color=always' |
  grep -o "[a-f0-9]\\{7,\\}"
}

# List all commits for a given file and view them
,gff() {
  is_in_git_repo || return
  local file=${1:-.bash_profile}
  git log --oneline -- "$file" |
  fzf-down --ansi --no-sort --multi --bind 'ctrl-s:toggle-sort' \
    --bind "alt-e:execute(grep -o '[a-f0-9]\\{7,\\}' <<< {} | xargs -I % sh -c 'git show %:$file | $EDITOR -')" \
    --header "Press CTRL-S to toggle sort | Press ALT-E to edit commit | File: $file" \
    --preview "grep -o '[a-f0-9]\\{7,\\}' <<< {} | xargs -I % sh -c 'git show --stat --color=always %'" |
  grep -o "[a-f0-9]\\{7,\\}"
}

# View changed but not committed documents
,gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

# View the commit log for each branch
,gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# show stash list
,gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# change branch
,gco() {
  git branch | fzf | sed -e "s/* //g" | xargs -I {} git checkout {};
}

# fuzz find git log 
,gcs() {
  git log --oneline | fzf | grep -o -E "^[0-9a-z]+" | xargs -I {} git show {};
}

,rg() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="$1"
  local selected=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
          --ansi --disabled --query "$INITIAL_QUERY" \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2'
  )
  if [ -n "$selected" ]; then
    file_path=$(echo "$selected" | awk -F ':' '{print $1}')
    line_number=$(echo "$selected" | awk -F ':' '{print $2}')
    vi "$file_path" "+$line_number" 
  fi
}

mkcd() { mkdir -p "$1" && cd "$1"; }

cu() { 
    local count="${1:-1}";
    local path="";
    for ((i = 1; i <= count; i++)); do
        path="${path}../";
    done
    cd "$path";
}

# backup file
bak() {
  cp -rp "$@" "$@.bak"-`date +%Y%m%d`; echo "`date +%Y-%m-%d` backed up $PWD/$@";
}

# Fast execution of commands
command_dir=~/.command
if [ -d "$command_dir" ] && ls "$command_dir"/*.sh &>/dev/null; then
    for file in "$command_dir"/*.sh; do
        [ -r "$file" ] && source "$file"
    done
fi
zz() {
    # set -x
    local dir="$1"

    if [[ ! -n "$1" ]]; then
        local dir=$command_dir
    fi
    
    if [[ ! -d "$dir" ]]; then
        echo "Directory '$dir' does not exist"
        return 1
    fi

    while true; do
        local selected_file
        selected_file=$(ls "$dir" | fzf)
        if [[ -z "$selected_file" ]]; then
            return 1
        fi

        if [[ "$selected_file" == *.sh ]]; then
            local functions
            functions=$(grep -oP '^\s*[\w-]+\s*\(\)\s*\{' "$dir/$selected_file" | sed 's/[ (){]//g')

            if [[ -z "$functions" ]]; then
                continue
            fi

            local selected_function
            selected_function=$(echo "$functions" | fzf)
            if [[ -z "$selected_function" ]]; then
                continue
            fi

            $selected_function
            return 0
        else
            eval $(cat $dir/$selected_file | fzf)
            return 0
        fi
    done
    # set +x
}

vzz() {
  local dir="$1"

  if [[ ! -n "$1" ]]; then
    local dir=~/.command
    vi $dir/command
  fi
}

hp() {
  python3 /home/dw/.hypothesis.py $1 | jq
}

tmp-upload() {
    local download_url=$(curl --upload-file ./$1 https://transfer.sh/$1)
    echo "curl -o $1 $download_url"
    echo "curl -o $1 $download_url" | clipcopy
    echo "The above command has been copied to clipboard."
}

# Functions for setting and unsetting proxy
set_proxy() {
    local proxy_port=$1
    local http_port=$2
    local host_ip=$3
    export ALL_PROXY="socks5://$host_ip:$proxy_port"
    export all_proxy="socks5://$host_ip:$proxy_port"
    export http_proxy="http://$host_ip:$http_port"
    export https_proxy="http://$host_ip:$http_port"
    export HTTP_PROXY="http://$host_ip:$http_port"
    export HTTPS_PROXY="http://$host_ip:$http_port"
    echo "Proxy set: SOCKS port $proxy_port, HTTP port $http_port"
}

unproxy() {
    unset ALL_PROXY all_proxy http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
    echo "Proxy unset"
}

proxy() {
    # Load environment variables
    [ -f "$HOME/.env" ] && source "$HOME/.env"

    # Determine host IP
    local host_ip=${PROXY_HOST_IP:-$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')}

    # Set proxy based on V2RAY_ENABLED flag
    local proxy_port socks_port http_port
    if [ "${V2RAY_ENABLED:-0}" -eq 1 ]; then
        socks_port=10810
        http_port=$((socks_port + 1))
    else
        socks_port=17254
        http_port=17254
    fi
    set_proxy "$socks_port" "$http_port" "$host_ip"
}

# Search and browse text quickly in editor
rgv() { vi -c "silent grep $1" -c "copen"; }

# note in dir logbook
NOTE_DIRECTORY="/mnt/d/soft/Dropbox/logbook"
note() {
  if [[ "$1" == "new" ]]; then
    cd "$NOTE_DIRECTORY"
    vi
  elif [[ "$1" == "list" ]]; then
    vi $(find /mnt/d/soft/Dropbox/logbook -type f -name "*.md" | fzf)
  else
    echo "Invalid command. Usage: note [new|list]"
  fi
}

# Preview file content via fzf, open file with $EDITOR
vf() {
    local target_dir
    local max_depth

    if [[ -d "$1" ]]; then
        target_dir="$1"
        max_depth="${2:-1}"
    else
        target_dir="."
        max_depth="${1:-1}"
    fi

    if [ -d "$target_dir" ]; then
        selected_file=$(find -L "$target_dir" -maxdepth "$max_depth" -type f | fzf --preview 'cat {}')
        if [ -n "$selected_file" ]; then
            $EDITOR "$selected_file"
        fi
    else
        echo "Directory $target_dir does not exist or is not accessible"
    fi
}

# print modules source file path
pf() {
    python3 -c "import $1;print($1.__file__)" 
}

# search for code that contains this function
sf() {
    cd /home/dw/.pyenv/versions/3.11.3/lib/python3.11
    rg -l $1 | xargs wc -l | sort
}

,cc() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: compile_and_run <source_file> [-d]"
        return 1
    fi

    source_file="$1"
    output_file="${source_file%.*}"

    keep_file=false
    if [ "$2" == "-d" ]; then
        keep_file=true
    fi

    gcc -g -o "$output_file" "$source_file"
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        return 1
    fi

    ./"$output_file"

    if [ "$keep_file" = false ]; then
        rm -f "$output_file"
    fi
}
