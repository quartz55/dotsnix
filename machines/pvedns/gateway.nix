{ ... }:
{
  networking.enableIPv6 = true;

  # Act as gateway/router
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 7500000;
    "net.core.wmem_max" = 7500000;

    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.eth0.rp_filter" = 0;
    "net.ipv4.conf.lan0.rp_filter" = 0;

    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    # source: https://github.com/mdlayher/homelab/blob/4dc452a121c6176cd22c0776b62291f7a03f2603/nixos/routnerr-3/configuration.nix#L45
    # By default, not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.eth0.accept_ra" = 2;
    "net.ipv6.conf.eth0.autoconf" = 1;
  };

  # IPv6 RA
  services.radvd = {
    enable = true;
    config = ''
      interface eth0 {
        AdvSendAdvert on;
        prefix 2001:8a0:dfe1:e500::/64 {
          AdvOnLink on;
          AdvAutonomous on;
        };
        RDNSS 2001:8a0:dfe1:e500::7 { };
      };
    '';
  };
  # DHCP server port
  # networking.firewall.allowedUDPPorts = [ 67 68 ];

  networking = {
    firewall.enable = false; # we manage everything ourselves
    nftables.enable = true;
    nftables.tables = {
      "homelabnat" = {
        enable = true;
        family = "ip";
        content = ''
          chain prerouting {
            type nat hook prerouting priority filter; policy accept;
          }

          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
            iifname "lan0" oifname "eth0" masquerade
          }
        '';
      };
      "homelabfilter" = {
        enable = false;
        family = "inet";
        content = ''
          chain trace {
            type filter hook prerouting priority -1;
            meta nftrace set 1
          }

          chain output {
            type filter hook output priority 100; policy accept;
            counter comment "count accepted packets"
          }

          chain rpfilter {
            type filter hook prerouting priority mangle + 10; policy drop;
            meta nfproto ipv4 udp sport . udp dport { 68 . 67, 67 . 68 } accept comment "DHCPv4 client/server"
            fib saddr . mark . iif oif exists accept
          }

          chain input {
            type filter hook input priority filter; policy drop;

            # ct state invalid counter drop comment "early drop of invalid packets"
            ct state {established, related} counter accept comment "accept all related to us"

            iif lo accept comment "accept loopback"
            iif != lo ip daddr 127.0.0.1/8 counter drop comment "drop connections to loopback not coming from loopback"
            iif != lo ip6 daddr ::1/128 counter drop comment "drop connections to loopback not coming from loopback"

            # ip protocol icmp counter accept comment "accept all ICMP types (for ping and debugging)"
            # meta l4proto ipv6-icmp counter accept comment "accept all ICMP types (for ping and debugging)"
            icmp type echo-request counter accept comment "allow ping"
            icmpv6 type != { nd-redirect, 139 } counter accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."

            iifname { "eth0", "lan0" } meta l4proto tcp th dport 22 accept comment "SSH"
            iifname { "eth0", "lan0" } meta l4proto tcp th dport 80 accept comment "HTTP"
            iifname { "eth0", "lan0" } meta l4proto tcp th dport { 5380, 538 } accept comment "DOH & DOT"
            iifname { "eth0", "lan0" } meta l4proto udp th dport { 53, 538 } accept comment "DNS & DOU"
            iifname { "eth0", "lan0" } meta nfproto ipv4 udp dport 67 accept comment "DHCP server"

            iifname "lan0" counter accept comment "accept all from trusted network"
            iifname "eth0" ip saddr 192.168.1.0/24 counter accept comment "accept all trusted WAN devices"
            iifname "eth0" ip6 saddr 2001:8a0:dfe1:e500::/64 counter accept comment "accept all trusted WAN devices"

            iifname "eth0" ip daddr 192.168.1.7/32 counter accept comment "accept all to self"
            iifname "eth0" ip daddr 192.168.1.2/32 counter accept comment "accept all to proxy"

            ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"

            tcp flags & (fin | syn | rst | ack) == syn log prefix "refused connection: " level info

            counter comment "count dropped packets"
          }

          chain forward {
            type filter hook forward priority filter; policy drop;

            iifname "lan0" oifname "eth0" counter accept comment "allow trusted LAN to WAN"
            iifname "eth0" oifname "lan0" ct state {established, related} counter accept comment "allow established back to LANs"
            iifname "eth0" ip saddr 192.168.1.0/24 oifname "lan0" counter accept comment "allow all trusted WAN devices"
            iifname "eth0" ip6 saddr 2001:8a0:dfe1:e500::/64 oifname "lan0" counter accept comment "allow all trusted WAN devices"
            iifname "eth0" oifname "eth0" counter accept comment "allow forwarding to gateway"

            # iifname "eth0" counter drop comment "drop all other packets"
            counter comment "drop all other packets"
          }
        '';
      };
    };
  };
}
