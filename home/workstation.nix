{ config, pkgs, lib, ... }:

with lib; {
  imports = [ ./base.nix ];
  home.packages = with pkgs; [
    # nix
    nixpkgs-fmt
    rnix-lsp

    # terminal/shell goodies
    # helix

    # compilers/vms/runtimes
    python2Full
    python39
    nodejs_latest

    # others
    docker-client
    docker-compose
    ffmpeg
    sqlite
    bitwarden-cli

    # zig-master
    ssm
    folderify
  ];
}
