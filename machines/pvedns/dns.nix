{ ... }:
{
  # Disable local DNS stub listener on 127.0.0.53
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=::1 127.0.0.1
      DNSStubListener=no
    '';
  };
  services.technitium-dns-server = {
    enable = true;
  };
  services.caddy = {
    enable = true;

    virtualHosts.":80".extraConfig = ''
      bind 0.0.0.0 [::0]

      # DNS-over-HTTP
      handle /dns-query {
        reverse_proxy :5380
      }

      # Default to Technitium UI
      handle {
        reverse_proxy :8080
      }
    '';
  };
}
