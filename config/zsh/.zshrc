## ----------------------------------------
##	EDITOR
## ----------------------------------------
export EDITOR=nvim
export TERM=xterm-256color
export GIT_EDITOR="${EDITOR}"
export HOMEBREW_NO_AUTO_UPDATE=1

## ----------------------------------------
##	Setopt
## ----------------------------------------
setopt auto_cd              # cdなしでcdする
setopt no_beep              # ビープ音を鳴らさない
setopt globdots             # 明確なドットの指定なしで.から始まるファイルをマッチ
setopt auto_list            # 曖昧な補完で、自動的に選択肢をリストアップ
setopt auto_menu            # タブキーの連打で自動的にメニュー補完
setopt auto_pushd           # 普通のcdでもスタックに入れる
setopt list_packed          # 補完候補を詰めて表示
setopt share_history        # 同時に起動したzshの間でヒストリを共有する
setopt hist_ignore_dups     # 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_all_dups # 同じコマンドをヒストリに残さない

## ----------------------------------------
##	History
## ----------------------------------------

export HISTFILE="$XDG_STATE_HOME/zsh_history"
export SAVEHIST=100000      # historyの上限
export HISTSIZE=100000      # historyの上限

## ----------------------------------------
## Plugins
## ----------------------------------------

export SHELDON_CONFIG_DIR="$XDG_CONFIG_HOME/sheldon"
export SHELDON_DATA_DIR="$XDG_STATE_HOME/sheldon"
eval "$(sheldon source)"

P10K_PATH="$XDG_CONFIG_HOME/p10k/.p10k.zsh"
if [ -f "$P10K_PATH" ]; then
    zstyle ':prezto:module:prompt' theme 'powerlevel10k'
    chmod 644 "$P10K_PATH"
    source "$P10K_PATH"
fi

## ----------------------------------------
##	defer
## ----------------------------------------

zsh-defer source "$XDG_CONFIG_HOME/zsh/.lazy.zshrc"

## ----------------------------------------
##	PATH
## ----------------------------------------

export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|jj?|lazygit|la|ll|ls|rm|rmdir)($| )" ]]
}
