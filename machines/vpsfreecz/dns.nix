{ ... }:
{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "john.razor97+acme@gmail.com";

  # NOTE @jcosta: this is needed for `transparent` in `proxy_bind`
  # services.nginx.appendConfig = let cfg = config.services.nginx; in ''user ${cfg.user} ${cfg.group};'';
  # systemd.services.nginx.serviceConfig.User = lib.mkForce "root";
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "dns.qrtz.club" = {
        kTLS = true;
        forceSSL = true;
        enableACME = true;
        # locations."/" = {
        #   return = ''404 "404 Not Found\n"'';
        # };
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000/dns-query";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Connection "";
          '';
        };
        locations."= /dns-query" = {
          proxyPass = "http://127.0.0.1:3000/dns-query";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Connection "";
          '';
        };
        locations."/admin/" = {
          proxyPass = "http://127.0.0.1:3000/";
          extraConfig = ''
            proxy_cookie_path / /admin/;
            proxy_redirect / /admin/;
          '';
        };
      };
    };
    streamConfig = ''
      # DNS upstream pool.
      upstream dns {
        zone dns 64k;
        server 127.0.0.1:8053;
      }

      # DNS(TCP) and DNS over TLS (DoT) Server
      # Terminates DNS and DoT, then proxies on to standard DNS.
      server {
        listen 53;
        listen 853 ssl;
        ssl_certificate /var/lib/acme/dns.qrtz.club/fullchain.pem;
        ssl_certificate_key /var/lib/acme/dns.qrtz.club/key.pem;
        ssl_trusted_certificate /var/lib/acme/dns.qrtz.club/chain.pem;
        proxy_pass dns;
        # proxy_bind $remote_addr transparent;
      }

      # DNS(UDP) Server
      server {
        listen 53 udp;
        proxy_responses 1;
        proxy_pass dns;
        # proxy_bind $remote_addr transparent;
      }
    '';
  };
  systemd.services.adguardhome.serviceConfig.SupplementaryGroups = [ "acme" ];
  services.adguardhome = {
    enable = true;
    settings = {
      users = [
        { name = "quartz"; password = "\"$2y$05$Elt/BH8139q4nnZA/xDSi.f/gSwRVnPcD98Q/YShlzXkpY4clx.eu\""; }
      ];
      dns = {
        port = 8053;
        bind_hosts = [ "0.0.0.0" ];
        upstream_dns = [
          "8.8.8.8"
          "8.8.4.4"
          "2001:4860:4860::8888"
          "2001:4860:4860::8844"
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
          "94.140.14.14"
          "94.140.15.15"
          "2a10:50c0::ad1:ff"
          "2a10:50c0::ad2:ff"
        ];
        bootstrap_dns = [ "8.8.8.8" "1.1.1.1" ];
        ednsClientSubnet = [ ];
      };
      dhcp.enabled = false;
      tls = {
        enabled = true;
        # We're handling TLS related things with nginx defined above
        # so we only need the raw DoH functionality
        force_https = false;
        port_https = 0;
        port_dns_over_tls = 0;
        port_dns_over_quic = 0;
        port_dnscrypt = 0;
        allow_unencrypted_doh = true;
      };
    };
  };

  networking.enableIPv6 = true;
  networking.firewall.allowedTCPPorts = [ 80 443 853 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
