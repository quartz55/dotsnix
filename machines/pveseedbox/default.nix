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
    ./vpn.nix
    ./rtorrent.nix
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

  fileSystems."/export/media" = {
    device = "/mnt/media";
    options = [ "bind" ];
  };

  services.prowlarr = {
    enable = true;
  };

  services.readarr = {
    enable = true;
  };
  users.users.readarr.extraGroups = [ "rtorrent" ];

  services.radarr = {
    enable = true;
  };
  users.users.radarr.extraGroups = [ "rtorrent" ];

  services.sonarr = {
    enable = true;
  };
  users.users.sonarr.extraGroups = [ "rtorrent" ];

  services.lidarr = {
    enable = true;
  };
  users.users.lidarr.extraGroups = [ "rtorrent" ];

  # Proxy
  services.caddy = {
    enable = true;

    # Default to Flood
    virtualHosts.":80".extraConfig = ''
      bind 0.0.0.0 [::0]

      handle_path /rutorrent/* {
        basic_auth {
      		quartz $2a$14$DSDkbxwEsnJqBRC5/k8bhe5TX.gM.TwIIi/hc5Z99hm40xaCAA6IK
       	}

        reverse_proxy :3001
      }

      # Prowlarr
      handle /indexers* {
        reverse_proxy :9696
      }
      # Readarr
      handle /books* {
        reverse_proxy :8787
      }
      # Radarr
      handle /movies* {
        reverse_proxy :7878
      }
      # Sonarr
      handle /tv* {
        reverse_proxy :8989
      }
      # Lidarr
      handle /music* {
        reverse_proxy :8686
      }

      # Default to Flood
      handle {
        reverse_proxy :3000
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
