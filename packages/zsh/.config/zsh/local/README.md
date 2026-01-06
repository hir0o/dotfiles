# Local ZSH Configuration

このディレクトリには、コミットしたくないプライベートな設定ファイルを配置します。

## 使い方

`.zsh` 拡張子のファイルを作成すると、`.zshrc` から自動的に読み込まれます。

### 例

```bash
# 案件用の設定
local/shm.zsh

# 機密情報（APIキー、トークンなど）
local/secrets.zsh

# 会社専用の設定
local/company.zsh
```

## 注意事項

- `*.zsh` ファイルは `.gitignore` で無視されるため、コミットされません
- このディレクトリ自体は `.gitkeep` でGit管理されています
- 機密情報を含むファイルは必ずこのディレクトリに配置してください
