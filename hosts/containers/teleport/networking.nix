{...}: {
  networking = {
    hostName = "teleport";
    useDHCP = false;
    useHostResolvConf = false; # don't expect the host's resolv.conf under systemd-networkd
    nameservers = ["192.168.1.1"]; # resolve via router, not ourselves — survives a broken Corefile

    firewall = {
      allowedUDPPorts = [80]; # normal DNS queries
      allowedTCPPorts = [80]; # large responses + zone transfers
    };
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      address = ["192.168.1.11/24"];
      routes = [{Gateway = "192.168.1.1";}];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
