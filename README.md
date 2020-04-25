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
I had many projects on my machine.
Some of them were managed by git.
After a while, I accidentally lost all of my data.
I rarely pushed my changes to github/gitlab, since i didn't thought someday my machine will broke and all of my efforts will be destroyed!

After that tragic event, i decided to push my changes regularly. But i had still one issue.

I didn't know which projects have staged files or untracked files.
I wanted a solution to list me my favorite projects and say which files changed and which of them are ready to commit.

This is exactly when i created giti.

## What does your software do?
Well, it's super easy to find out what does gitti do as said in repo description. But to simplify things:
1. Firstly add some git based directories.
2. If those directories have files that are in __untracked__ mode or in __staged__ mode, giti will show those file in separate tabs called: __Untracked__ and __Staged__, Respectively.
3. You can stage untracked files and also commit staged files by pressing buttons that exist in the bottom of each page.

I'm going to implement a feature that notify user whenever one of his repositories changed. So you don't need to ckeck giti everytime.
Just read the notification and decide to we

## Installation
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

### Distributions
#### Void

There is work-in-progress Pull-Request:

https://github.com/void-linux/void-packages/pull/21327


### Tip for Windows-manager's Users
Notice that, giti uses [GLib.Notification](https://valadoc.org/gio-2.0/GLib.Notification.html) internally. So users should install a `notification agent` to get notificaitons. (like: notify-osd, ...)

## TODO
- [ ] Periodically monitory changes in repos and send system notificatoin.
- [ ] Create statistic page that will show all changes in all directories at a glance!
- [ ] Remember the theme and default directory. (via: gsettings)
- [ ] Revert back latest commit to stage area. (via: `git reset --soft HEAD^`)

## License
![License](https://img.shields.io/github/license/LinArcX/giti.svg)
