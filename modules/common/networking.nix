{
  pkgs,
  lib,
  host,
  ...
}: {
  # Guest agent: runs INSIDE a container so the daemon can reach in.
  virtualisation.incus.agent.enable = host.incus;
  # Daemon: runs on a bare-metal host to actually run containers.
  virtualisation.incus.enable = host.incusHost or false;
  # Static networking (scripted backend)networking = {
  networking = {
    hostName = host.hostname;
    useDHCP = false;

    interfaces =
      lib.mapAttrs (_name: cfg: {
        ipv4.addresses = [
          {
            address = cfg.address;
            prefixLength = cfg.prefixLength;
          }
        ];
      })
      host.interfaces;

    bridges =
      lib.mapAttrs (_name: members: {interfaces = members;})
      (host.bridges or {});

    # NEW: declare VLAN links. Each entry = { id, interface }.
    vlans =
      lib.mapAttrs (_name: cfg: {
        id = cfg.id;
        interface = cfg.interface;
      })
      (host.vlans or {});

    defaultGateway = host.defaultGateway;
    nameservers = host.nameservers;
    firewall.allowedTCPPorts = host.allowedTCPPorts;
    firewall.allowedUDPPorts = host.allowedUDPPorts;
  };
}
