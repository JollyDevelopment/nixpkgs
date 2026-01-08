{
  lib,
  python3,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
}:

python3Packages.buildPythonApplication {
  pname = "kapowarr";
  version = "1.2.0-unstable-2026-01-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Casvt";
    repo = "Kapowarr";
    rev = "1682f537863385e6717e52430ff06870d0c1b1a5";
    hash = "sha256-f/ODr0QgpnDHUtdEFtISfsgDa+8gTao56WouLB5WGW8=";
  };

  # patch the pyproject.toml so the .whl has the files/folders
  # needed so pypaBuildPhase can put them in the $out/ paths properly
  patches = [
    ./patch.patch
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  nativeBuildInputs = [
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

  postInstall = ''
    # copy the primary script to the /bin/
    mkdir $out/bin
    mv $out/${python3.sitePackages}/Kapowarr.py $out/bin/kapowarr
    chmod +x $out/bin/kapowarr

    # wrap it so it can find its internal packages
    wrapProgram $out/bin/kapowarr \
      --set PYTHONPATH "$out/${python3.sitePackages}:$PYTHONPATH"

    # the program checks its own pyproject.toml when running
    # so make sure there is a copy it can find
    cp pyproject.toml $out/${python3.sitePackages}
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
