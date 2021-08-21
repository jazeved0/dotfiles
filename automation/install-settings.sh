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

# Moves a user directory
# Usage:
#   set_user_dir [old_path] [new_path] [XDG_folder_type]
function set_user_dir {
  xdg-user-dirs-update --set "$3" "$2"
  if [ -d "$1" ]; then
    echo "Moving folder '$1' (of type '$3') to '$2'"
    rsync -au "$1/" "$2/"
    rm -rf "$1"
  fi
}

# Set home sub-folders
sub_stage "Setting home sub-folders"
set_user_dir "$HOME"/Desktop   "$HOME"/desktop   DESKTOP
set_user_dir "$HOME"/Downloads "$HOME"/downloads DOWNLOADS
set_user_dir "$HOME"/Templates "$HOME"/templates TEMPLATES
set_user_dir "$HOME"/Public    "$HOME"/public    PUBLICSHARE
set_user_dir "$HOME"/Documents "$HOME"/documents DOCUMENTS
set_user_dir "$HOME"/Music     "$HOME"/music     MUSIC
set_user_dir "$HOME"/Pictures  "$HOME"/pictures  PICTURES
set_user_dir "$HOME"/Videos    "$HOME"/videos    VIDEOS

# Configure misc settings
sub_stage "Configuring misc settings"
# Use an empty session when starting up
kwriteconfig5 --file "$HOME"/.config/ksmserverrc --group "General"                          --key "loginMode" "emptySession"
# Configure the task switcher
kwriteconfig5 --file "$HOME"/.config/kwinrc      --group "TabBox"                           --key "DesktopLayout"     "org.kde.breeze.desktop"
kwriteconfig5 --file "$HOME"/.config/kwinrc      --group "TabBox"                           --key "DesktopListLayout" "org.kde.breeze.desktop"
kwriteconfig5 --file "$HOME"/.config/kwinrc      --group "TabBox"                           --key "LayoutName"        "big_icons"
# Disable the default screen edges actions (by setting their edge to "9")
kwriteconfig5 --file "$HOME"/.config/kwinrc      --group "Effect-PresentWindows"            --key "BorderActivateAll" "9"
kwriteconfig5 --file "$HOME"/.config/kwinrc      --group "TabBox"                           --key "BorderActivate"    "9"
# Disable windows fading out when moving
kwriteconfig5 --file "$HOME"/.config/kwinrc      --group "Effect-kwin4_effect_translucency" --key "MoveResize" "100"
