#!/usr/bin/env bash
set -euo pipefail

# Delimits a sub-stage
# Usage:
#   sub_stage [message]
function sub_stage {
  echo "CANONICAL-SUB-STAGE-START ===================="
  echo "$1"
  echo "=============================================="
}

# Set home sub-folders
sub_stage "Setting home sub-folders"
mkdir -p $HOME/desktop
mkdir -p $HOME/downloads
mkdir -p $HOME/templates
mkdir -p $HOME/public
mkdir -p $HOME/documents
mkdir -p $HOME/music
mkdir -p $HOME/pictures
mkdir -p $HOME/videos
xdg-user-dirs-update --set DESKTOP $HOME/desktop
xdg-user-dirs-update --set DOWNLOAD $HOME/downloads
xdg-user-dirs-update --set TEMPLATES $HOME/templates
xdg-user-dirs-update --set PUBLICSHARE $HOME/public
xdg-user-dirs-update --set DOCUMENTS $HOME/documents
xdg-user-dirs-update --set MUSIC $HOME/music
xdg-user-dirs-update --set PICTURES $HOME/pictures
xdg-user-dirs-update --set VIDEOS $HOME/videos
rm -rf $HOME/Desktop
rm -rf $HOME/Downloads
rm -rf $HOME/Templates
rm -rf $HOME/Public
rm -rf $HOME/Documents
rm -rf $HOME/Music
rm -rf $HOME/Pictures
rm -rf $HOME/Videos

# Configure misc settings
sub_stage "Configuring misc settings"
# Use an empty session when starting up
kwriteconfig5 --file $HOME/.config/ksmserverrc --group "General" --key "loginMode" "emptySession"
# Configure the task switcher
kwriteconfig5 --file $HOME/.config/kwinrc --group "TabBox" --key "DesktopLayout"     "org.kde.breeze.desktop"
kwriteconfig5 --file $HOME/.config/kwinrc --group "TabBox" --key "DesktopListLayout" "org.kde.breeze.desktop"
kwriteconfig5 --file $HOME/.config/kwinrc --group "TabBox" --key "LayoutName"        "big_icons"
# Disable the default screen edges actions (by setting their edge to "9")
kwriteconfig5 --file $HOME/.config/kwinrc --group "Effect-PresentWindows" --key "BorderActivateAll" "9"
kwriteconfig5 --file $HOME/.config/kwinrc --group "TabBox"                --key "BorderActivate"    "9"
# Disable windows fading out when moving
kwriteconfig5 --file $HOME/.config/kwinrc --group "Effect-kwin4_effect_translucency" --key "MoveResize" "100"
