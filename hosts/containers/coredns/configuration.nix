{...}: {
  services.coredns = {
    enable = true;
    config = ''
      home.arpa {
        hosts {
          192.168.1.10  caddy.home.arpa
          192.168.1.11  teleport.home.arpa
          192.168.1.50  pelican.home.arpa
          192.168.1.51  pelican-wings.home.arpa
          192.168.1.53  vaultwarden.home.arpa
          ttl 60
        }
      }
      . {
        forward . 1.1.1.1 9.9.9.9
        cache 30
        log
        errors
      }
    '';
  };
}
