{
  lib,
  python3,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
}:

python3Packages.buildPythonApplication rec {
  pname = "kapowarr";
  version = "1.2.0-unstable-2026-01-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Casvt";
    repo = "Kapowarr";
    rev = "1682f537863385e6717e52430ff06870d0c1b1a5";
    hash = "sha256-f/ODr0QgpnDHUtdEFtISfsgDa+8gTao56WouLB5WGW8=";
  };

  # patch in the license file change to avoid a warning
  # patch in an empty py-modules as otherwise the setuptools
  # throws 'Multiple top-level packages discovered in a flat-layout' errors
  patches = [
    ./pyproject.toml.patch
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  nativeBuildInputs = with python3Packages; [
    makeWrapper
  ];

  propagatedBuildInputs = with python3Packages; [
    typing-extensions
    requests
    beautifulsoup4
    flask
    waitress
    cryptography
    bencoding
    aiohttp
    flask-socketio
    websocket-client
  ];

  installPhase = ''
    runHook preInstall
     
    # Install the package structure
    mkdir -p $out/${python3.sitePackages}
    cp -r backend $out/${python3.sitePackages}/
    cp -r frontend $out/${python3.sitePackages}/

    # the program checks its own pyproject.toml when running
    # so make sure there is a copy it can find
    cp pyproject.toml $out/${python3.sitePackages}

    # Install the main script
    mkdir -p $out/bin
    cp Kapowarr.py $out/bin/kapowarr
    chmod +x $out/bin/kapowarr

    # Make sure the script can find the modules
    wrapProgram $out/bin/kapowarr \
      --set PYTHONPATH "$out/${python3.sitePackages}:$PYTHONPATH"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Kapowarr is a software to build and manage a comic book library, fitting in the *arr suite of software.";
    homepage = "https://casvt.github.io/Kapowarr/";
    license = licenses.gpl3Only;
    maintainers = [
      maintainers.JollyDevelopment
    ];
    platforms = platforms.all;
  };
}
