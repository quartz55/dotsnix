{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ];

  nix.package = pkgs.nixVersions.latest;
  nix.extraOptions = ''
    experimental-features = nix-command flakes auto-allocate-uids
    keep-outputs = true
    keep-derivations = true
  '';

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  nix.registry = {
    self.flake = inputs.self;

    nixpkgs = {
      from = {
        id = "nixpkgs";
        type = "indirect";
      };
      flake = inputs.nixpkgs;
    };
  };
}
