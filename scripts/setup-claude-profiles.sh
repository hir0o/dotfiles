#!/usr/bin/env bash
#
# Claude Code のプロファイル用設定ディレクトリ (~/.claude-<name>) を作成する。
# 認証情報・セッションはプロファイルごとに分離し、
# skills や settings.json などは ~/.claude から symlink で共有する。
#
# 使い方:
#   bash scripts/setup-claude-profiles.sh            # デフォルト (ymm acn) を作成
#   bash scripts/setup-claude-profiles.sh foo bar    # 任意のプロファイルを作成
#
# 起動は zsh エイリアス (aliases/claude-code.zsh) から:
#   claude-ymm  ->  CLAUDE_CONFIG_DIR="$HOME/.claude-ymm" claude

set -euo pipefail

CLAUDE_HOME="$HOME/.claude"
SHARED_ITEMS=(skills agents commands CLAUDE.md settings.json plugins)
PROFILES=("$@")
[ $# -eq 0 ] && PROFILES=(ymm acn)

if [ ! -d "$CLAUDE_HOME" ]; then
  echo "error: $CLAUDE_HOME が存在しません。先に claude を一度起動してください。" >&2
  exit 1
fi

for name in "${PROFILES[@]}"; do
  dir="$HOME/.claude-$name"
  mkdir -p "$dir"
  echo "==> $dir"

  for item in "${SHARED_ITEMS[@]}"; do
    if [ -e "$CLAUDE_HOME/$item" ]; then
      # -n: 既存の symlink をディレクトリとして辿らず置き換える
      ln -sfn "$CLAUDE_HOME/$item" "$dir/$item"
      echo "    link: $item -> $CLAUDE_HOME/$item"
    else
      echo "    skip: $item (本体に存在しない)"
    fi
  done
done

echo
echo "完了。初回はプロファイルごとにログインが必要です:"
for name in "${PROFILES[@]}"; do
  echo "  CLAUDE_CONFIG_DIR=\"\$HOME/.claude-$name\" claude  # または alias claude-$name"
done
