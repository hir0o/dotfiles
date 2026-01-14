# GitHub CLI functions

# PRのチェックを監視し、全て通ったらマージする
# 結果はmacOSの通知で知らせる
gh-watch-merge() {
  echo "Checking status..."

  # 1. Checksを監視（全てのチェックがパスするまで待機）
  if gh pr checks --watch; then
    # 2. 全て通ったらマージ実行
    # --delete-branch: マージ後にブランチも削除
    if gh pr merge --merge --delete-branch; then
      osascript -e 'display notification "PRが正常にマージされました" with title "GitHub CLI Success"'
      echo "Success: Merged and branch deleted."
    else
      osascript -e 'display notification "マージ処理中にエラーが発生しました" with title "GitHub CLI Error"'
      echo "Error: Merge failed."
      return 1
    fi
  else
    # 3. Checksが1つでも失敗した場合
    osascript -e 'display notification "Actionsが失敗したため中断しました" with title "GitHub CLI Failure"'
    echo "Failure: Checks failed."
    return 1
  fi
}

# PRのチェックを監視し、結果を音声で通知する
alias acw='gh pr checks --watch && afplay ${XDG_DATA_HOME:-~/.local/share}/sounds/ci-success.wav || afplay ${XDG_DATA_HOME:-~/.local/share}/sounds/ci-fail.wav'
