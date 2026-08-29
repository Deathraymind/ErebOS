{...}: {
  etworking.useDHCP = false;
  networking.hostName = "node1";
  networking.bridges.br0.interfaces = ["eno1"]; # FIXME: e.g. eno1
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.100"; # FIXME: node1's static IP (unchanged)
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "192.168.1.1"; # FIXME
  networking.nameservers = ["192.168.1.1"]; # FIXME
}
