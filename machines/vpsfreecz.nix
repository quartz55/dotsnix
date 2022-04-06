{ config, lib, pkgs, inputs, ... }:
with lib;
{
  imports = [
    ../modules/nixos/vpsadminos.nix
    ../modules/home-manager.nix
    ../modules/nix.nix
  ];

  machine.isVpsAdminOS = true;

  environment.systemPackages = with pkgs; [
    vim
    bat
    kakoune
  ];

  home-manager.users.root = {
    imports = [ ../home/base.nix ];
    home.stateVersion = config.system.stateVersion;
    home.enableNixpkgsReleaseCheck = false;

    systemd.user.startServices = true;

    manual.html.enable = true;
  };

  programs.fish.enable = true;
  users.users.root.shell = pkgs.fish;

  services.jmusicbot.enable = true;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "22.05";
}
