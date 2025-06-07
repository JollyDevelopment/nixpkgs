let
  # this is from master branch
  # futurepkgs = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/c115936c3c8967597bb22b6da09ce8e7cc92275d.tar.gz) { };
  # futurepkgs = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/c14a422804372ad96dd130daa2860f68d2c75185.tar.gz) { };

  # switch to this one whenever flutter329 hits unstable or 25.10
  futurepkgs = import (fetchTarball https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz) { };
in

{ pkgs ? import <nixpkgs> {} }:
 
let fhs = futurepkgs.buildFHSEnv {
  name = "android-env";
  environment.extraOutputsToInstall = [ "dev" ];
  targetPkgs = futurepkgs: with futurepkgs;
    [ 
      cmake
      git
      gitRepo
      gnupg
      curl
      procps
      openssl
      gnumake
      nettools
      # For nixos < 19.03, use `androidenv.platformTools`
      androidenv.androidPkgs.platform-tools
      android-studio
      jdk
      schedtool
      util-linux
      m4
      gperf
      perl
      libxml2
      zip
      unzip
      bison
      flex
      lzop
      python3
      mpv
      flutter332
      flutterPackages-source.stable
      libGL.dev
      libepoxy.dev
      mesa
      mutter.dev
      gtk3
      yq
      wayland
      xwayland
      kdePackages.wayland.dev
      libass.dev
      (
        vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            dart-code.flutter
            dart-code.dart-code
            eamodio.gitlens
            ms-python.python
            ms-python.vscode-pylance
            # kamadorueda.alejandra # nix language support
            vscodevim.vim
            # ms-azuretools.vscode-docker
            redhat.vscode-yaml
            # rust-lang.rust-analyzer 
            zainchen.json
            bbenoist.nix
          ] 
          ++ vscode-utils.extensionsFromVscodeMarketplace [
            {
              publisher = "42Crunch";
              name = "vscode-openapi";
              version = "4.33.1";
              hash = "sha256-iq0UpVaZMOzh4NIRPLk49ciFuO4A6PDSEMe1KKhfSxA=";
            }
          ];
        }
      )      
    ];
  multiPkgs = futurepkgs: with futurepkgs;
    [ zlib
      ncurses5
    ];
  runScript = "bash";
  profile = ''
    export ALLOW_NINJA_ENV=true
    export USE_CCACHE=1
    export ANDROID_JAVA_HOME=${futurepkgs.jdk.home}sdkmanager install avd
    export LD_LIBRARY_PATH=/home/jollyroberts/Documents/GITRepos/interstellar/build/linux/x64/debug/bundle/lib:${futurepkgs.wayland}/lib:${futurepkgs.mutter.dev}/lib:${futurepkgs.waylandpp}/lib:/usr/lib:/usr/lib32
    export FLUTTER_ROOT=${futurepkgs.flutter332.sdk}
    export PATH=${futurepkgs.flutter332.sdk}:${futurepkgs.wayland}:$PATH
    export CHROME_EXECUTABLE=/run/current-system/sw/bin/google-chrome-stable
    export C_INCLUDE_PATH=${futurepkgs.kdePackages.wayland.dev}/include
  '';
};
in futurepkgs.stdenv.mkDerivation {
  name = "android-env-shell";
  buildInputs = [ 
    fhs 
  ];
  shellHook = "exec android-env";
}
