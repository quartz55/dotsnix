with import <nixpkgs> {};

stdenv.mkDerivation rec {
    name = "starship-${version}";
    version = "0.41.0";

    src = fetchurl {
        url = "https://github.com/starship/starship/releases/download/v${version}/starship-x86_64-apple-darwin.tar.gz";
        sha256 = "d4c729625195346a744253f94fb0f78466306f3e25e964e64ffd0634321e1e09";
    };

    phases = "installPhase";

    installPhase = ''
      mkdir tmp
      tar -xzvf ${src} -C tmp
      mkdir -p $out/bin
      mv tmp/starship $out/bin/starship
    '';
}
