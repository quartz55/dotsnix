{ lib, rustPlatform, fetchgit, pkgs }:

rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "0.2.0";
  src = fetchgit {
    url = "git://github.com/helix-editor/${pname}";
    rev = "v${version}";
    sha256 = "sha256-CBCCJaXFSOmR+yDeTfTgCSpdgUDIwBecz1dU8a6j6jQ=";
    fetchSubmodules = true;
  };

  checkFlags = [
    "--skip buffer::tests::index_of_panics_on_out_of_bounds"
    "--skip buffer::tests::pos_of_panics_on_out_of_bounds"
    "--skip buffer::Buffer::pos_of"
    "--skip buffer::Buffer::index_of"
  ];
  buildInputs = with pkgs; [ libiconv ];
  cargoBuildFlags = [ "--features embed_runtime" ];
  cargoSha256 = "sha256-siyzMKZkCJV3jjpqW+A4YcDuucEmU5NIui/odhNixkM=";

  meta = with lib; {
    description = "A post-modern modal text editor.";
    homepage = "https://helix-editor.com";
    license = licenses.mpl20;
    maintainers = with maintainers; [ yusdacra ];
  };
}
