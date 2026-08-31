# hosts.nix
{
  caddy = {
    hostname = "caddy";
    ip = "192.168.1.10";
    prefixLength = 24;
    nameservers = "192.168.1.1";
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [8080 2022 80 443];
    allowedUDPPorts = [];
    incus = true;
  };
  pelican = {
    hostname = "pelican";
    ip = "192.168.1.50";
    prefixLength = 24;
    nameservers = "192.168.1.1";
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [8080 2022 80 443];
    allowedUDPPorts = [];
    incus = true;
  };
  pelican-wings = {
    hostname = "pelican-wings";
    ip = "192.168.1.51";
    prefixLength = 24;
    nameservers = "192.168.1.1";
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [8080 2022 80 443];
    allowedUDPPorts = [];
    incus = true;
  };
  vaultwarden = {
    hostname = "vaultwarden";
    ip = "192.168.1.53";
    prefixLength = 24;
    nameservers = "192.168.1.1";
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [8080 2022 80 443];
    allowedUDPPorts = [];
    incus = true;
  };

  nyx = {
  };
  # ...13 more
}
