{
  pkgs,
  lib,
  host,
  ...
}: {
  virtualisation.incus.agent.enable = host.incus;
  # Static networking (scripted backend)
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
    defaultGateway = host.defaultGateway;
    nameservers = host.nameservers;
    firewall.allowedTCPPorts = host.allowedTCPPorts;
    firewall.allowedUDPPorts = host.allowedUDPPorts;
  };
  time.timeZone = host.timeZone;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}
