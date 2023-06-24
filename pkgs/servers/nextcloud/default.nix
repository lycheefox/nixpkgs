{ lib, stdenv, fetchurl, nixosTests
, nextcloud27Packages
, nextcloud26Packages
, nextcloud25Packages
, nextcloud24Packages
}:

let
  generic = {
    version, sha256
  , eol ? false, extraVulnerabilities ? []
  , packages
  }: let
    major = lib.versions.major version;
  in stdenv.mkDerivation rec {
    pname = "nextcloud";
    inherit version;

    src = fetchurl {
      url = "https://download.nextcloud.com/server/releases/${pname}-${version}.tar.bz2";
      inherit sha256;
    };

    # This patch is only necessary for NC version <26.
    patches = lib.optional (lib.versionOlder major "26") (./patches + "/v${major}/0001-Setup-remove-custom-dbuser-creation-behavior.patch");

    passthru = {
      tests = nixosTests.nextcloud;
      inherit packages;
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      cp -R . $out/
      runHook postInstall
    '';

    meta = with lib; {
      changelog = "https://nextcloud.com/changelog/#${lib.replaceStrings [ "." ] [ "-" ] version}";
      description = "Sharing solution for files, calendars, contacts and more";
      homepage = "https://nextcloud.com";
      maintainers = with maintainers; [ schneefux bachp globin ma27 ];
      license = licenses.agpl3Plus;
      platforms = with platforms; unix;
      knownVulnerabilities = extraVulnerabilities
        ++ (optional eol "Nextcloud version ${version} is EOL");
    };
  };
in {
  nextcloud23 = throw ''
    Nextcloud v23 has been removed from `nixpkgs` as the support for is dropped
    by upstream in 2022-12. Please upgrade to at least Nextcloud v24 by declaring

        services.nextcloud.package = pkgs.nextcloud24;

    in your NixOS config.

    WARNING: if you were on Nextcloud 22 on NixOS 22.05 you have to upgrade to Nextcloud 23
    first on 22.05 because Nextcloud doesn't support upgrades accross multiple major versions!
  '';

  nextcloud24 = generic {
    version = "24.0.12";
    sha256 = "sha256-Lwk73300+vONIvOKXhHzruMnRv9K3T3xfHkLmzY5CDY=";
    packages = nextcloud24Packages;
  };

  nextcloud25 = generic {
    version = "25.0.8";
    sha256 = "sha256-Ia6afooDCNDZsGSoh5dddZvLUE3fU+jU6sy6MrxUMVs=";
    packages = nextcloud25Packages;
  };

  nextcloud26 = generic {
    version = "26.0.3";
    sha256 = "sha256-pagQy818Pc/yXyKAkyHy7UHtfMBgEgRImskOJYBgtck=";
    packages = nextcloud26Packages;
  };

  nextcloud27 = generic {
    version = "27.0.0";
    sha256 = "sha256-PTEqCbk0WsBYdY3XtAWb888LHw8ddHJRtvrDWFumUz8=";
    packages = nextcloud27Packages;
  };

  # tip: get the sha with:
  # curl 'https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2.sha256'
}
