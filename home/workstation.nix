{ pkgs, ... }:
{
  imports = [ ./base.nix ];
  home.packages = with pkgs; [
    # nix
    nixpkgs-fmt
    rnix-lsp
    nil

    # terminal/shell goodies
    # helix

    # others
    docker-client
    docker-compose

    # zig-master
    ssm
    folderify
  ];
}
