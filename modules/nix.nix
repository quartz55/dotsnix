{ inputs, lib, config, pkgs, ... }: {
  imports = [ ];

  nix.package = pkgs.nixVersions.unstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes auto-allocate-uids configurable-impure-env
    keep-outputs = true
    keep-derivations = true
  '';

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
  ];
  nix.registry = {
    self.flake = inputs.self;

    nixpkgs = {
      from = { id = "nixpkgs"; type = "indirect"; };
      flake = inputs.nixpkgs;
    };
  };
}
