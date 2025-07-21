{
  config,
  lib,
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
      name = "nas";
    }
  ];
  users.users.root.extraGroups = [ "nas" ];

  fileSystems."/export/users" = {
    device = "/mnt/users";
    options = [ "bind" ];
  };
  fileSystems."/export/media" = {
    device = "/mnt/media";
    options = [ "bind" ];
  };

  # NFS
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };
  services.nfs.server = {
    enable = true;
    # fixed rpc.statd port; for firewall
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    extraNfsdConfig = "";

    exports = ''
      /export         192.168.1.0/24(rw,fsid=0,no_subtree_check)
      /export/media   192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
      /export/users   192.168.1.0/24(rw,nohide,insecure,no_subtree_check)
    '';
  };

  # SAMBA
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        workgroup = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        #use sendfile = yes;
        #max protocol = smb2;
        # note: localhost is the ipv6 localhost ::1;
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
    };
    shares = {
      media = {
        path = "/export/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "media";
        "force group" = "media";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
    allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
  };
}
