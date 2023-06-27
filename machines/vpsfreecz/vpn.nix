{ pkgs, config, ... }:
let
  port = 42280;
  ethIf = "venet0";
in
{
  networking.nat = {
    enable = true;
    externalInterface = ethIf;
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall = {
    allowedUDPPorts = [ port ];
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.0.1/24" ];
      listenPort = port;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # Client configurations must setup `10.0.0.1` as DNS
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ${ethIf} -j MASQUERADE
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o ${ethIf} -j MASQUERADE
      '';

      privateKeyFile = config.sops.secrets.vpn.path;

      peers = [
        { 
          publicKey = "MPz7yRcKSrHlHEZZQWDBM6SByBnTN8pujF0VvrqpWyU=";
          # presharedKeyFile = config.sops.secrets.vpn.path;
          allowedIPs = [ "10.0.0.2/32" ];
        }
      ];
    };
  };
}