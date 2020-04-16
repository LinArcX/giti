let
  pkgs = import <nixpkgs> {};
  unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {};
  pkgs-2020-03-23 = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/793c1b5c72abbfed2f98add0811a022fc713dbf3.tar.gz) {};
in
  pkgs-2020-03-23.clangStdenv.mkDerivation rec {
    pname   = "giti";
    fname   = "com.github.linarcx.giti";
    version = "1.0.0";
    name    = "${pname}${version}";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs-2020-03-23.ninja
      pkgs-2020-03-23.meson
      pkgs-2020-03-23.wrapGAppsHook
    ];

    buildInputs = [
      pkgs-2020-03-23.uncrustify

      pkgs-2020-03-23.man
      pkgs-2020-03-23.man-pages
      pkgs-2020-03-23.posix_man_pages

      pkgs-2020-03-23.vala
      pkgs-2020-03-23.pantheon.granite
      pkgs-2020-03-23.fontconfig

      pkgs-2020-03-23.gtk3
      pkgs-2020-03-23.pcre
      pkgs-2020-03-23.harfbuzz
      pkgs-2020-03-23.xorg.libpthreadstubs
      pkgs-2020-03-23.xorg.libXdmcp
      pkgs-2020-03-23.utillinux
      pkgs-2020-03-23.libselinux
      pkgs-2020-03-23.libsepol
      pkgs-2020-03-23.libxkbcommon
      pkgs-2020-03-23.epoxy
      pkgs-2020-03-23.at_spi2_core.dev
      pkgs-2020-03-23.dbus
      pkgs-2020-03-23.xorg.libXtst

      pkgs-2020-03-23.libcanberra-gtk3
      pkgs-2020-03-23.libgit2-glib
      pkgs-2020-03-23.libgee
    ];

    FONTCONFIG_FILE = "${pkgs-2020-03-23.fontconfig.out}/etc/fonts/fonts.conf";
    LOCALE_ARCHIVE = "${pkgs-2020-03-23.glibcLocales}/lib/locale/locale-archive";

    shellHook = ''
      export NAME=${pname}
      export FULL_NAME=${fname}
      export CLANG=${pkgs-2020-03-23.clang}/bin/clang
      export CLANGXX=${pkgs-2020-03-23.clang}/bin/clang++
      export LLDB_VSCODE=${pkgs-2020-03-23.lldb_9}/bin/lldb-vscode
      export XDG_DATA_DIRS=$HOME/.nix-profile/share:/usr/local/share:/usr/share
    '';
  }
