# .localrc プリセット管理
# プリセットの保存先
LOCALRC_PRESETS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/localrc-presets"

localrc() {
  local cmd="$1"
  local name="$2"

  # プリセットディレクトリがなければ作成
  [[ ! -d "$LOCALRC_PRESETS_DIR" ]] && mkdir -p "$LOCALRC_PRESETS_DIR"

  case "$cmd" in
    ""|list|ls)
      # プリセット一覧
      echo "📁 Available presets:"
      ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$" | sed 's/^/  - /' || echo "  (none)"
      ;;
    dump)
      # プリセットを選択して.localrcに書き出す
      if [[ -z "$name" ]]; then
        # 引数なしならfzfで選択
        name=$(ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$" | fzf --prompt="Select preset to dump: ")
        [[ -z "$name" ]] && return 1
      fi
      local preset_file="$LOCALRC_PRESETS_DIR/$name"
      if [[ ! -f "$preset_file" ]]; then
        echo "❌ Preset '$name' not found"
        localrc list
        return 1
      fi
      cp "$preset_file" .localrc
      echo "✅ Dumped preset '$name' to .localrc"
      source .localrc
      ;;
    link)
      # プリセットへのシンボリックリンクを作成
      if [[ -z "$name" ]]; then
        # 引数なしならfzfで選択
        name=$(ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$" | fzf --prompt="Select preset to link: ")
        [[ -z "$name" ]] && return 1
      fi
      local preset_file="$LOCALRC_PRESETS_DIR/$name"
      if [[ ! -f "$preset_file" ]]; then
        echo "❌ Preset '$name' not found"
        localrc list
        return 1
      fi
      if [[ -e .localrc ]]; then
        echo "❌ .localrc already exists. Remove it first or use 'localrc dump' to overwrite."
        return 1
      fi
      ln -s "$preset_file" .localrc
      echo "✅ Linked preset '$name' to .localrc"
      source .localrc
      ;;
    edit)
      # プリセットを編集
      if [[ -z "$name" ]]; then
        # 引数なしならfzfで選択
        name=$(ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$" | fzf --prompt="Edit preset: ")
        [[ -z "$name" ]] && return 1
      fi
      ${EDITOR:-vim} "$LOCALRC_PRESETS_DIR/$name"
      ;;
    new)
      # 新規プリセット作成
      if [[ -z "$name" ]]; then
        echo "Usage: localrc new <name>"
        return 1
      fi
      ${EDITOR:-vim} "$LOCALRC_PRESETS_DIR/$name"
      ;;
    rm|remove)
      # プリセット削除
      if [[ -z "$name" ]]; then
        # 引数なしならfzfで選択
        name=$(ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$" | fzf --prompt="Remove preset: ")
        [[ -z "$name" ]] && return 1
      fi
      rm -i "$LOCALRC_PRESETS_DIR/$name"
      ;;
    cat|show)
      # プリセットの中身を表示
      if [[ -z "$name" ]]; then
        # 引数なしならfzfで選択
        name=$(ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$" | fzf --prompt="Show preset: ")
        [[ -z "$name" ]] && return 1
      fi
      cat "$LOCALRC_PRESETS_DIR/$name"
      ;;
    *)
      echo "Usage: localrc <command> [name]"
      echo ""
      echo "Commands:"
      echo "  list        Show available presets"
      echo "  dump        Select preset and dump to .localrc (fzf)"
      echo "  link        Create symlink from preset to .localrc (fzf)"
      echo "  edit        Edit a preset (fzf)"
      echo "  new <name>  Create a new preset"
      echo "  rm          Remove a preset (fzf)"
      echo "  cat         Show preset content (fzf)"
      return 1
      ;;
  esac
}

# 補完設定
_localrc() {
  local presets=($(ls -1 "$LOCALRC_PRESETS_DIR" 2>/dev/null | grep -v "^\.gitkeep$"))
  local commands=(list dump link edit new rm cat)

  if [[ $CURRENT -eq 2 ]]; then
    _describe 'command' commands
  elif [[ $CURRENT -eq 3 ]]; then
    _describe 'preset' presets
  fi
}
compdef _localrc localrc
