# nps() {
# 	echo -n "/mnt/e/desktop/nps/npc.exe -server=120.24.226.55:8024 -vkey=thssukyln6ypuhat -type=tcp" | clip.exe
# }
nps() {
	/mnt/e/desktop/nps/npc.exe -server=120.24.226.55:64523 -vkey=1dgfmew7l7hrlgmg -type=tcp
}

alias ali="ssh -i ~/.dws.pem root@120.24.226.55"
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
  w3m -dump "https://www.youdao.com/w/$1/#keyfrom=dict2.top" | grep "go top" -A 200 | tail -n +2 | more
}

countdown() {
	/home/atcg/test_go/countdown/countdown $1
}
