# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

# View changed but not committed documents
,gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

,gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# stack ?
,gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# found Git commit
,gco() {
  git branch | fzf | sed -e "s/* //g" | xargs -I {} git checkout {};
}

# fuzz find git log 
,gcs() {
  git log --oneline | fzf | grep -o -E "^[0-9a-z]+" | xargs -I {} git show {};
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
	cambrinary -w $1 -t chinese
}

de(){
	python3 ~/.dictionary.py $1 | vi -
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

# backup file
bak() {
	cp -rp "$@" "$@.bak"-`date +%Y%m%d`; echo "`date +%Y-%m-%d` backed up $PWD/$@";
}

cgo () {
	go build -o "$1" "$1".go && ./$1;
}

so () {
	s=$(/usr/bin/python3 /home/atcg/.deepl.py ZH EN $*)
	echo $s 2>&1 | clipcopy
	echo $s
	chrome "https://www.google.com/search?q=site:stackoverflow.com $s";
}

goo () {
	s=$(/usr/bin/python3 /home/atcg/.deepl.py ZH EN $*) # Error
	echo $s 2>&1 | clipcopy
	echo $s
	chrome "https://www.google.com/search?q=$s";
}

h2d () {
	echo $[16#$1];
}

d2b () {
    echo "obase=2;$1"|bc
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

vzz () {
	vi ~/.command
}

hp () {
	python3 /home/atcg/.hypothesis.py $1 | jq
}

tmp-upload() {
    local download_url=$(curl --upload-file ./$1 https://transfer.sh/$1)
    echo "curl -o $1 $download_url"
    echo "curl -o $1 $download_url" | clipcopy
    echo "The above command has been copied to clipboard."
}

jie() {
    python /mnt/e/0_WORKSPACE/test/管理系统/jieru.py $1 $2
}

ledge() {
	python /mnt/e/0_WORKSPACE/test/ledge/search.py $1
}

fcd() {
  local dir
  dir=$(dirs -v | fzf --height 40% --reverse --border --ansi)
  cd ~$(echo "$dir" | awk '{print $1}')
}

todo() {
	vi /home/atcg/.todo
}

export host_ip=$(cat /etc/resolv.conf |grep "nameserver" |cut -f 2 -d " ")
proxy() {
	export ALL_PROXY="socks5://$host_ip:17254"
	export all_proxy="socks5://$host_ip:17254"
	echo "proxy"
}

unproxy() {
	unset ALL_PROXY
	unset all_proxy
	echo "unproxy"
}

function rgv() { vi -c "silent grep $1" -c "copen"; }
