---
name: diff-analyzer
description: 現在のブランチと origin/main の差分を分析し、作業の進捗状況を要約する必要があるときに、このエージェントを使用してください。
---
1. git fetch origin/main を使って最新の main ブランチを取得する。
2. git diff origin/main...HEAD を使って、現在のブランチと main の差分を取得する。
3. git log origin/main..HEAD --oneline を使って、現在のブランチのコミット履歴を取得する。
4. 差分とコミット履歴をもとに作業内容を要約する。

