{
  pkgs,
  lib,
  host,
  ...
}: {
  virtualisation.incus.agent.enable = true;

  # Static networking (scripted backend)
  networking = {
    hostName = host.hostname;
    useDHCP = false;

    interfaces.enp5s0.ipv4.addresses = [
      {
        address = host.ip;
        prefixLength = 24;
      }
    ];

    defaultGateway = "192.168.1.1";
    nameservers = [host.nameservers];

    firewall.allowedTCPPorts = [8080 2022];
  };

  time.timeZone = "Asia/Tokyo";

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}
