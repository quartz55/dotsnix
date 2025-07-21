{ config, ... }:
{
  sops.secrets.protonvpn.sopsFile = ../../secrets/seedbox.yaml;

  # TODO: only route rtorrent through VPN
  # TODO: change to Portugal
  networking.wg-quick.interfaces = {
    # Bouncing = 8
    # NetShield = 2
    # Moderate NAT = on
    # NAT-PMP (Port Forwarding) = on
    # VPN Accelerator = on
    wg0 = {
      autostart = false;
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];

      privateKeyFile = config.sops.secrets.protonvpn.path;

      peers = [
        {
          publicKey = "XPVCz7LndzqWe7y3+WSo51hvNOX8nX5CTwVTWhzg8g8=";
          # All except LAN [ 10.0.0.0/8, 192.168.0.0/16 ]
          allowedIPs = [
            "0.0.0.0/5"
            "8.0.0.0/7"
            "11.0.0.0/8"
            "12.0.0.0/6"
            "16.0.0.0/4"
            "32.0.0.0/3"
            "64.0.0.0/2"
            "128.0.0.0/2"
            "192.0.0.0/9"
            "192.128.0.0/11"
            "192.160.0.0/13"
            "192.169.0.0/16"
            "192.170.0.0/15"
            "192.172.0.0/14"
            "192.176.0.0/12"
            "192.192.0.0/10"
            "193.0.0.0/8"
            "194.0.0.0/7"
            "196.0.0.0/6"
            "200.0.0.0/5"
            "208.0.0.0/4"
            "224.0.0.0/3"
            "::/0"
          ];
          endpoint = "149.88.27.234:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
