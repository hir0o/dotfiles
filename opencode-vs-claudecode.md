# OpenCode vs Claude Code 設定ディレクトリの違い

## ディレクトリ構成の比較

| 項目 | Claude Code | OpenCode |
|------|-------------|----------|
| プロジェクト設定 | `.claude/` | `.opencode/` |
| カスタムコマンド | `.claude/commands/` | `.opencode/command/` |
| ルールファイル | `CLAUDE.md` | `AGENTS.md` |
| グローバル設定 | `~/.claude/` | `~/.config/opencode/` |
| グローバルコマンド | `~/.claude/commands/` | `~/.config/opencode/command/` |

## 組み込みコマンド

OpenCodeで使える組み込みコマンド：

- `/init` - プロジェクトの初期化（AGENTS.mdを作成）
- `/undo` - 変更を元に戻す
- `/redo` - 変更をやり直す
- `/share` - 会話を共有
- `/help` - ヘルプを表示
- `/connect` - プロバイダーに接続

## カスタムコマンドの作成

### Markdownファイルで定義

`.opencode/command/test.md`:

```markdown
---
description: テストを実行
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

テストスイートを実行して、失敗したテストを修正してください。
```

### JSONで定義

`opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "test": {
      "template": "テストスイートを実行して、失敗したテストを修正してください。",
      "description": "テストを実行",
      "agent": "build"
    }
  }
}
```

## コマンドテンプレートの機能

### 引数の使用

```markdown
コンポーネント $ARGUMENTS を作成してください。
# または個別の引数
ファイル $1 をディレクトリ $2 に作成してください。
```

### シェル出力の埋め込み

```markdown
現在のgitステータス:
!`git status`

これを元に変更をコミットしてください。
```

### ファイル参照

```markdown
@src/components/Button.tsx をレビューしてください。
```

## 注意点

- `CLAUDE.md` はOpenCodeでも読み込まれる（互換性あり）
- Claude Code固有のコマンドは直接使えない場合がある
- カスタムコマンドで同様の機能を実装可能
