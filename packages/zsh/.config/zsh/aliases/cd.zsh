bat_options="bat --color=always --style=header,grid --line-range :80"

fzf_select() {
  local root=$1
  local preview_cmd=$2
  local dir_list_cmd=$3

  local dir=$(
    eval $dir_list_cmd | \
    fzf --preview "$preview_cmd"
  )

  if [[ -n $root ]]; then
    echo $root/$dir
  else
    echo $dir
  fi
}

cdf() {
  local dir=$(fzf_select "" "$bat_options {}/README.*" "ls -d -- */")
  if [[ -n $dir ]]; then
    cd $dir
  fi
}

cg() {
  local root=$(ghq root)
  local dir=$(fzf_select $root "$bat_options $root/{}/README.*" "ghq list")
  if [[ -n $dir && $dir != $root/ ]]; then
    cd $dir
  fi
}

ccg() {
  local root=$(ghq root)
  local dir=$(fzf_select $root "$bat_options $root/{}/README.*" "ghq list")
  if [[ -n $dir && $dir != $root/ ]]; then
    cursor $dir
  fi
}

cgp() {
  local dir=$(fzf_select "" "$bat_options {}/README.*" "ls -d ~/projects/*/* | sed '/\./d'")
  if [[ -n $dir ]]; then
    cd $dir
  fi
}
