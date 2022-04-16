{ inputs, homeManagerModules, lib, config, pkgs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = lib.attrValues homeManagerModules;
  };
}
