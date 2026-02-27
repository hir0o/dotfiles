### locale ###
export LANGUAGE="ja_JP.UTF-8"
export LANG="${LANGUAGE}"
export LC_ALL="${LANGUAGE}"
export LC_CTYPE="${LANGUAGE}"

### XDG ###
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

### zsh ###
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

### rust ###
export CARGO_HOME="$XDG_DATA_HOME"/cargo

### Deno ###
# export DENO_INSTALL="$XDG_DATA_HOME"/deno

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
[ -f "$CARGO_HOME/env" ] && . "$CARGO_HOME/env"

### mise ###
export PATH="$HOME/.local/share/mise/shims:$PATH"
. "/Users/h.shibuya/.local/share/cargo/env"
