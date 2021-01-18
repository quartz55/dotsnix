{ stdenv, fetchurl, pkgs }:

stdenv.mkDerivation rec {
  pname = "ssm-session-manager-plugin";
  version = "latest";

  src = fetchurl {
    url = "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip";
    sha256 = "1yvb3wgkbkp9xgf51vkkvmj6ngqq0zas8cg5yp8prryjv2jaizqw";
  };

  phases = [ "installPhase" ];

  buildInputs = with pkgs; [ awscli unzip ];

  installPhase =
    ''
    echo $(pwd)
    unzip ${src}
    mkdir -p $out/bin
    mv sessionmanager-bundle/bin/session-manager-plugin $out/bin/session-manager-plugin
    '';
}
