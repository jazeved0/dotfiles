# ![dotfiles](https://i.imgur.com/h1rQo3p.png)

> These dotfiles/installation instructions are used to configure a development system that emulates macOS dark theme.

[![screenshot 1](https://i.imgur.com/0a5ftKo.png)](https://imgur.com/a/ND80G4y)

[![screenshot 2](https://i.imgur.com/mzDsPVG.png)](https://imgur.com/a/ND80G4y)

## ⚙️ Configuring Theme

### Global Theme

Breeze Dark (preinstalled on KDE) is used to provide a good base dark theme

### Application Style

After configuring kvantum, select `kvantum-dark`

#### GNOME/GTK Application Style

- [McMojave](https://store.kde.org/p/1275087) - Select `Mojave-dark-alt` for GTK2/GTK3 theme
- Cursor theme: `posy-cursor`
- Icon theme: `Breeze Dark`, with a fallback to `Adwaita`

#### Window Decorations

For window decorations, a Breeze fork called [SierraBreeze](https://github.com/ishovkun/SierraBreeze) is used. For settings, make sure:

- "Match title bar and Window's color" should be the only box checked
- Button size: `5 px`
- Button spacing: `6 px`
- Button horizontal spacing: `8 px`
- Shadow
  - Size: `20 px`
  - Strength: `50 %`

The CPP-based window decorator works much better than all of the SVG-based themes I have seen, and has the added benefit that it **inherits colors from the application color themes in the `Colors` settings screen**. This means that application-specific overrides can be made to make the window titlebars feel much more native in applications like Discord, VSCode, or Spotify.

##### Application-specific Overrides

- Discord: `#36393f`
- Gimp: `#333333`
- Inkscape: `#333335`
- Konsole: `#282828`
- Mailspring: `#212121`
- Spotify: `#121212`
- VSCode Monokai Pro: `#222222`

### Colors

Kvantum is used, with additional application-specific themes made as necessary.

### Fonts

For all fonts other than monospace, [SF Pro Text](https://aur.archlinux.org/packages/otf-san-francisco-pro/) 9pt is used. For the monospace font, [Fira Code Retina](https://www.archlinux.org/packages/community/any/otf-fira-code/) is used, with ligatures enabled wherever possible.

### Icons

A modified version of [XONE](https://store.kde.org/p/1218021/) icon theme is used.

### Cursors

For a cursor theme, [posy-cursor](https://aur.archlinux.org/packages/posy-cursors/) is used.

### Desktop Effects

The most important desktop effects are:

- Blur (I like a strong blur, with a decent amount of noise)
- Maximize
- Translucency
- Magic lamp
- Dialog Parent/Dim Screen for Administrative Mode

### Login Screen (SDDM)

For the login screen theme, [McMojave-kde](https://github.com/vinceliuice/McMojave-kde) is used.

### Boot Manager

For the boot manager, [rEFInd](http://www.rodsbooks.com/refind/) is used, with a modified version of [rEFInd-minimal](https://github.com/EvanPurkhiser/rEFInd-minimal).

### Desktop Background

First, the [Dynamic Wallpaper](https://store.kde.org/p/1295389/) KDE plugin is installed. Then, a ported version of the macOS Catalina desktop background is used.

### Additional Notes

#### Programs

- I use [Konsole](https://konsole.kde.org/) for my terminal emulator, with ZSH as the interpreter and [Polyglot](https://github.com/agkozak/polyglot) as the prompt theme
- I use [Dolphin](https://kde.org/applications/system/org.kde.dolphin) as my file manager GUI
- I use [Mailspring](https://getmailspring.com/) as my desktop email client
- I use [`code-transparent`](https://aur.archlinux.org/packages/code-transparent/), an open source build of [Visual Studio Code](https://code.visualstudio.com/) that supports desktop transparency
  - This transparency is enabled via [this tutorial](https://userbase.kde.org/Tutorials/Force_Transparency_And_Blur): specifically, the kwin script [force blur](https://store.kde.org/p/1294604/) is used to enable this effect
  - The color theme is in the repo
