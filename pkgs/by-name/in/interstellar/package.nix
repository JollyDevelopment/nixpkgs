{
    alsa-lib,
    copyDesktopItems,
    ffmpeg,
    flutter329,
    fetchFromGitHub,
    imagemagick,
    lcms2,
    lib,
    libass,
    libbluray,
    libcaca,
    libdisplay-info,
    libdovi,
    libdrm,
    libdvdread,
    libdvdnav,
    libplacebo,
    libgbm,
    libpulseaudio,
    libuchardet,
    libunwind,
    libva,
    libvdpau,
    lua,
    makeDesktopItem,
    mpv,
    mujs,
    nv-codec-headers-12,
    openal,
    pipewire,
    rubberband,
    runCommand,
    shaderc,
    vulkan-loader,
    xorg,
    zimg,
}:

flutter329.buildFlutterApplication rec {
    pname   = "interstellar";
    version = "0.9.2";

    src = fetchFromGitHub {
        owner = "interstellar-app";
        repo  = "interstellar";
        tag   = "v${version}";
        hash  = "sha256-lJVkf4g+q8V6RurfSfrpFr6mk23tSZ+u9pbqbvfRqrE="; # v0.9.2
        fetchSubmodules = true;
    };

    pubspecLock = lib.importJSON ./pubspec.lock.v0.9.2.json;

    buildInputs = [
        alsa-lib
        ffmpeg
        imagemagick
        lcms2
        libass
        libbluray
        libcaca
        libdisplay-info
        libdovi
        libdrm
        libdvdread
        libdvdnav
        libgbm
        libplacebo
        libpulseaudio
        libuchardet
        libunwind
        libva
        libvdpau
        lua
        mpv
        mujs
        nv-codec-headers-12
        openal
        pipewire
        rubberband
        shaderc
        vulkan-loader
        xorg.libXpresent
        xorg.libXScrnSaver
        zimg
    ];

    nativeBuildInputs = [
        copyDesktopItems
    ];

    # set version and turn off flutter.generate for language translations (done in preBuild)
    patches = [
        ./locale_and_ver.patch
    ];

    # generate the language translation files
    # tweak the package_config.json to add a languageVersion to the self named entry
    # json_serializable breaks if the "interstellar" entry does not have a version key.
    # TODO - improve jq to find the entry with a map() or select() rather than specifying 
    # the last entry with [-1]
    preBuild = ''
        flutter gen-l10n
        cd .dart_tool/
        mv package_config.json orig.package_config.json
        jq '.packages[-1] |= {"name": "interstellar", "rootUri": "../", "packageUri": "lib/", "languageVersion": "3.6"}' orig.package_config.json > package_config.json
        cd ..
        packageRun build_runner build linux --delete-conflicting-outputs --release -vvvv 
    '';

    extraWrapProgramArgs = ''
        --prefix LD_LIBRARY_PATH : $out/app/interstellar/lib
    '';

    desktopItems = [
        (makeDesktopItem {
            name = "one.jwr.interstellar";
            desktopName = "Interstellar";
            exec = "interstellar";
            icon = "Interstellar";
            categories = [
                "Network"
                "News"
            ];
        })
    ];

    postInstall = ''
        for size in 16 22 24 32 36 48 64 72 96 128 192 256 512 1024; do
            mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
            convert -resize "$size"x"$size" $src/assets/icons/logo.png $out/share/icons/hicolor/"$size"x"$size"/apps/Interstellar.png
        done
    '';

    meta = {
        description = "An app for Mbin/Lemmy/PieFed, connecting you to the fediverse.";
        homepage    = "https://interstellar.jwr.one";
        license     = lib.licenses.agpl3Plus;
        mainProgram = "interstellar";
        platforms   = lib.platforms.linux;
        maintainers = with lib.maintainers; [ JollyDevelopment ];
    };
}