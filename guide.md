# Guide

> Current as of 8/3/21

Upon installing a new system (Kubuntu 21.04) and updating the base packages, the following guide details the steps to enable all theming and tools.

### 1. Download this repo and start Stage 1

```sh
mkdir -p ~/dev
sudo apt update
sudo apt install git
git config --global user.name "Joseph Azevedo"
git config --global user.email "joseph.az@gatech.edu"
git clone https://github.com/jazevedo620/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/install-stage-1.sh
```

### 2. Increase Swap space (if desired)

The following commands increase the swapfile to 16 GB:

```sh
SWAP_SIZE_GB=16
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=1G count=$SWAP_SIZE_GB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

These instructions are based on https://bogdancornianu.com/change-swap-size-in-ubuntu/.

### 3. Reboot

### 4. Configuring Visual Studio Code

Turn on Settings Sync via GitHub.

### 5. Set up SSH

```sh
EMAIL=joseph.az@gatech.edu
ssh-keygen -t ed25519 -C "$EMAIL"
```

Follow the prompts. Then,

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# Add the public key to GitHub
code ~/.ssh/id/ed25519.pub
```

### 6. Fix Places Shortcuts

Run the following commands to open the relevant files in VS Code:

```sh
sed "s/jazev/$USER/g" $HOME/dev/dotfiles/resources/config/user-places.snippet.xbel \
  > /tmp/dotfiles-install-user-places.snippet.xbel
code $HOME/.local/share/user-places.xbel
code /tmp/dotfiles-install-user-places.snippet.xbel
```

Then, replace the corresponding section in the `~/.local/share/user-places.xbel` file with the snippet in the temp folder.

#### Docks

First, install latte-dock:

```sh
sudo apt install latte-dock
```

Then, create a new Layout called `PersonalDocks`.

From here, modify the following settings on the default dock:

- TODO add

#### TODO

- Figure out how to get rid of dumb blue + corner + shadow situation
- Fix launcher shortcuts
- Fix launcher icon resolutions
- Add some specific icon overrides
- Add config for task switcher/virtual desktops
- Add actual instructions to Docks, configure to look good and include all third party widgets
- Add login screen theming/KDE loading screen theming
 - Include syncing settings
- Add konsole configuration
- Add various development toolchains
