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

    interfaces.${host.interface}.ipv4.addresses = [
      {
        address = host.ip;
        prefixLength = host.prefixLength;
      }
    ];

    defaultGateway = host.defaultGateway;
    nameservers = [host.nameservers];

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
