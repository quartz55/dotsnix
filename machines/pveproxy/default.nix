{
  config,
  pkgs,
  nixosModules,
  modulesPath,
  inputs,
  ...
}:

let
  domain = "qrtz.club";
in
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    nixosModules.proxmox
    inputs.crowdsec.nixosModules.crowdsec
    inputs.crowdsec.nixosModules.crowdsec-firewall-bouncer
  ];

  nixpkgs.overlays = [ inputs.crowdsec.overlays.default ];

  time.timeZone = "Europe/Lisbon";
  system.stateVersion = "24.05";

  proxmox.enable = true;

  proxmox.enableSops = true;
  sops.secrets.crowdsec.sopsFile = ../../secrets/crowdsec.yaml;
  sops.secrets.crowdsec-env-file.sopsFile = ../../secrets/crowdsec.yaml;
  sops.secrets.crowdsec-local-api-key.sopsFile = ../../secrets/crowdsec.yaml;
  sops.secrets.tailscale.sopsFile = ../../secrets/tailscale.yaml;
  sops.secrets.aws-dns-profile = {
    sopsFile = ../../secrets/awsdns.yaml;
    owner = "root";
    path = "/root/.aws/credentials";
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 7500000;
    "net.core.wmem_max" = 7500000;
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking =
    let
      iftailscale = config.services.tailscale.interfaceName;
    in
    {
      firewall.enable = false; # we manage everything ourselves
      nftables.enable = true;
      nftables.tables = {
        "fw" = {
          enable = true;
          family = "inet";
          content = ''
            chain postrouting {
              iifname "${iftailscale}" oifname { "eth0", "lan0" } masquerade
            }

            chain trace {
              type filter hook prerouting priority -1;
              meta nftrace set 1
            }

            chain output {
              type filter hook output priority 100; policy accept;
              counter comment "count accepted packets"
            }

            chain input {
              type filter hook input priority filter; policy drop;

              ct state invalid counter drop comment "early drop of invalid packets"
              ct state {established, related} counter accept comment "accept all related to us"

              iif lo accept comment "accept loopback"
              iif != lo ip daddr 127.0.0.1/8 counter drop comment "drop connections to loopback not coming from loopback"
              iif != lo ip6 daddr ::1/128 counter drop comment "drop connections to loopback not coming from loopback"

              ip saddr 192.168.1.0/24 ip protocol icmp counter accept comment "accept all ICMP types (for ping and debugging)"
              ip6 saddr 2001:8a0:dfe1:e500::/64 meta l4proto ipv6-icmp counter accept comment "accept all ICMP types (for ping and debugging)"

              iifname { "eth0", "lan0" } meta l4proto { tcp } th dport { 80, 443 } accept comment "HTTP/S"
              iifname { "eth0", "lan0" } meta l4proto { tcp } th dport { 22 } accept comment "Tailscale SSH"
              iifname { "eth0", "lan0" } meta l4proto { udp } th dport { ${toString config.services.tailscale.port} } accept comment "Tailscale UDP"

              iifname "lan0" counter accept comment "accept all from trusted network"
              iifname "${iftailscale}" counter accept comment "accept all from tailscale"
              iifname "eth0" ip saddr 192.168.1.0/24 counter accept comment "accept all trusted WAN devices"
              iifname "eth0" ip6 saddr 2001:8a0:dfe1:e500::/64 counter accept comment "accept all trusted WAN devices"

              counter comment "count dropped packets"
            }

            chain forward {
              type filter hook forward priority filter; policy drop;
              iifname "${iftailscale}" oifname { "eth0", "lan0" } counter accept comment "allow trusted Tailscale to LAN & WAN"
              oifname "${iftailscale}" ct state {established, related} counter accept comment "allow established back to Tailscale"

              counter comment "count dropped packets"
            }
          '';
        };
      };
    };

  services.resolved.enable = true;

  services.caddy = {
    enable = true;
    # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
    email = "qrtz@qrtz.club";

    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/hslatman/caddy-crowdsec-bouncer@v0.9.2"
      ];
      hash = "sha256-uHoJfi77rSk/a+T44g9yKWFcAiAnXD+4wam556CgN78=";
    };

    globalConfig = ''
      debug

      crowdsec {
        api_url http://127.0.0.1:8080
        api_key {$CROWDSEC_LOCAL_API_KEY}
        ticker_interval 15s
        #appsec_url http://localhost:7422
        #disable_streaming
        #enable_hard_fails
      }
    '';

    virtualHosts."media.${domain}".extraConfig = ''
      reverse_proxy media.qrtz.lab:8096
    '';

    virtualHosts."dns.${domain}".extraConfig = ''
      # DNS-over-HTTP
      handle /dns-query {
        reverse_proxy dns.qrtz.lab:5380
      }

      handle {
        reverse_proxy dns.qrtz.lab:80
      }
    '';

    virtualHosts."git.${domain}".extraConfig = ''
      handle {
        reverse_proxy git.qrtz.lab:80
      }
    '';

  };
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.sops.secrets.crowdsec-env-file.path;
  };

  services.tailscale = {
    enable = true;
    interfaceName = "tailscale0";
    port = 41641;
    authKeyFile = config.sops.secrets.tailscale.path;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--advertise-routes=10.0.0.0/8,192.168.0.0/24"
      "--advertise-exit-node"
    ];
  };
  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        ${pkgs.ethtool}/bin/ethtool -K eth0 rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;
    settings = {
      api_key = "\${CROWDSEC_LOCAL_API_KEY}";
      api_url = "http://127.0.0.1:8080";
      nftables = {
        ipv4 = {
          enabled = true;
          set-only = false;
          table = "crowdsec";
          chain = "crowdsec-chain";
        };
        ipv6 = {
          enabled = true;
          set-only = false;
          table = "crowdsec6";
          chain = "crowdsec6-chain";
        };
      };
    };
  };
  systemd.services.crowdsec-firewall-bouncer.serviceConfig = {
    EnvironmentFile = config.sops.secrets.crowdsec-env-file.path;
  };

  services.crowdsec = {
    enable = true;
    name = "proxy";
    allowLocalJournalAccess = true;
    enrollKeyFile = config.sops.secrets.crowdsec.path;
    acquisitions = [
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels.type = "syslog";
      }
    ];
    settings = {
      api = {
        server = {
          enable = true;
          listen_uri = "127.0.0.1:8080";
          trusted_ips = [
            "192.168.1.0/24"
            "10.0.0.0/24"
            "2001:8a0:dfe1:e500::/64"
          ];
        };
        cti = {
          enabled = true;
          key = "\${CROWDSEC_API_KEY}";
        };
      };
    };
  };
  systemd.services.crowdsec.serviceConfig = {
    EnvironmentFile = config.sops.secrets.crowdsec-env-file.path;
    ExecStartPre =
      let
        script = pkgs.writeScriptBin "register-bouncer" ''
          #!${pkgs.runtimeShell}
          set -eu
          set -o pipefail

          cscli collections install crowdsecurity/linux

          if ! cscli bouncers list | grep -q "my-bouncer"; then
            cscli bouncers add "my-bouncer" --key "$(tr -d '\n' < ${config.sops.secrets.crowdsec-local-api-key.path})"
          fi
        '';
      in
      [ "${script}/bin/register-bouncer" ];
  };

  services.cron =
    let
      zone_id = "Z0445726L508WAGPHU5R";
      record = "qrtz.club";
      src = ./update-route53.sh;
      bin = "dns-update";
      deps = with pkgs; [
        awscli2
        jq
        dig
      ];
      dns-update =
        pkgs.runCommand bin
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
            meta = {
              mainProgram = bin;
            };
          }
          ''
            mkdir -p $out/bin
            install -m +x ${src} $out/bin/${bin}
            wrapProgram $out/bin/${bin} --prefix PATH : ${pkgs.lib.makeBinPath deps}
          '';
    in
    {
      enable = true;
      systemCronJobs = [
        "*/5 * * * *      root    ${dns-update}/bin/${bin} --zone='${zone_id}' --record='${record}' --profile=dns >> /tmp/cron.log"
      ];
    };
}
