{ lib, fetchFromGitHub, python3, cdparanoia, cdrdao, flac
, sox, accuraterip-checksum, libsndfile, util-linux, substituteAll }:

python3.pkgs.buildPythonApplication rec {
  pname = "whipper";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "whipper-team";
    repo = "whipper";
    rev = "v${version}";
    sha256 = "00cq03cy5dyghmibsdsq5sdqv3bzkzhshsng74bpnb5lasxp3ia5";
  };

  pythonPath = with python3.pkgs; [
    musicbrainzngs
    mutagen
    pycdio
    pygobject3
    requests
    ruamel_yaml
    setuptools
    setuptools_scm
  ];

  buildInputs = [ libsndfile ];

  checkInputs = with python3.pkgs; [
    twisted
  ];

  patches = [
    (substituteAll {
      src = ./paths.patch;
      inherit cdparanoia;
    })
  ];

  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [ accuraterip-checksum cdrdao util-linux flac sox ])
  ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  # some tests require internet access
  # https://github.com/JoeLametta/whipper/issues/291
  doCheck = false;

  preCheck = ''
    HOME=$TMPDIR
  '';

  meta = with lib; {
    homepage = "https://github.com/whipper-team/whipper";
    description = "A CD ripper aiming for accuracy over speed";
    maintainers = with maintainers; [ emily ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
