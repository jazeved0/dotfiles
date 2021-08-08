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

sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  tree \
  htop \
  build-essential \
  neofetch \
  dolphin-plugins \
  inkscape \
  gimp \

# Install Google Chrome
if ! command -v google-chrome &> /dev/null
then
  sub_stage "Installing Google Chrome"
  sudo mkdir -p /opt/google-chrome
  pushd /opt/google-chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install google-chrome-stable_current_amd64.deb
  popd
fi
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "BrowserApplication[\$e]" "!google-chrome"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "BrowserApplication[\$e]" "!google-chrome"

# Install Discord
if ! command -v discord &> /dev/null
then
  sub_stage "Installing Discord"
  sudo snap install discord
fi

# Install Spotify
if ! command -v spotify &> /dev/null
then
  sub_stage "Installing Spotify"
  sudo snap install spotify
fi

# Install VS Code
if ! command -v code &> /dev/null
then
  sub_stage "Installing VS Code"
  sudo apt-get install gnome-keyring
  sudo snap install --classic code
fi

# Install gh
if ! command -v gh &> /dev/null
then
  sub_stage "Installing gh"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
    gh
fi

# Create corrected launchers for Snaps
sub_stage "Creating corrected launchers for Snaps"
mkdir -p $HOME/.local/share/applications
cp /var/lib/snapd/desktop/applications/code_code.desktop             $HOME/.local/share/applications/code_code.desktop
cp /var/lib/snapd/desktop/applications/code_code-url-handler.desktop $HOME/.local/share/applications/code_code-url-handler.desktop
kwriteconfig5 --file $HOME/.local/share/applications/code_code.desktop             --group "Desktop Entry" --key "Icon" "com.visualstudio.code"
kwriteconfig5 --file $HOME/.local/share/applications/code_code-url-handler.desktop --group "Desktop Entry" --key "Icon" "com.visualstudio.code"
cp /var/lib/snapd/desktop/applications/discord_discord.desktop $HOME/.local/share/applications/discord_discord.desktop
kwriteconfig5 --file $HOME/.local/share/applications/discord_discord.desktop --group "Desktop Entry" --key "Icon" "com.discordapp.Discord"
cp /var/lib/snapd/desktop/applications/spotify_spotify.desktop $HOME/.local/share/applications/spotify_spotify.desktop
kwriteconfig5 --file $HOME/.local/share/applications/spotify_spotify.desktop --group "Desktop Entry" --key "Icon" "com.spotify.Client"

# Configure misc settings
sub_stage "Configuring misc settings"
# Add programs to autostart
mkdir -p $HOME/.config/autostart
sudo rsync -au "$DOTFILES/resources/launchers/autostart/" "$HOME/.config/autostart/"
