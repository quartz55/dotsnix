{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.tailscale;
  ips = lib.strings.concatStringsSep "," cfg.exitNode.routes;
  extraFlags =
    (lib.optional cfg.enableSsh "--ssh")
    ++ (lib.optionals cfg.exitNode.enable [
      "--advertise-exit-node"
      "--advertise-routes=${ips}"
    ]);
  iftailscale = config.services.tailscale.interfaceName;
in
{
  meta.maintainers = [ maintainers.quartz55 ];

  options.tailscale = {
    enable = mkEnableOption ''
      Enable Tailscale node configuration
    '';

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the firewall for the specified port (and SSH if enabled).";
    };

    port = mkOption {
      type = types.int;
      default = 41641;
      example = 12345;
      description = ''
        uint16 (16 bit unsigned integer; between 0 and 65535 (both inclusive))
        The port to listen on for tunnel traffic (0=autoselect).
      '';
    };

    role = mkOption {
      type = types.enum [
        "none"
        "client"
        "server"
        "both"
      ];
      example = "server";
      description = ''
        Enables settings required for Tailscale’s routing features like subnet routers and exit nodes.
        To use these these features, you will still need to call sudo tailscale up with the relevant flags like --advertise-exit-node and --exit-node.
        When set to client or both, reverse path filtering will be set to loose instead of strict. When set to server or both, IP forwarding will be enabled.
      '';
    };

    enableSsh = mkOption {
      type = types.bool;
      default = false;
      example = true;
    };

    exitNode = {
      enable = mkEnableOption ''
        Advertise as exit node
      '';
      routes = mkOption {
        type = types.listOf (types.str);
        example = [
          "10.0.0.0/8"
          "192.168.0.0./24"
        ];
        default = [ ];
        description = ''
          A list of IP ranges to advertise
        '';
      };
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Add firewall rules to enable exit node to forward packets
        '';
      };
    };

    authKeyFile = mkOption {
      type = types.str;
    };

    enableSops = mkEnableOption ''
      Enable automatic garbage collection of nix store
    '';
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      interfaceName = "tailscale0";
      port = cfg.port;
      authKeyFile = cfg.authKeyFile;
      useRoutingFeatures = cfg.role;
      extraUpFlags = extraFlags;
    };

    networking.firewall = mkIf cfg.openFirewall {
      enable = true;
      allowedTCPPorts = [ cfg.port ] ++ lib.optional cfg.enableSsh 22;
      allowedUDPPorts = [ cfg.port ] ++ lib.optional cfg.enableSsh 22;
    };

    services.networkd-dispatcher = mkIf cfg.exitNode.enable {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ${pkgs.ethtool}/bin/ethtool -K eth0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };

    boot.kernel.sysctl = mkIf cfg.exitNode.enable {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };

    services.resolved = mkIf cfg.exitNode.enable {
      enable = true;
    };

    networking.nftables = mkIf (cfg.exitNode.enable && cfg.exitNode.enableFirewall) {
      enable = true;

      tables."tailscale-exit-node" = {
        enable = true;
        family = "inet";
        content = ''
          chain postrouting {
            iifname "${iftailscale}" oifname { "eth0", "lan0" } masquerade
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
}
