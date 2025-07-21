{
  inputs,
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
    # inputs.attic.nixosModules.atticd
  ];

  time.timeZone = "Europe/Lisbon";

  proxmox.enable = true;
  proxmox.enableSops = true;
  sops.secrets.tailscale.sopsFile = ../../secrets/tailscale.yaml;
  sops.secrets.attic-env-file.sopsFile = ../../secrets/attic.yaml;
  tailscale = {
    enable = true;
    enableSsh = true;
    role = "both";
    authKeyFile = config.sops.secrets.tailscale.path;
  };

  # binary cache
  services.atticd = {
    enable = true;

    environmentFile = config.sops.secrets.attic-env-file.path;

    settings = {
      listen = "[::]:8080";

      jwt = { };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
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
  networking.firewall.allowedTCPPorts = [
    8080
    22
  ];
}
