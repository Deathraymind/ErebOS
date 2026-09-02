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
    interface = "enp5s0";
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
    interface = "enp5s0";
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
    interface = "enp5s0";
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
    interface = "enp5s0";
  };
  coredns = {
    hostname = "coredns";
    ip = "192.168.1.15";
    prefixLength = 24;
    nameservers = "192.168.1.1";
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
    incus = true;
    interface = "eth0";
  };
  teleport = {
    hostname = "teleport";
    ip = "192.168.1.11";
    prefixLength = 24;
    nameservers = "192.168.1.1";
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [80 3080 443];
    allowedUDPPorts = [80 3080 443];
    incus = true;
    interface = "eth0";
  };
  nyx = {
  };
  # ...13 more
}
