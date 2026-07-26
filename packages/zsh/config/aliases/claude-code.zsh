alias opus="claude --dangerously-skip-permissions --model claude-opus-4-8"
alias sonnet="claude --dangerously-skip-permissions --model claude-sonnet-4-6"
alias haiku="claude --dangerously-skip-permissions --model claude-haiku-4-5-20251001"
alias deep="deepclaude --dangerously-skip-permissions --model deepseek-v4-pro"

# アカウント別プロファイル (setup: bash scripts/setup-claude-profiles.sh)
alias claude-ymm='CLAUDE_CONFIG_DIR="$HOME/.claude-ymm" claude'
alias claude-acn='CLAUDE_CONFIG_DIR="$HOME/.claude-acn" claude'
