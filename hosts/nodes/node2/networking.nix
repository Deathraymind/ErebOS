{...}: {
  networking.useDHCP = false;
  networking.hostName = "node2";
  networking.bridges.br0.interfaces = ["1enp3s0f0"]; # FIXME: e.g. eno1
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.99"; # FIXME: node1's static IP (unchanged)
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "192.168.1.1"; # FIXME
  networking.nameservers = ["192.168.1.1"]; # FIXME
}
