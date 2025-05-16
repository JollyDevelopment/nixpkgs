{
    copyDesktopItems,
    fetchFromGitHub,
    fetchPypi,
    fetchurl,
    makeDesktopItem,
    lib,
    python310,
    python310Packages,
    qt5,
}:

let
    comicfn2dict = 
        let 
            pname = "comicfn2dict";
            version = "0.2.5";
            format = "wheel";
        in
        python310Packages.buildPythonPackage {
            inherit pname version format;
            src = fetchPypi rec {
                inherit pname version format;
                dist = python;
                python = "py3";
                sha256 = "sha256-3lCDv7QgD9XPCssfASHcSgVYINvzxOgPCyeAMqSVOoo=";
            };
            doCheck = false;
        };
    isocodes = 
        let 
            pname = "isocodes";
            version = "2024.2.2";
            format = "wheel";
        in
        python310Packages.buildPythonPackage {
            inherit pname version format;
            src = fetchPypi rec {
                inherit pname version format;
                sha256 = "sha256-/vOfR4Id/wTdOjEdH43c2rrD3jfgSDmGl+cbaLh54Vw=";
            };
            doCheck = false;
        };
    unrar_cffi = 
        let 
            pname = "unrar_cffi";
            version = "0.2.2";
            format = "wheel";
        in
        python310Packages.buildPythonPackage {
            inherit pname version format;
            # this package is from 2021 so the url does not match what
            # fetchPypi builds, so just pull the .whl directly
            src = fetchurl {
                url = "https://files.pythonhosted.org/packages/94/b6/b53437008e65b1b35d390ea88fa00c2cfb68f4980fdd2f6809bbf957662b/unrar_cffi-0.2.2-cp39-cp39-manylinux_2_12_x86_64.manylinux2010_x86_64.whl";
                sha256 = "52e4d9c930893ac297c8b657c3d93b30c1f8a68a22f88aa56c5bc18c27314221";
            };
            doCheck = false;
        };        
in 

python310Packages.buildPythonApplication rec {
    pname = "comictagger";
    version = "1.5.5";

    src = fetchPypi {
        inherit pname version;
        hash  = "sha256-f/SS6mo5zIcNBN/FRMhRPMNOeB1BIqBhsAogjsmdjB0=";
    };

    # enable the qt5 GUI and .cbr (rar) support
    optional-dependencies = with python310Packages; {
        gui = [ pyqt5 ];
        cbr = [ rarfile ];
    };

    nativeBuildInputs = with python310Packages; [
        copyDesktopItems
        pyqt5
        qt5.wrapQtAppsHook
    ];

    # packages needed at runtime
    propagatedBuildInputs = with python310Packages; [
        appdirs
        beautifulsoup4
        chardet
        comicfn2dict
        importlib-metadata
        isocodes
        natsort
        packaging
        pathvalidate
        pillow
        pycountry
        pyrate-limiter
        pyqt5
        pyyaml
        rarfile
        rapidfuzz
        requests
        text2digits
        typing-extensions
        unrar_cffi
        wordninja
    ];

    # its a qt5 app so needs the wrapper to be able to find plugins
    # see https://nixos.org/manual/nixpkgs/stable/#sec-language-qt 
    dontWrapQtApps = true;
    makeWrapperArgs = [ "\${qtWrapperArgs[@]}" ];

    doCheck = false;

    # link the app icon for the desktop item
    postInstall = ''
        for s in 16 32 48 64 128 256; do
            mkdir -p $out/share/icons/hicolor/''${s}x''${s}/apps
            ln -s $out/${python310.sitePackages}/comictaggerlib/graphics/app.png \
                $out/share/icons/hicolor/''${s}x''${s}/apps/${pname}.png
        done
    '';

    # create the comictagger.desktop file
    desktopItems = [
        (makeDesktopItem {
            name = pname;
            exec = pname;
            icon = pname;
            desktopName = "Comic Tagger";
            categories = [
                "Utility"
                "Viewer"
                "Literature"
            ];
        })
    ];

    meta = {
        homepage = "https://github.com/comictagger/comictagger";
        description = "A multi-platform app for writing metadata to digital comics ";
        license =  lib.licenses.asl20;
    };

}