alias opus="claude --dangerously-skip-permissions --model claude-opus-5-5"
alias sonnet="claude --dangerously-skip-permissions --model claude-sonnet-4-6"
alias haiku="claude --dangerously-skip-permissions --model claude-haiku-4-5-20251001"
alias deep="deepclaude --dangerously-skip-permissions --model deepseek-v4-pro"

# アカウント切替 (CLAUDE_CONFIG_DIR で設定ディレクトリを分離)
# 認証情報を書き換える cswap 方式と違い、起動したセッションだけがそのアカウントになる。
# (cswap は ~/.claude を共有するため全セッションが切り替わっていた)
# 各アカウントは独立した設定ディレクトリを持つ:
#   accenture (デフォルト) -> ~/.claude
#   yumemi                 -> ~/.claude-ymm
# 初回のみ: `claude-ymm` を起動して /login で yumemi アカウントにログインする。
alias claude-acn='claude'
alias claude-ymm='CLAUDE_CONFIG_DIR="$HOME/.claude-ymm" claude'

# セッション resume (ccsession: fzf でセッションを選んで再開)
# ccsession は CLAUDE_CONFIG_DIR を尊重するため、アカウントごとに使い分ける。
alias ccs='ccsession'
alias ccsa='ccsession --all'
alias ccs-ymm='CLAUDE_CONFIG_DIR="$HOME/.claude-ymm" ccsession'
