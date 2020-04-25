<h4 align="center">
    <img src="data/assets/mascot.svg" align="center" width="100"/>
</h4>

<h4 align="center">
  <img src="https://img.shields.io/github/languages/top/LinArcX/giti.svg"/>  <img src="https://img.shields.io/github/repo-size/LinArcX/giti.svg"/>  <img src="https://img.shields.io/github/tag/LinArcX/giti.svg?colorB=green"/>
</h4>

<h1 align="center">
    <img src="data/assets/shot.png" align="center" width="800"/>
</h1>

## A long time ago..
I had many projects on my machine. Some of them were managed by git. After a couple of months, I accidentally lost all of my data.
And this tragic event led me in a new direction and gave me a good motivation to create giti.

## Features
Giti will monitor your __.git__ directories on your computer and periodically reports the latest changes.

## Installation
### Distributions
#### Void [[WIP](https://github.com/void-linux/void-packages/pull/21327)]

#### Arch [WIP]

### Install it from source
You can install giti by compiling from source, here's the list of dependencies required:

#### hostmake dependencies:
 - `ninja`
 - `meson`
 - `vala`

#### buildtime dependencies:
 - `gtk+-3.0`
 - `libgit2-glib-1.0`
 - `gee-0.8`
 - `granite`

#### Building
```
meson build --prefix=/usr
sudo ninja -C build install
```
And finally, run it:

`com.github.linarcx.giti`

## TODO
- [ ] Remember the theme and default directory.(gsettings)
- [ ] Revert back latest commit to stage area.(git reset --soft HEAD^)
- [ ] Show notification badges on applicaiton icon.
- [ ] Periodically monitory changes in repos and send system notificatoin.

## License
![License](https://img.shields.io/github/license/LinArcX/giti.svg)
