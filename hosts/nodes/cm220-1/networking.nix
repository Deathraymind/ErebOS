{...}: {
  networking.useDHCP = false;
  networking.hostName = "cm220-1";
  networking.bridges.br0.interfaces = ["enp1s0f0"]; # FIXME: e.g. eno1
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.98"; # FIXME: node1's static IP (unchanged)
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "192.168.1.1"; # FIXME
  networking.nameservers = ["192.168.1.1"]; # FIXME
}
