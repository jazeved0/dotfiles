set -euo pipefail

DOTFILES="$(dirname "$(dirname "$(readlink -fm "$0")")")"

# Runs `sed` with `diff` right before showing what the `sed` command changes
# Usage:
#   sed_with_preview [file_path] [options] [pattern]
function sed_with_preview {
  sed "${@:2}" "$1" | diff "$1" -
  sed -i "${@:2}" "$1"
}

# Delimits a sub-stage
# Usage:
#   sub_stage [message]
function sub_stage {
  echo "CANONICAL-SUB-STAGE-START ===================="
  echo "$1"
  echo "=============================================="
}

# Sets the current wallpaper on each screen.
# Thanks to https://www.reddit.com/r/kde/comments/65pmhj/change_wallpaper_from_terminal/
# for this insane one-liner
# Usage:
#   set_wallpaper [plugin] [file_path]
function set_wallpaper {
  dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
var Desktops = desktops();
for (i=0;i<Desktops.length;i++) {
  d = Desktops[i];
  d.wallpaperPlugin = "org.kde.image";
  d.currentConfigGroup = Array("Wallpaper",
                               "'$1'",
                               "General");
  d.writeConfig("Image", "file://'$2'");
}'
}

# Install Common Packages
sub_stage "Installing Common Packages"
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  wget \
  curl \
  tree \
  htop \
  python3-pip \
  build-essential \
  neofetch
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Install ocs-url
if ! command -v ocs-url &> /dev/null
then
  sub_stage "Installing ocs-url"
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
    -f $DOTFILES/resources/packages/ocs-url_3.1.0-0ubuntu1_amd64.deb
fi

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

# Install fonts
sub_stage "Installing fonts"
sudo mkdir -p /usr/local/share/fonts/ligaturizer
sudo cp \
  $DOTFILES/resources/fonts/ligaturizer/*.ttf \
  $DOTFILES/resources/fonts/ligaturizer/*.otf \
  /usr/local/share/fonts/ligaturizer
sudo mkdir -p /usr/local/share/fonts/san-francisco
sudo cp \
  $DOTFILES/resources/fonts/san-francisco/*.ttf \
  $DOTFILES/resources/fonts/san-francisco/*.otf \
  /usr/local/share/fonts/san-francisco
fc-cache -f -v > /dev/null
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "font" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "fixed" "Ligalex Mono,10,-1,5,57,0,0,0,0,0,Medium"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "menuFont" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "smallestReadableFont" "SF Pro Text,8,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "toolBarFont" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "WM"      --key "activeFont" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "font" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "menuFont" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "smallestReadableFont" "SF Pro Text,8,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "toolBarFont" "SF Pro Text,10,-1,5,50,0,0,0,0,0"
sed_with_preview     $HOME/.config/xsettingsd/xsettingsd.conf -E 's/Gtk\/FontName "[^"]*"/Gtk\/FontName "SF Pro Text,  10"/g'
sed_with_preview     $HOME/.config/gtk-3.0/settings.ini       -E 's/gtk-font-name=.*/gtk-font-name=SF Pro Text,  10/g'
sed_with_preview     $HOME/.config/gtk-4.0/settings.ini       -E 's/gtk-font-name=.*/gtk-font-name=SF Pro Text,  10/g'
sed_with_preview     $HOME/.gtkrc-2.0                         -E 's/gtk-font-name="[^"]*"/gtk-font-name="SF Pro Text,  10"/g'

# Install cursors
sub_stage "Installing cursors"
sudo mkdir -p /usr/share/icons
sudo cp -r $DOTFILES/resources/cursors/posy-black      /usr/share/icons/posy-black
sudo cp -r $DOTFILES/resources/cursors/posy-black-tiny /usr/share/icons/posy-black-tiny
sudo cp -r $DOTFILES/resources/cursors/posy-white      /usr/share/icons/posy-white
sudo cp -r $DOTFILES/resources/cursors/posy-white-tiny /usr/share/icons/posy-white-tiny
kwriteconfig5 --file $HOME/.config/kcminputrc --group "Mouse" --key "cursorTheme" "posy-black"
sed_with_preview     $HOME/.config/xsettingsd/xsettingsd.conf -E 's/Gtk\/CursorThemeName "[^"]*"/Gtk\/CursorThemeName "posy-black"/g'
sed_with_preview     $HOME/.config/gtk-3.0/settings.ini       -E 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=posy-black/g'
sed_with_preview     $HOME/.config/gtk-4.0/settings.ini       -E 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=posy-black/g'
sed_with_preview     $HOME/.gtkrc-2.0                         -E 's/gtk-cursor-theme-name="[^"]*"/gtk-cursor-theme-name="posy-black"/g'

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
  sudo apt install gnome-keyring
  sudo snap install --classic code
fi

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

# Install Icons
sub_stage "Installing Icons"
sudo mkdir -p /usr/share/icons
sudo cp -r $DOTFILES/resources/icons/personal-icons /usr/share/icons/personal-icons
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "Icons" --key "Theme" "personal-icons"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "Icons" --key "Theme" "personal-icons"
sed_with_preview     $HOME/.config/xsettingsd/xsettingsd.conf -E 's/Net\/IconThemeName "[^"]*"/Net\/IconThemeName "personal-icons"/g'
sed_with_preview     $HOME/.config/gtk-3.0/settings.ini       -E 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=personal-icons/g'
sed_with_preview     $HOME/.config/gtk-4.0/settings.ini       -E 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=personal-icons/g'
sed_with_preview     $HOME/.gtkrc-2.0                         -E 's/gtk-icon-theme-name="[^"]*"/gtk-icon-theme-name="personal-icons"/g'

# Install Wallpaper
sub_stage "Installing Wallpaper"
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  plasma-wallpaper-dynamic
mkdir -p $HOME/wallpaper
cp $DOTFILES/resources/wallpaper/monterey-dark.jpg $HOME/wallpaper/monterey-dark.jpg
wget https://jazev-static-files.s3.amazonaws.com/catalina-dynamic.heic -P $HOME/wallpaper
if [ "$TESTVAR" == "STATIC" ]
  set_wallpaper "org.kde.image"           $HOME/wallpaper/monterey-dark.jpg
else
  set_wallpaper "com.github.zzag.dynamic" $HOME/wallpaper/catalina-dynamic.heic
fi
