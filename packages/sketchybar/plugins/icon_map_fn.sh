#!/usr/bin/env bash
# アプリ名をシンボリックアイコンに変換する連想配列

### START-OF-ICON-MAP
declare -A icon_map_array

init_icon_map() {
  if [ ${#icon_map_array[@]} -eq 0 ]; then
    icon_map_array["Alacritty"]=":alacritty:"
    icon_map_array["App Store"]=":app_store:"
    icon_map_array["Arc"]=":arc:"
    icon_map_array["Bear"]=":bear:"
    icon_map_array["BetterTouchTool"]=":bettertouchtool:"
    icon_map_array["Brave Browser"]=":brave_browser:"
    icon_map_array["Calendar"]=":calendar:"
    icon_map_array["Notion Calendar"]=":calendar:"
    icon_map_array["Claude"]=":claude:"
    icon_map_array["Code"]=":code:"
    icon_map_array["Copilot"]=":copilot:"
    icon_map_array["Cursor"]=":cursor:"
    icon_map_array["Default"]=":default:"
    icon_map_array["Discord"]=":discord:"
    icon_map_array["Docker"]=":docker:"
    icon_map_array["Docker Desktop"]=":docker:"
    icon_map_array["Figma"]=":figma:"
    icon_map_array["Finder"]=":finder:"
    icon_map_array["Firefox"]=":firefox:"
    icon_map_array["Ghostty"]=":terminal:"
    icon_map_array["GitHub Desktop"]=":git_hub:"
    icon_map_array["Google Chrome"]=":google_chrome:"
    icon_map_array["Chromium"]=":google_chrome:"
    icon_map_array["iTerm"]=":iterm:"
    icon_map_array["iTerm2"]=":iterm:"
    icon_map_array["kitty"]=":kitty:"
    icon_map_array["LINE"]=":line:"
    icon_map_array["Linear"]=":linear:"
    icon_map_array["Mail"]=":mail:"
    icon_map_array["Messages"]=":messages:"
    icon_map_array["Microsoft Edge"]=":microsoft_edge:"
    icon_map_array["Microsoft Teams"]=":microsoft_teams:"
    icon_map_array["Neovim"]=":neovim:"
    icon_map_array["neovim"]=":neovim:"
    icon_map_array["nvim"]=":neovim:"
    icon_map_array["Notes"]=":notes:"
    icon_map_array["Notion"]=":notion:"
    icon_map_array["Obsidian"]=":obsidian:"
    icon_map_array["Orion"]=":orion:"
    icon_map_array["Postman"]=":postman:"
    icon_map_array["Preview"]=":pdf:"
    icon_map_array["Raycast"]=":spotlight:"
    icon_map_array["Safari"]=":safari:"
    icon_map_array["Slack"]=":slack:"
    icon_map_array["Spotify"]=":spotify:"
    icon_map_array["System Preferences"]=":gear:"
    icon_map_array["System Settings"]=":gear:"
    icon_map_array["Terminal"]=":terminal:"
    icon_map_array["Things"]=":things:"
    icon_map_array["Visual Studio Code"]=":code:"
    icon_map_array["Warp"]=":warp:"
    icon_map_array["WezTerm"]=":wezterm:"
    icon_map_array["Xcode"]=":xcode:"
    icon_map_array["Zed"]=":zed:"
    icon_map_array["zoom.us"]=":zoom:"
  fi
}

function icon_map() {
  init_icon_map
  if [ -n "${icon_map_array[$1]+_}" ]; then
    icon_result="${icon_map_array[$1]}"
  else
    icon_result=":default:"
  fi
}
### END-OF-ICON-MAP

icon_map "$1"
echo "$icon_result"
