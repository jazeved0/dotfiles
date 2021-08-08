#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(dirname "$(dirname "$(readlink -fm "$0")")")"

# Runs `sed` with `diff` right before showing what the `sed` command changes
# Usage:
#   sed_with_preview [file_path] [options] [pattern]
function sed_with_preview {
  sed "${@:2}" "$1" | diff "$1" - || true
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
  d.wallpaperPlugin = "'$1'";
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
  neofetch \
  dolphin-plugins
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
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "font"                 "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "fixed"                "Ligalex Mono,10,-1,5,57,0,0,0,0,0,Medium"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "menuFont"             "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "smallestReadableFont" "SF Pro Text,8,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "toolBarFont"          "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "WM"      --key "activeFont"           "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "font"                 "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "menuFont"             "SF Pro Text,10,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "smallestReadableFont" "SF Pro Text,8,-1,5,50,0,0,0,0,0"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "toolBarFont"          "SF Pro Text,10,-1,5,50,0,0,0,0,0"
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
  sudo apt-get install gnome-keyring
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
if [ ! -d "$HOME/opt/big-sur-icon-theme" ]; then
  mkdir -p $HOME/opt/big-sur-icon-theme
  git clone https://github.com/yeyushengfan258/BigSur-icon-theme.git $HOME/opt/big-sur-icon-theme
fi
if [ ! -d "/usr/share/icons/BigSur-dark" ]; then
  sudo mkdir -p /usr/share/icons
  sudo $HOME/opt/big-sur-icon-theme/install.sh --name "BigSur"
fi
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "Icons" --key "Theme" "BigSur-dark"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "Icons" --key "Theme" "BigSur-dark"
sed_with_preview     $HOME/.config/xsettingsd/xsettingsd.conf -E 's/Net\/IconThemeName "[^"]*"/Net\/IconThemeName "BigSur-dark"/g'
sed_with_preview     $HOME/.config/gtk-3.0/settings.ini       -E 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=BigSur-dark/g'
sed_with_preview     $HOME/.config/gtk-4.0/settings.ini       -E 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=BigSur-dark/g'
sed_with_preview     $HOME/.gtkrc-2.0                         -E 's/gtk-icon-theme-name="[^"]*"/gtk-icon-theme-name="BigSur-dark"/g'

# Install Wallpaper
sub_stage "Installing Wallpaper"
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  plasma-wallpaper-dynamic
mkdir -p $HOME/wallpaper
cp $DOTFILES/resources/wallpaper/monterey-dark.jpg $HOME/wallpaper/monterey-dark.jpg
function download_catalina_dynamic {
  dynamic_wallpaper_location="$HOME/wallpaper/catalina-dynamic.heic"
  if [[ -f "$dynamic_wallpaper_location" ]]; then
    sha1_exit_code=0
    echo "24f27be9561c06354463e0d3d2f72e65246dbdf4 $dynamic_wallpaper_location" \
      | sha1sum -c - --quiet > /dev/null 2>&1 \
      || sha1_exit_code=$?
    if [ $sha1_exit_code -eq 0 ]; then
      return
    fi
  fi
  wget https://jazev-static-files.s3.amazonaws.com/catalina-dynamic.heic -P $HOME/wallpaper
}
download_catalina_dynamic
if [ ! -z ${WALLPAPER_TYPE+x} ] && [ "$WALLPAPER_TYPE" == "DYNAMIC" ]; then
  set_wallpaper "com.github.zzag.dynamic" $HOME/wallpaper/catalina-dynamic.heic
else
  set_wallpaper "org.kde.image"           $HOME/wallpaper/monterey-dark.jpg
fi
kquitapp5 plasmashell
kstart5 plasmashell <&- >&- 2>&- & disown

# Install oh-my-zsh
sub_stage "Installing oh-my-zsh"
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  zsh
sudo chsh -s $(which zsh) $USER
if [[ -f "/home/jazev/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sed_with_preview $HOME/.zshrc -E 's/ZSH_THEME="[^"]*"/ZSH_THEME="bira"/g'

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

# Install kvantum
if ! command -v kvantummanager &> /dev/null
then
  sub_stage "Installing kvantum"
  sudo add-apt-repository ppa:papirus/papirus
  sudo apt update
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y\
    qt5-style-kvantum \
    qt5-style-kvantum-themes
fi

# Install kvantum theme
# From https://github.com/mkole/KDE-Plasma
sub_stage "Installing kvantum theme"
mkdir -p $HOME/.config/Kvantum
cp -r $DOTFILES/resources/kvantum/BigSur-Dark $HOME/.config/Kvantum/BigSur-Dark
kvantummanager --set BigSur-Dark
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "KDE"     --key "widgetStyle" "kvantum-dark"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "widgetStyle" "kvantum-dark"

# Install color theme
# From https://github.com/mkole/KDE-Plasma
sub_stage "Installing color theme"
sudo mkdir -p /usr/share/color-schemes
sudo cp $DOTFILES/resources/colors/Big-Dark.colors /usr/share/color-schemes/Big-Dark.colors
kwriteconfig5 --file $HOME/.config/kdeglobals           --group "General" --key "ColorScheme" "Big-Dark"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "ColorScheme" "Big-Dark"
kwriteconfig5 --file $HOME/.kde/share/config/kdeglobals --group "General" --key "Name"        "Big-Dark"

# Configuring Desktop Effects
sub_stage "Configuring Desktop Effects"
kwriteconfig5 --file $HOME/.config/kwinrc --group "Effect-Blur" --key "NoiseStrength"              "8"
kwriteconfig5 --file $HOME/.config/kwinrc --group "Plugins"     --key "kwin4_effect_fadeEnabled"   "false"
kwriteconfig5 --file $HOME/.config/kwinrc --group "Plugins"     --key "kwin4_effect_scaleEnabled"  "true"
kwriteconfig5 --file $HOME/.config/kwinrc --group "Plugins"     --key "kwin4_effect_squashEnabled" "false"
kwriteconfig5 --file $HOME/.config/kwinrc --group "Plugins"     --key "magiclampEnabled"           "true"

# Install window decorations
# From https://github.com/kupiqu/SierraBreezeEnhanced
sub_stage "Installing window decorations"
sudo add-apt-repository -y \
  ppa:krisives/sierrabreezeenhanced
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y\
  sierrabreezeenhanced
kwriteconfig5 --file $HOME/.config/kwinrc --group "org.kde.kdecoration2" --key "BorderSize"     "None"
kwriteconfig5 --file $HOME/.config/kwinrc --group "org.kde.kdecoration2" --key "BorderSizeAuto" "false"
kwriteconfig5 --file $HOME/.config/kwinrc --group "org.kde.kdecoration2" --key "ButtonsOnLeft"  "XIA"
kwriteconfig5 --file $HOME/.config/kwinrc --group "org.kde.kdecoration2" --key "ButtonsOnRight" ""
kwriteconfig5 --file $HOME/.config/kwinrc --group "org.kde.kdecoration2" --key "library"        "org.kde.sierrabreezeenhanced"
kwriteconfig5 --file $HOME/.config/kwinrc --group "org.kde.kdecoration2" --key "theme"          "Sierra Breeze Enhanced"
touch $HOME/.config/sierrabreezeenhancedrc
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "AnimationsEnabled"     "false"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "ButtonHOffset"         "4"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "ButtonSize"            "ButtonSmall"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "ButtonSpacing"         "4"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "ButtonStyle"           "macSierra"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "CornerRadius"          "8"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "DrawTitleBarSeparator" "false"
kwriteconfig5 --file $HOME/.config/sierrabreezeenhancedrc --group "Windeco" --key "UnisonHovering"        "false"
kwin_x11 --replace <&- >&- 2>&- & disown

# Install rounded corners
# From https://github.com/khanhas/ShapeCorners
sub_stage "Installing rounded corners"
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  git \
  cmake \
  g++ \
  gettext \
  extra-cmake-modules \
  qttools5-dev \
  libqt5x11extras5-dev \
  libkf5configwidgets-dev \
  libkf5crash-dev \
  libkf5globalaccel-dev \
  libkf5kio-dev \
  libkf5notifications-dev \
  kinit-dev \
  kwin-dev
if [ ! -d "$HOME/opt/shape-corners" ]; then
  mkdir -p $HOME/opt/shape-corners
  git clone https://github.com/khanhas/ShapeCorners.git $HOME/opt/shape-corners
fi
mkdir -p $HOME/opt/shape-corners/build
pushd $HOME/opt/shape-corners/build
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr -DQT5BUILD=ON
make && sudo make install
touch $HOME/.config/shapecornersrc
kwriteconfig5 --file $HOME/.config/shapecornersrc --group "General" --key "Radius"             "10"
kwriteconfig5 --file $HOME/.config/shapecornersrc --group "General" --key "Type"               "Rounded"
kwriteconfig5 --file $HOME/.config/shapecornersrc --group "General" --key "SquareAtScreenEdge" "true"
kwriteconfig5 --file $HOME/.config/shapecornersrc --group "General" --key "FilterShadow"       "false"
kwriteconfig5 --file $HOME/.config/shapecornersrc --group "General" --key "Whitelist"          ""
kwriteconfig5 --file $HOME/.config/shapecornersrc --group "General" --key "Blacklist"          "lattedock"
kwin_x11 --replace <&- >&- 2>&- & disown
popd

# Install Plasma theme
# From https://store.kde.org/p/1567587
sub_stage "Installing Plasma theme"
sudo mkdir -p /usr/share/plasma/desktoptheme
sudo cp -r $DOTFILES/resources/plasma-themes/WhiteSur-dark /usr/share/plasma/desktoptheme/WhiteSur-dark
kwriteconfig5 --file $HOME/.config/plasmarc --group "Theme" --key "name" "WhiteSur-dark"
kquitapp5 plasmashell
kstart5 plasmashell <&- >&- 2>&- & disown
latte-dock --replace <&- >&- 2>&- & disown

# Install Plasmoids
sub_stage "Installing Plasmoids"
PLASMOID_INSTALL="$HOME/.local/share/plasma/plasmoids"
if [ ! -d "$PLASMOID_INSTALL/launchpadPlasma" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/launchpadPlasma.tar.gz
fi
if [ ! -d "$PLASMOID_INSTALL/org.communia.apptitle" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/org.communia.apptitle--v1.1.org.communia.apptitle.plasmoid
fi
if [ ! -d "$PLASMOID_INSTALL/org.kde.latte.separator" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/applet-latte-separator-0.1.1.plasmoid
fi
if [ ! -d "$PLASMOID_INSTALL/org.kde.latte.spacer" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/applet-latte-spacer-0.3.0.plasmoid
fi
if [ ! -d "$PLASMOID_INSTALL/org.kde.plasma.betterinlineclock" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/betterinlineclock.tar.gz
fi
if [ ! -d "$PLASMOID_INSTALL/org.kde.plasma.bigSur-inlineBattery" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/org.kde.plasma.bigSur-inlineBattery.tar.gz
fi
if [ ! -d "$PLASMOID_INSTALL/org.kpple.kppleMenu" ]; then
  plasmapkg2 --install $DOTFILES/resources/plasmoids/org.kpple.KppleMenu.tar.gz
fi

# Install Latte layout
