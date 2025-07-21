{
  config,
  pkgs,
  nixosModules,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/proxmox-lxc.nix"
    nixosModules.proxmox
    nixosModules.tailscale
    ./dns.nix
    ./gateway.nix
  ];

  proxmox.enable = true;
  proxmox.enableSops = true;
  sops.secrets.tailscale.sopsFile = ../../secrets/tailscale.yaml;
  tailscale = {
    enable = true;
    enableSsh = true;
    role = "both";
    authKeyFile = config.sops.secrets.tailscale.path;
  };

  environment.systemPackages = with pkgs; [
    vim
    bat
    kakoune
  ];

  time.timeZone = "Europe/Lisbon";

  system.stateVersion = "24.05";
}
