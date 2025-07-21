{ pkgs, ... }:
{
  imports = [
    ./base.nix
    # ./emacs.nix
  ];

  home.packages = with pkgs; [
    # nix
    nixfmt-rfc-style
    nixd

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
