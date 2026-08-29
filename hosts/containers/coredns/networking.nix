{...}: {
  nix.settings.trusted-users = ["root" "@wheel"];
  networking = {
    hostName = "ct15";
    useDHCP = false;
    useHostResolvConf = false; # don't expect the host's resolv.conf under systemd-networkd
    nameservers = ["192.168.1.1"]; # resolve via router, not ourselves — survives a broken Corefile

    firewall = {
      allowedUDPPorts = [53]; # normal DNS queries
      allowedTCPPorts = [53]; # large responses + zone transfers
    };
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      address = ["192.168.1.15/24"];
      routes = [{Gateway = "192.168.1.1";}];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
