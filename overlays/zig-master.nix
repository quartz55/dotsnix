{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "zig-master";
  version = "0.8.0-dev.1561+f1e324216";

  archive = "zig-macos-x86_64-${version}";
  src = fetchurl {
    url = "https://ziglang.org/builds/${archive}.tar.xz";
    sha256 = "sha256-bvbWb48e6M66CY6ygqPmA9ULpdlr7ANOYLZwj6Es7Yc=";
  };

  phases = "installPhase";

  installPhase = ''
    mkdir tmp
    tar -xJf ${src} -C tmp
    mkdir -p $out/bin
    mkdir -p $out/lib
    mv tmp/${archive}/zig $out/bin/zig
    mv tmp/${archive}/lib/zig $out/lib/zig
  '';
}
