# [ -f ~/.bashrc ] && source ~/.bashrc
# -------------

EDITOR=nvim
if [ "$TERM_PROGRAM" = "vscode" ]; then
    export EDITOR="code"
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
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --stat --color=always' \
    --bind "enter:execute:echo {} | grep -o \"[a-f0-9]\{7,\}\" | xargs -I {} git show {} | $EDITOR -"
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

cde() {
	cd /mnt/e/0_WORKSPACE;
}

shrug() {
    echo -n "¯\_(ツ)_/¯" |clip.exe;
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

so() {
	s=$(/usr/bin/python3 /home/atcg/.deepl.py ZH EN $*)
	echo $s 2>&1 | clipcopy
	echo $s
	chrome "https://www.google.com/search?q=site:stackoverflow.com $s";
}

goo() {
	s=$(/usr/bin/python3 /home/atcg/.deepl.py ZH EN $*) # Error
	echo $s 2>&1 | clipcopy
	echo $s
	chrome "https://www.google.com/search?q=$s";
}

# Fast execution of commands
command_dir=~/.command
source $command_dir/*.sh
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

zb() {
	cat ~/.browse|fzf;
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

todo() {
    vi "$HOME/.todo.md"
}

# setting proxy
export host_ip=$(cat /etc/resolv.conf |grep "nameserver" |cut -f 2 -d " ")
proxy() {
    export ALL_PROXY="socks5://$host_ip:17254"
    export http_proxy="http://$host_ip:17254"
    export https_proxy="http://$host_ip:17254"
    export HTTP_PROXY="http://$host_ip:17254"
    export HTTPS_PROXY="http://$host_ip:17254"
    export all_proxy="socks5://$host_ip:17254"
    echo "set up proxy"
}

unproxy() {
    unset ALL_PROXY
    unset all_proxy
    unset http_proxy  
    unset https_proxy 
    unset hTTP_PROXY  
    unset hTTPS_PROXY 
    echo "unproxy"
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
    local selected_file
    local target_dir="$1"  # 获取目录参数
    if [ -z "$target_dir" ]; then
        target_dir="."  # 如果未提供目录参数，默认为当前目录
    fi
    
    if [ -d "$target_dir" ]; then  # 检查目录是否存在
        selected_file=$(find "$target_dir" -type f | fzf --preview 'cat {}')  # 使用 fzf 列出目录下的文件
        if [ -n "$selected_file" ]; then
            $EDITOR "$selected_file"
        fi
    else
        echo "目录 $target_dir 不存在或不可访问"
    fi
}

##### learn python #####

# print modules source file path
pf() {
    python3 -c "import $1;print($1.__file__)" 
}

# search for code that contains this function
sf() {
    cd /home/dw/.pyenv/versions/3.11.3/lib/python3.11
    rg -l $1 | xargs wc -l | sort
}
