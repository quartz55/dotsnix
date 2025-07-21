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
  ];

  proxmox.enable = true;
  proxmox.enableSops = true;
  sops.secrets.tailscale.sopsFile = ../../secrets/tailscale.yaml;
  tailscale = {
    enable = true;
    enableSsh = true;
    role = "both";
    authKeyFile = config.sops.secrets.tailscale.path;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    bat
    kakoune
  ];

  time.timeZone = "Europe/Lisbon";

  system.stateVersion = "24.05";

  proxmox.mappedGroups = [
    {
      id = 503;
      name = "media";
    }
  ];
  users.users.root.extraGroups = [ "media" ];

  fileSystems."/export/media" = {
    device = "/mnt/media";
    options = [ "bind" ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [
    "media"
    "render"
    "video"
  ];

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ ];
  #   allowedUDPPorts = [ ];
  # };
}
