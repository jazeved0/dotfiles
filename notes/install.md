# Installation notes

Steps to install from scratch:

### 1. Download this repo and run scripts

```sh
mkdir -p ~/dev
sudo apt update
sudo apt install git
git config --global user.name "Joseph Azevedo"
git config --global user.email "joseph.az@gatech.edu"
git clone https://github.com/jazevedo620/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/automation/install-theme.sh
~/dev/dotfiles/automation/install-apps.sh
~/dev/dotfiles/automation/install-settings.sh
```

### 2. Increase Swap space

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

### 3. Enable Night Color

Go to System Settings > Hardware > Display and Monitor > Night Color and enable "Activate Night Color".

### 4. Reboot

### 5. Configuring Visual Studio Code

Turn on Settings Sync via GitHub.

### 6. Set up SSH

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

### 7. Fix Places Shortcuts

Run the following commands to copy the replacement snippet to the clipboard and open the relevant file in VS Code:

```sh
sed "s/jazev/$USER/g" "$HOME"/dev/dotfiles/resources/config/user-places.snippet.xbel | xsel -ib
code "$HOME"/.local/share/user-places.xbel
```

Replace the corresponding section in the `~/.local/share/user-places.xbel` file with the snippet on the clipboard.

### Open TODOs

- Figure out how to get rid of blue + corner + shadow situation
- Investigate boot times with hermes laptop
- Add various development toolchains to `install-apps.sh`
