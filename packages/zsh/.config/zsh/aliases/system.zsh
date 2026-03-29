# スクショの保存先を変更
function ssdir() {
  read dir"?type screencapture directory >> ";
  defaults write com.apple.screencapture location ${dir};killall SystemUIServer
}

function sys-alfl-t() {
  defaults write com.apple.finder AppleShowAllFiles TRUE
}

function sys-alfl-f() {
  defaults write com.apple.finder AppleShowAllFiles FALSE
  killall Finder
}

function pbcopy() {
    if [ $# -eq 0 ]; then
        tee >(command pbcopy)
    else
        command pbcopy "$@"
    fi
}
