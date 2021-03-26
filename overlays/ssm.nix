{ stdenv, fetchurl, pkgs }:

stdenv.mkDerivation rec {
  pname = "ssm-session-manager-plugin";
  version = "1.2.30.0";

  src = fetchurl {
    url = "https://s3.amazonaws.com/session-manager-downloads/plugin/${version}/mac/sessionmanager-bundle.zip";
    sha256 = "sha256-kA0sOxBE7fcMsCQojVgbLMz1zU1e0wYeUptUm2ewvAU=";
  };

  phases = [ "installPhase" ];

  buildInputs = with pkgs; [ unzip ];

  installPhase =
    ''
    unzip ${src}
    mkdir -p $out/bin
    mv sessionmanager-bundle/bin/session-manager-plugin $out/bin/session-manager-plugin
    '';
}
