{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
    name = "zig-master";
    version = "0.8.0-dev.1001+811833658";

    archive = "zig-macos-x86_64-${version}";
    src = fetchurl {
        url = "https://ziglang.org/builds/${archive}.tar.xz";
        sha256 = "58e2d4a831415a406bd3d9cf1d105ca18b0655f034b4979955eced3fc2420791";
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
