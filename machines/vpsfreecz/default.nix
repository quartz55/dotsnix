{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ../../modules/nixos/vpsadminos.nix
    ../../modules/home-manager.nix
    ../../modules/nix.nix
    ./dns.nix
    ./vpn.nix
  ];

  sops.defaultSopsFile = ../../secrets/vpn.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.vpn = {};

  machine.isVpsAdminOS = true;

  environment.systemPackages = with pkgs; [
    vim
    bat
    kakoune
  ];

  home-manager.users.root = {
    imports = [ ../../home/base.nix ];
    home.stateVersion = config.system.stateVersion;
    home.enableNixpkgsReleaseCheck = false;

    systemd.user.startServices = true;

    manual.html.enable = true;
  };

  programs.fish.enable = true;
  users.users.root.shell = pkgs.fish;

  services.jmusicbot.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

  time.timeZone = "Europe/Amsterdam";
  nix.settings.system-features = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
  ];

  system.stateVersion = "22.05";
}
