{ lib, config, ... }:
{

  services.rtorrent = {
    enable = true;
    openFirewall = true;
    downloadDir = "/export/media/downloads";
  };

  proxmox.mappedGroups = [
    {
      id = 503; # nas
      name = "rtorrent";
    }
  ];
  users.users.root.extraGroups = [ "rtorrent" ];

  services.rutorrent = {
    enable = true;
    hostName = "seedbox.qrtz.lab";
    nginx.enable = true;
    plugins = [
      "httprpc"
      "_task"
      "_getdir"
      "_noty2"
      "data"
      "cpuload"
      "create"
      "datadir"
      "diskspace"
      "edit"
      "erasedata"
      "filedrop"
      "source"
      "theme"
    ];
  };
  services.nginx.virtualHosts.${config.services.rutorrent.hostName}.listen = [
    {
      addr = "127.0.0.1";
      port = 3001;
    }
  ];

  services.flood =
    with lib;
    let
      args = strings.splitString " " config.systemd.services.rtorrent.serviceConfig.ExecStart;
      importArg = lists.findFirst (x: strings.hasPrefix "import=" x) "" args;
      default = "/nix/store/k1l7nrg4pad59xs6ygzlb3w5g1kipz1i-rtorrent.rc";
      cfg = if importArg != "" then lists.last (strings.splitString "=" importArg) else default;
    in
    {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      extraArgs = [
        # "--auth=none"
        # "--rtorrent"
        # "--rtsocket=${config.services.rtorrent.rpcSocket}"
        # "--rtconfig=${cfg}"
      ];
    };
  users.users.flood = {
    isSystemUser = true;
    group = "flood";
    extraGroups = [ "rtorrent" ];
  };
  users.groups.flood = { };
  systemd.services.flood.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.flood.serviceConfig.User = "flood";
  systemd.services.flood.serviceConfig.Group = "flood";
}
