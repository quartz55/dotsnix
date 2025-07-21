{
  config,
  lib,
  pkgs,
  nixosModules,
  modulesPath,
  ...
}:

with lib;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    nixosModules.proxmox
    nixosModules.tailscale
  ];

  time.timeZone = "Europe/Lisbon";

  proxmox.enable = true;
  proxmox.enableSops = true;
  sops.secrets.tailscale.sopsFile = ../../secrets/tailscale.yaml;
  tailscale = {
    enable = true;
    enableSsh = true;
    role = "both";
    authKeyFile = config.sops.secrets.tailscale.path;
  };

  proxmox.nix.gc = false;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 45d";
  };

  nix.settings = {
    max-jobs = "auto";
    cores = 0;
    trusted-users = [ "root" ];
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
  };

  nix.settings.system-features = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
  ];
  system.stateVersion = "24.05";
}
