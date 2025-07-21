{
  lib,
  config,
  pkgs,
  nixosModules,
  modulesPath,
  ...
}:

let
  domain = "git.qrtz.club";
in
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
      name = "forgejo";
    }
  ];
  users.users.root.extraGroups = [ "forgejo" ];

  fileSystems."/export/git" = {
    device = "/mnt/git";
    options = [ "bind" ];
  };
  systemd.services.tmpfiles.unitConfig.RequiresMountsFor = "/export/git";
  systemd.services.tmpfiles.serviceConfig.Group = "forgejo";

  users.users.git = {
    isSystemUser = true;
    useDefaultShell = true;
    group = "git";
    extraGroups = [ "forgejo" ];
    home = config.services.forgejo.stateDir;
  };
  users.groups.git = { };

  services.forgejo = {
    enable = true;
    user = "git";
    package = pkgs.forgejo;
    database.type = "sqlite3";
    # stateDir = "/export/git/forgejo";
    repositoryRoot = "/export/git/forgejo/repos";
    lfs = {
      enable = true;
      contentDir = "/export/git/forgejo/lfs";
    };
    settings = {
      server = {
        # DOMAIN = "git.example.com";
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${domain}/";
        HTTP_PORT = 3000;
        ENABLE_GZIP = true;
        SSH_USER = "git";
        SSH_DOMAIN = "${domain}";
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true;
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      # Sending emails is completely optional
      # You can send a test email from the web UI at:
      # Profile Picture > Site Administration > Configuration >  Mailer Configuration
      # mailer = {
      #   ENABLED = true;
      #   SMTP_ADDR = "mail.example.com";
      #   FROM = "noreply@${domain}";
      #   USER = "noreply@${domain}";
      # };

      # https://forgejo.org/docs/latest/admin/setup/recommendations/
      database.SQLITE_JOURNAL_MODE = "WAL";
      cache.ADAPTER = "twoqueue";
    };
    # mailerPasswordFile = config.age.secrets.forgejo-mailer-password.path;
  };
  # sops.secrets.forgejo.mailer-password = {
  #   sopsFile = ../../secrets/forgejo.yaml;
  #   owner = "git";
  #   mode = "400";
  # };

  sops.secrets.forgejo-runner-token.sopsFile = ../../secrets/forgejo.yaml;
  sops.secrets.forgejo-admin-password = {
    sopsFile = ../../secrets/forgejo.yaml;
    owner = "git";
  };
  systemd.services.forgejo.preStart =
    let
      adminCmd = "${lib.getExe config.services.forgejo.package}/bin/gitea admin user";
      pwd = config.sops.secrets.forgejo-admin-password;
      user = "quartz"; # Note, Forgejo doesn't allow creation of an account named "admin"
    in
    ''
      ${adminCmd} create --config "${config.services.forgejo.customDir}/conf/app.ini" --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      ## uncomment this line to change an admin user which was already created
      # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
    '';

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = "monolith";
      # url = "https://${domain}";
      url = "http://localhost:3000";
      # Obtaining the path to the runner token file may differ
      # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      tokenFile = config.sops.secrets.forgejo-runner-token.path;
      labels = [
        # "ubuntu-22.04:docker://ghcr.io/catth
        "ubuntu-latest:docker://node:20-bullseye"
        "ubuntu-22.04:docker://node:20-bullseye"
        "nixos-latest:docker://nixos/nix"
        ## optionally provide native execution on the host:
        # "native:host"
      ];
    };
  };
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      fixed-cidr-v6 = "fd00::/80";
      ipv6 = true;
    };
  };
  networking.firewall.trustedInterfaces = [ "br-+" ];

  services.caddy = {
    enable = true;

    virtualHosts.":80".extraConfig = ''
      bind 0.0.0.0 [::0]
      reverse_proxy 127.0.0.1:3000
    '';
  };
  networking.firewall.allowedTCPPorts = [
    80
    22
  ];

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ ];
  #   allowedUDPPorts = [ ];
  # };
}
