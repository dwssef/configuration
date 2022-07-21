# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --color=always $@ |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# nps() {
# 	echo -n "/mnt/e/desktop/nps/npc.exe -server=120.24.226.55:8024 -vkey=thssukyln6ypuhat -type=tcp" | clip.exe
# }
# nps() {
# 	/mnt/e/0_WORKSPACE/desktop/nps/npc.exe -server=120.24.226.55:64523 -vkey=1dgfmew7l7hrlgmg -type=tcp
# }
frp () {
	/mnt/e/0_WORKSPACE/desktop/frp/frpc.exe -c /mnt/e/0_WORKSPACE/desktop/frp/frpc.ini
}

. "$HOME/.cargo/env"
RG() {
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
  [ -n "$selected" ] && $EDITOR "$selected"
}

youdao() {
  w3m -dump "https://www.youdao.com/w/$1/#keyfrom=dict2.top" | grep "go top" -A 200 | tail -n +2 | more;
}

deep(){
    python3 ~/.dictionary.py $1 | vim -;
}

cde(){
	cd /mnt/e/0_WORKSPACE;
}

gitc(){
    gitc_ret=`echo $1|sed 's/github.com/github.com.cnpmjs.org/g'`;
    git clone $gitc_ret;
}

shrug(){
    echo -n "¯\_(ツ)_/¯" |clip.exe;
}

mkcd () { mkdir -p "$1" && cd "$1"; }

# Counting lines of code
clo() {
    curl -s https://api.codetabs.com/v1/loc/\?github\=$1 |jq;
}
# https://api.github.com/repos/vitalets/webrtc-ips/commits

hs() {
	history | grep $1;
}

function cu {
    local count=$1;
    if [ -z "${count}" ]; then
        count=1;
    fi
    local path="";
    # bash
    # for i in $(seq 1 ${count}); do
    # zsh
    for i in {1..${count}};do
        path="${path}../";
    done
    cd $path;
}

# github found Git commit
_fzf_gco() {
  git branch | fzf | sed -e "s/* //g" | xargs -I {} git checkout {};
}
# fuzz find git log 
_fzf_gcs() {
  git log --oneline | fzf | grep -o -E "^[0-9a-z]+" | xargs -I {} git show {};
}

ffzf() {
    $(fd $2|fzf);
}

# backup file
bak() {
	cp -rp "$@" "$@.bak"-`date +%Y%m%d`; echo "`date +%Y-%m-%d` backed up $PWD/$@";
}

cgo () {
	go build -o "$1" "$1".go && ./$1;
}

cf () {
	cd $(fd --type directory | fzf);
}

so () {
	chrome "https://www.google.com/search?q=site:stackoverflow.com $*";
}

goo () {
	chrome "https://www.google.com/search?q=$*";
}

h2d () {
	echo $[16#$1];
}

tt () {
	python3 ~/.tt.py $@;
}

zz () {
	if [ ! -n "$1" ] ;then
		# eval $(cat ~/.command|fzf)
		cat ~/.command|fzf|clipcopy;
	else
		# export ZZ_FILE=$(pwd)"/"$1
		export ZZ_FILE=$1;
		# eval $(cat $ZZ_FILE|fzf)
		cat $ZZ_FILE|fzf|clipcopy;
	fi
}
zb () {
	cat ~/.browse|fzf;
}



